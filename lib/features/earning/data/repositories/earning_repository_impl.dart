import 'package:dartz/dartz.dart';
import 'package:presshop/core/api/network_info.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/commission.dart';
import '../../domain/entities/earning_profile.dart';
import '../../domain/entities/earning_transaction.dart';
import '../../domain/repositories/earning_repository.dart';
import '../datasources/earning_remote_data_source.dart';
import '../models/earning_model.dart';

class EarningRepositoryImpl implements EarningRepository {
  EarningRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  final EarningRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, EarningProfile>> getEarningProfile(
      String year, String month) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProfile =
            await remoteDataSource.getEarningProfile(year, month);
        final entity = EarningProfile(
          id: remoteProfile.id,
          avatar: remoteProfile.avatar,
          totalEarning: remoteProfile.totalEarning,
        );
        return Right(entity);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, TransactionsResult>> getTransactions(
      Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.getTransactions(params);

        final dataListResponse = remoteData['data'];
        final List dataList;

        if (dataListResponse is Map) {
          dataList = (dataListResponse['data'] as List?) ?? [];
        } else if (dataListResponse is List) {
          dataList = dataListResponse;
        } else {
          dataList = [];
        }
        final transactions = dataList.map((e) {
          final model = EarningTransactionDetail.fromJson(e);

          String uploadContent = "";

          if (model.contentDataList.isNotEmpty) {}

          return EarningTransaction(
            id: model.id,
            amount: model.amount,
            totalEarningAmt: model.totalEarningAmt,
            status: model.paidStatus ? "Paid" : "Pending",
            paidStatus: model.paidStatus,
            contentTitle: model.contentTitle,
            contentType: model.contentType,
            createdAt: model.createdAT,
            dueDate: model.dueDate, // Added
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
            uploadContent: uploadContent,
            contentId: model.contentId, // Added
          );
        }).toList();

        double totalVal = double.tryParse(remoteData['totalEarning']
                    ?.toString() ??
                remoteData['total_earnings']?.toString() ??
                (remoteData['data'] is Map
                    ? (remoteData['data']['total_earnings']?.toString() ??
                        remoteData['data']['total_earnings_sum']?.toString())
                    : null) ??
                "") ??
            0.0;

        if (totalVal == 0.0 && transactions.isNotEmpty) {
          for (var t in transactions) {
            totalVal += double.tryParse(t.amount) ?? 0.0;
          }
        }

        final totalEarning = totalVal.toString();

        return Right(TransactionsResult(
            transactions: transactions, totalEarning: totalEarning));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Commission>>> getCommissions(
      Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCommissions = await remoteDataSource.getCommissions(params);
        final entities = remoteCommissions
            .map((e) => Commission(
                  totalEarning: e.totalEarning,
                  commission: e.commission,
                  commissionReceived: e.commissionReceived,
                  commissionPending: e.commissionPending,
                  paidOn: e.paidOn,
                  firstName: e.firstName,
                  lastName: e.lastName,
                  dateOfJoining: e.dateOfJoining,
                  avatar: e.avatar,
                  currency: e.currency,
                  currencySymbol: e.currencySymbol,
                ))
            .toList();

        return Right(entities);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
