import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/account_settings/presentation/pages/account_settings.dart';
import 'package:presshop/features/account_settings/presentation/pages/change_password_screen.dart';
import 'package:presshop/features/account_settings/presentation/pages/contact_us_screen.dart';
import 'package:presshop/features/account_settings/presentation/pages/faq_screen.dart';
import 'package:presshop/features/authentication/presentation/pages/TermCheckScreen.dart';
import 'package:presshop/features/authentication/presentation/pages/UploadDocumnetsScreen.dart';
import 'package:presshop/features/bank/presentation/pages/my_banks_page.dart';
import 'package:presshop/features/chatbot/presentation/pages/chatBotScreen.dart';
import 'package:presshop/features/content/presentation/pages/my_content_page.dart';
import 'package:presshop/features/content/presentation/pages/my_draft_screen.dart';
import 'package:presshop/features/earning/presentation/pages/MyEarningScreen.dart';
import 'package:presshop/features/feed/presentation/pages/FeedScreen.dart';
import 'package:presshop/features/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:presshop/features/notification/presentation/pages/MyNotifications.dart';
import 'package:presshop/features/profile/presentation/pages/DigitalIdScreen.dart';
import 'package:presshop/features/profile/presentation/pages/my_profile_screen.dart';
import 'package:presshop/features/publish/presentation/pages/TutorialsScreen.dart';
import 'package:presshop/features/rating/presentation/pages/RatingReviewScreen.dart';
import 'package:presshop/features/referral/presentation/pages/refer_screen.dart';
import 'package:presshop/features/task/presentation/pages/my_task_screen.dart';

enum MenuAction {
  digitalId,
  myProfile,
  editProfile,
  chat,
  contact,
  leaderboard,
  paymentMethod,
  myDrafts,
  myContent,
  feed,

  myTasks,
  myEarnings,
  notification,
  ratingReview,
  referHopper,
  uploadDocs,
  faq,
  legal,
  privacy,
  priceTips,
  tutorials,
  changePassword,
  accountSettings,
  logout,
  currency,
}

class MenuData {
  final String icon;
  final String title;
  final MenuAction action;
  final Widget Function(BuildContext)? pageBuilder;
  final bool showAlertBadge;
  final bool isContactBrand;
  final bool isVisible;

  const MenuData({
    required this.icon,
    required this.title,
    required this.action,
    this.pageBuilder,
    this.showAlertBadge = false,
    this.isContactBrand = false,
    this.isVisible = true,
  });
}

