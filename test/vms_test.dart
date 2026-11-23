import 'package:flutter_test/flutter_test.dart';
import 'package:super_dolores/dominio/plataforma.dart';
import 'package:super_dolores/presentacion/vm/chat_vm.dart';
import 'package:super_dolores/presentacion/vm/inicio_vm.dart';
import 'package:super_dolores/presentacion/vm/metricas_vm.dart';
import 'package:super_dolores/presentacion/vm/monedero_vm.dart';
import 'package:super_dolores/presentacion/vm/tienda_vm.dart';
import 'package:super_dolores/presentacion/vm/viajes_vm.dart';

void main() {
  test('ViewModels operan sobre la plataforma y reportan errores seguros', () {
    final p = Plataforma(reloj: () => DateTime(2026, 11, 9, 10))..cargarDatosDemo();

    final inicio = InicioVm(p, 'ana');
    final monedero = MonederoVm(p, 'ana');
    final chat = ChatVm(p, 'ana');
    final tienda = TiendaVm(p, 'ana');
    final viajes = ViajesVm(p, 'ana');
    final metricas = MetricasVm(p);

    expect(inicio.nombreUsuario, 'Ana');
    expect(monedero.saldoCentavos, 100000);

    expect(chat.enviarTexto('Hola Luis'), isTrue);
    expect(chat.enviarTexto('   '), isFalse);
    expect(chat.error, isNotNull);

    tienda.cambiarCantidad('kilo', 2);
    expect(tienda.comprar(), isTrue);
    expect(tienda.ultimoPedido, isNotNull);

    expect(viajes.solicitar(), isTrue);
    final viajeId = viajes.misViajes.first.id;
    expect(viajes.aceptar(viajeId), isTrue);
    expect(viajes.iniciar(viajeId), isTrue);
    expect(viajes.finalizar(viajeId), isTrue);

    metricas.refrescar();
    expect(metricas.dau, 1);

    inicio.cambiarUsuario('luis');
    expect(inicio.usuarioId, 'luis');
  });
}