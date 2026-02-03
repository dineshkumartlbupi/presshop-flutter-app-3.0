import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/account_settings/presentation/bloc/faq/faq_bloc.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FAQScreen extends StatefulWidget {
  final bool priceTipsSelected;
  final String type;
  final String benefits;
  final int index;

  const FAQScreen({
    super.key,
    required this.priceTipsSelected,
    required this.type,
    this.benefits = "",
    required this.index,
  });

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> with AnalyticsPageMixin {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late FAQBloc _bloc;
  final ScrollController _listController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc = sl<FAQBloc>();

    String? initialCategoryName;
    if (widget.priceTipsSelected) {
      // Logic for price tips (handled by bloc usually, looks for "price tips" category or just loads generic)
    } else {
      if (widget.benefits.isNotEmpty) {
        initialCategoryName = "PRO benefits";
      } else if (widget.index == 1) {
        initialCategoryName = "Emergency";
      }
    }

    _bloc.add(FAQLoadCategories(
      initialCategoryName: initialCategoryName,
      type: widget.type,
    ));
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _listController.dispose();
    _bloc.close(); // Close bloc since we created it
    super.dispose();
  }

  void _onRefresh() {
    _bloc.add(const FAQLoadData(isRefresh: true));
  }

  void _onLoading() {
    // Implement pagination if supported by Bloc.
    // For now, FAQLoadData resets/loads all (limit 1000 in bloc).
    // If pagination is needed, we need to update Bloc to support loading more.
    // Assuming current bloc loads all for now based on 'limit: 1000' in bloc.
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (_) => _bloc,
      child: Scaffold(
        appBar: CommonAppBar(
          elevation: 0,
          hideLeading: false,
          title: Text(
            widget.priceTipsSelected ? AppStrings.priceTipsText : AppStrings.faqText,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: size.width * AppDimensions.appBarHeadingFontSize),
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
                height: size.width * AppDimensions.numD07,
                width: size.width * AppDimensions.numD07,
              ),
            ),
            SizedBox(
              width: size.width * AppDimensions.numD04,
            )
          ],
        ),
        body: SafeArea(
          child: BlocConsumer<FAQBloc, FAQState>(
            listener: (context, state) {
              if (state.status == FAQStatus.success) {
                _refreshController.refreshCompleted();
                _refreshController.loadComplete();
              } else if (state.status == FAQStatus.failure) {
                _refreshController.refreshFailed();
                // Show error snackbar or dialog?
              }
            },
            builder: (context, state) {
              if (state.categories.isEmpty &&
                  state.status == FAQStatus.loading) {
                return const SizedBox.shrink();
              }

              return SmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                enablePullUp: false, // Disabled pull up since bloc fetches 1000
                enablePullDown: true,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD04,
                            vertical: size.width * AppDimensions.numD03),
                        child: TextFormField(
                            decoration: InputDecoration(
                              hintText: AppStrings.searchText,
                              filled: true,
                              fillColor: AppColorTheme.colorLightGrey,
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * AppDimensions.numD035),
                              disabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.03),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  )),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.03),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  )),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.03),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  )),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.03),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  )),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.03),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  )),
                              suffixIcon: Padding(
                                padding:
                                    EdgeInsets.only(right: size.width * AppDimensions.numD04),
                                child: const ImageIcon(
                                  AssetImage("${iconsPath}ic_search.png"),
                                  color: Colors.black,
                                ),
                              ),
                              suffixIconColor: Colors.black,
                              suffixIconConstraints: BoxConstraints(
                                  maxHeight: size.width * AppDimensions.numD07),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: size.width * AppDimensions.numD04,
                                  vertical: size.width * AppDimensions.numD015),
                            ),
                            onChanged: (value) {
                              _bloc.add(FAQSearch(value));
                            }),
                      ),
                      state.categories.isEmpty
                          ? Center(
                              child: errorMessageWidget("No Category found"))
                          : Container(
                              height: size.width * AppDimensions.numD15,
                              margin:
                                  EdgeInsets.only(left: size.width * AppDimensions.numD035),
                              child: ListView.separated(
                                  controller: _listController,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    final category = state.categories[index];
                                    return InkWell(
                                      onTap: () {
                                        _bloc.add(FAQSelectCategory(index));
                                        _listController.animateTo(index * 100.0,
                                            duration: const Duration(
                                                milliseconds: 200),
                                            curve: Curves.ease);
                                      },
                                      child: Chip(
                                        backgroundColor: category.selected
                                            ? Colors.black
                                            : AppColorTheme.colorLightGrey,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width * AppDimensions.numD025,
                                            vertical: size.width * AppDimensions.numD02),
                                        label: Text(
                                          category.name.toTitleCase(),
                                          style: TextStyle(
                                              color: category.selected
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontFamily: "AirbnbCereal",
                                              fontSize: size.width * AppDimensions.numD036,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return SizedBox(
                                      width: size.width * AppDimensions.numD04,
                                    );
                                  },
                                  itemCount: state.categories.length),
                            ),
                      state.items.isNotEmpty
                          ? ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * AppDimensions.numD035),
                              itemBuilder: (context, index) {
                                var item = state.items[index];
                                return Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD02),
                                      border: Border.all(
                                          color: Colors.grey.shade300)),
                                  child: ExpansionTile(
                                    title: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: size.width * AppDimensions.numD01),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: size.width * AppDimensions.numD02,
                                              vertical: size.width * AppDimensions.numD01),
                                          decoration: BoxDecoration(
                                              color: AppColorTheme.colorThemePink,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * AppDimensions.numD01)),
                                          child: Text(
                                            "Q",
                                            style: TextStyle(
                                                fontSize: size.width * AppDimensions.numD036,
                                                color: Colors.white,
                                                fontFamily: "AirbnbCereal",
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * AppDimensions.numD02,
                                        ),
                                        Expanded(
                                            child: Text(
                                          item.question,
                                          style: TextStyle(
                                              fontSize: size.width * AppDimensions.numD035,
                                              color: Colors.black,
                                              fontFamily: "AirbnbCereal",
                                              fontWeight: FontWeight.bold),
                                        ))
                                      ],
                                    ),
                                    iconColor: Colors.black,
                                    onExpansionChanged: (value) {
                                      _bloc.add(FAQToggleItem(index));
                                    },
                                    initiallyExpanded: item.selected,
                                    children: [
                                      Container(
                                        height: 1,
                                        margin: EdgeInsets.only(
                                            bottom: size.width * AppDimensions.numD04,
                                            left: size.width * AppDimensions.numD04,
                                            right: size.width * AppDimensions.numD04),
                                        width: size.width,
                                        color: Colors.grey.shade300,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width * AppDimensions.numD04),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: size.width * AppDimensions.numD01),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      size.width * AppDimensions.numD02,
                                                  vertical:
                                                      size.width * AppDimensions.numD01),
                                              decoration: BoxDecoration(
                                                  color: AppColorTheme.colorThemePink,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width * AppDimensions.numD01)),
                                              child: Text(
                                                "A",
                                                style: TextStyle(
                                                    fontSize:
                                                        size.width * AppDimensions.numD035,
                                                    color: Colors.white,
                                                    fontFamily: "AirbnbCereal",
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width * AppDimensions.numD02,
                                            ),
                                            Expanded(
                                              child: Text(
                                                item.answer,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: "AirbnbCereal",
                                                    fontSize:
                                                        size.width * AppDimensions.numD035),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.width * AppDimensions.numD04,
                                      )
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  height: size.width * AppDimensions.numD04,
                                );
                              },
                              itemCount: state.items.length)
                          : state.status == FAQStatus.loading
                              ? const SizedBox.shrink()
                              : errorMessageWidget(widget.priceTipsSelected
                                  ? "No Price Tips Found"
                                  : "No FAQ found"),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  String get pageName => PageNames.faq;
}
