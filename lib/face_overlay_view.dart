import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'ktp_view.dart';

enum FaceGuideType {
  hide,
  showROIAndFaceROI,
}

class FaceOverlayView extends StatefulWidget {
  Rect cardROI;
  Rect faceROI;
  bool shouldShowDebugInfo;
  List<PointWithInfo> points;
  bool shouldShowKTPAnimationView;

  FaceOverlayView(
      {super.key,
      required this.cardROI,
      required this.faceROI,
      required this.shouldShowDebugInfo,
      required this.points,
      required this.shouldShowKTPAnimationView});


  @override
  State<FaceOverlayView> createState() => FaceOverlayViewState();
}

class FaceOverlayViewState extends State<FaceOverlayView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        drawSemiOpaqueOverlay(),
        drawROICornerGuide(),
        if (widget.shouldShowDebugInfo) drawDebugView(),
        if(widget.shouldShowKTPAnimationView) _buildKTPAnimationView(),
        drawFaceGuide(),
      ],
    );
  }
}

// MARK: Overlay

extension Overlay on FaceOverlayViewState {
  ColorFiltered drawSemiOpaqueOverlay() {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.6),
        BlendMode.srcOut,
      ), // This one will create the magic
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.pink,
              backgroundBlendMode: BlendMode.dstOut,
            ), // This one will handle background + difference out
          ),
          drawROICutoutView(),
        ],
      ),
    );
  }

  Widget drawROICutoutView() {
    return CustomPaint(
      painter: MaskPainter(widget.cardROI),
    );
  }

  Widget drawROICornerGuide() {
    var borderColor = widget.shouldShowDebugInfo ? Colors.yellow : Colors.transparent;
    return Stack(children: [
      Positioned(
        left: widget.cardROI.left,
        top: widget.cardROI.top,
        width: widget.cardROI.width,
        height: widget.cardROI.height,
        child: CustomPaint(
          painter: ROICornerGuidePainter(
              cornarColor: Colors.deepOrangeAccent, borderColor: borderColor),
        ),
      ),
    ]);
  }
}

// MARK: FaceGuide

extension FaceGuide on FaceOverlayViewState {
  Widget drawFaceGuide() {
    return Stack(
      children: [
        drawFaceAreaGuide(),
        _buildFaceView(),
      ],
    );
  }

  Widget _buildFaceView() {
    return Positioned(
        //right: myFaceROI.width,
        left: myFaceROI.left + 10,
        top: myFaceROI.top + 10,
        width: myFaceROI.width - 20,
        height: myFaceROI.height - 20,
        child: Container(
          color: Colors.transparent,
        ));
  }

  Rect get myFaceROI {
    var cardROI = widget.faceROI;
    return cardROI;
  }

  Widget drawFaceAreaGuide() {
    return Positioned(
        //right: myFaceROI.width,
        left: myFaceROI.left,
        top: myFaceROI.top,
        width: myFaceROI.width,
        height: myFaceROI.height,
        child: CustomPaint(
          painter: FaceROIGuidePainter(
              shouldShowDebugInfo: widget.shouldShowDebugInfo),
        ));
  }
}

extension KTPAnimationView on FaceOverlayViewState {
  Widget _buildKTPAnimationView() {
    return Positioned(
      //right: myFaceROI.width,
        left: widget.cardROI.left,
        top: widget.cardROI.top,
        width: widget.cardROI.width,
        height: widget.cardROI.height,
        child: Container(
          padding: const EdgeInsets.all(10),
          color: Colors.transparent,
          child: const KTPView(),
        ));
  }
}
extension DebugView on FaceOverlayViewState {
  Widget drawDebugView() {
    return Stack(
      children: [drawFaceROI(), drawCoordinatesView()],
    );
  }

  Widget drawFaceROI() {
    return Positioned(
      //right: myFaceROI.width,
      left: myFaceROI.left- 3,
      top: myFaceROI.top - 3,
      width: myFaceROI.height + 6,
      height: myFaceROI.width + 6,
      child: CustomPaint(
        painter: FaceROIPainter(),
      ),
    );
  }

  Widget drawCoordinatesView() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: CustomPaint(
          painter: CoordinatesGuidePainter(pointInfoList: widget.points),
        ),
      );
    });
  }
}