List<MenuData> buildMenu() => [
      MenuData(
        title: digitalIdText,
        icon: "${iconsPath}ic_id.png",
        action: MenuAction.digitalId,
        pageBuilder: (context) => const DigitalIdScreen(),
      ),
      MenuData(
        title: myProfileText,
        icon: "${iconsPath}ic_my_profile.png",
        action: MenuAction.myProfile,
        pageBuilder: (context) => MyProfile(
          editProfileScreen: false,
          screenType: myProfileText,
        ),
      ),
      MenuData(
        title: editProfileText,
        icon: "${iconsPath}ic_edit_profile.png",
        action: MenuAction.editProfile,
        pageBuilder: (context) => MyProfile(
          editProfileScreen: true,
          screenType: editProfileText,
        ),
      ),
      MenuData(
        title: "Chat",
        icon: "${iconsPath}ic_chat.png",
        action: MenuAction.chat,
        pageBuilder: (context) => ChatBotScreen(),
      ),
      MenuData(
        title: "$contactText PressHop",
        icon: "${iconsPath}ic_contact_us.png",
        action: MenuAction.contact,
        pageBuilder: (context) => const ContactUsScreen(),
        isContactBrand: true,
      ),
      MenuData(
        title: leaderboardText,
        icon: "${iconsPath}ic_ranking.png",
        action: MenuAction.leaderboard,
        pageBuilder: (context) => const LeaderboardPage(),
      ),
      MenuData(
        title: paymentMethodText,
        icon: "${iconsPath}ic_payment_method.png",
        action: MenuAction.paymentMethod,
        pageBuilder: (context) => const MyBanksPage(),
      ),
      MenuData(
        title: myDraftText,
        icon: "${iconsPath}ic_my_draft.png",
        action: MenuAction.myDrafts,
        pageBuilder: (context) => MyDraftScreen(
          publishedContent: false,
          screenType: '',
        ),
      ),
      MenuData(
        title: myContentText,
        icon: "${iconsPath}ic_content.png",
        action: MenuAction.myContent,
        pageBuilder: (context) => const MyContentPage(
            // hideLeading: false,
            ),
      ),
      MenuData(
        title: feedText,
        icon: "${iconsPath}ic_feed.png",
        action: MenuAction.feed,
        pageBuilder: (context) => const FeedScreen(),
      ),
      MenuData(
        title: "My tasks",
        icon: "${iconsPath}ic_task.png",
        action: MenuAction.myTasks,
        pageBuilder: (context) => MyTaskScreen(hideLeading: false),
      ),
      MenuData(
        title: "My earnings",
        icon: "${iconsPath}ic_earning.png",
        action: MenuAction.myEarnings,
        pageBuilder: (context) => MyEarningScreen(
          openDashboard: false,
          initialTapPosition: 0,
        ),
      ),
      MenuData(
        title: notificationText,
        icon: "${iconsPath}ic_feed.png",
        action: MenuAction.notification,
        pageBuilder: (context) => const MyNotificationScreen(
            count: 0), // Count now handled by BlocSelector
      ),
      MenuData(
        title: "$ratingText & ${reviewText.toLowerCase()}",
        icon: "${iconsPath}ic_rating_review.png",
        action: MenuAction.ratingReview,
        pageBuilder: (context) => const RatingReviewScreen(),
        showAlertBadge: true,
      ),
      MenuData(
        title: "Refer a Hopper",
        icon: "${iconsPath}gift.png",
        action: MenuAction.referHopper,
        pageBuilder: (context) => const ReferScreen(),
      ),
      MenuData(
        title: uploadDocsHeadingText,
        icon: "${iconsPath}ic_upload_documents.png",
        action: MenuAction.uploadDocs,
        pageBuilder: (context) => const UploadDocumentsScreen(
          menuScreen: true,
          hideLeading: false,
        ),
      ),
      MenuData(
        title: faqText,
        icon: "${iconsPath}ic_faq.png",
        action: MenuAction.faq,
        pageBuilder: (context) => FAQScreen(
          priceTipsSelected: false,
          type: 'faq',
          index: 0,
        ),
      ),
      MenuData(
        title: "$legalText $tcText",
        icon: "${iconsPath}ic_legal.png",
        action: MenuAction.legal,
        pageBuilder: (context) => TermCheckScreen(
          type: 'legal',
        ),
      ),
      MenuData(
        title: "Privacy policy",
        icon: "${iconsPath}ic_privacy.png",
        action: MenuAction.privacy,
        pageBuilder: (context) => TermCheckScreen(
          type: 'privacy_policy',
        ),
      ),
      MenuData(
        title: "Price tips",
        icon: "${iconsPath}ic_price_tips.png",
        action: MenuAction.priceTips,
        pageBuilder: (context) => FAQScreen(
          priceTipsSelected: true,
          type: 'price_tips',
          index: 0,
        ),
      ),
      MenuData(
        title: tutorialsText,
        icon: "${iconsPath}ic_tutorials.png",
        action: MenuAction.tutorials,
        pageBuilder: (context) => const TutorialsScreen(),
      ),
      MenuData(
        title: changePasswordText,
        icon: "${iconsPath}ic_change_password.png",
        action: MenuAction.changePassword,
        pageBuilder: (context) => const ChangePasswordScreen(),
      ),
      MenuData(
        title: accountSettingText,
        icon: "${iconsPath}ic_my_profile.png",
        action: MenuAction.accountSettings,
        pageBuilder: (context) => const AccountSetting(),
      ),
      MenuData(
        title: "Choose currency",
        icon: "${iconsPath}ic_payment_method.png",
        action: MenuAction.currency,
      ),
      MenuData(
        title: logoutText,
        icon: "${iconsPath}ic_logout.png",
        action: MenuAction.logout,
      ),
    ];
