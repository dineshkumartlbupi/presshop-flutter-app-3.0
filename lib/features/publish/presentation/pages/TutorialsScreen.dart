import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/chat/presentation/pages/FullVideoView.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:presshop/features/publish/presentation/bloc/tutorials/tutorials_bloc.dart';
import 'package:presshop/core/di/injection_container.dart';

class TutorialsScreen extends StatefulWidget {
  const TutorialsScreen({super.key});

  @override
  State<TutorialsScreen> createState() => _TutorialsScreenState();
}

class _TutorialsScreenState extends State<TutorialsScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController listController = ScrollController();
  late TutorialsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<TutorialsBloc>()..add(TutorialsLoadCategories());
  }

  @override
  void dispose() {
    _refreshController.dispose();
    listController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onRefresh() {
    String currentCategory = "";
    if (_bloc.state.categories.isNotEmpty &&
        _bloc.state.selectedCategoryIndex < _bloc.state.categories.length) {
      currentCategory =
          _bloc.state.categories[_bloc.state.selectedCategoryIndex].name;
    }

    _bloc.add(TutorialsLoadVideos(category: currentCategory, isRefresh: true));
  }

  void _onLoading() {
    String currentCategory = "";
    if (_bloc.state.categories.isNotEmpty &&
        _bloc.state.selectedCategoryIndex < _bloc.state.categories.length) {
      currentCategory =
          _bloc.state.categories[_bloc.state.selectedCategoryIndex].name;
    }
    _bloc.add(TutorialsLoadVideos(category: currentCategory, isLoadMore: true));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (_) => _bloc,
      child: BlocConsumer<TutorialsBloc, TutorialsState>(
        listener: (context, state) {
          if (state.status == TutorialsStatus.failure) {
            showSnackBar("Error", state.errorMessage, Colors.red);
            _refreshController.refreshFailed();
            _refreshController.loadFailed();
          } else if (state.status == TutorialsStatus.success) {
            _refreshController.refreshCompleted();
            if (state.hasReachedMax) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadComplete();
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: CommonAppBar(
              elevation: 0,
              hideLeading: false,
              title: Text(
                tutorialsText,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Dashboard(initialPosition: 2)));
                  },
                  child: Image.asset(
                    "${commonImagePath}rabbitLogo.png",
                    height: size.width * numD07,
                    width: size.width * numD07,
                  ),
                ),
                SizedBox(
                  width: size.width * numD04,
                )
              ],
            ),
            body: SafeArea(
              child: SmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                enablePullUp: true,
                enablePullDown: true,
                footer: const CustomFooter(builder: commonRefresherFooter),
                child: ListView(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04,
                              vertical: size.height * numD03),
                          child: TextFormField(
                            decoration: InputDecoration(
                                hintText: searchText,
                                filled: true,
                                fillColor: colorLightGrey,
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD035),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.03),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.03),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.03),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.03),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.03),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )),
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(
                                      right: size.width * numD04),
                                  child: const ImageIcon(
                                    AssetImage("${iconsPath}ic_search.png"),
                                    color: Colors.black,
                                  ),
                                ),
                                suffixIconColor: Colors.black,
                                suffixIconConstraints: BoxConstraints(
                                    maxHeight: size.width * numD07),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD05,
                                    vertical: size.width * numD02)),
                            onChanged: (value) {
                              _bloc.add(TutorialsSearchVideos(value));
                            },
                          ),
                        ),

                        /// Category
                        SizedBox(
                          height: size.width * numD10,
                          child: ListView.separated(
                              controller: listController,
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * numD04),
                              itemBuilder: (context, index) {
                                final category = state.categories[index];
                                final isSelected =
                                    state.selectedCategoryIndex == index;
                                return InkWell(
                                  onTap: () {
                                    _bloc.add(TutorialsSelectCategory(index));
                                    listController.animateTo(index * 100,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: Curves.ease);
                                  },
                                  child: Chip(
                                    backgroundColor: isSelected
                                        ? Colors.black
                                        : colorLightGrey,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * numD04,
                                        vertical: size.width * numD02),
                                    label: Text(
                                      category.name,
                                      style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: size.width * numD036,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  width: size.width * numD04,
                                );
                              },
                              itemCount: state.categories.length),
                        ),
                      ],
                    ),

                    if (state.status == TutorialsStatus.loading &&
                        state.videos.isEmpty)
                      SizedBox(
                          height: size.height * 0.5,
                          child: Center(child: showLoader()))
                    else if (state.videos.isNotEmpty || state.isSearch)
                      GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04,
                              vertical: size.width * numD04),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            mainAxisSpacing: size.width * numD04,
                            crossAxisSpacing: size.width * numD04,
                          ),
                          itemBuilder: (context, index) {
                            var item = state.isSearch
                                ? state.searchResults[index]
                                : state.videos[index];
                            return InkWell(
                              onTap: () {
                                _bloc.add(TutorialsAddViewCount(item.id));
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MediaViewScreen(
                                              mediaFile: item.video,
                                              type: MediaTypeEnum.video,
                                              isFromTutorialScreen: true,
                                            )));
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD04,
                                    vertical: size.width * numD04),
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: colorTextFieldIcon),
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04)),
                                child: Column(
                                  children: [
                                    Expanded(
                                      // Use Expanded to prevent overflow
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD04),
                                        child: Stack(
                                          children: [
                                            item.thumbnail.isNotEmpty
                                                ? Image.network(
                                                    item.thumbnail,
                                                    height: double.infinity,
                                                    width: size.width,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (context,
                                                            exception,
                                                            stackTrace) {
                                                      return Image.asset(
                                                        "${commonImagePath}rabbitLogo.png",
                                                        width: size.width,
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  )
                                                : Image.asset(
                                                    "${dummyImagePath}placeholderImage.png",
                                                    height: double.infinity,
                                                    width: size.width,
                                                    fit: BoxFit.cover,
                                                  ),
                                            Positioned(
                                              right: size.width * numD02,
                                              top: size.width * numD02,
                                              child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          size.width * numD01,
                                                      vertical:
                                                          size.width * 0.002),
                                                  decoration: BoxDecoration(
                                                      color: colorLightGreen
                                                          .withOpacity(0.8),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              size.width *
                                                                  numD015)),
                                                  child: Icon(
                                                    Icons.videocam_outlined,
                                                    size: size.width * numD045,
                                                    color: Colors.white,
                                                  )),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.width * numD01,
                                    ),
                                    Text(item.description,
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD03,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    SizedBox(
                                      height: size.width * numD01,
                                    ), // Spacer adjustment
                                    Row(
                                      children: [
                                        Image.asset(
                                          "${iconsPath}ic_clock.png",
                                          height: size.width * numD03,
                                        ),
                                        SizedBox(
                                          width: size.width * numD01,
                                        ),
                                        Text(
                                          item.duration,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD025,
                                              color: colorHint,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const Spacer(),
                                        Image.asset(
                                          "${iconsPath}ic_view.png",
                                          height: size.width * numD03,
                                        ),
                                        SizedBox(
                                          width: size.width * numD01,
                                        ),
                                        Text(
                                          item.view.toString(),
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD025,
                                              color: colorThemePink,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.width * numD01,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount: state.isSearch
                              ? state.searchResults.length
                              : state.videos.length)
                    else
                      Container() // Empty state or placeholder
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
