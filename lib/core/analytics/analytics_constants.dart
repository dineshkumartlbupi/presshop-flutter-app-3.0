class PageNames {
  // Authentication Pages
  static const String splash = 'splash_screen';
  static const String login = 'login_screen';
  static const String signup = 'signup_screen';
  static const String forgotPassword = 'forgot_password_screen';
  static const String resetPassword = 'reset_password_screen';
  static const String otpVerification = 'otp_verification_screen';
  static const String welcomeScreen = 'welcome_screen';
  static const String socialSignup = 'social_signup_screen';

  // Main Dashboard Pages
  static const String dashboard = 'dashboard_screen';
  static const String myContent = 'my_content_screen';
  static const String myTasks = 'my_tasks_screen';
  static const String camera = 'camera_screen';
  static const String chatBot = 'chat_bot_screen';
  static const String menu = 'menu_screen';

  // Content Management
  static const String publishContent = 'publish_content_screen';
  static const String contentDetail = 'content_detail_screen';
  static const String editContent = 'edit_content_screen';
  static const String contentPreview = 'content_preview_screen';
  static const String contentLibrary = 'content_library_screen';
  static const String manageContent = 'manage_content_screen';

  // Task Management
  static const String taskDetail = 'task_detail_screen';
  static const String taskList = 'task_list_screen';
  static const String broadcastScreen = 'broadcast_screen';
  static const String taskHistory = 'task_history_screen';
  static const String acceptedTasks = 'accepted_tasks_screen';
  static const String rejectedTasks = 'rejected_tasks_screen';
  static const String customGallery = 'custom_gallery_screen';
  static const String manageTaskPreviewMedia =
      'manage_task_preview_media_screen';

  // Chat & Communication
  static const String chatScreen = 'chat_screen';
  static const String chatListing = 'chat_listing_screen';
  static const String conversationScreen = 'conversation_screen';
  static const String groupChat = 'group_chat_screen';

  // Feed & Social
  static const String feedScreen = 'feed_screen';
  static const String feedDetail = 'feed_detail_screen';
  static const String socialFeed = 'social_feed_screen';

  // Profile & Settings
  static const String profile = 'profile_screen';
  static const String editProfile = 'edit_profile_screen';
  static const String settings = 'settings_screen';
  static const String privacy = 'privacy_screen';
  static const String security = 'security_screen';
  static const String notifications = 'notifications_screen';

  // Financial
  static const String myEarnings = 'my_earnings_screen';
  static const String transactionDetail = 'transaction_detail_screen';
  static const String paymentMethods = 'payment_methods_screen';
  static const String bankDetails = 'bank_details_screen';
  static const String commissionDetails = 'commission_details_screen';

  // Support & Help
  static const String faq = 'faq_screen';
  static const String helpCenter = 'help_center_screen';
  static const String contactUs = 'contact_us_screen';
  static const String feedback = 'feedback_screen';
  static const String tutorials = 'tutorials_screen';
  static const String termsConditions = 'terms_conditions_screen';
  static const String privacyPolicy = 'privacy_policy_screen';

  // Location & Map
  static const String map = 'map_screen';
  static const String locationPicker = 'location_picker_screen';
  static const String locationError = 'location_error_screen';

  // Media & Files
  static const String mediaViewer = 'media_viewer_screen';
  static const String imageEditor = 'image_editor_screen';
  static const String videoPlayer = 'video_player_screen';
  static const String audioPlayer = 'audio_player_screen';
  static const String documentViewer = 'document_viewer_screen';
  static const String fileManager = 'file_manager_screen';

  // Notifications & Alerts
  static const String alertScreen = 'alert_screen';
  static const String notificationDetail = 'notification_detail_screen';
  static const String pushNotifications = 'push_notifications_screen';

  // Referral & Social
  static const String referScreen = 'refer_screen';
  static const String referralHistory = 'referral_history_screen';
  static const String socialSharing = 'social_sharing_screen';

  // Onboarding & Tutorial
  static const String onboarding = 'onboarding_screen';
  static const String appIntro = 'app_intro_screen';
  static const String featureTour = 'feature_tour_screen';

  // Error & Loading
  static const String errorScreen = 'error_screen';
  static const String loadingScreen = 'loading_screen';
  static const String noInternet = 'no_internet_screen';

  // WebView & External
  static const String webView = 'web_view_screen';
  static const String externalLink = 'external_link_screen';

  // Search & Filter
  static const String searchScreen = 'search_screen';
  static const String filterScreen = 'filter_screen';
  static const String searchResults = 'search_results_screen';

  // Verification & Documents
  static const String documentUpload = 'document_upload_screen';
  static const String verification = 'verification_screen';
  static const String kycScreen = 'kyc_screen';

  // App Updates
  static const String updateScreen = 'update_screen';
  static const String changelogScreen = 'changelog_screen';

  /// Get all page names as a list for validation or debugging
  static List<String> get allPages => [
        splash,
        login,
        signup,
        forgotPassword,
        resetPassword,
        otpVerification,
        dashboard,
        myContent,
        myTasks,
        camera,
        chatBot,
        menu,
        publishContent,
        contentDetail,
        editContent,
        contentPreview,
        contentLibrary,
        manageContent,
        taskDetail,
        taskList,
        broadcastScreen,
        taskHistory,
        acceptedTasks,
        rejectedTasks,
        chatScreen,
        chatListing,
        conversationScreen,
        groupChat,
        feedScreen,
        feedDetail,
        socialFeed,
        profile,
        editProfile,
        settings,
        privacy,
        security,
        notifications,
        myEarnings,
        transactionDetail,
        paymentMethods,
        bankDetails,
        commissionDetails,
        faq,
        helpCenter,
        contactUs,
        feedback,
        tutorials,
        termsConditions,
        privacyPolicy,
        map,
        locationPicker,
        locationError,
        mediaViewer,
        imageEditor,
        videoPlayer,
        audioPlayer,
        documentViewer,
        fileManager,
        alertScreen,
        notificationDetail,
        pushNotifications,
        referScreen,
        referralHistory,
        socialSharing,
        onboarding,
        appIntro,
        featureTour,
        errorScreen,
        loadingScreen,
        noInternet,
        webView,
        externalLink,
        searchScreen,
        filterScreen,
        searchResults,
        documentUpload,
        verification,
        kycScreen,
        updateScreen,
        changelogScreen,
      ];

  /// Check if a page name is valid
  static bool isValidPageName(String pageName) {
    return allPages.contains(pageName);
  }
}

