import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';

import '../../utils/CommonWigdets.dart';

class LeadershipTableWidget extends StatelessWidget {
  const LeadershipTableWidget({super.key});

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
              child: ProfileImageWidget(size: size)),
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
              top: 20,
              left: 10,
              child: Image.asset(
                '${iconsPath}leader_rectangle.png',
                scale: 2,
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
            child: ProfileImageWidget(isLeader: true, size: size),
          ),
          Positioned(
              top: size.height * numD08,
              right: 0,
              child: ProfileImageWidget(size: size)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              "${iconsPath}leader_table_icon.png",
              color: Color(0xFFF3F5F4),
              fit: BoxFit.scaleDown,
            ),
          ),
        ],
      ),
    );
  }

  Widget ProfileImageWidget({bool isLeader = false, required Size size}) {
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
                  "\$100",
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD04,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
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
                      child: Image.network(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZpsXXKBYFCxvA8z2LAdRyohI_5VJd5lk0eQ&s",
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
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
                  "Sakil",
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
              left: 0,
              top: 20,
              child: Image.asset(
                "${iconsPath}leader_king.png",
                scale: 3,
              ),
            ),
        ],
      ),
    );
  }
}
