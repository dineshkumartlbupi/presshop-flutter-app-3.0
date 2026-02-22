import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:presshop/features/splash/presentation/pages/splash_screen.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/analytics/analytics_helper.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/widgets/common_web_view.dart';
import 'package:presshop/features/authentication/presentation/pages/LoginScreen.dart';
import 'package:presshop/features/authentication/presentation/pages/SignUpScreen.dart';
import 'package:presshop/features/authentication/presentation/pages/WelcomeScreen.dart';
<<<<<<< HEAD
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
=======
// import 'package:presshop/features/dashboard/presentation/pages/dashboard.dart';
>>>>>>> a0cdfcdaab405450221e4621439f64bb3ada7b02
import 'package:presshop/features/authentication/presentation/pages/ForgotPasswordScreen.dart';
import 'package:presshop/features/authentication/presentation/pages/ResetPasswordScreen.dart';
import 'package:presshop/features/authentication/presentation/pages/SocialSignUpScreen.dart';
import 'package:presshop/features/authentication/presentation/pages/UploadDocumnetsScreen.dart';
import 'package:presshop/features/authentication/presentation/pages/VerifyAccountScreen.dart';
import 'package:presshop/features/onboarding/presentation/pages/WalkThrough.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/features/authentication/presentation/bloc/signup_bloc.dart';
import 'package:presshop/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:presshop/core/router/router_constants.dart';
import 'package:presshop/features/authentication/presentation/bloc/signup_event.dart';
import 'package:presshop/features/bank/presentation/pages/my_banks_page.dart';
import 'package:presshop/features/profile/presentation/pages/digital_id_screen.dart';
import 'package:presshop/features/profile/presentation/pages/my_profile_screen.dart';
import 'package:presshop/features/account_settings/presentation/pages/account_settings.dart';
import 'package:presshop/features/account_settings/presentation/pages/account_delete_screen.dart';
import 'package:presshop/features/content/presentation/pages/content_detail_screen.dart';
import 'package:presshop/features/account_settings/presentation/pages/faq_screen.dart';
import 'package:presshop/features/notification/presentation/pages/MyNotifications.dart';
import 'package:presshop/features/account_settings/presentation/pages/change_password_screen.dart';
import 'package:presshop/features/account_settings/presentation/pages/contact_us_screen.dart';
import 'package:presshop/features/authentication/presentation/pages/TermCheckScreen.dart';
import 'package:presshop/features/publish/presentation/pages/TutorialsScreen.dart';
import 'package:presshop/features/chat/presentation/pages/ChatScreen.dart';
import 'package:presshop/features/task/presentation/pages/task_screen.dart';
import 'package:presshop/features/content/presentation/pages/manage_content_chat_screen.dart';
import 'package:presshop/features/task/presentation/pages/detail_new/task_details_screen.dart';
import 'package:presshop/features/task/presentation/pages/broadcast/BroardcastScreen.dart';
import 'package:presshop/features/task/presentation/pages/broadcast_chat/broadCastChatTaskScreen.dart';
import 'package:presshop/features/news/presentation/pages/news_page.dart';
import 'package:presshop/features/news/presentation/pages/news_detail_page.dart';
import 'package:presshop/features/news/domain/entities/news.dart';
import 'package:presshop/features/news/presentation/bloc/news_bloc.dart';
import 'package:presshop/features/news/presentation/bloc/news_event.dart';
import 'package:presshop/features/feed/presentation/pages/FeedScreen.dart';
import 'package:presshop/features/task/presentation/pages/broadcast_chat/MediaPreviewScreen.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';
import 'package:presshop/features/camera/presentation/pages/PreviewScreen.dart';
import 'package:presshop/features/chat/presentation/pages/FullVideoView.dart';
import 'package:presshop/features/camera/presentation/pages/CameraScreen.dart';
import 'package:presshop/features/camera/presentation/pages/CustomGallary.dart';
import 'package:presshop/features/menu/presentation/pages/menu_screen.dart';
import 'package:presshop/features/earning/presentation/pages/MyEarningScreen.dart';
import 'package:presshop/features/earning/presentation/pages/TransactionDetailScreen.dart';
import 'package:presshop/core/widgets/error/permission_error_screen.dart';
import 'package:presshop/core/widgets/error/location_error_screen.dart';
import 'package:presshop/features/chatbot/presentation/pages/chatBotScreen.dart';
import 'package:presshop/features/rating/presentation/pages/RatingReviewScreen.dart';
import 'package:presshop/features/publish/presentation/pages/AudioRecorderScreen.dart';
import 'package:presshop/features/publish/presentation/pages/HashTagSearchScreen.dart';
import 'package:presshop/features/task/presentation/pages/preview/manageTaskPreviewScreen.dart';
import 'package:presshop/features/task/presentation/pages/preview_media/manageTaskPreviewMediaScreen.dart';
import 'package:presshop/features/task/presentation/pages/task_grabbing_screen.dart';
import 'package:presshop/features/publish/presentation/pages/PublishContentScreen.dart';
import 'package:presshop/features/publish/presentation/pages/ContentSubmittedScreen.dart';
import 'package:presshop/features/publication/presentation/pages/publication_list_screen.dart';

