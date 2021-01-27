import 'package:flutter/material.dart';

class instrucoesConexao extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conectar'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('Instrucoes de conexao'),
//            RaisedButton(
//              onPressed: () {
//                Navigator.of(context).popUntil((route) => route.isFirst);
//              },
//              child: Text('Entendi!'),
//            )
          ],
        ),
      ),
    );
  }
}