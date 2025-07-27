import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/view/myEarning/earningDataModel.dart';

class CommissionWidget extends StatelessWidget {
  final CommissionData commissionData;
  late Size size;

  CommissionWidget({
    Key? key,
    required this.commissionData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: size.width * numD02,
      ),
      padding: EdgeInsets.only(
        top: size.width * numD04,
        bottom: size.width * numD04,
        left: size.width * numD04,
        right: size.width * numD04,
      ),
      decoration: BoxDecoration(
          color: colorLightGrey,
          borderRadius: BorderRadius.circular(size.width * numD02)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commissionData.firstName.isNotEmpty
                        ? "${commissionData.firstName.toTitleCase()} ${commissionData.lastName.toTitleCase()}"
                        : "",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * 0.045,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(
                        vertical: size.width * numD02,
                      ),
                      padding: EdgeInsets.only(
                        top: size.width * numD02,
                        bottom: size.width * numD02,
                        left: size.width * numD04,
                        right: size.width * numD04,
                      ),
                      decoration: BoxDecoration(
                          color: colorGrey4,
                          borderRadius:
                              BorderRadius.circular(size.width * numD02)),
                      child: Column(
                        children: [
                          Text(
                            "Date of Joining",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * 0.024,
                                color: Colors.black,
                                fontWeight: FontWeight.w300),
                          ),
                          Text(
                            commissionData.dateOfJoining,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * 0.025,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ))
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(size.width * numD03),
                child: Image.network(commissionData.avatar,
                    height: size.width * numD18,
                    width: size.width * numD20,
                    fit: BoxFit.cover,
                    errorBuilder: (context, i, b) => Image.asset(
                          "${dummyImagePath}placeholderImage.png",
                          fit: BoxFit.cover,
                          height: size.width * numD11,
                          width: size.width * numD12,
                        )),
              ),
            ],
          ),
          SizedBox(height: size.height * numD01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Total earning by the Hopper",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
              Container(
                width: size.width * numD20,
                padding: EdgeInsets.symmetric(
                    vertical: size.width * numD01,
                    horizontal: size.width * numD02),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.width * numD015),
                  color: colorThemePink,
                ),
                child: Text(
                  "£${formatDouble(double.parse(commissionData.totalEarning.toString()))}",
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD04,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
          SizedBox(height: size.height * numD01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Your 5% commission",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
              Container(
                width: size.width * numD20,
                padding: EdgeInsets.symmetric(
                    vertical: size.width * numD01,
                    horizontal: size.width * numD04),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.width * numD015),
                  color: Colors.black,
                ),
                child: Text(
                  "£${formatDouble(double.parse(commissionData.commission.toString()))}",
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD04,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
          SizedBox(height: size.height * numD01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Paid on",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
              Text(
                commissionData.paidOn ?? "-",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
          SizedBox(height: size.height * numD01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Commission received",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
              Text(
                "£${formatDouble(double.parse(commissionData.commissionReceived.toString()))}",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
          SizedBox(height: size.height * numD01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Commission pending",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
              Text(
                "£${formatDouble(double.parse(commissionData.commissionPending.toString()))}",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
            ],
          )
        ],
      ),
    );
  }
}
