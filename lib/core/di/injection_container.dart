import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/features/account_settings/domain/usecases/get_admin_contact_info.dart';
import 'package:presshop/features/authentication/presentation/bloc/upload_documents/upload_documents_bloc.dart';
import 'package:presshop/features/publish/domain/usecases/submit_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:presshop/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:presshop/features/authentication/presentation/bloc/signup_bloc.dart';
import 'package:presshop/features/authentication/presentation/bloc/verification_bloc.dart';
import 'package:presshop/features/authentication/data/datasources/verification_remote_datasource.dart';
import 'package:presshop/features/authentication/data/datasources/verification_remote_datasource_impl.dart';
import 'package:presshop/features/authentication/data/repositories/verification_repository_impl.dart';
import 'package:presshop/features/authentication/domain/repositories/verification_repository.dart';
import 'package:presshop/features/authentication/domain/usecases/verification/delete_document.dart';
import 'package:presshop/features/authentication/domain/usecases/verification/get_document_instructions.dart';
import 'package:presshop/features/authentication/domain/usecases/verification/get_uploaded_documents.dart';
import 'package:presshop/features/authentication/domain/usecases/verification/upload_document.dart';

import 'package:presshop/features/profile/domain/usecases/check_username.dart'
    as profile_check;
import 'package:presshop/features/profile/domain/usecases/get_avatars.dart'
    as profile_avatars;
import 'package:presshop/features/authentication/data/repositories/term_repository.dart';

import 'package:presshop/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:presshop/features/splash/data/datasources/splash_remote_data_source.dart';
import 'package:presshop/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:presshop/features/splash/domain/repositories/splash_repository.dart';
import 'package:presshop/features/splash/domain/usecases/check_splash_version.dart';
import 'package:presshop/features/chatbot/presentation/bloc/chatbot_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_bloc.dart';
import 'package:presshop/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:presshop/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:presshop/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:presshop/features/notification/domain/repositories/notification_repository.dart';
import 'package:presshop/features/notification/domain/usecases/get_notifications.dart';
import 'package:presshop/features/notification/domain/usecases/mark_notifications_read.dart';
import 'package:presshop/features/notification/domain/usecases/clear_all_notifications.dart';
import 'package:presshop/features/dashboard/domain/usecases/check_student_beans.dart';
import 'package:presshop/features/dashboard/domain/usecases/mark_student_beans_visited.dart';
import 'package:presshop/features/map/presentation/bloc/map_bloc.dart';
import 'package:presshop/features/map/data/datasources/map_remote_data_source.dart';
import 'package:presshop/features/map/data/repositories/map_repository_impl.dart';
import '../../features/menu/data/services/menu_service_impl.dart';
import '../../features/menu/domain/services/menu_service.dart';
import 'package:presshop/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';
import 'package:presshop/features/map/domain/usecases/get_current_location.dart';
import 'package:presshop/features/map/domain/usecases/get_incidents.dart';
import 'package:presshop/features/map/domain/usecases/report_incident.dart';
import 'package:presshop/features/map/domain/usecases/get_route.dart';
import 'package:presshop/features/map/domain/usecases/search_places.dart';
import 'package:presshop/features/map/domain/usecases/get_place_details.dart';
import 'package:presshop/features/map/data/services/marker_service.dart';
import 'package:presshop/core/api/global_socket_client.dart';
import 'package:presshop/features/map/data/datasources/incident_socket_datasource.dart';
import 'package:presshop/features/news/data/datasources/news_socket_datasource.dart';
import 'package:presshop/features/chat/data/datasources/chat_socket_datasource.dart';
import 'package:presshop/features/news/data/datasources/news_remote_datasource.dart';
import 'package:presshop/features/news/data/repositories/news_repository_impl.dart';
import 'package:presshop/features/news/domain/repositories/news_repository.dart';
import 'package:presshop/features/news/domain/usecases/get_aggregated_news.dart';
import 'package:presshop/features/news/domain/usecases/get_comments.dart';
import 'package:presshop/features/news/domain/usecases/get_news_detail.dart';
import 'package:presshop/features/news/presentation/bloc/news_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:presshop/features/earning/domain/repositories/earning_repository.dart';
import 'package:presshop/features/earning/data/repositories/earning_repository_impl.dart';
import 'package:presshop/features/earning/data/datasources/earning_remote_data_source.dart';
import 'package:presshop/features/earning/domain/usecases/get_earning_profile.dart';
import 'package:presshop/features/earning/domain/usecases/get_transactions.dart';
import 'package:presshop/features/earning/domain/usecases/get_commissions.dart';
import 'package:presshop/features/earning/presentation/bloc/earning_bloc.dart';
import 'package:presshop/features/alert/presentation/bloc/alert_bloc.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_bloc.dart';
import 'package:presshop/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:presshop/features/feed/domain/repositories/feed_repository.dart';
import 'package:presshop/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:presshop/features/feed/data/datasources/feed_remote_data_source.dart';
import 'package:presshop/features/feed/domain/usecases/get_feeds.dart';
import 'package:presshop/features/feed/domain/usecases/toggle_feed_interaction.dart';
import 'package:presshop/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:presshop/features/task/domain/repositories/task_repository.dart';
import 'package:presshop/features/task/data/repositories/task_repository_impl.dart';
import 'package:presshop/features/task/data/datasources/task_remote_datasource.dart';
import 'package:presshop/features/task/domain/usecases/get_all_tasks.dart';
import 'package:presshop/features/task/domain/usecases/get_local_tasks.dart';
import 'package:presshop/features/task/domain/usecases/get_task_detail.dart';
import 'package:presshop/features/task/domain/usecases/accept_reject_task.dart';
import 'package:presshop/features/task/domain/usecases/get_task_chat.dart';
import 'package:presshop/features/task/domain/usecases/upload_task_media.dart';
import 'package:presshop/features/task/domain/usecases/get_hopper_accepted_count.dart';
import 'package:presshop/features/task/domain/usecases/get_task_transaction_details.dart';
import 'package:presshop/features/task/domain/usecases/get_content_transaction_details.dart';

