import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/authentication/presentation/pages/LoginScreen.dart' hide Navigator;
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
        title1: walk1Title1Text,
        title2: walk1Title2Text,
        buttonText: "",
        description: walk1DescriptionText,
        showButton: false));

    walkthroughList.add(WalkthroughData(
      image: "${dummyImagePath}walk2.png",
      title1: walk2Title1Text,
      title2: walk2Title2Text,
      buttonText: walk2ButtonText,
      description: walk2DescriptionText,
      showButton: true,
    ));

    walkthroughList.add(WalkthroughData(
      image: "${dummyImagePath}walk3.png",
      title1: walk3Title1Text,
      title2: walk3Title2Text,
      buttonText: walk3ButtonText,
      description: walk3DescriptionText,
      showButton: true,
    ));

    walkthroughList.add(WalkthroughData(
      image: "${dummyImagePath}walk4.png",
      title1: walk4Title1Text,
      title2: walk4Title2Text,
      buttonText: walk4ButtonText,
      description: walk4DescriptionText,
      showButton: true,
    ));

    walkthroughList.add(WalkthroughData(
      image: "${dummyImagePath}walk5.png",
      title1: walk5Title1Text,
      title2: walk5Title2Text,
      buttonText: walk5ButtonText,
      description: walk5DescriptionText,
      showButton: true,
    ));

    walkthroughList.add(WalkthroughData(
        image: "${dummyImagePath}walk6.png",
        title1: walk6Title1Text,
        title2: walk6Title2Text,
        buttonText: walk6ButtonText,
        description: walk6DescriptionText,
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
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * numD06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.width * numD06,
                        ),
                        index % 2 == 0
                            ? Expanded(
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD1),
                                    child: Image.asset(
                                      walkthroughList[index].image,
                                      fit: BoxFit.cover,
                                      width: size.width,
                                    )),
                              )
                            : Container(),
                        SizedBox(
                            height: index % 2 == 0 ? size.width * numD04 : 0),
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
                                fontSize: size.width * numD07),
                          ),
                        ),
                        Text(
                          walkthroughList[index].title2,
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "AirbnbCereal_W_Bd",
                              fontWeight: FontWeight.w600,
                              fontSize: size.width * numD07),
                        ),
                        Text(walkthroughList[index].description,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'AirbnbCereal_W_Bk',
                                fontSize: size.width * numD035)),
                        SizedBox(
                            height: index % 2 == 0 ? 0 : size.width * numD04),
                        index % 2 == 0
                            ? Container()
                            : Expanded(
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD1),
                                    child: Image.asset(
                                      walkthroughList[index].image,
                                      fit: BoxFit.cover,
                                      width: size.width,
                                    )),
                              ),
                        SizedBox(height: size.width * numD04),
                        Row(
                          children: [
                            index == 0
                                ? InkWell(
                                    onTap: () {
                                      context.read<OnboardingBloc>().add(CompleteOnboarding());
                                    },
                                    splashColor: Colors.grey.shade300,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * numD02,
                                          vertical: size.width * numD03),
                                      child: Text(
                                        skipText,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal,
                                            fontFamily: 'AirbnbCereal_W_Md',
                                            fontSize: size.width * numD03),
                                      ),
                                    ))
                                : Container(),
                            const Spacer(),
                            walkthroughList[index].showButton
                                ? ElevatedButton(
                                    onPressed: () {
                                      context.read<OnboardingBloc>().add(CompleteOnboarding());
                                    },
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.width * numD012,
                                            horizontal: size.width * numD04),
                                        backgroundColor: colorThemePink,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD05))),
                                    child: Text(
                                      walkthroughList[index].buttonText,
                                      style: TextStyle(
                                          fontSize: size.width * numD035,
                                          color: Colors.white,
                                          fontFamily: 'AirbnbCereal_W_Md',
                                          fontWeight: FontWeight.w700),
                                    ))
                                : Container(),
                            const Spacer(),
                            InkWell(
                                onTap: () {
                                  if (index == (walkthroughList.length - 1)) {
                                    context.read<OnboardingBloc>().add(CompleteOnboarding());
                                  } else {
                                    controller.animateToPage(index + 1,
                                        duration: const Duration(milliseconds: 100),
                                        curve: Curves.linear);
                                  }
                                },
                                splashColor: Colors.grey.shade300,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * numD02,
                                      vertical: size.width * numD03),
                                  child: Text(
                                    nextText,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: size.width * numD03,
                                        fontWeight: FontWeight.normal),
                                  ),
                                )),
                          ],
                        ),
                        SizedBox(
                          height: size.width * numD03,
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
  String image = "";
  String title1 = "";
  String title2 = "";
  String description = "";
  String buttonText = "";
  bool showButton = false;

  WalkthroughData(
      {required this.image,
      required this.title1,
      required this.title2,
      required this.description,
      required this.buttonText,
      required this.showButton});
}
