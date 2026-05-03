import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/features/earning/domain/entities/earning_transaction.dart';
import '../models/media_house_model.dart';
import '../../domain/entities/publication_earning_stats.dart';
import '../../domain/entities/publication_transactions_result.dart';

abstract class PublicationRemoteDataSource {
  Future<PublicationEarningStats> getEarningStats(String type);
  Future<List<MediaHouseModel>> getMediaHouses();
  Future<PublicationTransactionsResult> getPublicationTransactions(
      Map<String, dynamic> params);
}

class PublicationRemoteDataSourceImpl implements PublicationRemoteDataSource {
  PublicationRemoteDataSourceImpl(this.apiClient);
  final ApiClient apiClient;

  @override
  Future<PublicationEarningStats> getEarningStats(String type) async {
    try {
      final Map<String, dynamic> params = {'type': type};
      final response = await apiClient.get(ApiConstantsNew.payments.earnings,
          queryParameters: params);

      final data = response.data;
      final earningData = EarningProfileDataModel.fromJson(data);

      return PublicationEarningStats(
        avatar: earningData.hopper.avatar,
        publicationCount:
            "", // This API doesn't seem to return count, transaction API does.
        totalEarning: earningData.totalEarning.toString(),
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<MediaHouseModel>> getMediaHouses() async {
    try {
      final response =
          await apiClient.get(ApiConstantsNew.tasks.mediaHouseList);
      final List<dynamic> dataList = response.data['data'];
      return dataList.map((e) => MediaHouseModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<PublicationTransactionsResult> getPublicationTransactions(
      Map<String, dynamic> params) async {
    try {
      final response = await apiClient.get(
          ApiConstantsNew.payments.publicationTransaction,
          queryParameters: params);

      final List<dynamic> dataList = response.data['data'];
      final String publicationCount =
          response.data['countofmediahouse'].toString();
      final String totalAmount = response.data['amount'].toString();

      final List<EarningTransaction> transactions = dataList
          .map(
              (e) => EarningTransactionDetail.fromJson(e)) // This returns Model
          .map((model) => _mapModelToEntity(model)) // Map Model to Entity
          .toList();

      return PublicationTransactionsResult(
        transactions: transactions,
        publicationCount: publicationCount,
        totalAmount: totalAmount,
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  EarningTransaction _mapModelToEntity(EarningTransactionDetail model) {
    return EarningTransaction(
        id: model.id,
        amount: model.amount,
        totalEarningAmt: model.totalEarningAmt,
        status: model.adminStatus, // Check if this is correct field mapping

        contentTitle: model.contentTitle,
        contentType: model.contentType,
        createdAt: model.createdAT,
        adminFullName: model.adminFullName,
        companyLogo: model.companyLogo,
        contentImage: model.contentImage,
        payableT0Hopper: model.payableT0Hopper,
        payableCommission: model.payableCommission,
        stripefee: model.stripefee,
        hopperBankLogo: model.hopperBankLogo,
        hopperBankName: model.hopperBankName,
        userFirstName: model.userFirstName,
        userLastName: model.userLastName,
        contentDataList: model.contentDataList,
        type: model.type,
        typesOfContent: model.typesOfContent,
        hopperAvatar: model.hopperAvatar,
        paidStatus: model.paidStatus,
        dueDate: model.dueDate);
  }
}
