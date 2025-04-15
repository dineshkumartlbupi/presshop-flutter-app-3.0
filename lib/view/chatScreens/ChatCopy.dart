import 'package:flutter/material.dart';
import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonTextField.dart';

class ChatScreen extends StatefulWidget {
  String title = "";
  ChatScreen({super.key,required this.title});


  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Size size;

  final TextEditingController _typingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
          elevation: 0,
          hideLeading: false,
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  size.width * numD01,
                ),
                height: size.width * numD11,
                width: size.width * numD11,
                decoration: const BoxDecoration(
                    color: colorSwitchBack, shape: BoxShape.circle),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    "${commonImagePath}rabbitLogo.png",
                    height: size.width * numD075,
                    width: size.width * numD075,
                  ),
                ),
              ),
              SizedBox(
                width: size.width * numD02,
              ),
              Text(
                widget.title.toUpperCase(),
                style: TextStyle(
                    color: Colors.black, fontSize: size.width * numD045),
              ),
            ],
          ),
          centerTitle: false,
          titleSpacing: 0,
          size: size,
          showActions: true,
          leadingFxn: () {
            Navigator.pop(context);
          },
          actionWidget: null),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * numD03,
          vertical: size.width * numD03,
        ),
        child: Column(
          children: [
            Expanded(
                child: ListView.separated(
                    padding: EdgeInsets.only(
                      bottom: size.width * numD03,
                    ),
                    reverse: true,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return index % 2 == 0
                          ? rightChatWidget()
                          : leftChatWidget();
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: size.width*numD06,
                      );
                    },
                    itemCount: 10)),
            Row(
              children: [
                SizedBox(
                  width: size.width * numD03,
                ),
                SizedBox(
                    height: size.width * numD075,
                    width: size.width * numD075,
                    child: Image.asset("${iconsPath}ic_attachment.png")),
                SizedBox(
                  width: size.width * numD05,
                ),
                Expanded(
                  child: CommonTextField(
                    size: size,
                    controller: _typingController,
                    hintText: "Type here ...",
                    prefixIcon: null,
                    borderColor: Colors.grey.shade300,
                    prefixIconHeight: 0,
                    suffixIconIconHeight: size.width * numD06,
                    textInputFormatters: null,
                    suffixIcon: InkWell(
                      onTap: null,
                      child: Image.asset(
                        "${iconsPath}ic_arrow_right.png",
                        color: Colors.black,
                        width: size.width * numD07,
                      ),
                    ),
                    hidePassword: false,
                    keyboardType: TextInputType.text,
                    validator: null,
                    enableValidations: true,
                    filled: false,
                    filledColor: Colors.transparent,
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  width: size.width * numD03,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget leftChatWidget() {
    return Container(
      margin: EdgeInsets.only(right: size.width*numD20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(
              size.width * numD01,
            ),
            height: size.width * numD12,
            width: size.width * numD12,
            decoration: const BoxDecoration(
                color: colorSwitchBack, shape: BoxShape.circle),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                height: size.width * numD09,
                width: size.width * numD09,
              ),
            ),
          ),
          SizedBox(width: size.width*numD02,),
          Expanded(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: size.width*numD02),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(size.width * numD04),
                        bottomLeft: Radius.circular(size.width * numD04),
                        bottomRight: Radius.circular(size.width * numD04),
                      ),
                      border: Border.all(width: 1.5, color: colorSwitchBack)),
                  padding: EdgeInsets.all(size.width * numD05),
                  child: Text(
                    "Okay, No problem! We can provide you other options.",
                    style: TextStyle(
                        fontSize: size.width * numD037,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: "AirbnbCereal_W_Bk"),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  width: size.width / 1.5,
                  padding: EdgeInsets.only(
                    right: size.width * numD02,
                    top: size.width * numD01,
                  ),
                  child: Text(
                    "12:10 PM",
                    style: TextStyle(
                        fontSize: size.width * numD03,
                        color: Color(0xFF979797),
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget rightChatWidget() {
    return Container(
      margin: EdgeInsets.only(left: size.width*numD20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorThemePink.withOpacity(0.4),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      topLeft: Radius.circular(size.width * numD04),
                    ),
                  ),
                  padding: EdgeInsets.all(size.width * numD05),
                  child: Text(
                    "Yes, that would be great.s s s s s s s s s s s ",
                    style: TextStyle(
                        fontSize: size.width * numD037,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: "AirbnbCereal_W_Bk"),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    right: size.width * numD02,
                    top: size.width * numD01,
                  ),
                  child: Text(
                    "12:10 PM",
                    style: TextStyle(
                        fontSize: size.width * numD03,
                        color: colorGoogleButtonBorder,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: size.width*numD02,),
          Container(
            padding: EdgeInsets.all(
              size.width * numD01,
            ),
            height: size.width * numD12,
            width: size.width * numD12,
            decoration: const BoxDecoration(
                color: colorLightGrey, shape: BoxShape.circle),
            child: ClipOval(
              clipBehavior: Clip.antiAlias,
              child:
              Image.asset("${dummyImagePath}avatar.png"),
            ),
          ),
        ],
      ),
    );
  }
}
