import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/features/authentication/domain/entities/document_data.dart';
import 'package:presshop/features/authentication/domain/entities/document_instruction.dart';
import 'package:presshop/features/authentication/presentation/bloc/upload_documents/upload_documents_bloc.dart';
import 'package:presshop/features/authentication/presentation/bloc/upload_documents/upload_documents_event.dart';
import 'package:presshop/features/authentication/presentation/bloc/upload_documents/upload_documents_state.dart';

import 'package:presshop/core/widgets/common_widgets.dart';

const String uploadDocumentsText = "Upload Documents";

class UploadDocumentsScreen extends StatefulWidget {
  final bool menuScreen;
  final bool hideLeading;

  const UploadDocumentsScreen(
      {super.key, required this.menuScreen, required this.hideLeading});

  @override
  State<StatefulWidget> createState() {
    return UploadDocumentsScreenState();
  }
}

class UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => sl<UploadDocumentsBloc>()
        ..add(GetDocumentInstructionsEvent())
        ..add(GetUploadedDocumentsEvent()),
      child: Scaffold(
        appBar: CommonAppBar(
          elevation: 0,
          hideLeading: widget.hideLeading,
          title: Text(
            uploadDocumentsText,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * appBarHeadingFontSize,
            ),
          ),
          centerTitle: false,
          titleSpacing: 0,
          size: size,
          showActions: false,
          leadingFxn: () {
            Navigator.pop(context);
          },
          actionWidget: null,
        ),
        body: BlocConsumer<UploadDocumentsBloc, UploadDocumentsState>(
          listener: (context, state) {
            if (state.status == UploadDocumentsStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage)),
              );
            } else if (state.status == UploadDocumentsStatus.uploaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Documents uploaded successfully')),
              );
              // Refresh lists after upload
              context
                  .read<UploadDocumentsBloc>()
                  .add(GetUploadedDocumentsEvent());
            } else if (state.status == UploadDocumentsStatus.deleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document deleted successfully')),
              );
              // Refresh lists after delete
              context
                  .read<UploadDocumentsBloc>()
                  .add(GetUploadedDocumentsEvent());
            }
          },
          builder: (context, state) {
            if (state.status == UploadDocumentsStatus.loading &&
                state.instructions.isEmpty &&
                state.uploadedDocuments.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.width * numD06),
                    Text(
                      "Please upload the following documents to get verified.",
                      style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: size.width * numD04),

                    // Instructions List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.instructions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.circle, size: size.width * numD015),
                              SizedBox(width: size.width * numD02),
                              Expanded(
                                child: Text(
                                  state.instructions[index].name,
                                  style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: size.width * numD05),

                    // Upload Button
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius:
                            BorderRadius.circular(size.width * numD02),
                      ),
                      child: InkWell(
                        onTap: () {
                          _showPicker(context);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: size.width * numD06),
                          child: Column(
                            children: [
                              Image.asset(
                                "${iconsPath}ic_upload_cloud.png",
                                height: size.width * numD15,
                              ),
                              SizedBox(height: size.width * numD02),
                              Text(
                                "Upload Documents",
                                style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD04,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Supported formats: PDF, JPG, PNG",
                                style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD03,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.width * numD05),

                    // Uploaded Documents List
                    if (state.uploadedDocuments.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.uploadedDocuments.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: size.width * numD02),
                        itemBuilder: (context, index) {
                          final doc = state.uploadedDocuments[index];
                          return Container(
                            padding: EdgeInsets.all(size.width * numD03),
                            decoration: BoxDecoration(
                              border: Border.all(color: colorGreyNew),
                              borderRadius:
                                  BorderRadius.circular(size.width * numD02),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  "${iconsPath}ic_document_file.png",
                                  height: size.width * numD1,
                                ),
                                SizedBox(width: size.width * numD03),
                                Expanded(
                                  child: Text(
                                    doc.documentName.split('/').last,
                                    style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (doc.status != null &&
                                    doc.status!.isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: doc.status == 'Verified'
                                            ? colorOnlineGreen
                                            : (doc.status == 'Rejected'
                                                ? Colors.red
                                                : Colors.orange),
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Text(doc.status!,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10)),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    context
                                        .read<UploadDocumentsBloc>()
                                        .add(DeleteDocumentEvent(doc.id));
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickFiles(context, true);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickFiles(context, false);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFiles(BuildContext context, bool isGallery) async {
    try {
      final List<File> pickedFiles = [];
      if (isGallery) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['jpg', 'pdf', 'doc', 'png', 'jpeg'],
        );
        if (result != null) {
          pickedFiles.addAll(result.paths.map((path) => File(path!)).toList());
        }
      } else {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.camera);
        if (image != null) {
          pickedFiles.add(File(image.path));
        }
      }

      if (pickedFiles.isNotEmpty && context.mounted) {
        context.read<UploadDocumentsBloc>().add(UploadFilesEvent(pickedFiles));
      }
    } catch (e) {
      debugPrint("Error picking files: $e");
    }
  }
}
