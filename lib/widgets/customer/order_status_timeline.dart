import 'package:flutter/material.dart';

class OrderStatusTimeline extends StatelessWidget {
  final String currentStatus;
  final DateTime orderPlacedAt;

  const OrderStatusTimeline({
    super.key,
    required this.currentStatus,
    required this.orderPlacedAt,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = _getOrderStatuses();
    final currentIndex = _getCurrentStatusIndex();

    return Column(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;

        return _buildTimelineItem(
          context,
          status: status,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isLast: index == statuses.length - 1,
        );
      }).toList(),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required OrderStatusItem status,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Línea vertical y círculo
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? (isCurrent ? _getStatusColor(status.status) : Colors.green)
                    : Colors.grey[300],
                border: Border.all(
                  color: isCompleted
                      ? (isCurrent ? _getStatusColor(status.status) : Colors.green)
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Icon(
                      isCurrent ? _getStatusIcon(status.status) : Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green : Colors.grey[300],
                margin: const EdgeInsets.only(top: 4),
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Contenido del estado
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted
                      ? (isCurrent ? _getStatusColor(status.status) : Colors.green[700])
                      : Colors.grey[600],
                ),
              ),
              if (status.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  status.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
              if (isCurrent && status.estimatedTime != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(status.status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    status.estimatedTime!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(status.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<OrderStatusItem> _getOrderStatuses() {
    return [
      OrderStatusItem(
        status: 'pending',
        title: 'Pedido Realizado',
        description: 'Tu pedido ha sido recibido',
        estimatedTime: 'Inmediato',
      ),
      OrderStatusItem(
        status: 'confirmed',
        title: 'Pedido Confirmado',
        description: 'El restaurante ha confirmado tu pedido',
        estimatedTime: '1-2 min',
      ),
      OrderStatusItem(
        status: 'preparing',
        title: 'En Preparación',
        description: 'Tu pedido está siendo preparado',
        estimatedTime: '15-25 min',
      ),
      OrderStatusItem(
        status: 'ready_for_pickup',
        title: 'Listo para Recoger',
        description: 'Tu pedido está listo para ser recogido',
        estimatedTime: '2-3 min',
      ),
      OrderStatusItem(
        status: 'out_for_delivery',
        title: 'En Camino',
        description: 'Tu pedido está en camino a tu ubicación',
        estimatedTime: '10-20 min',
      ),
      OrderStatusItem(
        status: 'delivered',
        title: 'Entregado',
        description: 'Tu pedido ha sido entregado exitosamente',
      ),
    ];
  }

  int _getCurrentStatusIndex() {
    final statuses = ['pending', 'confirmed', 'preparing', 'ready_for_pickup', 'out_for_delivery', 'delivered'];
    return statuses.indexOf(currentStatus);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready_for_pickup':
        return Colors.indigo;
      case 'out_for_delivery':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'preparing':
        return Icons.restaurant;
      case 'ready_for_pickup':
        return Icons.store;
      case 'out_for_delivery':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel;
      case 'refunded':
        return Icons.refresh;
      default:
        return Icons.help;
    }
  }
}

class OrderStatusItem {
  final String status;
  final String title;
  final String? description;
  final String? estimatedTime;

  OrderStatusItem({
    required this.status,
    required this.title,
    this.description,
    this.estimatedTime,
  });
}
