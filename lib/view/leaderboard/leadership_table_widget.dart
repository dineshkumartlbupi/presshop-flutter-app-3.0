import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/view/leaderboard/leaderboard_model.dart';

import '../../utils/CommonWigdets.dart';

class LeadershipTableWidget extends StatelessWidget {
  final List<Member> memberList;
  const LeadershipTableWidget({super.key, required this.memberList});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * numD25,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
              top: size.height * numD045,
              left: 0,
              child: profileImageWidget(
                  isLeader: false, size: size, member: memberList[1])),
          Positioned(
              left: size.width * numD32,
              bottom: 15,
              child: Image.asset(
                '${iconsPath}leader_circle.png',
                scale: 3,
              )),
          Positioned(
              left: size.width * numD28,
              top: 0,
              child: Image.asset(
                '${iconsPath}leader_triangle.png',
                scale: 2,
              )),
          Positioned(
              top: 15,
              left: 10,
              child: Image.asset(
                '${iconsPath}leader_rectangle.png',
                scale: 3,
              )),
          Positioned(
              top: size.height * numD02,
              right: 40,
              child: Image.asset(
                '${iconsPath}leader_star.png',
                scale: 3,
              )),
          Align(
              alignment: Alignment.topCenter,
              child: profileImageWidget(
                  isLeader: true, size: size, member: memberList[0])),
          Positioned(
              top: size.height * numD08,
              right: 0,
              child: profileImageWidget(
                  isLeader: false, size: size, member: memberList[2])),
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              "${iconsPath}leader_table_icon.png",
              color: Color.fromARGB(255, 234, 234, 234),
              fit: BoxFit.scaleDown,
            ),
          ),
        ],
      ),
    );
  }

  Widget profileImageWidget(
      {bool isLeader = false, required Size size, required Member member}) {
    print('member.totalEarnings====> ${member.totalEarnings}');
    print('member.userName====> ${member.userName}');
    print('member.avatar====> ${currencySymbol}');
    return SizedBox(
      height: size.height * numD18,
      width: size.width * numD34,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  formatCurrency(member.totalEarnings, currencySymbol),
                  style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD04,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Text(
                //   // formatCurrency(member.totalEarnings, currencySymbol),

                //   "$currencySymbol${member.totalEarnings}",
                //   style: commonTextStyle(
                //       size: size,
                //       fontSize: size.width * numD04,
                //       color: Colors.black,
                //       fontWeight: FontWeight.bold),
                // ),
                SizedBox(
                  height: size.height * numD005,
                ),
                Container(
                    padding: EdgeInsets.all(
                      size.width * numD01,
                    ),
                    height: size.width * numD24,
                    width: size.width * numD24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: avatarImageUrl + member.avatar,
                        errorWidget: (context, url, error) {
                          return Image.asset(
                            "${commonImagePath}rabbitLogo.png",
                            height: size.width * numD06,
                            width: size.width * numD06,
                          );
                        },
                        fit: BoxFit.cover,
                      ),
                    )),
                SizedBox(
                  height: size.height * numD005,
                ),
                Text(
                  member.userName,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
          if (isLeader)
            Positioned(
              left: -2,
              top: 20,
              child: Image.asset(
                "${iconsPath}leader_king.png",
                scale: 3.5,
              ),
            ),
        ],
      ),
    );
  }

  String formatCurrency(dynamic amount, String currencySymbol) {
    double value = double.tryParse(amount.toString()) ?? 0.0;

    String locale;
    switch (currencySymbol) {
      case '₹':
        locale = 'en_IN';
        break;
      case '\$':
        locale = 'en_US';
        break;
      case '£':
        locale = 'en_GB';
        break;
      case '€':
        locale = 'en_EU';
        break;
      default:
        locale = 'en_US';
    }

    final format =
        NumberFormat.currency(locale: locale, symbol: currencySymbol);
    return format.format(value);
  }
}
