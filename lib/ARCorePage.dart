import 'ARPage.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARCoreState extends State<ARPage> {
  ArCoreController arCoreController;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ARCore'),
        ),
        body: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
          enableTapRecognizer: true,
        ),
      ),
    );
  }
  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;

//    arCoreController.onPlaneTap = _onPlaneTapHandler;

    arCoreController.onPlaneDetected = _onPlaneDetected;
  }

  void _onPlaneDetected(ArCorePlane plane) {
    print("plano detected");

    final earthMaterial = ArCoreMaterial(
        color: Color.fromARGB(120, 66, 134, 244));
    final earthShape = ArCoreSphere(
      materials: [earthMaterial],
      radius: 0.1,
    );
    final earth = ArCoreNode(
        shape: earthShape,
        position: plane.centerPose.translation + vector.Vector3(0.0, 1.0, 0.0),
        rotation: plane.centerPose.rotation);

    arCoreController.addArCoreNode(earth);
  }

  void _addSphere(ArCoreController controller) {
    final material = ArCoreMaterial(
        color: Color.fromARGB(120, 66, 134, 244));
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.1,
    );
    final node = ArCoreNode(
      shape: sphere,
      position: vector.Vector3(0, 0, -1.5),
    );
    controller.addArCoreNode(node);
  }

  void _addCylindre(ArCoreController controller) {
    final material = ArCoreMaterial(
      color: Colors.red,
      reflectance: 1.0,
    );
    final cylindre = ArCoreCylinder(
      materials: [material],
      radius: 0.5,
      height: 0.3,
    );
    final node = ArCoreNode(
      shape: cylindre,
      position: vector.Vector3(0.0, -0.5, -2.0),
    );
    controller.addArCoreNode(node);
  }

  void _addCube(ArCoreController controller) {
    final material = ArCoreMaterial(
      color: Color.fromARGB(120, 66, 134, 244),
      metallic: 1.0,
    );
    final cube = ArCoreCube(
      materials: [material],
      size: vector.Vector3(0.5, 0.5, 0.5),
    );
    final node = ArCoreNode(
      shape: cube,
      position: vector.Vector3(-0.5, 0.5, -3.5),
    );
    controller.addArCoreNode(node);
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}