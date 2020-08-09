import 'dart:math' as math;
import 'dart:async';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:io' show Platform;
import 'ARCorePage.dart';

class ARPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      Platform.isAndroid ? ARCoreState() : ARKitState();
//  State<StatefulWidget> createState() => ARCoreState();

}

class ARKitState extends State<ARPage> {
  ARKitController arkitController;
  bool busy = false;
  ARKitNode alvo;
  ARKitNode tampi = ARKitReferenceNode(
    name: "tampi",
    url: 'models.scnassets/arrow.dae',
    scale: vector.Vector3(5, 5, 5),
    isHidden: false,
  );
  bool tampiPresente = false;
  ARKitPlane plane;
  ARKitNode node;
  String anchorId;

//  vector.Vector3 lastPosition;
  Timer timer;
  int angBalanco = 0;
  bool anchorWasFound = false;
  bool tracking = false;
  bool planoEncontrado = false;

  List<ARKitReferenceImage> imagens = [
    new ARKitReferenceImage(
        name:
            'https://upload.wikimedia.org/wikipedia/commons/9/97/The_Earth_seen_from_Apollo_17.jpg',
        physicalWidth: 0.16),
  ];

  @override
  void dispose() {
    timer?.cancel();
    arkitController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('AR')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if(tracking) {
              tracking = false;
              arkitController.remove("line");
            }
            else tracking = true;
            setState((){});
          },
          tooltip: 'Enviar',
          child: tracking ? Icon(Icons.stop) : Icon(Icons.play_arrow),
        ),
        body: Container(
          child: ARKitSceneView(
            showFeaturePoints: true,
            planeDetection: ARPlaneDetection.horizontal,
            enableTapRecognizer: true,
            onARKitViewCreated: onARKitViewCreated,
            maximumNumberOfTrackedImages: 1,
//            detectionImages: imagens,
            detectionImagesGroupName: 'AR Resources',
          ),
        ),
      );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onAddNodeForAnchor = onAnchorWasFound;
    this.arkitController.onUpdateNodeForAnchor = _handleUpdateAnchor;
    this.arkitController.onARTap = (List<ARKitTestResult> ar) {
      final planeTap = ar.firstWhere(
        (tap) => tap.type == ARKitHitTestResultType.existingPlaneUsingExtent,
        orElse: () => null,
      );
      if (planeTap != null) {
        _onPlaneTapHandler(planeTap.worldTransform);
      }
    };