/// Action Names Constants for User Interactions
class ActionNames {
  // Button Actions
  static const String buttonTap = 'button_tap';
  static const String buttonLongPress = 'button_long_press';
  static const String fabTap = 'fab_tap';

  // Navigation Actions
  static const String tabSwitch = 'tab_switch';
  static const String backButton = 'back_button';
  static const String drawerOpen = 'drawer_open';
  static const String bottomSheetOpen = 'bottom_sheet_open';
  static const String dialogOpen = 'dialog_open';

  // Gesture Actions
  static const String swipeLeft = 'swipe_left';
  static const String swipeRight = 'swipe_right';
  static const String swipeUp = 'swipe_up';
  static const String swipeDown = 'swipe_down';
  static const String pinchZoom = 'pinch_zoom';
  static const String doubleTap = 'double_tap';

  // Form Actions
  static const String textInput = 'text_input';
  static const String formSubmit = 'form_submit';
  static const String formCancel = 'form_cancel';
  static const String fieldFocus = 'field_focus';
  static const String dropdownSelect = 'dropdown_select';
  static const String checkboxToggle = 'checkbox_toggle';
  static const String radioSelect = 'radio_select';

  // Media Actions
  static const String photoCapture = 'photo_capture';
  static const String videoRecord = 'video_record';
  static const String audioRecord = 'audio_record';
  static const String fileSelect = 'file_select';
  static const String galleryOpen = 'gallery_open';

  // Content Actions
  static const String contentView = 'content_view';
  static const String contentShare = 'content_share';
  static const String contentLike = 'content_like';
  static const String contentComment = 'content_comment';
  static const String contentSave = 'content_save';
  static const String contentDelete = 'content_delete';

  // Search Actions
  static const String searchQuery = 'search_query';
  static const String searchFilter = 'search_filter';
  static const String searchSort = 'search_sort';
  static const String searchClear = 'search_clear';

  // Social Actions
  static const String follow = 'follow';
  static const String unfollow = 'unfollow';
  static const String block = 'block';
  static const String report = 'report';
  static const String invite = 'invite';

  // Settings Actions
  static const String settingChange = 'setting_change';
  static const String notificationToggle = 'notification_toggle';
  static const String privacyChange = 'privacy_change';
  static const String logout = 'logout';

  // Purchase Actions
  static const String purchase = 'purchase';
  static const String subscribe = 'subscribe';
  static const String upgrade = 'upgrade';
  static const String refund = 'refund';
}

/// Event Names Constants for Custom Events
class EventNames {
  // App Lifecycle
  static const String appOpen = 'app_open';
  static const String appBackground = 'app_background';
  static const String appForeground = 'app_foreground';
  static const String appClose = 'app_close';
  static const String appCrash = 'app_crash';

  // User Lifecycle
  static const String userRegistered = 'user_registered';
  static const String userLogin = 'user_login';
  static const String userLogout = 'user_logout';
  static const String userProfileComplete = 'user_profile_complete';
  static const String userVerified = 'user_verified';

  // Content Lifecycle
  static const String contentPublished = 'content_published';
  static const String contentUpdated = 'content_updated';
  static const String contentDeleted = 'content_deleted';
  static const String contentViewed = 'content_viewed';
  static const String contentShared = 'content_shared';

  // Task Lifecycle
  static const String taskReceived = 'task_received';
  static const String taskAccepted = 'task_accepted';
  static const String taskRejected = 'task_rejected';
  static const String taskCompleted = 'task_completed';
  static const String taskSubmitted = 'task_submitted';

  // Chat Events
  static const String chatStarted = 'chat_started';
  static const String messageSent = 'message_sent';
  static const String messageReceived = 'message_received';
  static const String chatEnded = 'chat_ended';

  // Feature Usage
  static const String featureUsed = 'feature_used';
  static const String tutorialCompleted = 'tutorial_completed';
  static const String helpViewed = 'help_viewed';
  static const String feedbackSubmitted = 'feedback_submitted';

  // Error Events
  static const String networkError = 'network_error';
  static const String apiError = 'api_error';
  static const String validationError = 'validation_error';
  static const String permissionDenied = 'permission_denied';

  // Performance Events
  static const String loadTimeExceeded = 'load_time_exceeded';
  static const String memoryWarning = 'memory_warning';
  static const String batteryLow = 'battery_low';

  // Business Events
  static const String earningGenerated = 'earning_generated';
  static const String paymentReceived = 'payment_received';
  static const String commissionEarned = 'commission_earned';
  static const String referralSuccessful = 'referral_successful';
}
