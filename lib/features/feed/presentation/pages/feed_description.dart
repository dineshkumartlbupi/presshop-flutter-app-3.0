import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;

  const ExpandableText({
    super.key,
    required this.text,
    this.trimLines = 4,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _readMore = true;
  late String firstHalf;
  late String secondHalf;
  bool _isOverflow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  void _checkOverflow() {
    final textSpan = TextSpan(
      text: widget.text,
      style: DefaultTextStyle.of(context).style,
    );
    final tp = TextPainter(
      text: textSpan,
      maxLines: widget.trimLines,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: MediaQuery.of(context).size.width);
    setState(() {
      _isOverflow = tp.didExceedMaxLines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      var size = MediaQuery.of(context).size;

      final span = TextSpan(
        text: widget.text,
        style: DefaultTextStyle.of(context).style,
      );
      final tp = TextPainter(
        text: span,
        maxLines: widget.trimLines,
        textDirection: TextDirection.ltr,
      );
      tp.layout(maxWidth: size.width);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: commonTextStyle(
                size: size,
                fontSize: size.width * numD03,
                lineHeight: 2,
                color: Colors.black,
                fontWeight: FontWeight.normal),
            maxLines: _readMore ? widget.trimLines : null,
            overflow: _readMore ? TextOverflow.ellipsis : TextOverflow.visible,
          ),
          if (tp.didExceedMaxLines)
            GestureDetector(
              onTap: () => setState(() => _readMore = !_readMore),
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  _readMore ? 'See more' : 'See less',
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD03,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      );
    });
  }
}

// Example usage:
// ExpandableText(text: "Your long description goes here...")
