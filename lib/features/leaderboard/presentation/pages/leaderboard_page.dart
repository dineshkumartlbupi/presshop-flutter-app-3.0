import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets_new.dart';
import 'package:presshop/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/leaderboard_bloc.dart';
import '../bloc/leaderboard_event.dart';
import '../bloc/leaderboard_state.dart';
import '../widgets/leadership_table_widget.dart';
import 'package:presshop/features/leaderboard/domain/entities/leaderboard_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:geocoding/geocoding.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  Future<String> _getInitialCountry() async {
    final prefs = sl<SharedPreferences>();
    String code = prefs.getString(SharedPreferencesKeys.countryCodeKey) ?? "";

    if (code.isEmpty) {
      try {
        final lat = prefs.getString(SharedPreferencesKeys.latitudeKey);
        final lon = prefs.getString(SharedPreferencesKeys.longitudeKey);

        if (lat != null && lat.isNotEmpty && lon != null && lon.isNotEmpty) {
          List<Placemark> placemarks = await placemarkFromCoordinates(
              double.parse(lat), double.parse(lon));
          if (placemarks.isNotEmpty) {
            final targetCountry = placemarks.first.country;
            final targetIso = placemarks.first.isoCountryCode;

            if (targetIso != null) code = targetIso.toLowerCase();
          }
        }
      } catch (e) {
        debugPrint("Error in _getInitialCountry: $e");
      }
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialCountry(),
      builder: (context, snapshot) {
        // While determining country, show a loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: CommonBrandedAppBar(
              title: "Leaderboard",
              size: MediaQuery.of(context).size,
              showLogo: true,
            ),
            body: Center(
                child: CommonWidgetsNew.showAnimatedLoader(
                    MediaQuery.of(context).size)),
          );
        }

        final initialCode = snapshot.data ?? "";
        return BlocProvider(
          create: (context) =>
              sl<LeaderboardBloc>()..add(GetLeaderboard(initialCode)),
          child: LeaderboardView(initialCode: initialCode),
        );
      },
    );
  }
}

class LeaderboardView extends StatefulWidget {
  final String initialCode;
  const LeaderboardView({super.key, this.initialCode = ""});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  late Size size;
  String selectedCountryCode = "";
  final ScrollController _scrollController = ScrollController();
  bool _isFirstLoad = true;
  LeaderboardEntity? _cachedLeaderboard;

