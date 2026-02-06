import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/core/services/location_service.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_bloc.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_controller_builder.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_event.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_state.dart';
import 'package:presshop/main.dart' as main_dart;

class MockLocationService extends Mock implements LocationService {}

class MockCameraController extends Mock implements CameraController {}

class MockRecorderController extends Mock implements RecorderController {}

class MockCameraControllerBuilder extends Mock
    implements CameraControllerBuilder {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CameraBloc bloc;
  late MockLocationService mockLocationService;
  late MockRecorderController mockRecorderController;
  late MockCameraController mockCameraController;
  late MockCameraControllerBuilder mockCameraControllerBuilder;

  // We can keep channel mocks for extra safety or other plugins,
  // but CameraController mock should bypass camera channel for initialize calls on itself.
  const MethodChannel photoManagerChannel =
      MethodChannel('com.fluttercandies/photo_manager');
  const MethodChannel cameraChannel =
      MethodChannel('plugins.flutter.io/camera');

  setUp(() {
    mockLocationService = MockLocationService();
    mockRecorderController = MockRecorderController();
    mockCameraController = MockCameraController();
    mockCameraControllerBuilder = MockCameraControllerBuilder();

    // Mock available cameras
    main_dart.cameras = [
      const CameraDescription(
          name: 'cam1',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90),
      const CameraDescription(
          name: 'cam2',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 270),
    ];

    registerFallbackValue(Permission.camera);
    registerFallbackValue(FlashMode.off);
    registerFallbackValue(CameraDescription(
        name: 'cam1',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90));
    registerFallbackValue(ResolutionPreset.medium);
    registerFallbackValue(ImageFormatGroup.jpeg);

    // Stub CameraController methods
    when(() => mockRecorderController.dispose()).thenAnswer((_) async {});
    when(() => mockCameraController.dispose()).thenAnswer((_) async {});

    // Important: The MockCameraController must simulate 'isInitialized' correctly if checked.
    // However, since we mock 'value', we can control it.
    when(() => mockCameraController.value).thenReturn(
        const CameraValue.uninitialized(CameraDescription(
                name: 'cam1',
                lensDirection: CameraLensDirection.back,
                sensorOrientation: 90))
            .copyWith(
                isInitialized: true)); // Pretend it initialized successfully

    when(() => mockCameraController.initialize()).thenAnswer((_) async {});
    when(() => mockCameraController.resumePreview()).thenAnswer((_) async {});
    when(() => mockCameraController.setFlashMode(any()))
        .thenAnswer((_) async {});

    // Stub Builder
    when(() => mockCameraControllerBuilder.create(
          any(),
          any(),
          enableAudio: any(named: 'enableAudio'),
          imageFormatGroup: any(named: 'imageFormatGroup'),
        )).thenReturn(mockCameraController);

    // Initialize bloc with mocked builder
    // Note: We don't necessarily need to pass initialState with controllers if the builder provides them.
    // But for the FIRST test (permission denied), if we want to confirm existing logic...
    // Also, _onInitialize checks if state.status == ready and controller.isInitialized to skip.
    // So passing initialization state is useful for "already initialized" scenarios.

    bloc = CameraBloc(mockLocationService,
        initialState: CameraState(
          recorderController: mockRecorderController,
          // cameraController: mockCameraController // Let's start with NO controller for fresh init test
          // selectedMode: 'Photo'
        ),
        cameraControllerBuilder: mockCameraControllerBuilder);

    // Mock PhotoManager Channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      photoManagerChannel,
      (methodCall) async {
        if (methodCall.method == 'requestPermissionExtend') {
          return 1; // Authorized
        } else if (methodCall.method == 'getAssetPathList') {
          return []; // empty list of albums
        }
        return null;
      },
    );

    // Mock Camera Channel (only for availableCameras if needed, but we set global variable)
    // Also, created CameraController (which is a Mock) won't use channel.
    // BUT! MockCameraController.value getter returns a CameraValue. CameraValue creation logic? No it's const.
    // So we are safe from channel for MockCameraController methods we stubbed.
    // However, we should still mock availableCameras channel just in case.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(cameraChannel, (methodCall) async {
      if (methodCall.method == 'availableCameras') {
        return [
          {'name': 'cam1', 'lensFacing': 'back', 'sensorOrientation': 90},
          {'name': 'cam2', 'lensFacing': 'front', 'sensorOrientation': 270}
        ];
      }
      return null;
    });
  });

  tearDown(() {
    bloc.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      photoManagerChannel,
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      cameraChannel,
      null,
    );
  });

  group('CameraInitializeEvent', () {
    blocTest<CameraBloc, CameraState>(
        'emits [CameraStatus.loading, CameraStatus.ready] when permission is granted and cameras exist',
        build: () {
          when(() => mockLocationService.requestPermission(any()))
              .thenAnswer((_) async => true);
          return bloc;
        },
        act: (bloc) => bloc.add(CameraInitializeEvent()),
        expect: () => [
              isA<CameraState>()
                  .having((s) => s.status, 'status', CameraStatus.loading),
              isA<CameraState>()
                  .having((s) => s.status, 'status', CameraStatus.ready)
                  .having((s) => s.cameraController, 'cameraController',
                      mockCameraController), // Should match our mock
            ],
        verify: (_) {
          verify(() => mockCameraController.initialize()).called(1);
          verify(() => mockCameraController.resumePreview()).called(1);
        });
  });

  group('CameraSwitchEvent', () {
    blocTest<CameraBloc, CameraState>('should switch camera and emit ready',
        build: () {
          // Prepare a bloc that is ALREADY holding a controller (the same mock for simplicity, or we could create another mock)
          return CameraBloc(mockLocationService,
              cameraControllerBuilder: mockCameraControllerBuilder,
              initialState: CameraState(
                  status: CameraStatus.ready,
                  isFrontCamera: false,
                  recorderController: mockRecorderController,
                  cameraController: mockCameraController));
        },
        act: (bloc) => bloc.add(CameraSwitchEvent()),
        expect: () => [
              // Loading with new isFrontCamera = true
              isA<CameraState>()
                  .having((s) => s.status, 'status', CameraStatus.loading)
                  .having((s) => s.isFrontCamera, 'isFrontCamera', true),
              // Ready with successful switch
              isA<CameraState>()
                  .having((s) => s.status, 'status', CameraStatus.ready)
                  .having((s) => s.isFrontCamera, 'isFrontCamera', true)
                  .having((s) => s.cameraController, 'cameraController',
                      mockCameraController), // It uses the same mock factory returns
            ],
        verify: (_) {
          // Verify create was called with high resolution (switch logic)
          verify(() => mockCameraControllerBuilder.create(
              any(), ResolutionPreset.high,
              imageFormatGroup: ImageFormatGroup.jpeg)).called(1);
        });
  });

  group('CameraFlashToggleEvent', () {
    test('should toggle flash mode', () async {
      // Arrange
      CameraBloc cameraBloc = CameraBloc(mockLocationService,
          cameraControllerBuilder: mockCameraControllerBuilder,
          initialState: CameraState(
              status: CameraStatus.ready,
              cameraController: mockCameraController));

      // Act
      cameraBloc.add(CameraFlashToggleEvent());

      // Assert
      await expectLater(
          cameraBloc.stream,
          emits(isA<CameraState>()
              .having((s) => s.isFlashOn, 'isFlashOn', true)));
      verify(() => mockCameraController.setFlashMode(FlashMode.torch))
          .called(1);
      cameraBloc.close();
    });
  });
}
