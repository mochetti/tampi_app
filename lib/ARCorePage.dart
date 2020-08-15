import 'ARPage.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'websocket.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARCoreState extends State<ARPage> {
  ArCoreController arCoreController;
  bool tracking = false;
  bool busyTracking = false;
  bool alvoExiste = false;
  Timer timer;

  ArCoreNode alvo = ArCoreReferenceNode(
    name: 'alvo',
    objectUrl: 'assets/nykz-flag.dae',
  );
  ArCoreNode tampi = ArCoreReferenceNode(
    name: 'tampi',
    objectUrl: 'assets/arrow.dae',

    /// testar com esses parametros ao inves de se basear na ancora da imagem
//        position: augmentedImage.centerPose.translation,
//        rotation: augmentedImage.centerPose.rotation
  );

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
          enableTapRecognizer: true,

          /// talvez tenhamos problems com isso
          type: ArCoreViewType.AUGMENTEDIMAGES,
        ),
        floatingActionButton: Visibility(
          child: FloatingActionButton(
            onPressed: () {
              if (tracking) {
                tracking = false;
                arCoreController.removeNode(nodeName: 'line');
                String s = 'm0:0e';
                print(s);
                sockets.send(s);
              } else {
                tracking = true;
                timer = Timer.periodic(
                    Duration(milliseconds: 100),
                    (timer) => (busyTracking || alvo.position.value == null)
                        ? print('tracking ocupado ou alvo invalido ou IsHidden')
                        : tracarCaminho());
              }
              setState(() {});
            },
            tooltip: 'Enviar',
            child: tracking ? Icon(Icons.stop) : Icon(Icons.play_arrow),
          ),
          visible: alvoExiste,
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

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    final hit = hits.first;
    _addAlvo(hit);
  }

  Future _addAlvo(ArCoreHitTestResult hit) async {

    alvo.position.value = hit.pose.translation;
//    alvo.rotation.value = hit.pose.rotation;
    alvoExiste = true;
    arCoreController.addArCoreNodeWithAnchor(alvo);
  }

  Future atualizaTampi(ArCoreAugmentedImage augmentedImage) async {
    await arCoreController.addArCoreNodeToAugmentedImage(
        tampi, augmentedImage.index); // esse await adianta alguma coisa aqui ?
  }

  Future<void> tracarCaminho() {
    print('tracar caminho');
    print(alvo.position.value);
    busyTracking = true;

    arCoreController.removeNode(nodeName: 'line');

    /// nao tem ARCoreLine - desenhar a linha usando um Cube esticado (?)
    /// precisa mesmo de uma linha ? rs
//    final line = ArCoreNode(
//      fromVector: tampi.position.value,
//      toVector: alvo.position.value,
//    );
//    final lineNode = ArCoreNode(name: 'line', shape: line);
//    arCoreController.addArCoreNode(lineNode);

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
    double angAlvo = math.atan(dx / dz);
    if (angAlvo < -math.pi) angAlvo += 2 * math.pi;

    double ang = (tampi.rotation.value.y - angAlvo) * 180 / math.pi;

    print('angulo entre = ' + ang.toString());

    String s = 'm'; // caracter de inicio de movimento
    int vel = 400;

    // alinha
    if (ang < -10) {
      // gira pra esquerda
      print('esquerda');
      s += (-vel).toStringAsFixed(0);
      s += ':';
      s += vel.toStringAsFixed(0);
    } else if (ang > 10) {
      // gira pra direita
      print('direita');
      s += vel.toStringAsFixed(0);
      s += ':';
      s += (-vel).toStringAsFixed(0);
    } else {
      // anda reto
      print('anda reto');
      s += vel.toStringAsFixed(0);
      s += ':';
      s += vel.toStringAsFixed(0);
    }

    s += 'e';
    print(s);
    sockets.send(s);

    return Future.delayed(
        Duration(milliseconds: 200), () => busyTracking = false);
  }

  String _calculateDistanceBetweenPoints(vector.Vector3 A, vector.Vector3 B) {
    final length = A.distanceTo(B);
    return '${(length * 100).toStringAsFixed(2)} cm';
  }

  @override
  void dispose() {
    arCoreController.dispose();

    super.dispose();
  }
}
