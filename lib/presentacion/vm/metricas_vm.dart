import 'package:flutter/foundation.dart';

import '../../../dominio/analitica.dart';
import '../../../dominio/dinero.dart';
import '../../../dominio/plataforma.dart';

class MetricasVm extends ChangeNotifier {
  final Plataforma _p;
  DateTime _diaReferencia;

  MetricasVm(this._p) : _diaReferencia = soloFecha(_p.reloj());

  DateTime get diaReferencia => _diaReferencia;
  Analitica get analitica => _p.analitica;

  int get dau => analitica.dau(_diaReferencia);
  int get wau => analitica.wau(_diaReferencia);
  int get mau => analitica.mau(_diaReferencia);
  double get stickiness => analitica.stickiness(_diaReferencia);
  double get serviciosPorUsuario => analitica.serviciosPorUsuario(masDias(_diaReferencia, -6), _diaReferencia);
  double get porcentajeMultiservicio => analitica.porcentajeMultiservicio(masDias(_diaReferencia, -6), _diaReferencia);

  ({double unServicio, double multiservicio, int nUno, int nMulti}) get retencionSemana2 =>
      analitica.retencionSemana2PorServicios(masDias(_diaReferencia, -13), _diaReferencia);

  void cambiarDia(DateTime dia) {
    _diaReferencia = soloFecha(dia);
    notifyListeners();
  }

  void refrescar() => notifyListeners();
}