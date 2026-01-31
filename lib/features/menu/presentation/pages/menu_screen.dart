import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/features/authentication/presentation/pages/LoginScreen.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:presshop/features/menu/presentation/pages/menu_config.dart';
import 'package:presshop/features/menu/presentation/bloc/menu_ui_cubit.dart';
import 'package:presshop/features/menu/presentation/widgets/currency_selector_sheet.dart';
import 'package:presshop/core/extensions/context_extensions.dart';

class MenuScreen extends StatelessWidget {
  MenuScreen({super.key});

  final List<MenuData> menuList = buildMenu();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => sl<MenuBloc>()..add(MenuLoadCounts())),
        BlocProvider(create: (context) => MenuUiCubit()),
      ],
      child: AnalyticsWrapper(
        pageName: PageNames.menu,
        parameters: const {'page': 'menu_screen'},
        child: BlocListener<MenuBloc, MenuState>(
          listener: (context, state) {
            if (state.logoutStatus == MenuLogoutStatus.success) {
              _navigateToLogin(context);
            } else if (state.logoutStatus == MenuLogoutStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? "Logout failed")),
              );
            }
          },
          child: Builder(builder: (context) => _buildContent(context)),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false);
  }

  void _onMenuTap(BuildContext context, MenuData item) {
    switch (item.action) {
      case MenuAction.logout:
        logoutDialog(context.mqSize, context);
        break;
      case MenuAction.currency:
        _showCurrencyBottomSheet(context);
        break;
      default:
        if (item.page != null) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => item.page!))
              .then((value) {
            context.read<MenuBloc>().add(MenuLoadCounts());
          });
        }
    }
  }

  Widget _buildContent(BuildContext context) {
    final size = context.mqSize;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          menuText,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * appBarHeadingFontSize),
        ),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: false,
        leadingFxn: () => Navigator.pop(context),
        actionWidget: [],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * numD06, vertical: size.width * numD02),
          itemCount: menuList.length,
          separatorBuilder: (context, index) => const Divider(
            thickness: 2,
            color: colorLightGrey,
          ),
          itemBuilder: (context, index) {
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
        builder: (BuildContext dialogContext) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              insetPadding:
                  EdgeInsets.symmetric(horizontal: size.width * numD04),
              content: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size.width * numD045)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: size.width * numD04),
                      child: Row(
                        children: [
                          Text(
                            youWIllBeMissedText,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * numD05,
                                fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              icon: Icon(
                                Icons.close,
                                color: Colors.black,
                                size: size.width * numD06,
                              ))
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * numD04),
                      child: const Divider(
                        color: Colors.black,
                        thickness: 0.5,
                      ),
                    ),
                    SizedBox(height: size.width * numD02),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * numD04),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                                border: Border.all(color: Colors.black)),
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                                child: Image.asset(
                                  "assets/rabbits/logout_rabbit.png",
                                  height: size.width * numD30,
                                  width: size.width * numD35,
                                  fit: BoxFit.cover,
                                )),
                          ),
                          SizedBox(width: size.width * numD04),
                          Expanded(
                            child: Text(
                              logoutMessageText,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD035,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.width * numD02),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD04,
                          vertical: size.width * numD04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                              child: SizedBox(
                            height: size.width * numD12,
                            child: commonElevatedButton(
                                logoutText,
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, Colors.black), () {
                              Navigator.pop(dialogContext);
                              menuBloc.add(MenuLogoutRequested());
                            }),
                          )),
                          SizedBox(width: size.width * numD04),
                          Expanded(
                              child: SizedBox(
                            height: size.width * numD12,
                            child: commonElevatedButton(
                                stayLoggedInText,
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, colorThemePink),
                                () => Navigator.pop(dialogContext)),
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
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

class MenuTile extends StatelessWidget {
  final MenuData item;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = context.mqSize;
    final isNotification = item.action == MenuAction.notification;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical:
                isNotification ? size.width * numD01 : size.width * numD02),
        child: Row(
          children: [
            if (isNotification)
              const NotificationBadge()
            else
              _buildIcon(context),
            SizedBox(
              width:
                  isNotification ? size.width * numD015 : size.width * numD03,
            ),
            Expanded(
              child: _buildTitle(context),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.black,
              size: size.width * numD04,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final size = context.mqSize;
    // Original logic for "Alerts" and "Choose currency" size
    final isSpecialSize =
        item.showAlertBadge || item.action == MenuAction.currency;
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ImageIcon(
          AssetImage(item.icon),
          size: isSpecialSize ? size.width * numD072 : size.width * numD06,
          color: Colors.black,
        ),
        if (item.showAlertBadge)
          BlocSelector<MenuBloc, MenuState, int>(
            selector: (state) => state.alertCount,
            builder: (context, count) {
              if (count == 0) return const SizedBox.shrink();
              return Container(
                margin: EdgeInsets.only(top: size.width * numD004),
                child: CircleAvatar(
                  backgroundColor: colorThemePink,
                  radius: size.width * numD016,
                  child: FittedBox(
                    child: Padding(
                      padding: EdgeInsets.all(size.width * numD004),
                      child: Text(
                        "$count",
                        style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD019,
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
              fontSize: size.width * numD035,
              color: Colors.black,
              fontFamily: "AirbnbCereal",
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            "Hop",
            style: TextStyle(
              fontSize: size.width * numD035,
              color: Colors.black,
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
        fontSize: size.width * numD035,
        color: Colors.black,
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
          width: size.width * numD075,
          height: size.width * numD075,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                height: size.width * numD06,
                width: size.width * numD06,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.2),
                  borderRadius: BorderRadius.circular(size.width * numD015),
                ),
              ),
              if (count > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(size.width * 0.002),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          Icons.circle,
                          color: colorThemePink,
                          size: size.width * numD04,
                        ),
                      ),
                      Text(
                        count.toString(),
                        style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD025,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      )
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
