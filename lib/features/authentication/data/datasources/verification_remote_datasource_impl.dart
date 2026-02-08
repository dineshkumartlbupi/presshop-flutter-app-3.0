import 'dart:io';
import 'package:dio/dio.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/features/authentication/data/datasources/verification_remote_datasource.dart';
import 'package:presshop/features/authentication/data/models/document_data_model.dart';
import 'package:presshop/features/authentication/data/models/document_instruction_model.dart';

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  VerificationRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<List<DocumentInstructionModel>> getDocumentInstructions() async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew.misc.generalMgmt,
        queryParameters: {'type': 'doc'},
      );
      final data = response.data['status'] as List;
      return data.map((e) => DocumentInstructionModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<DocumentDataModel>> getUploadedDocuments() async {
    try {
      final String hopperId =
          apiClient.sharedPreferences.getString(hopperIdKey) ?? '';
      final response = await apiClient.get(
        ApiConstantsNew.profile.getUploadedDocs,
        queryParameters: {'hopper_id': hopperId},
        options: Options(headers: {"x-user-id": hopperId}),
      );
      final data = response.data['data'] as List;
      return data.map((e) => DocumentDataModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> uploadDocuments(List<File> files) async {
    try {
      final formData = FormData();
      for (var file in files) {
        formData.files.add(MapEntry(
          "doc_name",
          await MultipartFile.fromFile(file.path),
        ));
      }
      final String hopperId =
          apiClient.sharedPreferences.getString(hopperIdKey) ?? '';
      await apiClient.multipartPost(
        ApiConstantsNew.profile.uploadDocNew,
        formData: formData,
        options: Options(method: "PATCH", headers: {"x-user-id": hopperId}),
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      final String hopperId =
          apiClient.sharedPreferences.getString(hopperIdKey) ?? '';
      await apiClient.post(
        ApiConstantsNew.profile.deleteDocument,
        data: {'document_id': documentId},
        options: Options(headers: {"x-user-id": hopperId}),
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
