import 'package:flutter/foundation.dart';

import '../../../dominio/comercio.dart';
import '../../../dominio/excepciones.dart';
import '../../../dominio/plataforma.dart';

class TiendaVm extends ChangeNotifier {
  final Plataforma _p;
  String _usuarioId;
  String _tiendaId;
  final Map<String, int> carrito = {};
  String? error;
  Pedido? ultimoPedido;
  int _claveSeq = 0;

  TiendaVm(this._p, this._usuarioId) : _tiendaId = _p.comercio.tiendas.first.id;

  String get usuarioId => _usuarioId;
  String get tiendaId => _tiendaId;
  List<Tienda> get tiendas => _p.comercio.tiendas;
  Tienda get tiendaActual => tiendas.firstWhere((t) => t.id == _tiendaId, orElse: () => tiendas.first);
  List<Pedido> get misPedidos => _p.comercio.pedidosDe(_usuarioId);

  int get totalCarritoCentavos {
    var total = 0;
    for (final e in carrito.entries) {
      final prod = tiendaActual.producto(e.key);
      if (prod != null && e.value > 0) {
        total += prod.precioCentavos * e.value;
      }
    }
    return total;
  }

  void cambiarUsuario(String nuevoUsuarioId) {
    _usuarioId = nuevoUsuarioId;
    error = null;
    ultimoPedido = null;
    notifyListeners();
  }

  void seleccionarTienda(String nuevaTiendaId) {
    if (_tiendaId == nuevaTiendaId) return;
    _tiendaId = nuevaTiendaId;
    carrito.clear();
    error = null;
    notifyListeners();
  }

  void cambiarCantidad(String productoId, int delta) {
    final prod = tiendaActual.producto(productoId);
    if (prod == null) return;
    final actual = carrito[productoId] ?? 0;
    final siguiente = actual + delta;
    if (siguiente <= 0) {
      carrito.remove(productoId);
    } else if (siguiente <= ServicioComercio.maxPorProducto) {
      carrito[productoId] = siguiente;
    }
    error = null;
    notifyListeners();
  }

  bool comprar() {
    error = null;
    ultimoPedido = null;
    try {
      final ctx = _p.contextoPara(Plataforma.miniTienda, _usuarioId);
      final items = Map<String, int>.from(carrito);
      final pedido = ctx.comercio.comprar(_tiendaId, items, clave: 'vm-ped-${++_claveSeq}');
      carrito.clear();
      ultimoPedido = pedido;
      notifyListeners();
      return true;
    } catch (e) {
      error = mensajeSeguro(e);
      notifyListeners();
      return false;
    }
  }
}
