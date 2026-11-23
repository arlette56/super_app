import 'package:flutter/material.dart';

import '../../../dominio/dinero.dart';
import '../vm/tienda_vm.dart';
import 'widgets.dart';

class PantallaTienda extends StatelessWidget {
  final TiendaVm vm;
  final VoidCallback onCambioEstado;

  const PantallaTienda({super.key, required this.vm, required this.onCambioEstado});

  @override
  Widget build(BuildContext context) {
    final tienda = vm.tiendaActual;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BannerError(mensaje: vm.error),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final t in vm.tiendas)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${t.emoji} ${t.nombre}'),
                    selected: t.id == tienda.id,
                    onSelected: (_) {
                      vm.seleccionarTienda(t.id);
                      onCambioEstado();
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final prod in tienda.productos)
          Card(
            child: ListTile(
              title: Text(prod.nombre),
              subtitle: Text('${formatearPesos(prod.precioCentavos)} · Stock: ${prod.existencias}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      vm.cambiarCantidad(prod.id, -1);
                      onCambioEstado();
                    },
                  ),
                  Text('${vm.carrito[prod.id] ?? 0}'),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      vm.cambiarCantidad(prod.id, 1);
                      onCambioEstado();
                    },
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total carrito: ${formatearPesos(vm.totalCarritoCentavos)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                FilledButton(
                  onPressed: () {
                    if (vm.comprar()) onCambioEstado();
                  },
                  child: const Text('Comprar'),
                ),
              ],
            ),
          ),
        ),
        if (vm.ultimoPedido != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Último pedido: ${vm.ultimoPedido!.id} por ${formatearPesos(vm.ultimoPedido!.totalCentavos)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}