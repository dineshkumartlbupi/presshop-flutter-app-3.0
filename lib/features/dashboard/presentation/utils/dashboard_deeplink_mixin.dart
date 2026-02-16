import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/router/router_constants.dart';

mixin DashboardDeepLinkMixin<T extends StatefulWidget> on State<T> {
  void initDeepLinks(AppLinks linkStream) {
    linkStream.uriLinkStream.listen((link) {
      debugPrint('linkStream index got? link: $link');
      jump2Screen(link.path);
    }, onError: (err) {
      debugPrint('got err: $err');
    });

    _handleInitialLink(linkStream);
  }

  Future<void> _handleInitialLink(AppLinks linkStream) async {
    try {
      final initialLink = await linkStream.getInitialLink();
      if (initialLink != null) {
        debugPrint('initial link: $initialLink');
        jump2Screen(initialLink.path);
      }
    } catch (e) {
      debugPrint('exception -----> $e');
    }
  }

  void jump2Screen(String link) async {
    debugPrint("dashboardDeepLiking-->$link");
    if (link.isNotEmpty) {
      if (link.contains("shareLinkforUserid")) {
        context.pushNamed(AppRoutes.myContentName);
      } else if (link.split("&").last == "type=Group") {
        String groupId = link.substring(link.lastIndexOf("?") + 1, link.length);
        debugPrint(
            "groupId : ${groupId.replaceAll("group_id=", "").replaceAll("&type=Group", "")}");
      }
    }
  }
}
