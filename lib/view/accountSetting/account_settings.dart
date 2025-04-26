import 'package:flutter/material.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonWigdets.dart';

import '../../utils/Common.dart';
import '../dashboard/Dashboard.dart';
import 'account_delete_screen.dart';

class AccountSetting extends StatelessWidget {
  const AccountSetting({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: CommonAppBar(
          elevation: 0,
          hideLeading: false,
          title: Text(
            "Account Settings",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: size.width * appBarHeadingFontSize),
          ),
          centerTitle: false,
          titleSpacing: 0,
          size: size,
          showActions: true,
          leadingFxn: () {
            /*  if (widget.editProfileScreen) {
              widget.editProfileScreen = false;
            }*/
            Navigator.pop(context);
          },
          actionWidget: [],
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * numD01, vertical: size.height * numD015),
          children: [
            ListTile(
              title: Text(
                "Delete Account",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD04,
                    color: Colors.red,
                    fontWeight: FontWeight.w600),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: size.width * numD05,
                color: Colors.red,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountDeleteScreen()));
                // Navigate to change password screen
              },
            ),
          ],
        ));
  }
}
