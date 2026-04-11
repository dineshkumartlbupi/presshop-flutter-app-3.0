import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets_new.dart';

import 'package:presshop/features/authentication/presentation/bloc/upload_documents/upload_documents_bloc.dart';
import 'package:presshop/features/authentication/presentation/bloc/upload_documents/upload_documents_event.dart';
import 'package:presshop/features/authentication/presentation/bloc/upload_documents/upload_documents_state.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/features/authentication/domain/entities/document_instruction.dart';

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
    final instructions = [
      DocumentInstruction(id: "1", name: AppStrings.validDegreeText),
      DocumentInstruction(id: "2", name: AppStrings.validMembershipText),
      DocumentInstruction(id: "3", name: AppStrings.validPassportText),
      DocumentInstruction(id: "4", name: AppStrings.othersText),
    ];
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
              if ((state.status == UploadDocumentsStatus.loading ||
                      state.status == UploadDocumentsStatus.initial) &&
                  state.uploadedDocuments.isEmpty) {
                return CommonWidgetsNew.showAnimatedLoader(size);
              }

              return Stack(
                children: [
                  SafeArea(
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
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text:
                                      "${AppStrings.uploadDocsSubHeading1Text} ",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "AirbnbCereal",
                                      height: 1.5,
                                      fontSize:
                                          size.width * AppDimensions.numD035)),
                              WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Image.asset("${iconsPath}ic_pro.png",
                                      height:
                                          size.width * AppDimensions.numD06)),
                              TextSpan(
                                  text:
                                      " ${AppStrings.uploadDocsSubHeading2Text}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "AirbnbCereal",
                                      height: 1.5,
                                      fontSize:
                                          size.width * AppDimensions.numD035)),
                            ]),
                          ),
                          SizedBox(height: size.width * AppDimensions.numD04),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text:
                                      "Once your docs are approved, you will qualify as a ",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "AirbnbCereal",
                                      height: 1.5,
                                      fontSize:
                                          size.width * AppDimensions.numD035)),
                              WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Image.asset("${iconsPath}ic_pro.png",
                                      height:
                                          size.width * AppDimensions.numD06)),
                              TextSpan(
                                  text: "\nand be eligible for attractive ",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "AirbnbCereal",
                                      height: 1.5,
                                      fontSize:
                                          size.width * AppDimensions.numD035)),
                              TextSpan(
                                  text: "benefits",
                                  style: TextStyle(
                                      color: AppColorTheme.colorThemePink,
                                      fontFamily: "AirbnbCereal",
                                      height: 1.5,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      fontWeight: FontWeight.w600),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      context.pushNamed(
                                        AppRoutes.faqName,
                                        extra: {"type": "faq"},
                                      );
                                    }),
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
                            padding: EdgeInsets.all(
                                size.width * AppDimensions.numD04),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD02),
                                border: Border.all(color: Colors.black)),
                            child: Column(
                              children: [
                                _buildInstructionRow(
                                    size, AppStrings.validDegreeText),
                                _buildInstructionRow(
                                    size, AppStrings.validMembershipText),
                                _buildInstructionRow(
                                    size, AppStrings.validPassportText),
                                _buildInstructionRow(
                                    size, AppStrings.othersText),
                              ],
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
                                crossAxisSpacing:
                                    size.width * AppDimensions.numD03,
                                mainAxisSpacing:
                                    size.width * AppDimensions.numD03,
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
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                                      doc.documentUrl, // Use URL for image preview
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Center(
                                                              child: Icon(
                                                                  Icons
                                                                      .insert_drive_file,
                                                                  size: 40,
                                                                  color: Colors
                                                                      .grey)),
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
                                                          AppDimensions
                                                              .numD018),
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
                                        height:
                                            size.width * AppDimensions.numD02,
                                      ),
                                      Text(
                                        doc.documentName.split("/").last,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width *
                                                AppDimensions.numD03,
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
                                  AppDimensions
                                      .numD20), // Spacer for bottom button
                        ],
                      ),
                    ),
                  ),
                  if (state.status == UploadDocumentsStatus.loading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withOpacity(0.5),
                        child:
                            Center(child: CommonWidgetsNew.showAnimatedLoader(size)),
                      ),
                    ),
                ],
              );
            },
          ),
          // bottomNavigationBar: Padding(
          //   padding: EdgeInsets.all(size.width * AppDimensions.numD05),
          //   child: Builder(builder: (context) {
          //     return Container(
          //       height: size.width * AppDimensions.numD13,
          //       child: commonElevatedButton(
          //         "Upload Documents",
          //         size,
          //         commonButtonTextStyle(size),
          //         commonButtonStyle(size, AppColorTheme.colorThemePink),
          //         () {
          //           // Open Verification Sheet
          //           final state = context.read<UploadDocumentsBloc>().state;
          //           _showVerificationSheet(context, state.instructions);
          //         },
          //       ),
          //     );
          //   }),
          // )),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(size.width * AppDimensions.numD05),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Builder(builder: (context) {
                      return SizedBox(
                        height: size.width * AppDimensions.numD13,
                        child: commonElevatedButton(
                          "Upload",
                          size,
                          commonButtonTextStyle(size),
                          commonButtonStyle(size, AppColorTheme.colorThemePink),
                          () {
                            // Open Verification Sheet
                            _showVerificationSheet(context, instructions);
                          },
                        ),
                      );
                    }),
                  ),
                  SizedBox(width: size.width * AppDimensions.numD04),
                  Expanded(
                    child: SizedBox(
                      height: size.width * AppDimensions.numD13,
                      child: commonElevatedButton(
                        "Exit",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, Colors.black),
                        () {
                          context.pop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildInstructionRow(Size size, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.width * AppDimensions.numD02),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(
                top: size.width * AppDimensions.numD012,
              ),
              child: Icon(
                Icons.circle,
                color: AppColorTheme.colorThemePink,
                size: size.width * AppDimensions.numD035,
              ),
            ),
            SizedBox(
              width: size.width * AppDimensions.numD03,
            ),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: size.width * AppDimensions.numD036,
                      color: Colors.black,
                      fontFamily: "AirbnbCereal",
                      fontWeight: FontWeight.w400)),
            ),
          ]),
    );
  }

  void _showTopOverlayAlert(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: size.width * AppDimensions.numD05,
                vertical: size.width * AppDimensions.numD04),
            color: Colors.red,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Error",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: size.width * AppDimensions.numD04)),
                SizedBox(height: 4),
                Text(message,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      entry.remove();
    });
  }

  void _showVerificationSheet(
      BuildContext contextValue, List<dynamic> instructions) {
    // Track uploaded files per instruction index
    Map<int, List<File>> uploadedFilesPerInstruction = {};

    // Helper to get all files across all instructions
    List<File> getAllFiles() {
      final allFiles = <File>[];
      uploadedFilesPerInstruction.forEach((_, files) {
        allFiles.addAll(files);
      });
      return allFiles;
    }

    // Helper to pick files for the currently selected instruction (only 1 file per option)
    Future<void> pickFilesForInstruction(
        int instructionIndex, StateSetter setModalState) async {
      bool? isGallery = await _showSelectionOption(contextValue);
      if (isGallery != null) {
        List<File>? files = await _pickFilesNew(contextValue, isGallery);
        if (files != null && files.isNotEmpty) {
          setModalState(() {
            // Only keep the first picked file — one upload per option
            uploadedFilesPerInstruction[instructionIndex] = [files.first];
          });
        }
      }
    }

    showModalBottomSheet(
      context: contextValue,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bc) {
        return StatefulBuilder(builder: (context, setModalState) {
          // All uploaded files across all options for display
          List<File> allUploadedFiles = getAllFiles();

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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.width * AppDimensions.numD035),
                        Text(
                          "Kindly upload clear copies of your original documents to complete bank verification.",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "AirbnbCereal",
                              fontSize: size.width * AppDimensions.numD035),
                        ),
                        SizedBox(height: size.width * AppDimensions.numD04),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: instructions.length,
                          itemBuilder: (context, index) {
                            // Checkmark only if files have been uploaded for this option
                            bool hasUploadedFiles =
                                (uploadedFilesPerInstruction[index] ?? [])
                                    .isNotEmpty;
                            return InkWell(
                              onTap: () async {
                                // Check if already uploaded for this option
                                if ((uploadedFilesPerInstruction[index] ?? [])
                                    .isNotEmpty) {
                                  _showTopOverlayAlert(contextValue,
                                      "You have already uploaded ${instructions[index].name}.");
                                  return;
                                }
                                setModalState(() {
                                  selectedDocType = instructions[index].name;
                                });
                                // Immediately open file picker for this option
                                await pickFilesForInstruction(
                                    index, setModalState);
                              },
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: size.width *
                                              AppDimensions.numD005),
                                      child: hasUploadedFiles
                                          ? Icon(
                                              Icons.check_box,
                                              color:
                                                  AppColorTheme.colorThemePink,
                                              size: size.width *
                                                  AppDimensions.numD05,
                                            )
                                          : Icon(
                                              Icons.circle,
                                              color:
                                                  AppColorTheme.colorThemePink,
                                              size: size.width *
                                                  AppDimensions.numD035,
                                            ),
                                    ),
                                    SizedBox(
                                      width: size.width * AppDimensions.numD04,
                                    ),
                                    Expanded(
                                      child: Text(instructions[index].name,
                                          style: TextStyle(
                                              fontSize: size.width *
                                                  AppDimensions.numD035,
                                              color: Colors.black,
                                              fontFamily: "AirbnbCereal",
                                              fontWeight: FontWeight.w400)),
                                    ),
                                  ]),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height: size.width * AppDimensions.numD025,
                            );
                          },
                        ),

                        SizedBox(height: size.width * AppDimensions.numD06),

                        // Dropdown to select document
                        InkWell(
                          onTap: () async {
                            // 1. Pick document type
                            final docType = await _showDocumentTypeSheet(
                                contextValue, instructions);
                            if (docType != null) {
                              final instrIndex = instructions
                                  .indexWhere((e) => e.name == docType);

                              // Check if already uploaded for this option
                              if (instrIndex >= 0 &&
                                  (uploadedFilesPerInstruction[instrIndex] ??
                                          [])
                                      .isNotEmpty) {
                                _showTopOverlayAlert(contextValue,
                                    "You have already uploaded $docType.");
                                return;
                              }

                              setModalState(() {
                                selectedDocType = docType;
                              });

                              // 2. Pick files for the selected instruction
                              if (instrIndex >= 0) {
                                await pickFilesForInstruction(
                                    instrIndex, setModalState);
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(
                                size.width * AppDimensions.numD035),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColorTheme.colorTextFieldBorder),
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD03)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Text(
                                        selectedDocType ?? "Select Document",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: selectedDocType == null
                                                ? Colors.grey
                                                : Colors.black,
                                            fontSize: size.width *
                                                AppDimensions.numD035,
                                            fontFamily: "AirbnbCereal"))),
                                const Icon(
                                  Icons.keyboard_arrow_down_sharp,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Show all uploaded files across all options
                        if (allUploadedFiles.isNotEmpty) ...[
                          SizedBox(height: size.width * AppDimensions.numD06),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing:
                                  size.width * AppDimensions.numD03,
                              mainAxisSpacing:
                                  size.width * AppDimensions.numD03,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: allUploadedFiles.length,
                            itemBuilder: (context, index) {
                              final file = allUploadedFiles[index];
                              bool isImage = file.path.endsWith('.jpg') ||
                                  file.path.endsWith('.png') ||
                                  file.path.endsWith('.jpeg');
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
                                            child: isImage
                                                ? Image.file(
                                                    file,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  )
                                                : Center(
                                                    child: Icon(
                                                      Icons.insert_drive_file,
                                                      color: AppColorTheme
                                                          .colorThemePink,
                                                      size: size.width * 0.1,
                                                    ),
                                                  ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setModalState(() {
                                                // Find which instruction this file belongs to and remove it
                                                for (var key
                                                    in uploadedFilesPerInstruction
                                                        .keys
                                                        .toList()) {
                                                  if (uploadedFilesPerInstruction[
                                                              key]
                                                          ?.contains(file) ==
                                                      true) {
                                                    uploadedFilesPerInstruction[
                                                            key]
                                                        ?.remove(file);
                                                    if ((uploadedFilesPerInstruction[
                                                                key] ??
                                                            [])
                                                        .isEmpty) {
                                                      uploadedFilesPerInstruction
                                                          .remove(key);
                                                    }
                                                    break;
                                                  }
                                                }
                                              });
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
                                                      AppDimensions.numD05,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            size.width * AppDimensions.numD02),
                                    Text(
                                      file.path.split("/").last,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize:
                                              size.width * AppDimensions.numD03,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],

                        SizedBox(height: size.width * AppDimensions.numD06),
                      ],
                    ),
                  ),
                ),

                // Submit Button
                SafeArea(
                  child: BlocBuilder<UploadDocumentsBloc, UploadDocumentsState>(
                    bloc: contextValue.read<UploadDocumentsBloc>(),
                    builder: (context, state) {
                      return SizedBox(
                        width: size.width,
                        height: size.width * AppDimensions.numD13,
                        child: state.status == UploadDocumentsStatus.loading
                            ? Center(
                                child:
                                    CommonWidgetsNew.showAnimatedLoader(size))
                            : commonElevatedButton(
                                AppStrings.submitText,
                                size,
                                commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                                commonButtonStyle(
                                    size, AppColorTheme.colorThemePink), () {
                                final allFiles = getAllFiles();
                                if (allFiles.isEmpty) {
                                  ScaffoldMessenger.of(contextValue)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                              "Please upload at least one document")));
                                  return;
                                }

                                // Dispatch upload event with all files
                                contextValue
                                    .read<UploadDocumentsBloc>()
                                    .add(UploadFilesEvent(allFiles));
                              }),
                      );
                    },
                  ),
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
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: size.width * AppDimensions.numD048,
                            fontFamily: "AirbnbCereal",
                            fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: Colors.black,
                            size: size.width * AppDimensions.numD08),
                        onPressed: () => context.pop(),
                      )
                    ],
                  ),
                  const Divider(color: Colors.black, thickness: 1.2),
                  SizedBox(height: size.width * AppDimensions.numD02),
                  ...instructions
                      .map((e) => InkWell(
                            onTap: () {
                              context.pop(e.name);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.width * AppDimensions.numD03),
                              child: Text(e.name,
                                  style: TextStyle(
                                      fontSize:
                                          size.width * AppDimensions.numD038,
                                      color: Colors.black,
                                      fontFamily: "AirbnbCereal",
                                      fontWeight: FontWeight.w400)),
                            ),
                          ))
                      ,
                  SizedBox(height: size.width * AppDimensions.numD05),
                ],
              ));
        });
  }

  Future<bool?> _showSelectionOption(BuildContext context) async {
    var size = MediaQuery.sizeOf(context);
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bc) {
        return SafeArea(
          child: Container(
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
                                    size.width * AppDimensions.numD04),
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
                                    size.width * AppDimensions.numD04),
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
          ),
        );
      },
    );
  }

  Future<List<File>?> _pickFilesNew(
      BuildContext context, bool isGallery) async {
    try {
      final List<File> pickedFiles = [];
      if (isGallery) {
        // My Gallery - only 1 image allowed
        final ImagePicker picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          pickedFiles.add(File(image.path));
        }
      } else {
        // My Files
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
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
}
