import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/utils/extensions.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:presshop/core/core_export.dart';
import '../bloc/leaderboard_bloc.dart';
import '../bloc/leaderboard_event.dart';
import '../bloc/leaderboard_state.dart';
import '../widgets/leadership_table_widget.dart';
import 'package:presshop/features/leaderboard/domain/entities/leaderboard_entity.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LeaderboardBloc>()..add(const GetLeaderboard("global")),
      child: const LeaderboardView(),
    );
  }
}

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  late Size size;
  String selectedCountryCode = "global";
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Pagination could be added here
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String getFormattedDate(DateTime dateTime) {
    try {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return "${months[dateTime.month - 1]} ${dateTime.year}";
    } catch (e) {
      return dateTime.toString();
    }
  }

  String formatCurrency(dynamic amount, String currencySymbol) {
    double value = double.tryParse(amount.toString()) ?? 0.0;
    String locale;
    switch (currencySymbol) {
      case '₹': locale = 'en_IN'; break;
      case '\$': locale = 'en_US'; break;
      case '£': locale = 'en_GB'; break;
      case '€': locale = 'en_EU'; break;
      default: locale = 'en_US';
    }
    return NumberFormat.currency(locale: locale, symbol: currencySymbol).format(value);
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
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          if (state is LeaderboardLoading) {
             return const Center(child: CircularProgressIndicator());
          } else if (state is LeaderboardError) {
             return Center(child: Text(state.message));
          } else if (state is LeaderboardLoaded) {
             return _buildBody(state.leaderboard);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(LeaderboardEntity leaderboard) {
     return Padding(
        padding: EdgeInsets.all(size.width * numD04),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: size.width * numD10,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: leaderboard.countryList.length,
                itemBuilder: (context, index) {
                  var countryItem = leaderboard.countryList[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCountryCode = countryItem.countryCode;
                      });
                      context.read<LeaderboardBloc>().add(GetLeaderboard(selectedCountryCode));
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: size.width * numD03),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD03,
                          vertical: size.width * numD015),
                      decoration: BoxDecoration(
                        color: selectedCountryCode == countryItem.countryCode
                            ? colorThemePink
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(size.width * numD02),
                      ),
                      child: Center(
                        child: Text(countryItem.country,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: selectedCountryCode == countryItem.countryCode
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  );
                },
              ),
            ),
             if (leaderboard.memberList.isEmpty) ...[
                Padding(
                  padding: EdgeInsets.only(top: size.height * numD30),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "No Member available in this Country",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              ] else ...[
                 SizedBox(height: size.height * numD04),
                 LeadershipTableWidget(
                    memberList: leaderboard.memberList.take(3).toList(),
                 ),
                 SizedBox(height: size.height * numD04),
                 Text(
                    '${leaderboard.totalMember} total earning members',
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w500)),
                 Divider(
                    height: size.height * numD02,
                    thickness: 0.5,
                    color: Colors.black,
                 ),
                 Expanded(
                   child: ListView.builder(
                     controller: _scrollController,
                     itemCount: leaderboard.memberList.length,
                     itemBuilder: (context, index) {
                       var memberItem = leaderboard.memberList[index];
                       return Padding(
                         padding: EdgeInsets.only(bottom: size.height * numD02),
                         child: Row(
                           children: [
                             Container(
                                 padding: EdgeInsets.all(
                                   size.width * numD01,
                                 ),
                                 height: size.width * numD15,
                                 width: size.width * numD15,
                                 child: ClipOval(
                                   clipBehavior: Clip.antiAlias,
                                   child: CachedNetworkImage(
                                     imageUrl: avatarImageUrl + memberItem.avatar,
                                     errorWidget: (context, url, error) {
                                       return Image.asset(
                                         "${commonImagePath}rabbitLogo.png",
                                         height: size.width * numD06,
                                         width: size.width * numD06,
                                         fit: BoxFit.cover,
                                       );
                                     },
                                     fit: BoxFit.cover,
                                   ),
                                 )),
                             SizedBox(width: size.width * numD03),
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(
                                   memberItem.userName.toTitleCase(),
                                   style: commonTextStyle(
                                       size: size,
                                       fontSize: size.width * numD04,
                                       color: Colors.black,
                                       fontWeight: FontWeight.w500),
                                 ),
                                 SizedBox(height: size.height * numD005),
                                 Text(
                                   "Hopper since ${getFormattedDate(memberItem.createdAt)}",
                                   style: commonTextStyle(
                                       size: size,
                                       fontSize: size.width * numD032,
                                       color: Colors.grey,
                                       fontWeight: FontWeight.w400),
                                 ),
                               ],
                             ),
                             Spacer(),
                             Text(
                               formatCurrency(memberItem.totalEarnings, currencySymbol),
                               style: commonTextStyle(
                                   size: size,
                                   fontSize: size.width * numD04,
                                   color: Colors.black,
                                   fontWeight: FontWeight.bold),
                             )
                           ],
                         ),
                       );
                     },
                   ),
                 ),
              ]
          ],
        ),
     );
  }
}
