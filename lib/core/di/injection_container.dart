import 'package:get_it/get_it.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/features/publish/domain/usecases/submit_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:presshop/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:presshop/features/authentication/presentation/bloc/signup_bloc.dart';
import 'package:presshop/features/authentication/presentation/bloc/verification_bloc.dart'; // Import
import 'package:presshop/features/profile/domain/usecases/check_username.dart' as profile_check;
import 'package:presshop/features/profile/domain/usecases/get_avatars.dart' as profile_avatars;

import 'package:presshop/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:presshop/features/chatbot/presentation/bloc/chatbot_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_bloc.dart';
import 'package:presshop/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:presshop/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:presshop/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:presshop/features/notification/domain/repositories/notification_repository.dart';
import 'package:presshop/features/notification/domain/usecases/get_notifications.dart';
import 'package:presshop/features/notification/domain/usecases/mark_notifications_read.dart';
import 'package:presshop/features/notification/domain/usecases/clear_all_notifications.dart';
import 'package:presshop/features/notification/domain/usecases/check_student_beans.dart';
import 'package:presshop/features/notification/domain/usecases/activate_student_beans.dart';
import 'package:presshop/features/notification/domain/usecases/mark_student_beans_visited.dart';
import 'package:presshop/features/map/presentation/bloc/map_bloc.dart';
import 'package:presshop/features/map/data/datasources/map_remote_datasource.dart';
import 'package:presshop/features/map/data/datasources/map_remote_datasource_impl.dart';
import 'package:presshop/features/map/data/repositories/map_repository_impl.dart';
import 'package:presshop/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';
import 'package:presshop/features/map/domain/usecases/get_current_location.dart';
import 'package:presshop/features/map/domain/usecases/get_incidents.dart';
import 'package:presshop/features/map/domain/usecases/report_incident.dart';
import 'package:presshop/features/map/domain/usecases/get_route.dart';
import 'package:presshop/features/map/domain/usecases/search_places.dart';
import 'package:presshop/features/map/domain/usecases/get_place_details.dart';
import 'package:presshop/features/map/presentation/pages/services/marker_service.dart';
import 'package:presshop/features/map/presentation/pages/services/socket_service.dart';
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
import 'package:presshop/features/task/data/datasources/task_remote_data_source.dart';
import 'package:presshop/features/task/domain/usecases/get_all_tasks.dart';
import 'package:presshop/features/task/domain/usecases/get_local_tasks.dart';
import 'package:presshop/features/task/domain/usecases/get_task_detail.dart';

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


import 'package:presshop/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:presshop/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:presshop/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:presshop/features/dashboard/domain/usecases/get_active_admins.dart';
import 'package:presshop/features/dashboard/domain/usecases/update_location.dart';
import 'package:presshop/features/dashboard/domain/usecases/add_device.dart';
import 'package:presshop/features/dashboard/domain/usecases/remove_device.dart';
import 'package:presshop/features/dashboard/domain/usecases/get_dashboard_task_detail.dart';
import 'package:presshop/features/dashboard/domain/usecases/get_room_id.dart';
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

import 'package:presshop/features/account_settings/presentation/bloc/account_settings_bloc.dart';
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

