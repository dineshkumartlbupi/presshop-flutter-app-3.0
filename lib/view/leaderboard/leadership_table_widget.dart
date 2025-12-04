import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/view/leaderboard/leaderboard_model.dart';
import '../../utils/CommonWigdets.dart';

class LeadershipTableWidget extends StatelessWidget {
  final List<Member> memberList;

  const LeadershipTableWidget({
    super.key,
    required this.memberList,
  });

  @override
  Widget build(BuildContext context) {
    print('👥 memberList count: ${memberList.length}');

    final activeList = memberList.isEmpty ? dummyMembers : memberList;

    final safeList = List<Member?>.generate(
      3,
      (index) => index < activeList.length ? activeList[index] : null,
    );

    Size size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height * numD25,
      width: double.infinity,
      child: Stack(
        children: [
          // LEFT (2nd place)
          Positioned(
            top: size.height * numD045,
            left: 0,
            child: profileImageWidget(
              isLeader: false,
              size: size,
              member: safeList[1],
            ),
          ),

          // Background shapes
          Positioned(
            left: size.width * numD32,
            bottom: 15,
            child: Image.asset('${iconsPath}leader_circle.png', scale: 3),
          ),
          Positioned(
            left: size.width * numD28,
            top: 0,
            child: Image.asset('${iconsPath}leader_triangle.png', scale: 2),
          ),
          Positioned(
            top: 15,
            left: 10,
            child: Image.asset('${iconsPath}leader_rectangle.png', scale: 3),
          ),
          Positioned(
            top: size.height * numD02,
            right: 40,
            child: Image.asset('${iconsPath}leader_star.png', scale: 3),
          ),

          // CENTER (1st place)
          Align(
            alignment: Alignment.topCenter,
            child: profileImageWidget(
              isLeader: true,
              size: size,
              member: safeList[0],
            ),
          ),

          // RIGHT (3rd place)
          Positioned(
            top: size.height * numD08,
            right: 0,
            child: profileImageWidget(
              isLeader: false,
              size: size,
              member: safeList[2],
            ),
          ),

          // Bottom table decoration
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              "${iconsPath}leader_table_icon.png",
              color: const Color.fromARGB(255, 234, 234, 234),
              fit: BoxFit.scaleDown,
            ),
          ),
        ],
      ),
    );
  }

  Widget profileImageWidget({
    bool isLeader = false,
    required Size size,
    Member? member,
  }) {
    final hasData = member != null;
    final name = hasData ? member.userName : "--";
    final earnings = hasData ? member.totalEarnings : 0.0;
    final avatar = hasData ? member.avatar : "";

    print(
        '🧍 Member Debug -> Name: $name | Earnings: $earnings | Avatar: $avatar');

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
                  hasData
                      ? formatCurrency(earnings, currencySymbol)
                      : formatCurrency(0, currencySymbol),
                  style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD04,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * numD005),
                Container(
                  padding: EdgeInsets.all(size.width * numD01),
                  height: size.width * numD24,
                  width: size.width * numD24,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    clipBehavior: Clip.antiAlias,
                    child: hasData && avatar.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: avatarImageUrl + avatar,
                            errorWidget: (context, url, error) {
                              return Image.asset(
                                "${commonImagePath}rabbitLogo.png",
                                height: size.width * numD06,
                                width: size.width * numD06,
                              );
                            },
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "${commonImagePath}rabbitLogo.png",
                            height: size.width * numD06,
                            width: size.width * numD06,
                          ),
                  ),
                ),
                SizedBox(height: size.height * numD005),
                Text(
                  name,
                  style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Crown for leader
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

// ✅ Dummy members for testing
final dummyMembers = [
  Member(
    id: "1",
    userName: "Alice",
    country: "India",
    createdAt: DateTime.now(),
    totalEarnings: "1234.56",
    avatar: "",
  ),
  Member(
    id: "2",
    userName: "Bob",
    country: "USA",
    createdAt: DateTime.now(),
    totalEarnings: "987.00",
    avatar: "",
  ),
  Member(
    id: "3",
    userName: "Charlie",
    country: "UK",
    createdAt: DateTime.now(),
    totalEarnings: "789.50",
    avatar: "",
  ),
];
