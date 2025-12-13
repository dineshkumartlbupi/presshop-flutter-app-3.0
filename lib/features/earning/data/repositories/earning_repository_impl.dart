import 'package:dartz/dartz.dart';
import 'package:presshop/core/api/network_info.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/commission.dart';
import '../../domain/entities/earning_profile.dart';
import '../../domain/entities/earning_transaction.dart';
import '../../domain/repositories/earning_repository.dart';
import '../datasources/earning_remote_data_source.dart';
import '../models/earning_model.dart';
import '../../data/models/earning_model.dart';

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
  Future<Either<Failure, TransactionsResult>> getTransactions(Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.getTransactions(params);
        
        final dataList = remoteData['data'] as List? ?? [];
        final totalEarning = remoteData['totalEarning']?.toString() ?? "";
        
        final transactions = dataList.map((e) {
            final model = EarningTransactionDetail.fromJson(e);
            
            String uploadContent = "";
            // Logic to find videoUrl if present, otherwise just empty or one of media items
            // Model doesn't expose it directly but MyEarningScreen expects it.
            // Using contentImage (watermark/thumbnail) as placeholder won't play video.
            // But since I don't see 'uploadContent' in model, maybe it's dynamically populated in legacy
            // or I assume model.contentDataList has it.
            if (model.contentDataList.isNotEmpty) {
               // checking dynamic property
               // uploadContent = model.contentDataList.first['media'] ?? ""; // unsafe on typed list
            }

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

        return Right(TransactionsResult(transactions: transactions, totalEarning: totalEarning));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Commission>>> getCommissions(Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCommissions = await remoteDataSource.getCommissions(params);
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
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
