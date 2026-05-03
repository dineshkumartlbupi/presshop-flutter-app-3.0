import 'dart:io';
import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/widgets/common_text_field.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:presshop/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:presshop/features/profile/presentation/bloc/profile_event.dart';
import 'package:presshop/features/profile/presentation/bloc/profile_state.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:presshop/features/profile/presentation/pages/my_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/main.dart';

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class MockDashboardBloc extends MockBloc<DashboardEvent, DashboardState>
    implements DashboardBloc {}

void main() {
  late MockProfileBloc mockProfileBloc;
  late MockDashboardBloc mockDashboardBloc;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesKeys.hopperIdKey: "123", // Mock required keys
      SharedPreferencesKeys.tokenKey: "mock_token",
    });
    sharedPreferences = await SharedPreferences
        .getInstance(); // Initialize global var from main.dart

    HttpOverrides.global = MockHttpOverrides(); // Enable HTTP mocking
    mockProfileBloc = MockProfileBloc();
    mockDashboardBloc = MockDashboardBloc();

    // Setup Service Locator mocking if needed,
    // but here the screen uses SL. We might need to mock SL or ensure it's not used directly in build if possible.
    // Looking at MyProfile, it uses `myProfileApi()` in `initState` which calls `_dashboardBloc.add`.
    // It also injects `DashboardBloc` via `sl<DashboardBloc>()`.

    // We need to register the mock in GetIt (sl)
    if (sl.isRegistered<DashboardBloc>()) {
      sl.unregister<DashboardBloc>();
    }
    sl.registerFactory<DashboardBloc>(() => mockDashboardBloc);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<ProfileBloc>(
        create: (_) => mockProfileBloc,
        child: MyProfile(editProfileScreen: false, screenType: 'Profile'),
      ),
    );
  }

  testWidgets('renders MyProfile screen and finds key widgets', (tester) async {
    // arrange
    when(() => mockProfileBloc.state).thenReturn(ProfileInitial());
    // Dashboard bloc stubbing
    whenListen(mockDashboardBloc, Stream<DashboardState>.empty(),
        initialState: DashboardInitial());

    // act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(
        const Duration(milliseconds: 600)); // Advance past the InitState delay
    await tester.pumpAndSettle(); // allow everything to settle

    // assert
    // Check if the screen title is present
    expect(find.text('Profile'), findsOneWidget);

    // Check if CommonTextFields are present (implies form is rendered)
    // We expect at least the username, firstname, lastname, email fields to be there.
    expect(find.byType(CommonTextField), findsAtLeastNWidgets(3));
  });

  tearDown(() {
    sl.reset();
  });
}

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient extends Mock implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return Future.value(MockHttpClientRequest());
  }
}

class MockHttpClientRequest extends Mock implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() {
    return Future.value(MockHttpClientResponse());
  }

  @override
  HttpHeaders get headers => MockHttpHeaders();
}

class MockHttpClientResponse extends Mock implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.empty().listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

class MockHttpHeaders extends Mock implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}
