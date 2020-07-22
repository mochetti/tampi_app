import 'dart:math';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:arkit_plugin/widget/arkit_scene_view.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v;

class MyImageTracker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyImageTracker();
  }
}

class _MyImageTracker extends State<MyImageTracker> {
  final tampi = ARKitNode(
    name: "tampi",
    geometry: ARKitSphere(
      radius: 0.06,
    ),
  );
  bool presente = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ARKitSceneView(
          showFeaturePoints: true,
          maximumNumberOfTrackedImages: 1,
          detectionImagesGroupName: 'AR Resources',
          onARKitViewCreated: (c) {
//            c.onAddNodeForAnchor = (anchor) {
//              if (anchor is ARKitImageAnchor) {
//                final imagePosition = v.Vector3(
//                  anchor.transform.getColumn(3).x,
//                  anchor.transform.getColumn(3).y,
//                  anchor.transform.getColumn(3).z,
//                );
//                final node = ARKitNode(
//                  name: "MyNode",
//                  geometry: ARKitSphere(
//                    radius: 0.06,
//                  ),
//                  position: imagePosition,
//                );
//                c.add(node);
//              }
//            };
            c.onUpdateNodeForAnchor = (anchor) {
              if (anchor is ARKitImageAnchor) {
                if (!anchor.isTracked) print('not tracked');
                if (anchor.transform.getColumn(3).z == null) print('null');
                final imagePosition = v.Vector3(
                  anchor.transform.getColumn(3).x,
                  anchor.transform.getColumn(3).y,
                  anchor.transform.getColumn(3).z,
                );
//                final node = ARKitNode(
//                  name: "MyNode",
//                  geometry: ARKitSphere(
//                    radius: 0.06,
//                  ),
//                  position: imagePosition,
//                );
                tampi.position.value = imagePosition;
                if(!presente){
                  presente = true;
                  c.add(tampi);
                }
              }
            };
          }),
    );
  }
}
