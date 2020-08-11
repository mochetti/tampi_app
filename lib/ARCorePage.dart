import 'ARPage.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARCoreState extends State<ARPage> {
  ArCoreController arCoreController;
  Map<int, ArCoreAugmentedImage> augmentedImagesMap = Map();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AR Core'),
        ),
        body: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
          type: ArCoreViewType.AUGMENTEDIMAGES,
        ),
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) async {
    arCoreController = controller;
    arCoreController.onTrackingImage = _handleOnTrackingImage;
    loadSingleImage();
    //OR
//    loadImagesDatabase();
  }

  loadSingleImage() async {
    final ByteData bytes = await rootBundle.load('assets/cebolinha.png');
    arCoreController.loadSingleAugmentedImage(
        bytes: bytes.buffer.asUint8List());
  }

  loadImagesDatabase() async {
    final ByteData bytes = await rootBundle.load('assets/myimages.imgdb');
    arCoreController.loadAugmentedImagesDatabase(
        bytes: bytes.buffer.asUint8List());
  }

  _handleOnTrackingImage(ArCoreAugmentedImage augmentedImage) {
    if (!augmentedImagesMap.containsKey(augmentedImage.index)) {
      augmentedImagesMap[augmentedImage.index] = augmentedImage;
      atualizaTampi(augmentedImage);
    }
  }

  Future atualizaTampi(ArCoreAugmentedImage augmentedImage) async {

    final arrow = ArCoreReferenceNode(
        name: 'tampi',
        objectUrl: 'assets/arrow.dae',
        position: augmentedImage.centerPose.translation,
        rotation: augmentedImage.centerPose.rotation);

    await arCoreController.addArCoreNode(arrow);                                // esse await adianta alguma coisa aqui ?
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}
