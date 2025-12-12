import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/features/earning/domain/entities/earning_transaction.dart';
import '../models/media_house_model.dart';
import '../../domain/entities/publication_earning_stats.dart';
import '../../domain/entities/publication_transactions_result.dart';

abstract class PublicationRemoteDataSource {
  Future<PublicationEarningStats> getEarningStats(String type);
  Future<List<MediaHouseModel>> getMediaHouses();
  Future<PublicationTransactionsResult> getPublicationTransactions(Map<String, dynamic> params);
}

class PublicationRemoteDataSourceImpl implements PublicationRemoteDataSource {
  final ApiClient apiClient;

  PublicationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PublicationEarningStats> getEarningStats(String type) async {
    final Map<String, dynamic> params = {'type': type};
    final response = await apiClient.get(getEarningDataAPI, queryParameters: params);
    
    // Response mapping logic based on legacy code of PublicationListScreen
    // "resp" contains the data.
    final data = response.data;
    final earningData = EarningProfileDataModel.fromJson(data);
    
    return PublicationEarningStats(
      avatar: earningData.avatar,
      publicationCount: "", // This API doesn't seem to return count, transaction API does.
      totalEarning: earningData.totalEarning,
    );
  }

  @override
  Future<List<MediaHouseModel>> getMediaHouses() async {
    final response = await apiClient.get(getMediaHouseDetailAPI);
    final List<dynamic> dataList = response.redirects;
    return dataList.map((e) => MediaHouseModel.fromJson(e)).toList();
  }

  @override
  Future<PublicationTransactionsResult> getPublicationTransactions(Map<String, dynamic> params) async {
     final response = await apiClient.get(getPublicationTransactionAPI, queryParameters: params);
     
     final List<dynamic> dataList = response['data'];
     final String publicationCount = response['countofmediahouse'].toString();
     final String totalAmount = response['amount'].toString();
     
     final List<EarningTransaction> transactions = dataList
         .map((e) => EarningTransactionDetail.fromJson(e)) // This returns Model
         .map((model) => _mapModelToEntity(model)) // Map Model to Entity
         .toList();

     return PublicationTransactionsResult(
       transactions: transactions,
       publicationCount: publicationCount,
       totalAmount: totalAmount,
     );
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
       dueDate: ''
    );
  }
}
