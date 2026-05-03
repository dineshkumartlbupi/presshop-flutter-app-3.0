import 'package:flutter/material.dart';

class CommentInputWidget extends StatelessWidget {

  const CommentInputWidget({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText,
    this.height,
    this.autofocus = false,
  });
  final TextEditingController controller;
  final VoidCallback onSend;
  final String? hintText;
  final double? height;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Apply correct height logic: fixed if provided, else auto with min constraints
      height: height,
      constraints: height == null
          ? const BoxConstraints(minHeight: 80)
          : null, // Min height only if dynamic
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // Aligns button to bottom
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              maxLines: null, // Allow multiline
              // If height is fixed, we want to fill it (expands=true, minLines=null)
              // If height is dynamic, we want to start with 3 lines (expands=false, minLines=3)
              expands: height != null,
              minLines: height != null ? null : 3,
              keyboardType: TextInputType.multiline,
              textAlignVertical: TextAlignVertical.top, // Start text at top
              style: const TextStyle(fontSize: 14, color: Colors.black),
              decoration: InputDecoration(
                hintText: hintText ?? "Leave your comment",
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets
                    .zero, // Remove internal padding to align with container
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              height: 24,
              width: 24,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Image.asset(
                "assets/icons/comment_send.png",
                height: 16,
                width: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
