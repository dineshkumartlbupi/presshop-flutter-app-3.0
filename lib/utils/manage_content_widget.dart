import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonWigdets.dart';

import '../main.dart';

class ManageContentWidget extends StatelessWidget {
  Map<String, dynamic> data = {};
  ManageContentWidget(this.data, {super.key});
  late Size size;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Card(
      elevation: 3,
      color: colorLightGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * numD03),
      ),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.width * numD04),
                border: Border.all(color: lightGrey.withOpacity(.6)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.width * numD04),
                child: Image.network(
                  data['userDetails'][0]['profile_image'],
                  fit: BoxFit.cover,
                  height: size.width * numD20,
                  width: size.width * numD20,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Image.asset(
                      "${dummyImagePath}news.png",
                      fit: BoxFit.contain,
                      width: size.width * numD20,
                      height: size.width * numD20,
                    );
                  },
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: size.height * numD006,
              children: [
                SizedBox(
                  width: size.width * numD32,
                  child: Text(data['userDetails'][0]['company_name'],
                      maxLines: 2,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD03,
                          color: Colors.black,
                          fontWeight: FontWeight.w700)),
                ),
                Row(
                  spacing: size.width * numD01,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey,
                      size: size.width * numD05,
                    ),
                    Text(
                        dateTimeFormatter(
                            dateTime: data['createdAt'].toString(),
                            format: "hh:mm a"),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD03,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500))
                  ],
                ),
                Row(
                  spacing: size.width * numD01,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: Colors.grey,
                      size: size.width * numD05,
                    ),
                    Text(
                        dateTimeFormatter(
                            dateTime: data['createdAt'].toString(),
                            format: "dd MMM yyyy"),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD03,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500))
                  ],
                )
              ],
            ),
            Container(
              width: size.width * numD30,
              padding: EdgeInsets.symmetric(vertical: size.width * numD012),
              decoration: BoxDecoration(
                  color: data['message_type'] == "Offered"
                      ? Colors.black
                      : lightGrey,
                  borderRadius: BorderRadius.circular(size.width * numD03)),
              child: Column(
                children: [
                  Text(
                    data['message_type'] == "Offered"
                        ? 'Offered Price'
                        : 'Sold Price',
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: data['message_type'] == "Offered"
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w400),
                  ),
                  FittedBox(
                    child: Container(
                      margin: EdgeInsets.only(
                        left: size.width * numD02,
                        right: size.width * numD02,
                      ),
                      child: Text(
                        "$currencySymbol${formatDouble(double.parse(data['amount']))}",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD05,
                            color: data['message_type'] == "Offered"
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
