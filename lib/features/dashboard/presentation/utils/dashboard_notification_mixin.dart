import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:presshop/features/chat/presentation/pages/ChatScreen.dart';
import 'package:presshop/features/notification/presentation/pages/MyNotifications.dart';

mixin DashboardNotificationMixin<T extends StatefulWidget> on State<T> {
  void initFirebaseMessaging({
    required Function(String) onTaskAssigned,
    required VoidCallback onProfileUpdate,
  }) {
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        if (message != null) {
          debugPrint("New Notification");
        }
      },
    );

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("FirebaseMessage: ${message.data}");

      if (message.data.isNotEmpty &&
          message.data["notification_type"].toString() == "media_house_tasks") {
        onTaskAssigned(message.data["broadCast_id"]);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        if (message.data.isNotEmpty &&
            message.data["notification_type"].toString() == "studentbeans") {
          onProfileUpdate();
          return;
        }
        if (message.data.isNotEmpty &&
            message.data["notification_type"].toString() ==
                "media_house_tasks") {
          onTaskAssigned(message.data["broadCast_id"]);
        } else if (message.data.isNotEmpty &&
            message.data["notification_type"].toString() ==
                "initiate_admin_chat") {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationScreen(
                    hideLeading: false,
                    message: '',
                  ),
                ),
              );
            }
          });
        } else if (message.data.isNotEmpty &&
            message.data["image"] != null &&
            message.data["image"].isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyNotificationScreen(
                count: 1,
              ),
            ),
          );
        }
      },
    );
  }
}
