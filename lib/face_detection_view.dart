import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_overlay/face_overlay_view.dart';

class FaceDetectionView extends StatefulWidget {
  const FaceDetectionView({Key? key}) : super(key: key);

  @override
  State<FaceDetectionView> createState() => FaceDetectionViewState();
}

class FaceDetectionViewState extends State<FaceDetectionView> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var viewPadding = MediaQuery.of(context).viewPadding;
    var roi = ROI(size: size, viewPadding: viewPadding);
    roi.calculateForKtp();
    return Container(
        color: Colors.transparent,
        child: FaceOverlayView(cardROI: roi.cardROI, faceROI: roi.faceROI, shouldShowDebugInfo: true, points: getCoordinatePoints(), shouldShowKTPAnimationView: true,));
  }
}

extension DebugPoints on FaceDetectionViewState {
  List<PointWithInfo> getCoordinatePoints() {
    List<PointWithInfo> pointsInfo = [];
    for (double i = 0; i < 2000; i+=100) {
      for (double j = 0; j < 2000; j+=100) {

        pointsInfo.add(PointWithInfo(location: Offset(i, j), info: '($i,$j)'));
      }
    }
    return pointsInfo;
  }
}

const cameraShutterContainerHeight = 134.0;

class ROI {
  late double width;
  late double spaceWidth;
  late double height;
  late double spaceHeight;
  final Size size;
  final EdgeInsets viewPadding;

  ROI({
    required this.size,
    required this.viewPadding,
  });

  void calculateForKtp() {
    var screenWidth = size.width;
    var screenHeight = size.height;
    var statusBarHeight = viewPadding.top;
    width = 91.85 / 100 * screenWidth;
    spaceWidth = 8.15 / 100 * screenWidth / 2;
    height = width *
        11 /
        18; //Change to 10 / 16 if the overlay is already in the middle
    var previewHeight =
        screenHeight - cameraShutterContainerHeight - statusBarHeight;
    spaceHeight = (previewHeight - height) / 2;
    debugPrint('ktp width & space: $width : $spaceWidth');
    debugPrint('ktp height & space: $height : $spaceHeight');
  }

  void calculateForSelfie() {
    var screenWidth = size.width;
    var screenHeight = size.height;
    var statusBarHeight = viewPadding.top;
    width = 84 / 100 * screenWidth;
    spaceWidth = 16 / 100 * screenWidth / 2;
    height = width;
    var previewHeight =
        screenHeight - cameraShutterContainerHeight - statusBarHeight;
    spaceHeight = (previewHeight - height) / 2;
    debugPrint('selfie width & space: $width : $spaceWidth');
    debugPrint('selfie height & space: $height : $spaceHeight');
  }

  Rect get cardROI {
    return Rect.fromPoints(
      Offset(spaceWidth, spaceHeight),
      Offset(width + spaceWidth, height + spaceHeight),
    );
  }

  Rect get faceROI {
    return ktpFaceROI;
  }

  Rect get ktpFaceROI {
    /*
    var topLeft = Offset(spaceWidth, spaceHeight).scale(16, 1.18);
    var topRight = Offset(width + spaceWidth, spaceHeight).scale(0.95, 1.18);
    var bottomLeft = Offset(spaceWidth, spaceHeight + height).scale(16, 0.836);
    var bottomRight =
        Offset(width + spaceWidth, spaceHeight + height).scale(0.95, 0.77);
    return Rect.fromPoints(topLeft, bottomRight);
     */


    /*
    var topLeft =  const Offset(0, 0);
    var bottomRight = const Offset(80, 90);
    return Rect.fromPoints(topLeft, bottomRight);
    */




   // var topLeft =  cardROI.topRight.scale(0.8, 1.2);
    //return Rect.fromCenter(center: topLeft, width: 100, height: 100);

    var topLeft =  cardROI.topRight.scale(0.7, 1.2);
    var bottomRight = cardROI.topRight.scale(0.94, 1.6);
    return Rect.fromPoints(topLeft, bottomRight);

  }
}
