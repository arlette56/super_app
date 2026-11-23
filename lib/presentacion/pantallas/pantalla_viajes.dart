import 'package:flutter/material.dart';

import '../../../dominio/dinero.dart';
import '../../../dominio/transporte.dart';
import '../vm/viajes_vm.dart';
import 'widgets.dart';

class PantallaViajes extends StatelessWidget {
  final ViajesVm vm;
  final VoidCallback onCambioEstado;

  const PantallaViajes({super.key, required this.vm, required this.onCambioEstado});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BannerError(mensaje: vm.error),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Origen: ${ViajesVm.origenDemo.nombre}'),
                const SizedBox(height: 8),
                DropdownButtonFormField<DestinoDemo>(
                  initialValue: vm.destino,
                  decoration: const InputDecoration(labelText: 'Destino', border: OutlineInputBorder()),
                  items: [
                    for (final d in ViajesVm.destinosDemo)
                      DropdownMenuItem(value: d, child: Text(d.nombre)),
                  ],
                  onChanged: (d) {
                    if (d != null) {
                      vm.seleccionarDestino(d);
                      onCambioEstado();
                    }
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Estimado: ${formatearPesos(vm.estimadoCentavos)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    FilledButton(
                      onPressed: () {
                        if (vm.solicitar()) onCambioEstado();
                      },
                      child: const Text('Solicitar viaje'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text('Mis viajes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final v in vm.misViajes)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${v.id} · Estado: ${v.estado.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Estimado: ${formatearPesos(v.estimadoCentavos)}'
                      '${v.cobradoCentavos != null ? ' · Cobrado: ${formatearPesos(v.cobradoCentavos!)}' : ''}'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (v.estado == EstadoViaje.solicitado)
                        FilledButton.tonal(
                          onPressed: () {
                            if (vm.aceptar(v.id)) onCambioEstado();
                          },
                          child: const Text('Aceptar'),
                        ),
                      if (v.estado == EstadoViaje.aceptado)
                        FilledButton.tonal(
                          onPressed: () {
                            if (vm.iniciar(v.id)) onCambioEstado();
                          },
                          child: const Text('Iniciar'),
                        ),
                      if (v.estado == EstadoViaje.enCurso)
                        FilledButton(
                          onPressed: () {
                            if (vm.finalizar(v.id)) onCambioEstado();
                          },
                          child: const Text('Finalizar'),
                        ),
                      if (v.estado == EstadoViaje.solicitado || v.estado == EstadoViaje.aceptado)
                        OutlinedButton(
                          onPressed: () {
                            if (vm.cancelar(v.id)) onCambioEstado();
                          },
                          child: const Text('Cancelar'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}