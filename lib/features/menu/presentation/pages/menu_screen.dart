import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/extensions/context_extensions.dart';
import 'package:presshop/core/services/background_location_service.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';

import 'package:presshop/core/di/injection_container.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:presshop/core/widgets/dialogs.dart';
import 'package:presshop/core/widgets/logo_widget.dart';
import 'package:presshop/core/widgets/new_home_app_bar.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:presshop/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:presshop/features/menu/presentation/pages/menu_config.dart';
import 'package:presshop/features/menu/presentation/bloc/menu_ui_cubit.dart';
import 'package:presshop/features/menu/presentation/widgets/currency_selector_sheet.dart';
import 'package:presshop/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:presshop/features/profile/presentation/bloc/profile_event.dart';
import 'package:presshop/core/theme/bloc/theme_bloc.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late final List<MenuData> menuList;
  late final MenuBloc _menuBloc;
  late final MenuUiCubit _uiCubit;

  @override
  void initState() {
    super.initState();
    BackgroundLocationService.syncRunningStatus();
    menuList = buildMenu();
    _menuBloc = sl<MenuBloc>()..add(MenuLoadCounts());
    _uiCubit = MenuUiCubit();
    // Silent pre-load profile data
    sl<ProfileBloc>().add(const FetchProfileEvent(showLoader: false));
  }

  @override
  void dispose() {
    _menuBloc.close();
    _uiCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _menuBloc),
        BlocProvider.value(value: _uiCubit),
      ],
      child: AnalyticsWrapper(
        pageName: PageNames.menu,
        parameters: const {'page': 'menu_screen'},
        child: BlocListener<MenuBloc, MenuState>(
          bloc: _menuBloc,
          listener: (context, state) {
            if (state.logoutStatus == MenuLogoutStatus.success) {
              _navigateToLogin(context);
            } else if (state.logoutStatus == MenuLogoutStatus.failure) {
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text(state.errorMessage ?? "Logout failed")),
              // );
            }
          },
          child: Builder(builder: (context) => _buildContent(context)),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    context.goNamed(AppRoutes.loginName);
  }

  void _onMenuTap(BuildContext context, MenuData item) {
    switch (item.action) {
      case MenuAction.logout:
        AppLogger.trackAction(ActionNames.logout);
        logoutDialog(context.mqSize, context);
        break;

      case MenuAction.notification:
        context.pushNamed(
          AppRoutes.notificationsName,
          extra: {'count': 0},
        ).then((value) {
          // ignore: use_build_context_synchronously
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.digitalId:
        context.pushNamed(AppRoutes.digitalIdName).then((value) {
          // ignore: use_build_context_synchronously
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.myProfile:
        context.pushNamed(
          AppRoutes.profileName,
          extra: {
            'editProfileScreen': false,
            'screenType': AppStrings.myProfileText,
          },
        ).then((value) {
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.editProfile:
        context.pushNamed(
          AppRoutes.profileName,
          extra: {
            'editProfileScreen': true,
            'screenType': AppStrings.editProfileText,
          },
        ).then((value) {
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.paymentMethod:
        context.pushNamed(AppRoutes.bankName).then((value) {
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.accountDelete:
        context.pushNamed(AppRoutes.accountDeleteName).then((value) {
          // ignore: use_build_context_synchronously
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.changePassword:
        context.pushNamed(AppRoutes.changePasswordName).then((value) {
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.contact:
        context.pushNamed(AppRoutes.contactUsName).then((value) {
          // ignore: use_build_context_synchronously
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.faq:
        context.pushNamed(
          AppRoutes.faqName,
          extra: {
            'priceTipsSelected': false,
            'type': 'faq',
            'index': 0,
          },
        ).then((value) {
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.priceTips:
        context.pushNamed(
          AppRoutes.faqName,
          extra: {
            'priceTipsSelected': true,
            'type': 'price_tips',
            'index': 0,
          },
        ).then((value) {
          // ignore: use_build_context_synchronously
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.legal:
        context.pushNamed(
          AppRoutes.termName,
          extra: {'type': 'legal'},
        ).then((value) {
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.privacy:
        context.pushNamed(
          AppRoutes.termName,
          extra: {'type': 'privacy_policy'},
        ).then((value) {
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.currency:
        _showCurrencyBottomSheet(context);
        break;
      case MenuAction.chat:
        context.pushNamed(AppRoutes.chatBotName).then((value) {
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.leaderboard:
        context.pushNamed(AppRoutes.leaderboardName).then((value) {
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.myDrafts:
        context.pushNamed(
          AppRoutes.myDraftName,
          extra: {'publishedContent': false, 'screenType': ''},
        ).then((value) {
          // ignore: use_build_context_synchronously
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.myContent:
        context.pushNamed(AppRoutes.myContentName).then((value) {
          // ignore: use_build_context_synchronously
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.feed:
        context.pushNamed(AppRoutes.feedName).then((value) {
          // ignore: use_build_context_synchronously
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.myTasks:
        context.pushNamed(
          AppRoutes.myTasksName,
          extra: {'hideLeading': false},
        ).then((value) {
          // ignore: use_build_context_synchronously
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.myEarnings:
        context.pushNamed(
          AppRoutes.myEarningName,
          extra: {'openDashboard': false, 'initialTapPosition': 0},
        ).then((value) {
          // ignore: use_build_context_synchronously
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;

      case MenuAction.ratingReview:
        context.pushNamed(AppRoutes.ratingReviewName).then((value) {
          // ignore: use_build_context_synchronously
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.referHopper:
        context.pushNamed(AppRoutes.referName).then((value) {
          // ignore: use_build_context_synchronously
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.uploadDocs:
        context.pushNamed(
          AppRoutes.uploadDocumentsName,
          extra: {'menuScreen': true, 'hideLeading': false},
        ).then((value) {
          // ignore: use_build_context_synchronously
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.tutorials:
        context.pushNamed(AppRoutes.tutorialsName).then((value) {
          // ignore: use_build_context_synchronously
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
      case MenuAction.locationSharing:
        context.pushNamed(AppRoutes.locationSharingName).then((value) {
          // ignore: use_build_context_synchronously
          context.read<MenuBloc>().add(MenuLoadCounts());
        });
        break;
    }
  }

  Widget _buildContent(BuildContext context) {
    final size = context.mqSize;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: Center(
          child: InkWell(
            onTap: () {
              print('click------------------------>');
              try {
                context
                    .read<DashboardBloc>()
                    .add(const ChangeDashboardTabEvent(2));
              } catch (e) {
                context.goNamed(AppRoutes.dashboardName,
                    extra: {'initialPosition': 2});
              }
            },
            child: Padding(
              padding: EdgeInsets.only(
                  left: size.width * AppDimensions.numD01,
                  bottom: size.width * AppDimensions.numD01),
              child: LogoWidget.buildLogo(size),
            ),
          ),
        ),
      ),
      //  CommonAppBar(
      //   elevation: 0,
      //   hideLeading: false,
      //   title: Text(
      //     AppStrings.menuText,
      //     style: TextStyle(
      //         color: Colors.black,
      //         fontWeight: FontWeight.bold,
      //         fontSize: size.width * AppDimensions.appBarHeadingFontSize),
      //   ),
      //   centerTitle: false,
      //   titleSpacing: 0,
      //   size: size,
      //   showActions: false,
      //   leadingFxn: () => context.pop(),
      //   actionWidget: [],
      // ),

      body: SafeArea(
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.commonPaddingSize(size),
              vertical: size.width * AppDimensions.numD02),
          itemCount: menuList.length,
          separatorBuilder: (context, index) => const Divider(
            thickness: 2,
            color: AppColorTheme.colorLightGrey,
          ),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                children: [
                  // Theme Toggle
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: size.width * AppDimensions.numD02),
                    child: Row(
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          size: size.width * AppDimensions.numD06,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        SizedBox(
                          width: size.width * AppDimensions.numD03,
                        ),
                        Text(
                          "Dark Mode",
                          style: TextStyle(
                              fontSize: size.width * AppDimensions.numD035,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.normal),
                        ),
                        const Spacer(),
                        BlocBuilder<ThemeBloc, ThemeState>(
                          builder: (context, state) {
                            final isDark = state.themeMode == ThemeMode.dark;
                            return GestureDetector(
                              onTap: () {
                                context
                                    .read<ThemeBloc>()
                                    .add(ToggleThemeEvent());
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 60,
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: isDark
                                      ? Colors.blueGrey[800]
                                      : Colors.blue[100],
                                ),
                                child: Stack(
                                  children: [
                                    AnimatedPositioned(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      left: isDark ? 32 : 2,
                                      top: 2,
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: Icon(
                                          isDark
                                              ? Icons.nightlight_round
                                              : Icons.wb_sunny,
                                          size: 16,
                                          color: isDark
                                              ? Colors.blueGrey[800]
                                              : Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 2,
                    color: AppColorTheme.colorLightGrey,
                  ),
                  // Location Toggle
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: size.width * AppDimensions.numD02),
                    child: Row(
                      children: [
                        ImageIcon(
                          const AssetImage("assets/markers/location1.webp"),
                          size: size.width * AppDimensions.numD06,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        SizedBox(
                          width: size.width * AppDimensions.numD03,
                        ),
                        Text(
                          "Enable location",
                          style: TextStyle(
                              fontSize: size.width * AppDimensions.numD035,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.normal),
                        ),
                        const Spacer(),
                        ValueListenableBuilder<bool>(
                          valueListenable:
                              BackgroundLocationService.isRunningNotifier,
                          builder: (context, isRunning, child) {
                            return FlutterSwitch(
                              width: 55,
                              height: 27,
                              padding: 2,
                              value: isRunning,
                              inactiveColor: AppColorTheme.colorThemePink,
                              activeColor: Colors.green,
                              onToggle: (val) {
                                _toggleLocationService(val, size);
                              },
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ],
              );
            }

            final item = menuList[index];
            return MenuTile(
              item: item,
              onTap: () => _onMenuTap(context, item),
            );
          },
        ),
      ),
    );
  }

  void logoutDialog(Size size, BuildContext context) {
    final menuBloc = context.read<MenuBloc>();

    showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD04),
              content: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        size.width * AppDimensions.numD045)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: size.width * AppDimensions.numD04),
                      child: Row(
                        children: [
                          Text(
                            AppStrings.youWIllBeMissedText,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: size.width * AppDimensions.numD05,
                                fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                              onPressed: () => context.pop(),
                              icon: Icon(
                                Icons.close,
                                color: Theme.of(context).iconTheme.color,
                                size: size.width * AppDimensions.numD06,
                              ))
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD04),
                      child: Divider(
                        color: Theme.of(context).dividerColor,
                        thickness: 0.5,
                      ),
                    ),
                    SizedBox(height: size.width * AppDimensions.numD02),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD04),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD04),
                                border: Border.all(
                                    color: Theme.of(context).dividerColor)),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD04),
                                child: Image.asset(
                                  "assets/rabbits/logout_rabbit.png",
                                  height: size.width * AppDimensions.numD30,
                                  width: size.width * AppDimensions.numD35,
                                  fit: BoxFit.cover,
                                )),
                          ),
                          SizedBox(width: size.width * AppDimensions.numD04),
                          Expanded(
                            child: Text(
                              AppStrings.logoutMessageText,
                              softWrap: true,
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontSize: size.width * AppDimensions.numD035,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.width * AppDimensions.numD02),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD04,
                          vertical: size.width * AppDimensions.numD04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                              child: SizedBox(
                            height: size.width * AppDimensions.numD12,
                            child: commonElevatedButton(
                                AppStrings.logoutText,
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(
                                    size,
                                    Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color ??
                                        Colors.black), () {
                              context.pop();
                              menuBloc.add(MenuLogoutRequested());
                            }),
                          )),
                          SizedBox(width: size.width * AppDimensions.numD04),
                          Expanded(
                              child: SizedBox(
                            height: size.width * AppDimensions.numD12,
                            child: commonElevatedButton(
                                AppStrings.stayLoggedInText,
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(
                                    size, AppColorTheme.colorThemePink),
                                () => context.pop()),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
        });
  }

  void _showCurrencyBottomSheet(BuildContext context) {
    final uiCubit = context.read<MenuUiCubit>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (_) {
        return BlocBuilder<MenuUiCubit, MenuUiState>(
          bloc: uiCubit,
          builder: (context, uiState) {
            return CurrencySelectorSheet(
              selectedCurrency: uiState.currency,
              onSelected: (currency) {
                uiCubit.setCurrency(currency);
                context.pop();
              },
            );
          },
        );
      },
    );
  }

  void _toggleLocationService(bool value, Size size) async {
    if (value) {
      await BackgroundLocationService.initService(
        context: context,
        showPrePermissionDialog: true,
      );
    } else {
      AllDialogs.showStopServiceConfirmationNew(size);
      // await BackgroundLocationService.stopService();
    }
  }
}

class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.item,
    required this.onTap,
  });
  final MenuData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = context.mqSize;
    final isNotification = item.action == MenuAction.notification;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: isNotification
                ? size.width * AppDimensions.numD01
                : size.width * AppDimensions.numD02),
        child: Row(
          children: [
            if (isNotification)
              const NotificationBadge()
            else
              _buildIcon(context),
            SizedBox(
              width: isNotification
                  ? size.width * AppDimensions.numD015
                  : size.width * AppDimensions.numD03,
            ),
            Expanded(
              child: _buildTitle(context),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Theme.of(context).iconTheme.color,
              size: size.width * AppDimensions.numD04,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final size = context.mqSize;
    // Original logic for "Alerts" and "Choose currency" size
    final isSpecialSize = item.action == MenuAction.currency;
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ImageIcon(
          AssetImage(item.icon),
          size: isSpecialSize
              ? size.width * AppDimensions.numD072
              : size.width * AppDimensions.numD06,
          color: Theme.of(context).iconTheme.color,
        ),
        if (item.showAlertBadge)
          BlocSelector<MenuBloc, MenuState, int>(
            selector: (state) => state.alertCount,
            builder: (context, count) {
              if (count == 0) return const SizedBox.shrink();
              return Container(
                margin:
                    EdgeInsets.only(top: size.width * AppDimensions.numD004),
                child: CircleAvatar(
                  backgroundColor: AppColorTheme.colorThemePink,
                  radius: size.width * AppDimensions.numD016,
                  child: FittedBox(
                    child: Padding(
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD004),
                      child: Text(
                        "$count",
                        style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD019,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    final size = context.mqSize;
    if (item.isContactBrand) {
      return Row(
        children: [
          Text(
            "Contact Press",
            style: TextStyle(
              fontSize: size.width * AppDimensions.numD035,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: "AirbnbCereal",
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            "Hop",
            style: TextStyle(
              fontSize: size.width * AppDimensions.numD035,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              letterSpacing: 0,
              fontFamily: "AirbnbCereal",
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      );
    }
    return Text(
      item.title,
      style: TextStyle(
        fontSize: size.width * AppDimensions.numD035,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontFamily: "AirbnbCereal",
        fontWeight: FontWeight.normal,
      ),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final size = context.mqSize;
    return BlocSelector<MenuBloc, MenuState, int>(
      selector: (state) => state.notificationCount,
      builder: (context, count) {
        return SizedBox(
          width: size.width * AppDimensions.numD075,
          height: size.width * AppDimensions.numD075,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                height: size.width * AppDimensions.numD06,
                width: size.width * AppDimensions.numD06,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).dividerColor, width: 1.2),
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD015),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        padding: EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          count.toString(),
                          style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD025,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