import 'package:presshop/features/authentication/domain/usecases/login_user.dart';
import 'package:presshop/features/authentication/domain/usecases/social_login_user.dart';
import 'package:presshop/features/authentication/domain/usecases/register_user.dart';
import 'package:presshop/features/authentication/domain/usecases/logout_user.dart';
import 'package:presshop/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:presshop/features/leaderboard/domain/usecases/get_leaderboard.dart';
import 'package:presshop/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:presshop/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:presshop/features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import 'package:presshop/features/authentication/domain/usecases/check_auth_status.dart';
import 'package:presshop/features/authentication/domain/usecases/get_profile.dart'; // Import
import 'package:presshop/features/bank/presentation/bloc/bank_bloc.dart';
import 'package:presshop/features/bank/domain/usecases/get_banks.dart';
import 'package:presshop/features/bank/domain/usecases/delete_bank.dart';
import 'package:presshop/features/bank/domain/usecases/set_default_bank.dart';
import 'package:presshop/features/bank/domain/usecases/get_stripe_onboarding_url.dart';
import 'package:presshop/features/bank/domain/repositories/bank_repository.dart';
import 'package:presshop/features/bank/data/repositories/bank_repository_impl.dart';
import 'package:presshop/features/bank/data/datasources/bank_remote_data_source.dart';
import 'package:presshop/features/authentication/domain/usecases/send_otp.dart';
import 'package:presshop/features/authentication/domain/usecases/verify_otp.dart'; // Import
import 'package:presshop/features/authentication/domain/usecases/social_register_user.dart';
import 'package:presshop/features/authentication/domain/usecases/forgot_password.dart';
import 'package:presshop/features/authentication/domain/usecases/verify_forgot_password_otp.dart';
import 'package:presshop/features/authentication/domain/usecases/reset_password.dart';

import 'package:presshop/features/dashboard/presentation/bloc/dashboard_bloc.dart';
// ... existing imports ...

// Import
// Import

// ... existing imports ...

import 'package:presshop/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:presshop/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:presshop/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:presshop/features/dashboard/domain/usecases/get_active_admins.dart';
import 'package:presshop/features/dashboard/domain/usecases/update_location.dart';
import 'package:presshop/features/dashboard/domain/usecases/add_device.dart';
import 'package:presshop/features/dashboard/domain/usecases/remove_device.dart';
import 'package:presshop/features/dashboard/domain/usecases/get_dashboard_task_detail.dart';
import 'package:presshop/features/dashboard/domain/usecases/get_room_id.dart';
import 'package:presshop/features/task/domain/usecases/get_room_id.dart'
    as task_room;
