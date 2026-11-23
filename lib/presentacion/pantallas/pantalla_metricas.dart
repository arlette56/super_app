import 'package:flutter/material.dart';

import '../vm/metricas_vm.dart';

class PantallaMetricas extends StatelessWidget {
  final MetricasVm vm;

  const PantallaMetricas({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final sem2 = vm.retencionSemana2;
    return Scaffold(
      appBar: AppBar(title: const Text('Tablero de retención')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                '⚠️ Datos de práctica/simulación: las diferencias entre grupos muestran correlación, no causalidad sin un experimento A/B.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('DAU / WAU / MAU'),
              subtitle: Text('Stickiness (DAU/MAU): ${(vm.stickiness * 100).toStringAsFixed(1)}%'),
              trailing: Text('${vm.dau} / ${vm.wau} / ${vm.mau}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Servicios por usuario (7 días)'),
              subtitle: Text('Multiservicio (≥2): ${(vm.porcentajeMultiservicio * 100).toStringAsFixed(1)}%'),
              trailing: Text(vm.serviciosPorUsuario.toStringAsFixed(2),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Retención semana 2 (1 servicio vs. ≥2 servicios)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('1 servicio (n=${sem2.nUno}): ${(sem2.unServicio * 100).toStringAsFixed(1)}%'),
                  Text('≥2 servicios (n=${sem2.nMulti}): ${(sem2.multiservicio * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}