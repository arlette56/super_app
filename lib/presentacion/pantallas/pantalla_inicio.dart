import 'package:flutter/material.dart';

import '../../../dominio/dinero.dart';
import '../../../dominio/mini_app.dart';
import '../vm/inicio_vm.dart';
import 'widgets.dart';

class PantallaInicio extends StatelessWidget {
  final InicioVm vm;
  final List<MiniApp> miniAppsActivas;
  final ValueChanged<MiniApp> onAbrirMiniApp;
  final VoidCallback onAbrirMetricas;

  const PantallaInicio({
    super.key,
    required this.vm,
    required this.miniAppsActivas,
    required this.onAbrirMiniApp,
    required this.onAbrirMetricas,
  });

  @override
  Widget build(BuildContext context) {
    final sug = vm.sugerencia;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TarjetaResumenUsuario(
          nombre: vm.nombreUsuario,
          saldoCentavos: vm.saldoCentavos,
          puntos: vm.puntos,
          nivelNombre: vm.nivel.nombre,
          racha: vm.racha,
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Text(sug.servicio.emoji, style: const TextStyle(fontSize: 24)),
            title: Text('Sugerencia: ${sug.servicio.nombre}'),
            subtitle: Text(sug.razon),
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Notificaciones promocionales'),
          subtitle: const Text('Máximo 2 al día · Sin avisos de 10 pm a 8 am'),
          value: vm.promocionesActivas,
          onChanged: vm.togglePromociones,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Servicios activos', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: onAbrirMetricas,
              icon: const Icon(Icons.insights),
              label: const Text('Tablero de retención'),
            ),
          ],
        ),
        for (final app in miniAppsActivas)
          TileMiniApp(
            app: app,
            onTap: () => onAbrirMiniApp(app),
          ),
        const SizedBox(height: 16),
        Text('Avisos recientes (${vm.notificaciones.length})', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        if (vm.notificaciones.isEmpty)
          const Text('Sin notificaciones por ahora.')
        else
          for (final n in vm.notificaciones.take(5))
            Card(
              child: ListTile(
                title: Text(n.titulo),
                subtitle: Text('${n.cuerpo} · ${n.tipo.name}'),
                trailing: Text('${n.fecha.hour.toString().padLeft(2, '0')}:${n.fecha.minute.toString().padLeft(2, '0')}'),
              ),
            ),
        const SizedBox(height: 8),
        Text('Mensajes sin leer: ${vm.noLeidos} · Monto base ejemplo: ${formatearPesos(10000)}'),
      ],
    );
  }
}