import 'package:presshop/features/dashboard/domain/usecases/activate_student_beans.dart'
    as dashboard_beans;
import 'package:presshop/features/dashboard/domain/usecases/check_app_version.dart';
import 'package:presshop/features/authentication/domain/usecases/check_username.dart';
import 'package:presshop/features/authentication/domain/usecases/check_email.dart';
import 'package:presshop/features/authentication/domain/usecases/check_phone.dart';
import 'package:presshop/features/authentication/domain/usecases/get_avatars.dart';
import 'package:presshop/features/authentication/domain/usecases/verify_referral_code.dart';
import 'package:presshop/features/authentication/domain/usecases/social_exists.dart';
import 'package:presshop/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:presshop/features/profile/domain/usecases/get_profile_data.dart';
import 'package:presshop/features/profile/domain/usecases/update_profile_data.dart';
import 'package:presshop/features/profile/domain/usecases/upload_profile_image.dart';
import 'package:presshop/features/profile/domain/usecases/change_password.dart';
import 'package:presshop/features/profile/domain/repositories/profile_repository.dart';
import 'package:presshop/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:presshop/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:presshop/features/content/presentation/bloc/content_bloc.dart';
import 'package:presshop/features/content/domain/usecases/get_my_content.dart';
import 'package:presshop/features/content/domain/usecases/publish_content.dart';
import 'package:presshop/features/content/domain/usecases/save_draft.dart';
import 'package:presshop/features/content/domain/usecases/upload_media.dart';
import 'package:presshop/features/content/domain/usecases/delete_content.dart';
import 'package:presshop/features/content/domain/usecases/search_hashtags.dart';
import 'package:presshop/features/content/domain/usecases/get_trending_hashtags.dart';
import 'package:presshop/features/content/domain/usecases/get_content_detail.dart';
import 'package:presshop/features/content/domain/repositories/content_repository.dart';
import 'package:presshop/features/content/data/repositories/content_repository_impl.dart';
import 'package:presshop/features/content/data/datasources/content_remote_data_source.dart';

import 'package:presshop/features/content/domain/usecases/get_media_house_offers.dart';
import 'package:presshop/features/content/domain/usecases/get_content_transactions.dart';

import 'package:presshop/features/account_settings/presentation/bloc/account_settings_bloc.dart';
import 'package:presshop/features/account_settings/presentation/bloc/faq/faq_bloc.dart';
import 'package:presshop/features/rating/presentation/bloc/rating/rating_bloc.dart';
import 'package:presshop/features/rating/domain/usecases/get_reviews.dart';
import 'package:presshop/features/rating/domain/usecases/get_media_houses.dart'
    as rating_media;
import 'package:presshop/features/rating/domain/repositories/rating_repository.dart';
import 'package:presshop/features/rating/data/repositories/rating_repository_impl.dart';
import 'package:presshop/features/rating/data/datasources/rating_remote_datasource.dart';
import 'package:presshop/features/account_settings/domain/usecases/get_faqs.dart';
import 'package:presshop/features/account_settings/domain/usecases/get_price_tips.dart';
import 'package:presshop/features/account_settings/domain/usecases/get_faq_categories.dart';
import 'package:presshop/features/account_settings/domain/usecases/delete_account.dart';
import 'package:presshop/features/account_settings/domain/repositories/account_settings_repository.dart';
import 'package:presshop/features/account_settings/data/repositories/account_settings_repository_impl.dart';
import 'package:presshop/features/account_settings/data/datasources/account_settings_remote_datasource.dart';

import 'package:presshop/features/authentication/domain/repositories/auth_repository.dart';
import 'package:presshop/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:presshop/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:presshop/features/authentication/data/datasources/auth_local_data_source.dart';

import 'package:presshop/features/authentication/domain/usecases/check_onboarding_status.dart';
import 'package:presshop/features/publication/presentation/bloc/publication_bloc.dart';
import 'package:presshop/features/publication/domain/usecases/get_publication_earning_stats.dart';
import 'package:presshop/features/publication/domain/usecases/get_media_houses.dart';
import 'package:presshop/features/publication/domain/usecases/get_publication_transactions.dart';
import 'package:presshop/features/publication/domain/repositories/publication_repository.dart';
import 'package:presshop/features/publication/data/repositories/publication_repository_impl.dart';
import 'package:presshop/features/publication/data/datasources/publication_remote_data_source.dart';
import 'package:presshop/features/authentication/domain/usecases/set_onboarding_seen.dart';
import 'package:presshop/features/onboarding/presentation/bloc/onboarding_bloc.dart';

