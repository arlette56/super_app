import 'package:flutter/material.dart';

import '../../../dominio/dinero.dart';
import '../vm/monedero_vm.dart';
import 'widgets.dart';

class PantallaMonedero extends StatelessWidget {
  final MonederoVm vm;
  final VoidCallback onCambioEstado;

  const PantallaMonedero({super.key, required this.vm, required this.onCambioEstado});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BannerError(mensaje: vm.error),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saldo disponible'),
                const SizedBox(height: 4),
                Text(
                  formatearPesos(vm.saldoCentavos),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Puntos acumulados: ${vm.puntos} (100 pts = ${formatearPesos(1000)})'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: () {
                if (vm.recargar(20000, concepto: 'Recarga rápida')) onCambioEstado();
              },
              child: Text('Recargar ${formatearPesos(20000)}'),
            ),
            FilledButton.tonal(
              onPressed: () {
                if (vm.canjearPuntos(100)) onCambioEstado();
              },
              child: const Text('Canjear 100 pts'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Movimientos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final mov in vm.movimientos)
          Card(
            child: ListTile(
              title: Text(mov.concepto),
              subtitle: Text('${mov.tipo.name} · ${mov.contraparte ?? 'cuenta'}'),
              trailing: Text(
                formatearPesos(mov.montoCentavos),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: mov.montoCentavos >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