import 'package:presshop/features/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:presshop/features/referral/presentation/pages/refer_screen.dart';
import 'package:presshop/features/content/presentation/pages/my_draft_screen.dart';
import 'package:presshop/features/content/presentation/pages/content_page.dart';

import 'package:presshop/features/content/data/models/my_content_data_model.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey, // Use existing navigator key for legacy support
    initialLocation: '/',
    observers: [
      AnalyticsHelper.observer,
      AnalyticsRouteObserver(),
    ],
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),
      // Future routes will be added here
      GoRoute(
        path: AppRoutes.welcomePath,
        name: AppRoutes.welcomeName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return WelcomeScreen(
            hideLeading: extra?['hideLeading'] ?? true,
            screenType: extra?['screenType'] ?? 'welcome',
            isSocialLogin: extra?['isSocialLogin'] ?? false,
            sourceDataType: extra?['sourceDataType'] ?? "",
            sourceDataIsOpened: extra?['sourceDataIsOpened'] ?? false,
            sourceDataUrl: extra?['sourceDataUrl'] ?? "",
            sourceDataHeading: extra?['sourceDataHeading'] ?? "",
            sourceDataDescription: extra?['sourceDataDescription'] ?? "",
            isClick: extra?['isClick'] ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.walkthroughPath,
        name: AppRoutes.walkthroughName,
        builder: (context, state) => const Walkthrough(),
      ),
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signupPath,
        name: AppRoutes.signupName,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<SignUpBloc>()..add(FetchAvatarsEvent()),
          child: SignUpScreen(
            socialLogin: false,
            socialId: "",
            email: "",
            name: "",
            phoneNumber: "",
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboardPath,
        name: AppRoutes.dashboardName,
        builder: (context, state) {
          int initialPos = 2; // Default
          bool openChatScreen = false;
          bool openBeansActivation = false;
          bool openNotification = false;

          if (state.extra is Map<String, dynamic>) {
            final args = state.extra as Map<String, dynamic>;
            initialPos = args['initialPosition'] ?? 2;
            openChatScreen = args['openChatScreen'] ?? false;
            openBeansActivation = args['openBeansActivation'] ?? false;
            openNotification = args['openNotification'] ?? false;
          }
          return Dashboard(
            initialPosition: initialPos,
            openChatScreen: openChatScreen,
            openBeansActivation: openBeansActivation,
            openNotification: openNotification,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bankPath,
        name: AppRoutes.bankName,
        builder: (context, state) => const MyBanksPage(),
      ),
      GoRoute(
        path: AppRoutes.profilePath,
        name: AppRoutes.profileName,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return MyProfile(
            editProfileScreen: args?['editProfileScreen'] ?? false,
            screenType: args?['screenType'] ?? "",
          );
        },
      ),
      GoRoute(
        path: AppRoutes.digitalIdPath,
        name: AppRoutes.digitalIdName,
        builder: (context, state) => const DigitalIdScreen(),
      ),
      GoRoute(
        path: AppRoutes.accountSettingsPath,
        name: AppRoutes.accountSettingsName,
        builder: (context, state) => const AccountSetting(),
      ),
      GoRoute(
        path: AppRoutes.accountDeletePath,
        name: AppRoutes.accountDeleteName,
        builder: (context, state) => const AccountDeleteScreen(),
      ),
      GoRoute(
        path: AppRoutes.faqPath,
        name: AppRoutes.faqName,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return FAQScreen(
            priceTipsSelected: args?['priceTipsSelected'] ?? false,
            type: args?['type'] ?? 'faq',
            benefits: args?['benefits'] ?? "",
            index: args?['index'] ?? 0,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.changePasswordPath,
        name: AppRoutes.changePasswordName,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.contactUsPath,
        name: AppRoutes.contactUsName,
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: AppRoutes.termPath,
        name: AppRoutes.termName,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return TermCheckScreen(
            type: args?['type'] ?? 'legal',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.tutorialsPath,
        name: AppRoutes.tutorialsName,
        builder: (context, state) => const TutorialsScreen(),
      ),
      GoRoute(
        path: AppRoutes.chatPath,
        name: AppRoutes.chatName,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return BlocProvider(
            create: (context) => sl<ChatBloc>(),
            child: ConversationScreen(
              hideLeading: args?['hideLeading'] ?? false,
              message: args?['message'] ?? "",
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.conversationPath,
        name: AppRoutes.conversationName,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return BlocProvider(
            create: (context) => sl<ChatBloc>(),
            child: ConversationScreen(
              hideLeading: args?['hideLeading'] ?? false,
              message: args?['message'] ?? "",
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.myTasksPath,
        name: AppRoutes.myTasksName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MyTaskScreen(
            hideLeading: extra?['hideLeading'] ?? false,
            broadCastId: extra?['broadCastId'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.manageTaskPath,
        name: AppRoutes.manageTaskName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ManageContentChatScreen(
            roomId: extra['roomId'],
            type: extra['type'],
            mediaHouseDetail: extra['mediaHouseDetail'],
            contentId: extra['contentId'],
            taskDetail: extra['taskDetail'],
            contentMedia: extra['contentMedia'],
            myContentData: extra['myContentData'],
            contentHeader: extra['contentHeader'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.taskDetailNewPath,
        name: AppRoutes.taskDetailNewName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return TaskDetailScreen(
            taskStatus: extra['taskStatus'],
            taskId: extra['taskId'],
            totalEarning: extra['totalEarning'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.broadcastPath,
        name: AppRoutes.broadcastName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BroadCastScreen(
            taskId: extra['taskId'],
            mediaHouseId: extra['mediaHouseId'],
            autoAction: extra['autoAction'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.broadcastChatPath,
        name: AppRoutes.broadcastChatName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BroadCastChatTaskScreen(
            taskDetail: extra['taskDetail'] as TaskAssignedEntity?,
            roomId: extra['roomId'] as String,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.mediaPreviewPath,
        name: AppRoutes.mediaPreviewName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return MediaPreviewScreen(
            mediaList: extra['mediaList'] as List<MediaData>,
            onMediaUpdated:
                extra['onMediaUpdated'] as Function(List<MediaData>),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.fullVideoViewPath,
        name: AppRoutes.fullVideoViewName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return MediaViewScreen(
            mediaFile: extra['mediaFile'],
            type: extra['type'],
            isFromTutorialScreen: extra['isFromTutorialScreen'] ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.previewPath,
        name: AppRoutes.previewName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PreviewScreen(
            cameraData: extra['cameraData'],
            pickAgain: extra['pickAgain'] ?? false,
            cameraListData: extra['cameraListData'] ?? [],
            mediaList:
                (extra['mediaList'] as List<dynamic>?)?.cast<MediaData>() ?? [],
            type: extra['type'] ?? '',
            myContentData: extra['myContentData'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.locationErrorPath,
        name: AppRoutes.locationErrorName,
        builder: (context, state) => LocationErrorScreen(),
      ),
      GoRoute(
        path: AppRoutes.cameraPath,
        name: AppRoutes.cameraName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CameraScreen(
            picAgain: extra['picAgain'],
            previousScreen: extra['previousScreen'],
            autoInitialize: extra['autoInitialize'] ?? true,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.myEarningPath,
        name: AppRoutes.myEarningName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MyEarningScreen(
            openDashboard: extra?['openDashboard'] ?? false,
            initialTapPosition: extra?['initialTapPosition'] ?? 0,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.transactionDetailPath,
        name: AppRoutes.transactionDetailName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return TransactionDetailScreen(
            type: extra['type'],
            transactionData: extra['transactionData'],
            pageType: extra['pageType'],
            shouldShowPublication: extra['shouldShowPublication'] ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.permissionErrorPath,
        name: AppRoutes.permissionErrorName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PermissionErrorScreen(
            permissionsStatus: extra['permissionsStatus'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.newsPath,
        name: AppRoutes.newsName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BlocProvider(
            create: (context) => sl<NewsBloc>()
              ..add(GetAggregatedNewsEvent(
                lat: extra['latitude'] ?? 0.0,
                lng: extra['longitude'] ?? 0.0,
                km: 50,
              )),
            child: NewsPage(
              hideLeading: extra['hideLeading'] ?? false,
              latitude: extra['latitude'],
              longitude: extra['longitude'],
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.newsDetailsPath,
        name: AppRoutes.newsDetailsName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return NewsDetailPage(
            newsId: extra['newsId'] as String,
            initialNews: extra['initialNews'] as News?,
            scrollToComments: extra['scrollToComments'] ?? false,
            initialCommentId: extra['initialCommentId'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.feedPath,
        name: AppRoutes.feedName,
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordPath,
        name: AppRoutes.forgotPasswordName,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPasswordPath,
        name: AppRoutes.resetPasswordName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ResetPasswordScreen(
            emailAddressValue: extra['emailAddressValue'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.socialSignUpPath,
        name: AppRoutes.socialSignUpName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return SocialSignUp(
            socialLogin: extra['socialLogin'] ?? false,
            socialId: extra['socialId'] ?? "",
            email: extra['email'] ?? "",
            name: extra['name'] ?? "",
            socialType: extra['socialType'] ?? "",
            phoneNumber: extra['phoneNumber'] ?? "",
          );
        },
      ),
      GoRoute(
        path: AppRoutes.termCheckPath,
        name: AppRoutes.termCheckName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return TermCheckScreen(
            type: extra['type'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.uploadDocumentsPath,
        name: AppRoutes.uploadDocumentsName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return UploadDocumentsScreen(
            menuScreen: extra?['menuScreen'] ?? false,
            hideLeading: extra?['hideLeading'] ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.verifyAccountPath,
        name: AppRoutes.verifyAccountName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return VerifyAccountScreen(
            emailAddressValue: extra['emailAddressValue'],
            mobileNumberValue: extra['mobileNumberValue'],
            countryCode: extra['countryCode'],
            params: extra['params'],
            imagePath: extra['imagePath'],
            sociallogin: extra['sociallogin'] ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notificationsPath,
        name: AppRoutes.notificationsName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MyNotificationScreen(
            count: extra?['count'] ?? 0,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.contentDetailPath,
        name: AppRoutes.contentDetailName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return MyContentDetailScreen(
            paymentStatus: extra['paymentStatus'],
            exclusive: extra['exclusive'],
            offerCount: extra['offerCount'],
            purchasedMediahouseCount: extra['purchasedMediahouseCount'],
            contentId: extra['contentId'],
            hopperID: extra['hopperID'] ?? "",
          );
        },
      ),
      GoRoute(
        path: AppRoutes.chatBotPath,
        name: AppRoutes.chatBotName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ChatBotScreen(
            hideLeading: extra?['hideLeading'] ?? true,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.ratingReviewPath,
        name: AppRoutes.ratingReviewName,
        builder: (context, state) => const RatingReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.audioRecorderPath,
        name: AppRoutes.audioRecorderName,
        builder: (context, state) => const AudioRecorderScreen(),
      ),
      GoRoute(
        path: AppRoutes.hashTagSearchPath,
        name: AppRoutes.hashTagSearchName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return HashTagSearchScreen(
            country: extra['country'],
            tagData: extra['tagData'],
            initialSelectedHashTags: extra['initialSelectedHashTags'],
            countryTagId: extra['countryTagId'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.manageTaskPreviewPath,
        name: AppRoutes.manageTaskPreviewName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ManageTaskPreviewScreen(
            cameraListData: extra['cameraListData'] as List<CameraData>,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.manageTaskPreviewMediaPath,
        name: AppRoutes.manageTaskPreviewMediaName,
        builder: (context, state) => const ManageTaskPreviewMediaScreen(),
      ),
      GoRoute(
        path: AppRoutes.publishContentPath,
        name: AppRoutes.publishContentName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PublishContentScreen(
            publishData: extra['publishData'] as PublishData?,
            myContentData: extra['myContentData'] as MyContentData?,
            docType: extra['docType'] as String,
            hideDraft: extra['hideDraft'] as bool,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.publicationListPath,
        name: AppRoutes.publicationListName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PublicationListScreen(
            contentId: extra['contentId'] as String,
            contentType: extra['contentType'] as String,
            publicationCount: extra['publicationCount'] as String,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.leaderboardPath,
        name: AppRoutes.leaderboardName,
        builder: (context, state) => const LeaderboardPage(),
      ),
      GoRoute(
        path: AppRoutes.referPath,
        name: AppRoutes.referName,
        builder: (context, state) => const ReferScreen(),
      ),
      GoRoute(
        path: AppRoutes.myDraftPath,
        name: AppRoutes.myDraftName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MyDraftScreen(
            publishedContent: extra?['publishedContent'] ?? false,
            screenType: extra?['screenType'] ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.myContentPath,
        name: AppRoutes.myContentName,
        builder: (context, state) => const MyContentPage(),
      ),
      GoRoute(
        path: AppRoutes.contentSubmittedPath,
        name: AppRoutes.contentSubmittedName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ContentSubmittedScreen(
            myContentDetail: extra['myContentDetail'] as MyContentData?,
            publishData: extra['publishData'] as PublishData?,
            price: extra['price'] as String,
            sellType: extra['sellType'] as String,
            isBeta: extra['isBeta'] as bool,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.commonWebViewPath,
        name: AppRoutes.commonWebViewName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CommonWebView(
            webUrl: extra['webUrl'],
            title: extra['title'],
            accountId: extra['accountId'] ?? "",
            type: extra['type'] ?? "",
          );
        },
      ),
      GoRoute(
        path: AppRoutes.customGalleryPath,
        name: AppRoutes.customGalleryName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CustomGallery(
            picAgain: extra['picAgain'] ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.locationSharingPath,
        name: AppRoutes.locationSharingName,
        builder: (context, state) => const TaskGrabbingScreen(),
      ),
      GoRoute(
        path: AppRoutes.menuPath,
        name: AppRoutes.menuName,
        builder: (context, state) => const MenuScreen(),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