import 'package:presshop/features/publish/domain/usecases/get_content_categories.dart';
import 'package:presshop/features/publish/domain/usecases/get_charities.dart';
import 'package:presshop/features/publish/domain/usecases/get_share_exclusive_price.dart';
import 'package:presshop/features/publish/domain/repositories/publish_repository.dart';
import 'package:presshop/features/publish/data/repositories/publish_repository_impl.dart';
import 'package:presshop/features/publish/data/datasources/publish_remote_data_source.dart';
import 'package:presshop/features/publish/presentation/bloc/publish_bloc.dart';
import 'package:presshop/features/publish/presentation/bloc/tutorials/tutorials_bloc.dart';
import 'package:presshop/features/publish/domain/usecases/get_tutorial_categories.dart';
import 'package:presshop/features/publish/domain/usecases/get_tutorial_videos.dart';
import 'package:presshop/features/publish/domain/usecases/add_tutorial_view_count.dart';
import 'package:presshop/features/publish/domain/repositories/tutorials_repository.dart';
import 'package:presshop/features/publish/data/repositories/tutorials_repository_impl.dart';
import 'package:presshop/features/publish/data/datasources/tutorials_remote_datasource.dart';

import 'package:presshop/core/services/location_service.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => AppLinks());

  sl.registerLazySingleton(() => FirebaseAnalytics.instance);
  sl.registerLazySingleton(() => FirebaseCrashlytics.instance);
  sl.registerLazySingleton(() => GoogleSignIn(
        clientId: Platform.isIOS
            ? '750460561502-geuno4tt1ic52cor9l2obl1vhuogvsp0.apps.googleusercontent.com'
            : null,
        serverClientId:
            '750460561502-fajfc82s14phu6iu767i7qm53qmu2r8f.apps.googleusercontent.com',
        scopes: ['email'],
      ));

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => ApiClient(sl(), sl(), sl()));
  sl.registerLazySingleton(() => LocationService());

  //! Data Sources - Register first
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl(), secureStorage: sl()),
  );
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Repositories - Register second
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<TermsRepository>(
    () => TermsRepository(sl<ApiClient>()),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  //! Use Cases - Register third (before BLoCs)
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => SocialLoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => SendOtp(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerLazySingleton(() => SocialRegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => SetOnboardingSeen(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => VerifyForgotPasswordOtp(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));

  // Use cases needed by SplashBloc
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => CheckSplashVersion(sl()));
  sl.registerLazySingleton(() => CheckOnboardingStatus(sl()));

  // Splash Feature Dependencies
  sl.registerLazySingleton<SplashRemoteDataSource>(
    () => SplashRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Use cases needed by SignUpBloc
  sl.registerLazySingleton(() => CheckUserName(sl()));
  sl.registerLazySingleton(() => CheckEmail(sl()));
  sl.registerLazySingleton(() => CheckPhone(sl()));
  sl.registerLazySingleton(() => GetAvatars(sl()));
  sl.registerLazySingleton(() => VerifyReferralCode(sl()));
  sl.registerLazySingleton(() => SocialExists(sl()));

  //! Features - Authentication
  // Blocs - Register last
  sl.registerFactory(
    () => AuthBloc(
      loginUser: sl(),
      socialLoginUser: sl(),
      forgotPassword: sl(),
      verifyForgotPasswordOtp: sl(),
      resetPassword: sl(),
    ),
  );
  sl.registerFactory(
    () => SignUpBloc(
      registerUser: sl(),
      sendOtp: sl(),
      checkUserName: sl(),
      checkEmail: sl(),
      checkPhone: sl(),
      getAvatars: sl(),
      verifyReferralCode: sl(),
      socialExists: sl(),
      socialRegisterUser: sl(),
    ),
  );

  sl.registerFactory(
    () => SplashBloc(
      checkAuthStatus: sl(),
      getProfile: sl(),
      checkAppVersion: sl(),
      checkOnboardingStatus: sl(),
    ),
  );
  sl.registerFactory(() => OnboardingBloc(setOnboardingSeen: sl()));
  sl.registerFactory(
    () => PublicationBloc(
      getPublicationEarningStats: sl(),
      getMediaHouses: sl(),
      getPublicationTransactions: sl(),
    ),
  );
  sl.registerFactory(
    () => PublishBloc(
      getContentCategories: sl(),
      getCharities: sl(),
      getShareExclusivePrice: sl(),
      submitContent: sl(),
    ),
  );
  sl.registerFactory(
    () => TutorialsBloc(
      getTutorialCategories: sl(),
      getTutorialVideos: sl(),
      addTutorialViewCount: sl(),
    ),
  );
  sl.registerFactory(
    () => VerificationBloc(
      verifyOtp: sl(),
      registerUser: sl(),
      socialRegisterUser: sl(),
      sendOtp: sl(),
    ),
  );

  sl.registerFactory(
    () => DashboardBloc(
      getActiveAdmins: sl(),
      updateLocation: sl(),
      addDevice: sl(),
      getDashboardTaskDetail: sl(),
      getRoomId: sl(),
      checkAppVersion: sl(),
      activateStudentBeans: sl(),
      checkStudentBeans: sl(),
      markStudentBeansVisited: sl(),
      getProfile: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ProfileBloc(
      getProfileData: sl(),
      updateProfileData: sl(),
      uploadProfileImage: sl(),
      changePassword: sl(),
      checkUserName: sl(),
      getAvatars: sl(),
      checkEmail: sl(),
      checkPhone: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ContentBloc(
      getMyContent: sl(),
      publishContent: sl(),
      saveDraft: sl(),
      uploadMedia: sl(),
      deleteContent: sl(),
      searchHashtags: sl(),
      getTrendingHashtags: sl(),
      getContentDetail: sl(),
      getMediaHouseOffers: sl(),
      getContentTransactions: sl(),
    ),
  );

  sl.registerFactory(
    () => AccountSettingsBloc(
      deleteAccount: sl(),
      changePassword: sl(),
      getAdminContactInfo: sl(),
    ),
  );
  // Verification
  sl.registerFactory(
    () => UploadDocumentsBloc(
      getDocumentInstructions: sl(),
      getUploadedDocuments: sl(),
      uploadDocument: sl(),
      deleteDocument: sl(),
    ),
  );
  sl.registerFactory(
    () => FAQBloc(getFAQs: sl(), getPriceTips: sl(), getFAQCategories: sl()),
  );
  sl.registerFactory(() => RatingBloc(getReviews: sl(), getMediaHouses: sl()));

  sl.registerFactory(() => LeaderboardBloc(getLeaderboardData: sl()));

  sl.registerFactory(
    () => BankBloc(
      getBanks: sl(),
      deleteBank: sl(),
      setDefaultBank: sl(),
      getStripeOnboardingUrl: sl(),
    ),
  );

  sl.registerFactory(() => ChatbotBloc(apiClient: sl()));
  sl.registerFactory(
    () => TaskBloc(
      getAllTasks: sl(),
      getLocalTasks: sl(),
      getTaskDetail: sl(),
      acceptRejectTask: sl(),
      getTaskChat: sl(),
      uploadTaskMedia: sl(),
      getRoomId: sl(),
      getHopperAcceptedCount: sl(),
      getTaskTransactionDetails: sl(),
      getContentTransactionDetails: sl(),
    ),
  );
  sl.registerFactory(
    () => NotificationBloc(
      getNotifications: sl(),
      markNotificationsAsRead: sl(),
      clearAllNotifications: sl(),
      checkStudentBeans: sl(),
      activateStudentBeans: sl(),
      markStudentBeansVisited: sl(),
    ),
  );
  sl.registerFactory(
    () => EarningBloc(
      getEarningProfile: sl(),
      getTransactions: sl(),
      getCommissions: sl(),
    ),
  );
  sl.registerFactory(() => AlertBloc(apiClient: sl()));
  sl.registerFactory(() => CameraBloc(sl()));
  sl.registerFactory(
    () => ChatBloc(chatSocketDataSource: sl()),
  );
  sl.registerFactory(
    () => FeedBloc(getFeeds: sl(), toggleFeedInteraction: sl()),
  );
  sl.registerFactory(
    () => NewsBloc(
      getAggregatedNews: sl(),
      getNewsDetail: sl(),
      getComments: sl(),
      newsSocketDataSource: sl(),
      sharedPreferences: sl(),
    ),
  );

  sl.registerFactory(
    () => MapBloc(
      getCurrentLocation: sl(),
      getRoute: sl(),
      repository: sl(),
      incidentSocketDataSource: sl(),
      newsRepository: sl(),
      markerService: sl(),
      sharedPreferences: sl(),
    ),
  );
  // Menu
  sl.registerFactory(
    () => MenuBloc(
      getNotifications: sl(),
      removeDevice: sl(),
      logoutUser: sl(),
      menuService: sl(),
      authLocalDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<MenuService>(
    () => MenuServiceImpl(googleSignIn: sl()),
  );

  sl.registerLazySingleton(() => GetActiveAdmins(sl()));
  sl.registerLazySingleton(() => UpdateLocation(sl()));
  sl.registerLazySingleton(() => AddDevice(sl()));
  sl.registerLazySingleton(() => RemoveDevice(sl()));
  sl.registerLazySingleton(() => GetDashboardTaskDetail(sl()));
  sl.registerLazySingleton(() => GetRoomId(sl()));
  sl.registerLazySingleton(() => dashboard_beans.ActivateStudentBeans(sl()));
  sl.registerLazySingleton(() => CheckStudentBeans(sl()));
  sl.registerLazySingleton(() => MarkStudentBeansVisited(sl()));
  sl.registerLazySingleton(() => CheckAppVersion(sl()));
  sl.registerLazySingleton(() => GetProfileData(sl()));
  sl.registerLazySingleton(() => UpdateProfileData(sl()));
  sl.registerLazySingleton(() => UploadProfileImage(sl()));
  sl.registerLazySingleton(() => ChangePassword(sl()));
  sl.registerLazySingleton(() => GetMyContent(sl()));
  sl.registerLazySingleton(() => PublishContent(sl()));
  sl.registerLazySingleton(() => SaveDraft(sl()));
  sl.registerLazySingleton(() => UploadMedia(sl()));
  sl.registerLazySingleton(() => DeleteContent(sl()));
  sl.registerLazySingleton(() => SearchHashtags(sl()));
  sl.registerLazySingleton(() => profile_check.CheckUserName(sl()));
  sl.registerLazySingleton(() => profile_avatars.GetAvatars(sl()));
  sl.registerLazySingleton(() => GetTrendingHashtags(sl()));
  sl.registerLazySingleton(() => GetContentDetail(sl()));
  sl.registerLazySingleton(() => GetMediaHouseOffers(sl()));
  sl.registerLazySingleton(() => GetContentTransactions(sl()));

  // Account Settings Use Cases ==========================================>
  sl.registerLazySingleton(() => DeleteAccount(sl()));
  sl.registerLazySingleton(() => GetAdminContactInfo(sl()));
  sl.registerLazySingleton(() => GetFAQs(sl()));
  sl.registerLazySingleton(() => GetPriceTips(sl()));
  sl.registerLazySingleton(() => GetFAQCategories(sl()));
  sl.registerLazySingleton(() => GetReviews(sl()));
  sl.registerLazySingleton(() => rating_media.GetMediaHouses(sl()));
  // Leaderboard Use Cases ================================================>
  sl.registerLazySingleton(() => GetLeaderboardData(sl()));

  // Bank Use Cases ================================================>
  sl.registerLazySingleton(() => GetBanks(sl()));
  sl.registerLazySingleton(() => DeleteBank(sl()));
  sl.registerLazySingleton(() => SetDefaultBank(sl()));
  sl.registerLazySingleton(() => GetStripeOnboardingUrl(sl()));

  // Earning Use Cases ================================================>
  sl.registerLazySingleton(() => GetEarningProfile(sl()));
  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => GetCommissions(sl()));

  // Feed Use Cases ================================================>
  sl.registerLazySingleton(() => GetFeeds(sl()));
  sl.registerLazySingleton(() => ToggleFeedInteraction(sl()));

  // Notification Use Cases ================================================>
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => MarkNotificationsAsRead(sl()));
  sl.registerLazySingleton(() => ClearAllNotifications(sl()));

  // Verification Use Cases ================================================>
  sl.registerLazySingleton(() => GetDocumentInstructions(sl()));
  sl.registerLazySingleton(() => GetUploadedDocuments(sl()));
  sl.registerLazySingleton(() => UploadDocument(sl()));
  sl.registerLazySingleton(() => DeleteDocument(sl()));

  // Verification Repository ================================================>
  sl.registerLazySingleton<VerificationRepository>(
    () => VerificationRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Verification Data Sources ================================================>
  sl.registerLazySingleton<VerificationRemoteDataSource>(
    () => VerificationRemoteDataSourceImpl(apiClient: sl()),
  );

  // Publication Use Cases ================================================>
  sl.registerLazySingleton(() => GetPublicationEarningStats(sl()));
  sl.registerLazySingleton(() => GetMediaHouses(sl()));
  sl.registerLazySingleton(() => GetPublicationTransactions(sl()));

  // Publish Use Cases ================================================>
  sl.registerLazySingleton(() => GetContentCategories(sl()));
  sl.registerLazySingleton(() => GetCharities(sl()));
  sl.registerLazySingleton(() => GetShareExclusivePrice(sl()));
  sl.registerLazySingleton(() => SubmitContent(sl()));
  sl.registerLazySingleton(() => GetTutorialCategories(sl()));
  sl.registerLazySingleton(() => GetTutorialVideos(sl()));
  sl.registerLazySingleton(() => AddTutorialViewCount(sl()));

  // Map Use Cases
  sl.registerLazySingleton(() => GetCurrentLocation(sl()));
  sl.registerLazySingleton(() => GetIncidents(sl()));
  sl.registerLazySingleton(() => ReportIncident(sl()));
  sl.registerLazySingleton(() => GetRoute(sl()));
  sl.registerLazySingleton(() => SearchPlaces(sl()));
  sl.registerLazySingleton(() => GetPlaceDetails(sl()));

  // News Use Cases ================================================>
  sl.registerLazySingleton(() => GetAggregatedNews(sl()));
  sl.registerLazySingleton(() => GetNewsDetail(sl()));
  sl.registerLazySingleton(() => GetComments(sl()));

  // Profile Repository ================================================>
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ContentRepository>(
    () => ContentRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<AccountSettingsRepository>(
    () => AccountSettingsRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<RatingRepository>(
    () => RatingRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<BankRepository>(
    () => BankRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<EarningRepository>(
    () => EarningRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<PublicationRepository>(
    () => PublicationRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<PublishRepository>(
    () => PublishRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<TutorialsRepository>(
    () => TutorialsRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<MapRepository>(
    () => MapRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources ================================================>

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ContentRemoteDataSource>(
    () => ContentRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AccountSettingsRemoteDataSource>(
    () => AccountSettingsRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<RatingRemoteDataSource>(
    () => RatingRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<LeaderboardRemoteDataSource>(
    () => LeaderboardRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<BankRemoteDataSource>(
    () => BankRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<EarningRemoteDataSource>(
    () => EarningRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<FeedRemoteDataSource>(
    () => FeedRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetAllTasks(sl()));
  sl.registerLazySingleton(() => GetLocalTasks(sl()));
  sl.registerLazySingleton(() => GetTaskDetail(sl()));
  sl.registerLazySingleton(() => AcceptRejectTask(sl()));
  sl.registerLazySingleton(() => GetTaskChat(sl()));
  sl.registerLazySingleton(() => UploadTaskMedia(sl()));
  sl.registerLazySingleton(() => task_room.GetRoomId(sl()));
  sl.registerLazySingleton(() => GetHopperAcceptedCount(sl()));
  sl.registerLazySingleton(() => GetTaskTransactionDetails(sl()));
  sl.registerLazySingleton(() => GetContentTransactionDetails(sl()));

  sl.registerLazySingleton<PublicationRemoteDataSource>(
    () => PublicationRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<PublishRemoteDataSource>(
    () => PublishRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<TutorialsRemoteDataSource>(
    () => TutorialsRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<MapRemoteDataSource>(
    () => MapRemoteDataSourceImpl(
      apiClient: sl(),
      googleApiKey: 'AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI',
      locationService: sl(),
    ),
  );

  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton(() => MarkerService());
  sl.registerLazySingleton(() => GlobalSocketClient());
  sl.registerLazySingleton(() => IncidentSocketDataSource(client: sl()));
  sl.registerLazySingleton(() => NewsSocketDataSource(client: sl()));
  sl.registerLazySingleton(() => ChatSocketDataSource(client: sl()));
}
