import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';

import 'package:presshop/features/authentication/presentation/bloc/upload_documents/upload_documents_bloc.dart';
import 'package:presshop/features/authentication/presentation/bloc/upload_documents/upload_documents_event.dart';
import 'package:presshop/features/authentication/presentation/bloc/upload_documents/upload_documents_state.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/widgets/common_widgets.dart';

const String uploadDocumentsText = "Upload Documents";

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen(
      {super.key, required this.menuScreen, required this.hideLeading});
  final bool menuScreen;
  final bool hideLeading;

  @override
  State<StatefulWidget> createState() {
    return UploadDocumentsScreenState();
  }
}

class UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  late Size size;
  String? selectedDocType;

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
                fontSize: size.width * AppDimensions.appBarHeadingFontSize,
              ),
            ),
            centerTitle: false,
            titleSpacing: 0,
            size: size,
            showActions: false,
            leadingFxn: () {
              context.pop();
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
                context.pop(); // Close any open sheets if needed
              } else if (state.status == UploadDocumentsStatus.deleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Document deleted successfully')),
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
                return const SizedBox.shrink();
              }

              return SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * AppDimensions.numD04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.width * AppDimensions.numD06),
                      Text(
                        AppStrings.uploadDocsHeadingText,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontFamily: "AirbnbCereal",
                            fontSize: size.width * AppDimensions.numD07),
                      ),
                      SizedBox(height: size.width * AppDimensions.numD02),
                      Text(
                        "If you're a professional photographer or journalist, and want to sign up as a PRO please upload your docs for review.",
                        style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: size.width * AppDimensions.numD02),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: "${AppStrings.uploadDocsSubHeading1Text} ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "AirbnbCereal",
                                  fontSize:
                                      size.width * AppDimensions.numD035)),
                          WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Image.asset("${iconsPath}ic_pro.png",
                                  height: size.width * AppDimensions.numD06)),
                          TextSpan(
                              text: " ${AppStrings.uploadDocsSubHeading2Text}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "AirbnbCereal",
                                  fontSize:
                                      size.width * AppDimensions.numD035)),
                        ]),
                      ),

                      SizedBox(height: size.width * AppDimensions.numD06),

                      // Instructions List (Checklist style from screenshot 1)
                      Text("Upload your documents for verification (any 2)",
                          style: TextStyle(
                              fontSize: size.width * AppDimensions.numD038,
                              color: Colors.black,
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.w400)),
                      SizedBox(height: size.width * AppDimensions.numD04),
                      Container(
                        padding:
                            EdgeInsets.all(size.width * AppDimensions.numD04),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(
                                size.width * AppDimensions.numD02),
                            border: Border.all(color: Colors.black)),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.instructions.length,
                          itemBuilder: (context, index) {
                            return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: size.width * AppDimensions.numD009,
                                    ),
                                    child: Icon(
                                      Icons.circle,
                                      color: AppColorTheme.colorThemePink,
                                      size: size.width * AppDimensions.numD035,
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD02,
                                  ),
                                  Expanded(
                                    child: Text(state.instructions[index].name,
                                        style: TextStyle(
                                            fontSize: size.width *
                                                AppDimensions.numD036,
                                            color: Colors.black,
                                            fontFamily: "AirbnbCereal",
                                            fontWeight: FontWeight.w400)),
                                  ),
                                ]);
                          },
                        ),
                      ),

                      SizedBox(height: size.width * AppDimensions.numD05),

                      // Uploaded Documents Grid/List
                      if (state.uploadedDocuments.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: size.width * AppDimensions.numD03,
                            mainAxisSpacing: size.width * AppDimensions.numD03,
                            childAspectRatio: 1,
                          ),
                          itemCount: state.uploadedDocuments.length,
                          itemBuilder: (context, index) {
                            final doc = state.uploadedDocuments[index];
                            return Container(
                              padding: EdgeInsets.all(
                                  size.width * AppDimensions.numD025),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD04),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD03),
                                          child: doc.documentName
                                                  .endsWith(".pdf")
                                              ? Image.asset(
                                                  "${iconsPath}pdfIcon.png",
                                                  height: size.width *
                                                      AppDimensions.numD28,
                                                  width: size.width *
                                                      AppDimensions.numD38,
                                                )
                                              : Image.network(
                                                  doc.documentName, // Assuming doc is an image for preview
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Center(
                                                          child: Icon(
                                                              Icons
                                                                  .insert_drive_file,
                                                              size: 40,
                                                              color:
                                                                  Colors.grey)),
                                                ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            context
                                                .read<UploadDocumentsBloc>()
                                                .add(DeleteDocumentEvent(
                                                    doc.id));
                                          },
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                  size.width *
                                                      AppDimensions.numD018),
                                              child: Image.asset(
                                                  "${iconsPath}ic_deleteIcon.png",
                                                  height: size.width *
                                                      AppDimensions.numD05),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.width * AppDimensions.numD02,
                                  ),
                                  Text(
                                    doc.documentName.split("/").last,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD03,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    height: Platform.isIOS
                                        ? size.width * AppDimensions.numD02
                                        : 0,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                      SizedBox(
                          height: size.width *
                              AppDimensions.numD20), // Spacer for bottom button
                    ],
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(size.width * AppDimensions.numD05),
            child: Builder(builder: (context) {
              return Container(
                height: size.width * AppDimensions.numD13,
                child: commonElevatedButton(
                  "Upload Documents",
                  size,
                  commonButtonTextStyle(size),
                  commonButtonStyle(size, AppColorTheme.colorThemePink),
                  () {
                    // Open Verification Sheet
                    final state = context.read<UploadDocumentsBloc>().state;
                    _showVerificationSheet(context, state.instructions);
                  },
                ),
              );
            }),
          )),
    );
  }

  void _showVerificationSheet(
      BuildContext contextValue, List<dynamic> instructions) {
    List<File> selectedFiles = [];

    showModalBottomSheet(
      context: contextValue,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bc) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            height: size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size.width * AppDimensions.numD05),
                topRight: Radius.circular(size.width * AppDimensions.numD05),
              ),
            ),
            padding: EdgeInsets.all(size.width * AppDimensions.numD05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Upload docs for verification",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD045,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1.3,
                ),
                SizedBox(height: size.width * AppDimensions.numD035),
                Text(
                  "Kindly upload clear copies of your original documents to complete bank verification.",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: "AirbnbCereal",
                      fontSize: size.width * AppDimensions.numD035),
                ),
                SizedBox(height: size.width * AppDimensions.numD04),
                Expanded(
                  child: ListView.separated(
                    itemCount: instructions.length,
                    itemBuilder: (context, index) {
                      return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: size.width * AppDimensions.numD005),
                              child: Icon(
                                Icons.circle,
                                color: AppColorTheme.colorThemePink,
                                size: size.width * AppDimensions.numD035,
                              ),
                            ),
                            SizedBox(
                              width: size.width * AppDimensions.numD04,
                            ),
                            Expanded(
                              child: Text(instructions[index].name,
                                  style: TextStyle(
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      color: Colors.black,
                                      fontFamily: "AirbnbCereal",
                                      fontWeight: FontWeight.w400)),
                            ),
                          ]);
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: size.width * AppDimensions.numD025,
                      );
                    },
                  ),
                ),

                // Dropdown to select document
                InkWell(
                  onTap: () async {
                    final result = await _showDocumentTypeSheet(
                        contextValue, instructions);
                    if (result != null) {
                      setModalState(() {
                        selectedDocType = result;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(size.width * AppDimensions.numD035),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColorTheme.colorTextFieldBorder),
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD03)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(selectedDocType ?? "Select Document",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: selectedDocType == null
                                        ? Colors.grey
                                        : Colors.black,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    fontFamily: "AirbnbCereal"))),
                        const Icon(
                          Icons.keyboard_arrow_down_sharp,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: size.width * AppDimensions.numD06),

                // File selection box
                InkWell(
                  onTap: () async {
                    // Show option to pick between Gallery and Files
                    bool? isGallery = await _showSelectionOption(contextValue);
                    if (isGallery != null) {
                      List<File>? files =
                          await _pickFilesNew(contextValue, isGallery);
                      if (files != null && files.isNotEmpty) {
                        setModalState(() {
                          selectedFiles.addAll(files);
                        });
                      }
                    }
                  },
                  child: Container(
                    width: size.width,
                    padding: EdgeInsets.all(size.width * AppDimensions.numD03),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColorTheme.colorThemePink,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD03),
                        color: AppColorTheme.colorThemePink
                            .withValues(alpha: 0.05)),
                    child: selectedFiles.isNotEmpty
                        ? Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedFiles.map((file) {
                              bool isImage = file.path.endsWith('.jpg') ||
                                  file.path.endsWith('.png') ||
                                  file.path.endsWith('.jpeg');
                              return Stack(
                                children: [
                                  Container(
                                    width: size.width * 0.2,
                                    height: size.width * 0.2,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.grey.shade300)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: isImage
                                          ? Image.file(file, fit: BoxFit.cover)
                                          : Icon(Icons.insert_drive_file,
                                              color:
                                                  AppColorTheme.colorThemePink,
                                              size: size.width * 0.08),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: () {
                                        setModalState(() {
                                          selectedFiles.remove(file);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.cancel,
                                            color: Colors.red, size: 20),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            }).toList(),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.file_upload_outlined,
                                  color: AppColorTheme.colorThemePink,
                                  size: size.width * 0.08),
                              SizedBox(height: size.width * 0.02),
                              Text("Tap to select image or document",
                                  style: TextStyle(
                                      color: AppColorTheme.colorThemePink,
                                      fontFamily: "AirbnbCereal",
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                  ),
                ),

                // Submit Button
                SizedBox(
                  width: size.width,
                  height: size.width * AppDimensions.numD13,
                  child: commonElevatedButton(
                      AppStrings.submitText,
                      size,
                      commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD035,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                      commonButtonStyle(size, AppColorTheme.colorThemePink),
                      () {
                    if (selectedDocType == null) {
                      ScaffoldMessenger.of(contextValue).showSnackBar(
                          const SnackBar(
                              content: Text("Please select a document type")));
                      return;
                    }
                    if (selectedFiles.isEmpty) {
                      ScaffoldMessenger.of(contextValue).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Please select an image or document to upload")));
                      return;
                    }
                    // Dispatch upload event with the selected files
                    contextValue
                        .read<UploadDocumentsBloc>()
                        .add(UploadFilesEvent(selectedFiles));
                  }),
                ),
                SizedBox(height: size.width * AppDimensions.numD04),
              ],
            ),
          );
        });
      },
    );
  }

  Future<String?> _showDocumentTypeSheet(
      BuildContext context, List<dynamic> instructions) {
    return showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (bc) {
          return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size.width * AppDimensions.numD05),
                  topRight: Radius.circular(size.width * AppDimensions.numD05),
                ),
              ),
              padding: EdgeInsets.all(size.width * AppDimensions.numD05),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Document",
                        style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD05,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => context.pop(),
                      )
                    ],
                  ),
                  Divider(),
                  ...instructions
                      .map((e) => ListTile(
                            title: Text(e.name,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal)),
                            onTap: () {
                              context.pop(e.name);
                            },
                          ))
                      .toList(),
                  SizedBox(height: size.width * AppDimensions.numD05),
                ],
              ));
        });
  }

  Future<bool?> _showSelectionOption(BuildContext context) async {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bc) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size.width * AppDimensions.numD05),
              topRight: Radius.circular(size.width * AppDimensions.numD05),
            ),
          ),
          padding: EdgeInsets.all(size.width * AppDimensions.numD05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Option",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: size.width * AppDimensions.numD048,
                        fontFamily: "AirbnbCereal",
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: Icon(Icons.close_rounded,
                          color: Colors.black,
                          size: size.width * AppDimensions.numD08)),
                ],
              ),
              const Divider(color: Colors.black, thickness: 1.2),
              SizedBox(
                height: size.width * AppDimensions.numD04,
              ),
              Container(
                margin: EdgeInsets.only(
                    left: size.width * AppDimensions.numD06,
                    right: size.width * AppDimensions.numD06),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          context.pop(true);
                        },
                        child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(
                                  size.width * AppDimensions.numD02),
                            ),
                            height: size.width * AppDimensions.numD25,
                            padding: EdgeInsets.all(
                                size.width * AppDimensions.numD02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.file_upload_outlined,
                                    size: size.width * AppDimensions.numD08),
                                SizedBox(
                                  height: size.width * AppDimensions.numD03,
                                ),
                                Text(
                                  "My Gallery",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      fontFamily: "AirbnbCereal",
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            )),
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.05,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          context.pop(false);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(
                                  size.width * AppDimensions.numD02),
                            ),
                            height: size.width * AppDimensions.numD25,
                            padding: EdgeInsets.all(
                                size.width * AppDimensions.numD04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.file_copy_outlined,
                                  size: size.width * AppDimensions.numD08,
                                ),
                                SizedBox(
                                  height: size.width * AppDimensions.numD03,
                                ),
                                Text(
                                  "My Files",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      fontFamily: "AirbnbCereal",
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD06,
              ),
            ],
          ),
        );
      },
    );
  }

  // New helper to distinguish gallery vs files cleaner
  Future<List<File>?> _pickFilesNew(
      BuildContext context, bool isGallery) async {
    try {
      final List<File> pickedFiles = [];
      if (isGallery) {
        // My Gallery
        final ImagePicker picker = ImagePicker();
        final List<XFile> images = await picker.pickMultiImage();
        if (images.isNotEmpty) {
          pickedFiles.addAll(images.map((e) => File(e.path)).toList());
        }
      } else {
        // My Files
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['jpg', 'pdf', 'doc', 'png', 'jpeg'],
        );
        if (result != null) {
          pickedFiles.addAll(result.paths.map((path) => File(path!)).toList());
        }
      }

      return pickedFiles;
    } catch (e) {
      debugPrint("Error picking files: $e");
      return null;
    }
  }

  Future<void> _pickFiles(BuildContext context, bool isGallery) async {
    // Forward to new method with corrected mapping
    // original: isGallery(true)=FilePicker, false=Camera
    // new: true=Gallery(ImagePicker), false=FilePicker
    // This mapping is tricky. I'll just use _pickFilesNew in the UI calls.
    _pickFilesNew(context, isGallery);
  }
}
