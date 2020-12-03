import 'package:flutter/material.dart';
import 'TampaDialogPage.dart';
import 'bottle_cap_button_widget.dart';

class Tampinha {
  double pot = 50;
  int acao = 0;

  Tampinha() {}

  Tampinha.fromTampinha(Tampinha t) {
    pot = t.pot;
    acao = t.acao;
  }

  // devolve uma cópia
  Tampinha clone() {
    Tampinha t = new Tampinha.fromTampinha(this);
    return t;
  }

  // devolve o valor do potenciometro como string
  String getPot() {
    double valor = 0;
    switch (acao) {
      case 0: // vazio
        return '';
        break;
      case 1: // andar
        valor = pot;
        break;
      case 2: // girar
        valor = pot * 1.8 - 90;
        break;
      case 3: // buzina
        valor = pot * 19 + 100;
        break;
      default:
        valor = pot;
        break;
    }
    return valor.toStringAsFixed(1);
  }

  // devolve o valor do pot entre 0 e 1023 (para enviar pelo ws)
  int getPotRaw() {
    return (pot * 1023/100).toInt();
  }

  // devolve acao como o comando correspondente
  String getAcao() {
    List<String> acoes = <String>[
      '',
      'andar',
      'girar',
      'buzina',
      'US',
      'seta e',
      'seta d',
      'farol'
    ];
    return acoes[acao];
  }

  IconData getIcons() {
    List<IconData> icons = [
      Icons.radio_button_checked,
      Icons.keyboard_arrow_up,
      Icons.rotate_90_degrees_ccw,
      Icons.volume_up,
      Icons.graphic_eq,
      Icons.wb_incandescent,
      Icons.wb_incandescent,
      Icons.highlight,
    ];
    return icons[acao];
  }

  // devolve a cor da tampinha
  Color getCor() {
    List<MaterialColor> cores = <MaterialColor>[
      Colors.grey,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.amber,
      Colors.cyan,
      Colors.purple,
      Colors.deepOrange
    ];
    return cores[acao];
  }

  // retorna a grandeza do valor ajustado pelo potenciometro
  String getGrandeza() {
    List<String> grandezas = <String>[
      '',
      ' cm',
      ' graus',
      ' Hz',
      ' cm',
      '',
      '',
      '',
      '',
    ];
    return grandezas[acao];
  }
}

// bocal
class Tampa extends StatefulWidget {
  final Function add;
  final int id;
  final Tampinha t;

  Tampa(this.add, this.id, this.t);

  @override
  _Tampa createState() => _Tampa();
}

class _Tampa extends State<Tampa> {
  Tampinha _t;

  @override
  void initState() {
    super.initState();
    _t = widget.t;
  }

  Future<void> dialogTampa() async {
    // this will contain the result from Navigator.pop(context, result)
    final tSelected = await showDialog<Tampinha>(
      context: context,
      builder: (context) => TampaDialog(t: _t),
    );

    // execution of this code continues when the dialog was closed (popped)

    // note that the result can also be null, so check it
    // (back button or pressed outside of the dialog)
    if (tSelected != null) {
      setState(() {
        _t.acao = tSelected.acao;
        _t.pot = tSelected.pot;
      });
      widget.add(_t, widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: bottleCapButton(
        text: _t.getAcao() + '\n' + _t.getPot() + _t.getGrandeza(),
        leadingIcon: _t.getAcao() == '' ? Icon(Icons.radio_button_checked) : null,
        color: _t.getCor(),
        onClick: dialogTampa,
      ),
    );
  }
}

class TampaSelecao extends StatefulWidget {
  final Function setTampinha;
  final Tampinha t;
  final int acao;

  TampaSelecao(this.setTampinha, this.t, this.acao);

  @override
  _TampaSelecao createState() => _TampaSelecao();
}

class _TampaSelecao extends State<TampaSelecao> {
  Tampinha _t = new Tampinha();

  @override
  void initState() {
    super.initState();
    _t.acao = widget.acao;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _t.acao == widget.t.acao && _t.acao > 0
                ? Colors.black.withOpacity(1)
                : Colors.black.withOpacity(0),
            blurRadius: 20,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: bottleCapButton(
        text: _t.getAcao(),
        textFontSize: 14,
        leadingIcon: Icon(_t.getIcons()),
        leadingIconMargin: 1,
        color: _t.acao == widget.t.acao ? _t.getCor() : _t.getCor(),
        onClick: () => widget.setTampinha(_t.acao),
      ),
    );
  }
}