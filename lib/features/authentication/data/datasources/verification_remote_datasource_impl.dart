import 'dart:io';
import 'package:dio/dio.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/features/authentication/data/datasources/verification_remote_datasource.dart';
import 'package:presshop/features/authentication/data/models/document_data_model.dart';
import 'package:presshop/features/authentication/data/models/document_instruction_model.dart';

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final ApiClient apiClient;

  VerificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<DocumentInstructionModel>> getDocumentInstructions() async {
    final response = await apiClient.get(
      getAllCmsUrl,
      queryParameters: {'type': 'doc'},
    );
    final data = response.data['status'] as List;
    return data.map((e) => DocumentInstructionModel.fromJson(e)).toList();
  }

  @override
  Future<List<DocumentDataModel>> getUploadedDocuments() async {
    final response = await apiClient.get(getUploadDocUrl);

    // Check if the response contains 'data' and parse it.
    // Based on `callGetUploadDocAPI` in original file, it just makes a GET.
    // We need to see how it was parsed. Original `getUploadDocReq` case in `onResponse`.

    // Looking at `UploadDocumnetsScreen.dart` line 2315:
    /*
        case getUploadDocReq:
          debugPrint('getUploadDocReq_successResponse ===> ${jsonDecode(response)}');
          var data = jsonDecode(response);
          var dataList = data['data'] as List;
          docList = dataList.map((e) => DocumentDataModel.fromJson(e)).toList();
          setState(() {});
          break;
    */

    final data = response.data['data'] as List;
    return data.map((e) => DocumentDataModel.fromJson(e)).toList();
  }

  @override
  Future<void> uploadDocuments(List<File> files) async {
    final formData = FormData();
    for (var file in files) {
      formData.files.add(MapEntry(
        "doc_name",
        await MultipartFile.fromFile(file.path),
      ));
    }
    await apiClient.multipartPost(
      uploadDocUrl,
      formData: formData,
      options: Options(method: "PATCH"),
    );
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    await apiClient.post(
      deleteDocUrl,
      data: {'document_id': documentId},
    );
  }
}
