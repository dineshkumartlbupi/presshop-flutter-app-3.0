import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/authentication/presentation/pages/LoginScreen.dart';
import 'package:presshop/core/di/injection_container.dart' as di;
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class Walkthrough extends StatefulWidget {
  const Walkthrough({super.key});

  @override
  State<Walkthrough> createState() => _WalkthroughState();
}

class _WalkthroughState extends State<Walkthrough> {
  List<WalkthroughData> walkthroughList = [];
  PageController controller = PageController();
  int walkIndex = 0;
  String deviceId = "";

  @override
  void initState() {
    super.initState();
    walkthroughList.add(WalkthroughData(
        image: "${dummyImagePath}walk1.png",
        title1: AppStrings.walk1Title1Text,
        title2: AppStrings.walk1Title2Text,
        buttonText: "",
        description: AppStrings.walk1DescriptionText,
        showButton: false));

    walkthroughList.add(WalkthroughData(
      image: "${dummyImagePath}walk2.png",
      title1: AppStrings.walk2Title1Text,
      title2: AppStrings.walk2Title2Text,
      buttonText: AppStrings.walk2ButtonText,
      description: AppStrings.walk2DescriptionText,
      showButton: true,
    ));

    walkthroughList.add(WalkthroughData(
      image: "${dummyImagePath}walk3.png",
      title1: AppStrings.walk3Title1Text,
      title2: AppStrings.walk3Title2Text,
      buttonText: AppStrings.walk3ButtonText,
      description: AppStrings.walk3DescriptionText,
      showButton: true,
    ));

    walkthroughList.add(WalkthroughData(
      image: "${dummyImagePath}walk4.png",
      title1: AppStrings.walk4Title1Text,
      title2: AppStrings.walk4Title2Text,
      buttonText: AppStrings.walk4ButtonText,
      description: AppStrings.walk4DescriptionText,
      showButton: true,
    ));

    walkthroughList.add(WalkthroughData(
      image: "${dummyImagePath}walk5.png",
      title1: AppStrings.walk5Title1Text,
      title2: AppStrings.walk5Title2Text,
      buttonText: AppStrings.walk5ButtonText,
      description: AppStrings.walk5DescriptionText,
      showButton: true,
    ));

    walkthroughList.add(WalkthroughData(
        image: "${dummyImagePath}walk6.png",
        title1: AppStrings.walk6Title1Text,
        title2: AppStrings.walk6Title2Text,
        buttonText: AppStrings.walk6ButtonText,
        description: AppStrings.walk6DescriptionText,
        showButton: true));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => di.sl<OnboardingBloc>(),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false);
          } else if (state is OnboardingError) {
            // Fallback to login anyway or show error?
            // Usually just log and proceed
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false);
          }
        },
        child: Builder(builder: (context) {
          return Scaffold(
            body: SafeArea(
              child: PageView.builder(
                controller: controller,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * AppDimensions.numD06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.width * AppDimensions.numD06,
                        ),
                        index % 2 == 0
                            ? Expanded(
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD1),
                                    child: Image.asset(
                                      walkthroughList[index].image,
                                      fit: BoxFit.cover,
                                      width: size.width,
                                    )),
                              )
                            : Container(),
                        SizedBox(
                            height: index % 2 == 0
                                ? size.width * AppDimensions.numD04
                                : 0),
                        Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                            image: AssetImage(
                                "assets/commonImages/walkTitleBackGround.png"),
                            fit: BoxFit.fitWidth,
                          )),
                          child: Text(
                            walkthroughList[index].title1,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontFamily: "AirbnbCereal_W_Bd",
                                fontSize: size.width * AppDimensions.numD07),
                          ),
                        ),
                        Text(
                          walkthroughList[index].title2,
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "AirbnbCereal_W_Bd",
                              fontWeight: FontWeight.w600,
                              fontSize: size.width * AppDimensions.numD07),
                        ),
                        Text(walkthroughList[index].description,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'AirbnbCereal_W_Bk',
                                fontSize: size.width * AppDimensions.numD035)),
                        SizedBox(
                            height: index % 2 == 0
                                ? 0
                                : size.width * AppDimensions.numD04),
                        index % 2 == 0
                            ? Container()
                            : Expanded(
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD1),
                                    child: Image.asset(
                                      walkthroughList[index].image,
                                      fit: BoxFit.cover,
                                      width: size.width,
                                    )),
                              ),
                        SizedBox(height: size.width * AppDimensions.numD04),
                        Row(
                          children: [
                            index == 0
                                ? InkWell(
                                    onTap: () {
                                      context
                                          .read<OnboardingBloc>()
                                          .add(CompleteOnboarding());
                                    },
                                    splashColor: Colors.grey.shade300,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              size.width * AppDimensions.numD02,
                                          vertical: size.width *
                                              AppDimensions.numD03),
                                      child: Text(
                                        AppStrings.skipText,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal,
                                            fontFamily: 'AirbnbCereal_W_Md',
                                            fontSize: size.width *
                                                AppDimensions.numD03),
                                      ),
                                    ))
                                : Container(),
                            const Spacer(),
                            walkthroughList[index].showButton
                                ? ElevatedButton(
                                    onPressed: () {
                                      context
                                          .read<OnboardingBloc>()
                                          .add(CompleteOnboarding());
                                    },
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.width *
                                                AppDimensions.numD012,
                                            horizontal: size.width *
                                                AppDimensions.numD04),
                                        backgroundColor:
                                            AppColorTheme.colorThemePink,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width *
                                                    AppDimensions.numD05))),
                                    child: Text(
                                      walkthroughList[index].buttonText,
                                      style: TextStyle(
                                          fontSize: size.width *
                                              AppDimensions.numD035,
                                          color: Colors.white,
                                          fontFamily: 'AirbnbCereal_W_Md',
                                          fontWeight: FontWeight.w700),
                                    ))
                                : Container(),
                            const Spacer(),
                            InkWell(
                                onTap: () {
                                  if (index == (walkthroughList.length - 1)) {
                                    context
                                        .read<OnboardingBloc>()
                                        .add(CompleteOnboarding());
                                  } else {
                                    controller.animateToPage(index + 1,
                                        duration:
                                            const Duration(milliseconds: 100),
                                        curve: Curves.linear);
                                  }
                                },
                                splashColor: Colors.grey.shade300,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          size.width * AppDimensions.numD02,
                                      vertical:
                                          size.width * AppDimensions.numD03),
                                  child: Text(
                                    AppStrings.nextText,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            size.width * AppDimensions.numD03,
                                        fontWeight: FontWeight.normal),
                                  ),
                                )),
                          ],
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD03,
                        ),
                      ],
                    ),
                  );
                },
                itemCount: walkthroughList.length,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class WalkthroughData {
  WalkthroughData(
      {required this.image,
      required this.title1,
      required this.title2,
      required this.description,
      required this.buttonText,
      required this.showButton});
  String image = "";
  String title1 = "";
  String title2 = "";
  String description = "";
  String buttonText = "";
  bool showButton = false;
}
