import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/chat/presentation/pages/full_video_view.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/features/publish/presentation/bloc/tutorials/tutorials_bloc.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/utils/common_utils.dart';
import 'package:presshop/core/widgets/video_thumbnail_widget.dart';
import '../widgets/tutorial_item_card.dart';

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
//           showSnackBar("Error", state.errorMessage, Colors.red);
            _refreshController.refreshFailed();
            _refreshController.loadFailed();
          } else if (state.status == TutorialsStatus.success) {
            _refreshController.refreshCompleted();
            if (state.hasReachedMax) {
              //_refreshController.loadNoData();
            } else {
              _refreshController.loadComplete();
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: CommonBrandedAppBar(
              title: AppStrings.tutorialsText,
              size: size,
              showLogo: true,
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
                              horizontal: AppDimensions.commonPaddingSize(size),
                              vertical: size.height * AppDimensions.numD03),
                          child: TextFormField(
                            decoration: InputDecoration(
                                hintText: AppStrings.searchText,
                                filled: true,
                                fillColor: AppColorTheme.colorLightGrey,
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        size.width * AppDimensions.numD035),
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
                                      right: size.width * AppDimensions.numD04),
                                  child: const ImageIcon(
                                    AssetImage("${iconsPath}ic_search.png"),
                                    color: Colors.black,
                                  ),
                                ),
                                suffixIconColor: Colors.black,
                                suffixIconConstraints: BoxConstraints(
                                    maxHeight:
                                        size.width * AppDimensions.numD07),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal:
                                        size.width * AppDimensions.numD05,
                                    vertical:
                                        size.width * AppDimensions.numD02)),
                            onChanged: (value) {
                              _bloc.add(TutorialsSearchVideos(value));
                            },
                          ),
                        ),

                        /// Category
                        SizedBox(
                          height: size.width * AppDimensions.numD10,
                          child: ListView.separated(
                              controller: listController,
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      size.width * AppDimensions.numD04),
                              itemBuilder: (context, index) {
                                final category = state.categories[index];
                                final isSelected =
                                    state.selectedCategoryIndex == index;
                                return InkWell(
                                  onTap: () {
                                    _bloc.add(TutorialsSelectCategory(index));
                                    // Removed hardcoded animateTo for better reliability
                                  },
                                  child: Chip(
                                    backgroundColor: isSelected
                                        ? Colors.black
                                        : AppColorTheme.colorLightGrey,
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            size.width * AppDimensions.numD04,
                                        vertical:
                                            size.width * AppDimensions.numD02),
                                    label: Text(
                                      category.name,
                                      style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: size.width *
                                              AppDimensions.numD036,
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
                      ],
                    ),
                    if (state.status == TutorialsStatus.loading ||
                        state.status == TutorialsStatus.initial)
                      if (state.videos.isEmpty)
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: size.height * 0.1),
                          child: Center(child: showAnimatedLoader(size)),
                        )
                      else
                        const SizedBox.shrink()
                    else if (state.videos.isNotEmpty || state.isSearch)
                      GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04,
                              vertical: size.width * AppDimensions.numD04),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            mainAxisSpacing: size.width * AppDimensions.numD04,
                            crossAxisSpacing: size.width * AppDimensions.numD04,
                          ),
                          itemBuilder: (context, index) {
                            var item = state.isSearch
                                ? state.searchResults[index]
                                : state.videos[index];
                            return TutorialItemCard(
                              item: item,
                              size: size,
                              onTap: () {
                                _bloc.add(TutorialsAddViewCount(item.id));
                                context.pushNamed(AppRoutes.fullVideoViewName,
                                    extra: {
                                      'mediaFile': item.video,
                                      'type': MediaTypeEnum.video,
                                      'isFromTutorialScreen': true,
                                    });
                              },
                            );
                          },
                          itemCount: state.isSearch
                              ? state.searchResults.length
                              : state.videos.length)
                    else
                      SizedBox(
                        height: size.height * 0.4,
                        child: Center(
                          child: Text(
                            "No tutorials found",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD04,
                                color: AppColorTheme.colorHint,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
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
