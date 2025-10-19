import 'package:flutter/material.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/view/leaderboard/leadership_table_widget.dart';

import '../../utils/Common.dart';
import '../../utils/CommonWigdets.dart';
import '../dashboard/Dashboard.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<StatefulWidget> createState() => LeaderboardScreenState();
}

class LeaderboardScreenState extends State<LeaderboardScreen> {
  late Size size;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // User has scrolled to the bottom, trigger pagination
      // _loadMoreData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          "Leaderboard",
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
          Navigator.pop(context);
        },
        actionWidget: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => Dashboard(initialPosition: 2)),
                  (route) => false);
            },
            child: Image.asset(
              "${commonImagePath}rabbitLogo.png",
              height: size.width * numD07,
              width: size.width * numD07,
            ),
          ),
          SizedBox(
            width: size.width * numD02,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * numD04),
        child: Column(
          children: [LeadershipTableWidget()],
        ),
      ),
    );
  }
}
