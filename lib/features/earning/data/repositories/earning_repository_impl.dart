import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/commission.dart';
import '../../domain/entities/earning_profile.dart';
import '../../domain/repositories/earning_repository.dart';
import '../datasources/earning_remote_data_source.dart';
import '../models/earning_model.dart';
import 'package:presshop/features/earning/domain/entities/earning_profile.dart' as entity_profile; // Alias to avoid conflict if needed, or mapping logic

class EarningRepositoryImpl implements EarningRepository {
  final EarningRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  EarningRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, EarningProfile>> getEarningProfile(String year, String month) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProfile = await remoteDataSource.getEarningProfile(year, month);
        // Map Model to Entity
        final entity = EarningProfile(
          id: remoteProfile.id,
          avatar: remoteProfile.avatar,
          totalEarning: remoteProfile.totalEarning,
        );
        return Right(entity);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, TransactionsResult>> getTransactions(Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.getTransactions(params);
        
        final dataList = remoteData['data'] as List? ?? [];
        final totalEarning = remoteData['totalEarning']?.toString() ?? "";
        
        // Map Models (EarningTransactionDetail) to Entities (EarningTransaction)
        // EarningTransactionDetail is currently in models layer.
        final transactions = dataList.map((e) {
            final model = EarningTransactionDetail.fromJson(e);
            return EarningTransaction(
                id: model.id,
                amount: model.amount,
                totalEarningAmt: model.totalEarningAmt,
                status: model.paidStatus ? "Paid" : "Pending", 
                isPaid: model.paidStatus,
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
            );
        }).toList();

        return Right(TransactionsResult(transactions: transactions, totalEarning: totalEarning));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Commission>>> getCommissions(Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCommissions = await remoteDataSource.getCommissions(params);
         // Map Model to Entity
        final entities = remoteCommissions.map((e) => Commission(
          totalEarning: e.totalEarning,
          commission: e.commission,
          commissionReceived: e.commissionReceived,
          commissionPending: e.commissionPending,
          paidOn: e.paidOn,
          firstName: e.firstName,
          lastName: e.lastName,
          dateOfJoining: e.dateOfJoining,
          avatar: e.avatar,
        )).toList();
        
        return Right(entities);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