//    this.arkitController.onDidRemoveNodeForAnchor = onAnchorWasRemoved;
  }

  void onAnchorWasFound(ARKitAnchor anchor) {
    if (anchor is ARKitPlaneAnchor) {
//      if(planoEncontrado) return;
      _addPlane(arkitController, anchor);
      planoEncontrado = true;
      return;
    }
    return;
  }

  void _handleUpdateAnchor(ARKitAnchor anchor) {
    if (anchor.identifier == anchorId) {
      final ARKitPlaneAnchor planeAnchor = anchor;
      node.position.value =
          vector.Vector3(planeAnchor.center.x, 0, planeAnchor.center.z);
      plane.width.value = planeAnchor.extent.x;
      plane.height.value = planeAnchor.extent.z;
      return;
    } else if (anchor is ARKitImageAnchor) {
      if (!anchor.isTracked) {
        print('not tracked');
        tampi.isHidden.value = true;
        arkitController.remove("line");
        return;
      }
      tampi.isHidden.value = false;

      if (busy) return;

      busy = true;

      atualizaTampi(anchor);

      if (!tampiPresente) {
        print('tampi presente');
        tampiPresente = true;
        arkitController.add(tampi);
      }

      if (tracking) {
        tracarCaminho();
      }
    }
  }

  void onAnchorWasRemoved(ARKitAnchor anchor) {
//    if (anchor is ARKitImageAnchor) {
    print('soldado abatido');
//    }
  }

  void _addPlane(ARKitController controller, ARKitPlaneAnchor anchor) {
    print('add plane');
    anchorId = anchor.identifier;
    plane = ARKitPlane(
      width: anchor.extent.x,
      height: anchor.extent.z,
      materials: [
        ARKitMaterial(
          transparency: 0.5,
          diffuse: ARKitMaterialProperty(color: Colors.white),
        )
      ],
    );

    node = ARKitNode(
      geometry: plane,
      position: vector.Vector3(anchor.center.x, 0, anchor.center.z),
      rotation: vector.Vector4(1, 0, 0, -math.pi / 2),
    );
    controller.add(node, parentNodeName: anchor.nodeName);
  }

  void _onPlaneTapHandler(Matrix4 transform) {
    arkitController.remove('alvo');

    final position = vector.Vector3(
      transform.getColumn(3).x,
      transform.getColumn(3).y,
      transform.getColumn(3).z,
    );

    final node = ARKitReferenceNode(
      name: 'alvo',
      url: 'models.scnassets/nykz-flag.dae',
      position: position,
//      scale: vector.Vector3(0.002, 0.002, 0.002),
    );

    arkitController.add(node);
    alvo = node;
  }

  void tracarCaminho() {
    if (alvo.position == null) return;

    arkitController.remove("line");
    final line = ARKitLine(
      fromVector: tampi.position.value,
      toVector: alvo.position.value,
    );
    final lineNode = ARKitNode(name: "line", geometry: line);
    arkitController.add(lineNode);

    final distance = _calculateDistanceBetweenPoints(
        alvo.position.value, tampi.position.value);
//      final point = _getMiddleVector(position, lastPosition);
//      _drawText(distance, point);
    print(distance);

//    tracking = true; // habilita o loop

    // insere nodes no caminho
//    final bool chegou = false;
//    final xAtual = tampi.position.value.x;
//    final yAtual = tampi.position.value.y;
//    final zAtual = tampi.position.value.z;
//    while(!chegou) {
//      final x = (tampi.position.value.x + alvo.position.value.x) / 2;
//      final y = (tampi.position.value.y + alvo.position.value.y) / 2;
//      final meioZ = (tampi.position.value.z + alvo.position.value.z) / 2;
//      final node = ARKitNode(
//        geometry: ARKitSphere(
//          radius: 0.01,
//        ),
//        position: vector.Vector3(meioX, meioY, meioZ),
//      );
//      this.arkitController.add(node);
//    }

    // calcula o angulo
    final dx = alvo.position.value.x - tampi.position.value.x;
    final dz = alvo.position.value.z - tampi.position.value.z;
    final angAlvo = math.atan(dx / dz);
    final ang = (tampi.eulerAngles.value.y - angAlvo) * 180 / math.pi;
    print('angulo entre = ' + ang.toString());

    // alinha
    String s = 'm'; // caracter de movimento
    if (ang < -10) {
      // gira pra esquerda
      print('esquerda');
    } else if (ang > 10) {
      // gira pra direita
      print('direita');
    } else {
      // anda reto
      print('anda reto');
    }

    // add websocket
  }

  String _calculateDistanceBetweenPoints(vector.Vector3 A, vector.Vector3 B) {
    final length = A.distanceTo(B);
    return '${(length * 100).toStringAsFixed(2)} cm';
  }

  Future<void> atualizaTampi(ARKitAnchor anchor) {
    print('atualizando o tampi');

    final tampiPosition = vector.Vector3(
      anchor.transform.getColumn(3).x,
      anchor.transform.getColumn(3).y,
      anchor.transform.getColumn(3).z,
    );

    // get the matrix coordinates
    double r00 = anchor.transform.getRotation().entry(0, 0);
    double r10 = anchor.transform.getRotation().entry(1, 0);
    double r11 = anchor.transform.getRotation().entry(1, 1);
    double r12 = anchor.transform.getRotation().entry(1, 2);
    double r20 = anchor.transform.getRotation().entry(2, 0);
    double r21 = anchor.transform.getRotation().entry(2, 1);
    double r22 = anchor.transform.getRotation().entry(2, 2);

    // calculate the euler angles
    double rx, ry, rz;

    double sy = math.sqrt(r00 * r00 + r10 * r10);

    bool singular = sy < 1e-6; // If

    if (!singular) {
//      print("matriz é singular");
      rx = math.atan2(r21, r22);
      ry = math.atan2(-r20, sy);
      rz = math.atan2(r10, r00);
    } else {
      print("matriz nao singular");
      rx = math.atan2(-r12, r11);
      ry = math.atan2(-r20, sy);
      rz = 0;
    }

//    print(ry * 180 / math.pi);

    tampi.position.value = tampiPosition;
    tampi.eulerAngles.value = vector.Vector3(0, ry, 0);
    return Future.delayed(Duration(milliseconds: 100), () => busy = false);
  }
}
