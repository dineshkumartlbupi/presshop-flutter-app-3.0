import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/features/authentication/data/datasources/verification_remote_datasource.dart';
import 'package:presshop/features/authentication/domain/entities/document_data.dart';
import 'package:presshop/features/authentication/domain/entities/document_instruction.dart';
import 'package:presshop/features/authentication/domain/repositories/verification_repository.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  VerificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<DocumentInstruction>>>
      getDocumentInstructions() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.getDocumentInstructions();
        return Right(remoteData);
      } catch (e) {
        return const Left(ServerFailure(message: 'Server Error'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<DocumentData>>> getUploadedDocuments() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.getUploadedDocuments();
        return Right(remoteData);
      } catch (e) {
        return const Left(ServerFailure(message: 'Server Error'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> uploadDocuments(List<File> files) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.uploadDocuments(files);
        return const Right(null);
      } catch (e) {
        return const Left(ServerFailure(message: 'Server Error'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(String documentId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteDocument(documentId);
        return const Right(null);
      } catch (e) {
        return const Left(ServerFailure(message: 'Server Error'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