  @override
  void initState() {
    super.initState();
    selectedCountryCode = widget.initialCode;
    if (selectedCountryCode.isEmpty) {
      selectedCountryCode = sl<SharedPreferences>()
              .getString(SharedPreferencesKeys.countryCodeKey) ??
          "";
    }
    // Set first load to true if we don't have a saved code,
    // or if we want to re-verify against the server list (safer)
    _isFirstLoad = true;
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

  bool showOverlayLoader = false;
  String getFormattedDate(DateTime dateTime) {
    try {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
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
    return NumberFormat.currency(locale: locale, symbol: currencySymbol)
        .format(value);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CommonBrandedAppBar(
        title: 'Leaderboard',
        size: size,
        showLogo: true,
      ),
      body: BlocConsumer<LeaderboardBloc, LeaderboardState>(
        listener: (context, state) async {
          if (state is LeaderboardLoaded && _isFirstLoad) {
            _isFirstLoad = false;
            final prefs = sl<SharedPreferences>();
            String? targetCountry;

            try {
              final lat = prefs.getString(SharedPreferencesKeys.latitudeKey);
              final lon = prefs.getString(SharedPreferencesKeys.longitudeKey);

              if (lat != null &&
                  lat.isNotEmpty &&
                  lon != null &&
                  lon.isNotEmpty) {
                List<Placemark> placemarks = await placemarkFromCoordinates(
                    double.parse(lat), double.parse(lon));
                if (placemarks.isNotEmpty) {
                  targetCountry = placemarks.first.country;
                }
              }
            } catch (e) {
              debugPrint("Error getting country from lat/long: $e");
            }

            if (targetCountry == null || targetCountry.isEmpty) {
              targetCountry =
                  prefs.getString(SharedPreferencesKeys.countryKey) ?? "";
            }

            if (targetCountry != null && targetCountry!.isNotEmpty) {
              final countryIndex = state.leaderboard.countryList.indexWhere(
                  (c) =>
                      c.country.toLowerCase() == targetCountry!.toLowerCase() ||
                      c.countryCode.toLowerCase() ==
                          targetCountry!.toLowerCase());

              if (countryIndex != -1) {
                var countryItem = state.leaderboard.countryList[countryIndex];
                if (selectedCountryCode != countryItem.countryCode) {
                  setState(() {
                    selectedCountryCode = countryItem.countryCode;
                  });
                  prefs.setString(SharedPreferencesKeys.countryCodeKey,
                      selectedCountryCode);
                  context
                      .read<LeaderboardBloc>()
                      .add(GetLeaderboard(selectedCountryCode));
                }
              }
            }
          }
        },
        builder: (context, state) {
          if (state is LeaderboardLoaded) {
            _cachedLeaderboard = state.leaderboard;
          }

          final bool showMainLoader = _cachedLeaderboard == null &&
              (state is LeaderboardLoading || state is LeaderboardInitial);
          showOverlayLoader =
              _cachedLeaderboard != null && state is LeaderboardLoading;

          if (showOverlayLoader) {
            return Container(
              color: Colors.white.withOpacity(0.5),
              child: Center(
                child: CommonWidgetsNew.showAnimatedLoader(size),
              ),
            );
          }

          return Stack(
            children: [
              if (_cachedLeaderboard != null) _buildBody(_cachedLeaderboard!),
              if (showMainLoader)
                Center(
                    child: Center(
                        child: CommonWidgetsNew.showAnimatedLoader(size))),
              if (_cachedLeaderboard == null && state is LeaderboardError)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        height: size.width * 0.2,
                        width: size.width * 0.2,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      SizedBox(height: size.width * AppDimensions.numD04),
                      Text(
                        "Oops! Failed to load leaderboard",
                        style: commonTextStyle(
                          color: Colors.black,
                          size: size,
                          fontSize: size.width * AppDimensions.numD045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.width * AppDimensions.numD02),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD10),
                        child: Text(
                          "We're having trouble connecting to the server. Please check your connection and try again.",
                          textAlign: TextAlign.center,
                          style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: size.width * AppDimensions.numD06),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<LeaderboardBloc>()
                              .add(const GetLeaderboard(""));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorTheme.colorThemePink,
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD08,
                            vertical: size.width * AppDimensions.numD03,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                size.width * AppDimensions.numD02),
                          ),
                        ),
                        child: Text(
                          "Try Again",
                          style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(LeaderboardEntity leaderboard) {
    return Padding(
      padding: EdgeInsets.all(size.width * AppDimensions.numD04),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: size.width * AppDimensions.numD10,
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
                    context
                        .read<LeaderboardBloc>()
                        .add(GetLeaderboard(selectedCountryCode));
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                        right: size.width * AppDimensions.numD03),
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * AppDimensions.numD03,
                        vertical: size.width * AppDimensions.numD015),
                    decoration: BoxDecoration(
                      color: (selectedCountryCode.toLowerCase() ==
                                  countryItem.countryCode.toLowerCase() ||
                              (selectedCountryCode == "" &&
                                  countryItem.country == "Global"))
                          ? AppColorTheme.colorThemePink
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD02),
                    ),
                    child: Center(
                      child: Text(countryItem.country,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD035,
                              color: (selectedCountryCode.toLowerCase() ==
                                          countryItem.countryCode
                                              .toLowerCase() ||
                                      (selectedCountryCode == "" &&
                                          countryItem.country == "Global"))
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leaderboard.memberList.isEmpty) ...[
                  Padding(
                    padding: EdgeInsets.only(
                        top: size.height * AppDimensions.numD30),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "No Member available in this Country",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                ] else ...[
                  SizedBox(height: size.height * AppDimensions.numD04),
                  LeadershipTableWidget(
                    memberList: leaderboard.memberList.take(3).toList(),
                    currencySymbol: leaderboard.currencySymbol,
                  ),
                  SizedBox(height: size.height * AppDimensions.numD04),
                  Text(
                    '${leaderboard.totalMember} total earning ${leaderboard.totalMember == '1' ? 'member' : 'members'}',
                    style: commonTextStyle(
                      size: size,
                      fontSize: size.width * AppDimensions.numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Divider(
                    height: size.height * AppDimensions.numD02,
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
                          padding: EdgeInsets.only(
                              bottom: size.height * AppDimensions.numD02),
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(
                                    size.width * AppDimensions.numD01,
                                  ),
                                  height: size.width * AppDimensions.numD15,
                                  width: size.width * AppDimensions.numD15,
                                  child: ClipOval(
                                    clipBehavior: Clip.antiAlias,
                                    child: CachedNetworkImage(
                                      imageUrl: memberItem.avatar,
                                      errorWidget: (context, url, error) {
                                        return Image.asset(
                                          "${commonImagePath}rabbitLogo.png",
                                          height:
                                              size.width * AppDimensions.numD06,
                                          width:
                                              size.width * AppDimensions.numD06,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                              SizedBox(
                                  width: size.width * AppDimensions.numD03),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    memberItem.userName.toTitleCase(),
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD04,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                      height:
                                          size.height * AppDimensions.numD005),
                                  Text(
                                    "Hopper since ${getFormattedDate(memberItem.createdAt)}",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD032,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Text(
                                formatCurrency(
                                    memberItem.totalEarnings,
                                    leaderboard.currencySymbol.isNotEmpty
                                        ? leaderboard.currencySymbol
                                        : currencySymbol),
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * AppDimensions.numD04,
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
          ),
        ],
      ),
    );
  }
}
