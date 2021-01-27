import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';

// WebSocketsNotifications sockets =
//     new WebSocketsNotifications(); // variável global

bool tentarReconectar = true;

/// o id padrao do esp é 192.168.4.1
const String _SERVER_ADDRESS = "ws://192.168.4.1:81"; // endereco ip
const Iterable<String> protocol = {'echo-protocol'};

class WebSocketsNotifications {
  static final WebSocketsNotifications _sockets =
      new WebSocketsNotifications._internal();

  factory WebSocketsNotifications() {
    return _sockets;
  }

  WebSocketsNotifications._internal();

  IOWebSocketChannel _channel; // canal do websocket

  bool isOn = false; // controla se a conexao existe

  ///
  /// Listeners
  /// List of methods to be called when a new message
  /// comes in.
  ///
  ObserverList<Function> _listeners = new ObserverList<Function>();

  /// ----------------------------------------------------------
  /// Initialization the WebSockets connection with the server
  /// ----------------------------------------------------------
  initCommunication() {
    ///
    /// Just in case, close any previous communication
    ///
    reset();

    ///
    /// Open a new WebSocket communication
    ///
    try {
      _channel = new IOWebSocketChannel.connect(_SERVER_ADDRESS);

      ///
      /// Start listening to new notifications / messages
      ///
      _channel.stream.listen(
        _onReceptionOfMessageFromServer,
        onDone: () {
          // conexao destruida
          isOn = false;
          print('ws destruido');
          if (tentarReconectar) {
            print('tentando reconectar');
            initCommunication();
          }
        },
        onError: (error) {
          // erro na conexao
          isOn = false;
          debugPrint('ws erro: $error');
          _returnErro();
        },
        cancelOnError: true,
      );
    } on Exception catch (e) {
      ///
      /// General error handling
      /// TODO
      ///
      print('erro ao abrir o ws');
      print(e.toString());
    }
  }

  /// ----------------------------------------------------------
  /// Closes the WebSocket communication
  /// ----------------------------------------------------------
  reset() {
    if (_channel != null) {
      if (_channel.sink != null) {
        _channel.sink.close();
        isOn = false;
      }
    }
  }

  /// ---------------------------------------------------------
  /// Sends a message to the server
  /// ---------------------------------------------------------
  send(String message) {
    if (_channel != null) {
      if (_channel.sink != null && isOn) {
        _channel.sink.add(message);
      }
    }
  }

  /// ---------------------------------------------------------
  /// Adds a callback to be invoked in case of incoming
  /// notification
  /// ---------------------------------------------------------
  addListener(Function callback) {
    print(callback.toString() + ' foi adicionado');
    _listeners.add(callback);
  }

  removeListener(Function callback) {
    print(callback.toString() + ' foi removido');
    _listeners.remove(callback);
  }

  /// ----------------------------------------------------------
  /// Callback which is invoked each time that we are receiving
  /// a message from the server
  /// ----------------------------------------------------------
  _onReceptionOfMessageFromServer(message) {
//    print('recebemos algo');

    isOn = true;
    tentarReconectar = true;
    _listeners.forEach((Function callback) {
      callback(message);
    });
  }

  _returnErro() {
    _listeners.forEach((Function callback) {
      callback('erro');
    });
  }
}