class FaceROIGuidePainter extends CustomPainter {
  bool shouldShowDebugInfo;

  FaceROIGuidePainter({required this.shouldShowDebugInfo});

  @override
  void paint(Canvas canvas, Size size) {
    var rect =
        Rect.fromPoints(const Offset(0, 0), Offset(size.height, size.width));
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    double dashWidth = 1, dashSpace = 7, startX = 0, minY = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }

    while (minY < size.height) {
      canvas.drawLine(Offset(size.width, minY),
          Offset(size.width, minY + dashWidth), paint);
      minY += dashWidth + dashSpace;
    }

    startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height),
          Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }

    minY = 0;

    while (minY < size.height) {
      canvas.drawLine(Offset(0, minY), Offset(0, minY + dashWidth), paint);
      minY += dashWidth + dashSpace;
    }

    if (shouldShowDebugInfo) {
      var guideRect = Rect.fromPoints(
          rect.topLeft.scale(1.2, 1.2), rect.bottomRight.scale(1.2, 1.2));
      //canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(FaceROIGuidePainter oldDelegate) {
    return false;
  }
}

class FaceROIPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var rect =
        Rect.fromPoints(const Offset(0, 0), Offset(size.height, size.width));
    final paint = Paint()
      ..color = Colors.lightBlue
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(FaceROIPainter oldDelegate) {
    return false;
  }
}

class MaskPainter extends CustomPainter {
  Rect cardROI;

  MaskPainter(this.cardROI);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawRect(cardROI, paint);
  }

  @override
  bool shouldRepaint(MaskPainter oldDelegate) {
    return false;
  }
}

class ROICornerGuidePainter extends CustomPainter {
  final Color cornarColor;
  final Color borderColor;

  ROICornerGuidePainter({required this.cornarColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;
    double r = 10; //<-- corner radius
    double extraLine = 40; //<--- lines in ptr

    Paint blackPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Paint redPaint = Paint()
      ..color = cornarColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    RRect fullRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w / 2, h / 2), width: w, height: h),
      Radius.circular(r),
    );

    Path topLeftArc = Path();
    topLeftArc.moveTo(0, 0 + extraLine);
    topLeftArc.lineTo(0, 0 + r);
    topLeftArc.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    topLeftArc.lineTo(extraLine, 0);

    Path topRightArc = Path();
    topRightArc.moveTo(w - extraLine, 0);
    topRightArc.lineTo(w - r, 0);
    topRightArc.arcToPoint(Offset(w, r), radius: Radius.circular(r));
    topRightArc.lineTo(w, extraLine);

    Path bottomLeftArc = Path();
    bottomLeftArc.moveTo(extraLine, h);
    bottomLeftArc.lineTo(r, h);
    bottomLeftArc.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));
    bottomLeftArc.lineTo(0, h - extraLine);

    Path bottomRightArc = Path();
    bottomRightArc.moveTo(w, h - extraLine);
    bottomRightArc.lineTo(w, h - r);
    bottomRightArc.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));
    bottomRightArc.lineTo(w - r - extraLine, h);

    canvas.drawRRect(fullRect, blackPaint);
    canvas.drawPath(topLeftArc, redPaint);
    canvas.drawPath(topRightArc, redPaint);
    canvas.drawPath(bottomLeftArc, redPaint);
    canvas.drawPath(bottomRightArc, redPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CoordinatesGuidePainter extends CustomPainter {
  List<PointWithInfo> pointInfoList;

  CoordinatesGuidePainter({required this.pointInfoList});

  @override
  void paint(Canvas canvas, Size size) {
    const pointMode = PointMode.points;
    List<Offset> points = [];

    for (PointWithInfo info in pointInfoList) {
      var name = info.info;
      points.add(info.location);

      const textStyle = TextStyle(
        color: Colors.red,
        fontSize: 10,
      );
      var textSpan = TextSpan(
        text: name,
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.rtl,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      final offset = info.location;
      textPainter.paint(canvas, offset);
    }

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(pointMode, points, paint);
  }

  @override
  bool shouldRepaint(CoordinatesGuidePainter oldDelegate) {
    return false;
  }
}

class PointWithInfo {
  Offset location;
  String info;
  PointWithInfo({required this.location, required this.info});
}
