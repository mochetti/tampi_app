import 'package:flutter/material.dart';
import 'Tampas.dart';

class TampaDialog extends StatefulWidget {
  final Tampinha t;

  const TampaDialog({Key key, this.t}) : super(key: key);

  @override
  _TampaDialog createState() => _TampaDialog();
}

class _TampaDialog extends State<TampaDialog> {
  Tampinha _t = new Tampinha();

  void _setTampinha(int acao) {
    setState(() {
      _t.acao = acao;
    });
  }

  @override
  void initState() {
    super.initState();
    _t.acao = widget.t.acao;
    _t.pot = widget.t.pot;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
//      title: Text('Tampinha'),
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(10),
      child: Container(
//        height: 550,
        child: Column(
          children: <Widget>[
            Container(
              height: 40,
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.lightBlue.withOpacity(0.9),
              ),
              child: Center(
                child: Text(
                  'Tampinha',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 385,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.lightBlue.withOpacity(0.9),
              ),
              child: SingleChildScrollView(
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  children: <Widget>[
                    TampaSelecao(_setTampinha, _t, 1),
                    TampaSelecao(_setTampinha, _t, 2),
                    TampaSelecao(_setTampinha, _t, 3),
                    TampaSelecao(_setTampinha, _t, 4),
                    TampaSelecao(_setTampinha, _t, 5),
                    TampaSelecao(_setTampinha, _t, 6),
                    TampaSelecao(_setTampinha, _t, 7),
                    TampaSelecao(_setTampinha, _t, 0),
                    TampaSelecao(_setTampinha, _t, 0),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.lightBlue),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Slider(
                  activeColor: Colors.red,
                  inactiveColor: Colors.red.withOpacity(0.5),
                  value: _t.pot,
                  min: 0,
                  max: 100,
                  label: _t.getPot() + _t.getGrandeza(),
                  divisions: 100,
                  onChanged: _t.acao == 0
                      ? null
                      : (value) {
                          setState(() {
                            _t.pot = value;
                          });
                        },
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 50,
              width: double.maxFinite,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.lightBlue,
                onPressed: () {
                  // Use the second argument of Navigator.pop(...) to pass
                  // back a result to the page that opened the dialog
                  Navigator.pop(context, _t);
                },
                child: Text(
                  'OK',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FuncaoDialog extends StatefulWidget {
  final int id;
  final List<Tampinha> tes;

  const FuncaoDialog({Key key, this.id, this.tes}) : super(key: key);

  @override
  _FuncaoDialog createState() => _FuncaoDialog();
}

class _FuncaoDialog extends State<FuncaoDialog> {
  List<Tampinha> tes = new List.filled(3, Tampinha());

  void _addComando(Tampinha t, int id) {
    tes[(id - 8) % 3] = t;
  }

  @override
  void initState() {
    super.initState();
    tes[0] = widget.tes[0];
    tes[1] = widget.tes[1];
    tes[2] = widget.tes[2];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.only(left: 10, right: 10, top: 315, bottom: 318),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 40,
            width: double.maxFinite,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.lightBlue.withOpacity(0.9),
            ),
            child: Center(
              child: Text(
                'Função ' + widget.id.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.lightBlue.withOpacity(0.9),
            ),
            child: SingleChildScrollView(
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                children: <Widget>[
                  Tampa(_addComando, widget.id * 3 + 8, widget.tes[0]),
                  Tampa(_addComando, widget.id * 3 + 9, widget.tes[1]),
                  Tampa(_addComando, widget.id * 3 + 10, widget.tes[2]),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 50,
            width: double.maxFinite,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: Colors.lightBlue,
              onPressed: () {
                // Use the second argument of Navigator.pop(...) to pass
                // back a result to the page that opened the dialog
                Navigator.pop(context, tes);
              },
              child: Text(
                'OK',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