import 'package:presshop/features/publish/presentation/bloc/publish_bloc.dart';
import 'package:presshop/features/publish/domain/usecases/get_content_categories.dart';
import 'package:presshop/features/publish/domain/usecases/get_charities.dart';
import 'package:presshop/features/publish/domain/usecases/get_share_exclusive_price.dart';
import 'package:presshop/features/publish/domain/repositories/publish_repository.dart';
import 'package:presshop/features/publish/data/repositories/publish_repository_impl.dart';
import 'package:presshop/features/publish/data/datasources/publish_remote_data_source.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => InternetConnectionChecker());

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => ApiClient(sl(), sl()));

  //! Features - Authentication
  // Blocs
  sl.registerFactory(() => AuthBloc(
        loginUser: sl(),
        socialLoginUser: sl(),
        forgotPassword: sl(),
        verifyForgotPasswordOtp: sl(),
        resetPassword: sl(),
      ));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => VerifyForgotPasswordOtp(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerFactory(() => SignUpBloc(
    registerUser: sl(),
    sendOtp: sl(),
    checkUserName: sl(),
    checkEmail: sl(),
    checkPhone: sl(),
    getAvatars: sl(),
    verifyReferralCode: sl(),
    socialExists: sl(),
    socialRegisterUser: sl(),
  ));
  sl.registerFactory(() => SplashBloc(
      checkAuthStatus: sl(),
      getProfile: sl(),
      checkAppVersion: sl(),
      checkOnboardingStatus: sl(),
  ));
  sl.registerFactory(() => OnboardingBloc(setOnboardingSeen: sl()));
  sl.registerFactory(() => PublicationBloc(
    getPublicationEarningStats: sl(),
    getMediaHouses: sl(),
    getPublicationTransactions: sl(),
  ));
  // sl.registerFactory(() => PublishBloc(
  //   getContentCategories: sl(),
  //   getCharities: sl(),
  //   getShareExclusivePrice: sl(), submitContent:SubmitContent(),
  // ));
  sl.registerFactory(() => VerificationBloc(
    verifyOtp: sl(),
    registerUser: sl(),
    socialRegisterUser: sl(),
    sendOtp: sl(),
  ));

  sl.registerFactory(() => DashboardBloc(
    getActiveAdmins: sl(),
    updateLocation: sl(),
    addDevice: sl(),
    getDashboardTaskDetail: sl(),
    getRoomId: sl(),
    checkAppVersion: sl(),
    activateStudentBeans: sl(),
    getProfile: sl(),
  ));

  sl.registerFactory(() => ProfileBloc(
    getProfileData: sl(),
    updateProfileData: sl(),
    uploadProfileImage: sl(),
    changePassword: sl(),
    checkUserName: sl(),
    getAvatars: sl(),
    checkEmail: sl(),
    checkPhone: sl(),
  ));

  

  sl.registerFactory(() => ContentBloc(
    getMyContent: sl(),
    publishContent: sl(),
    saveDraft: sl(),
    uploadMedia: sl(),
    deleteContent: sl(),
    searchHashtags: sl(),

    getTrendingHashtags: sl(),
    getContentDetail: sl(),
  ));

  sl.registerFactory(() => AccountSettingsBloc(
    deleteAccount: sl(),
    changePassword: sl(),
    getAdminContactInfo: sl(),
  ));

  sl.registerFactory(() => LeaderboardBloc(
    getLeaderboardData: sl(),
  ));

  sl.registerFactory(() => BankBloc(
    getBanks: sl(),
    deleteBank: sl(),
    setDefaultBank: sl(),
    getStripeOnboardingUrl: sl(),
  ));

  sl.registerFactory(() => ChatbotBloc());
  sl.registerFactory(() => ChatbotBloc());
  sl.registerFactory(() => TaskBloc(
    getAllTasks: sl(),
    getLocalTasks: sl(),
    getTaskDetail: sl(),
    sharedPreferences: sl(),
  ));
  sl.registerFactory(() => NotificationBloc(
    getNotifications: sl(),
    markNotificationsAsRead: sl(),
    clearAllNotifications: sl(),
    checkStudentBeans: sl(),
    activateStudentBeans: sl(),
    markStudentBeansVisited: sl(),
  ));
  sl.registerFactory(() => EarningBloc(
    getEarningProfile: sl(),
    getTransactions: sl(),
    getCommissions: sl(),
  ));
  sl.registerFactory(() => AlertBloc());
  sl.registerFactory(() => CameraBloc());
  sl.registerFactory(() => ChatBloc());
  sl.registerFactory(() => FeedBloc(
    getFeeds: sl(),
    toggleFeedInteraction: sl(),
  ));
  sl.registerFactory(() => MapBloc(
    getCurrentLocation: sl(),
    getIncidents: sl(),
    reportIncident: sl(),
    getRoute: sl(),
    searchPlaces: sl(),
    getPlaceDetails: sl(),
    repository: sl(),
    markerService: sl(),
  ));

  sl.registerFactory(() => MenuBloc(
    getNotifications: sl(),
    removeDevice: sl(),
    logoutUser: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => SocialLoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => SendOtp(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerLazySingleton(() => SocialRegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => CheckOnboardingStatus(sl()));
  sl.registerLazySingleton(() => SetOnboardingSeen(sl()));
  
  // Dashboard Use Cases
  sl.registerLazySingleton(() => GetActiveAdmins(sl()));
  sl.registerLazySingleton(() => UpdateLocation(sl()));
  sl.registerLazySingleton(() => AddDevice(sl()));
  sl.registerLazySingleton(() => RemoveDevice(sl()));
  sl.registerLazySingleton(() => GetDashboardTaskDetail(sl()));
  sl.registerLazySingleton(() => GetRoomId(sl()));
  sl.registerLazySingleton(() => CheckAppVersion(sl()));
  sl.registerLazySingleton(() => ActivateStudentBeans(sl()));
  sl.registerLazySingleton(() => CheckUserName(sl()));
  sl.registerLazySingleton(() => CheckEmail(sl()));
  sl.registerLazySingleton(() => CheckPhone(sl()));
  sl.registerLazySingleton(() => GetAvatars(sl()));
  sl.registerLazySingleton(() => VerifyReferralCode(sl()));
  sl.registerLazySingleton(() => SocialExists(sl()));
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


  // Account Settings Use Cases
  sl.registerLazySingleton(() => DeleteAccount(sl()));
  
  // Leaderboard Use Cases
  sl.registerLazySingleton(() => GetLeaderboardData(sl()));

  // Bank Use Cases
  sl.registerLazySingleton(() => GetBanks(sl()));
  sl.registerLazySingleton(() => DeleteBank(sl()));
  sl.registerLazySingleton(() => SetDefaultBank(sl()));
  sl.registerLazySingleton(() => GetStripeOnboardingUrl(sl()));
  
  // Earning Use Cases
  sl.registerLazySingleton(() => GetEarningProfile(sl()));
  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => GetCommissions(sl()));
  
  // Feed Use Cases
  sl.registerLazySingleton(() => GetFeeds(sl()));
  sl.registerLazySingleton(() => ToggleFeedInteraction(sl()));

  // Notification Use Cases
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => MarkNotificationsAsRead(sl()));
  sl.registerLazySingleton(() => ClearAllNotifications(sl()));
  sl.registerLazySingleton(() => CheckStudentBeans(sl()));
  sl.registerLazySingleton(() => ActivateStudentBeans(sl()));
  sl.registerLazySingleton(() => MarkStudentBeansVisited(sl()));

  // Publication Use Cases
  sl.registerLazySingleton(() => GetPublicationEarningStats(sl()));
  sl.registerLazySingleton(() => GetMediaHouses(sl()));
  sl.registerLazySingleton(() => GetPublicationTransactions(sl()));

  // Publish Use Cases
  sl.registerLazySingleton(() => GetContentCategories(sl()));
  sl.registerLazySingleton(() => GetCharities(sl()));
  sl.registerLazySingleton(() => GetShareExclusivePrice(sl()));

  // Map Use Cases
  sl.registerLazySingleton(() => GetCurrentLocation(sl()));
  sl.registerLazySingleton(() => GetIncidents(sl()));
  sl.registerLazySingleton(() => ReportIncident(sl()));
  sl.registerLazySingleton(() => GetRoute(sl()));
  sl.registerLazySingleton(() => SearchPlaces(sl()));
  sl.registerLazySingleton(() => GetPlaceDetails(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ContentRepository>(
    () => ContentRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<AccountSettingsRepository>(
    () => AccountSettingsRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<BankRepository>(
    () => BankRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<EarningRepository>(
    () => EarningRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<PublicationRepository>(
    () => PublicationRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<PublishRepository>(
    () => PublishRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<MapRepository>(
    () => MapRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ContentRemoteDataSource>(
    () => ContentRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AccountSettingsRemoteDataSource>(
    () => AccountSettingsRemoteDataSourceImpl(sl()),
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

  // Task Feature
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(dio: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetAllTasks(sl()));
  sl.registerLazySingleton(() => GetLocalTasks(sl()));
  sl.registerLazySingleton(() => GetTaskDetail(sl()));

  // Notification Feature
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(dio: sl(), sharedPreferences: sl()),
  );

  sl.registerLazySingleton<PublicationRemoteDataSource>(
    () => PublicationRemoteDataSourceImpl( sl()),
  );

  sl.registerLazySingleton<PublishRemoteDataSource>(
    () => PublishRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<MapRemoteDataSource>(
    () => MapRemoteDataSourceImpl(dio: sl(), socketService: sl()),
  );

  sl.registerLazySingleton(() => MarkerService());
  sl.registerLazySingleton(() => SocketService());

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
}
