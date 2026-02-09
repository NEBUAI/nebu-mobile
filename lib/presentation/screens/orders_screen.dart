import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock data - Replace with actual orders from provider
    final orders = _getMockOrders();

    return Scaffold(
      appBar: AppBar(title: Text('orders.title'.tr()), elevation: 0),
      body: orders.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(order: order);
              },
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.shopping_bag_outlined,
          size: 100,
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 24),
        Text(
          'orders.no_orders'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'orders.no_orders_desc'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  List<_Order> _getMockOrders() => [
    // TODO(dev): Replace with actual API call
    _Order(
      id: 'ORD-001',
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: 'delivered',
      items: [
        _OrderItem(name: 'Nebu Robot - Blue', quantity: 1, price: 149.99),
        _OrderItem(name: 'Extra Battery Pack', quantity: 2, price: 29.99),
      ],
    ),
    _Order(
      id: 'ORD-002',
      date: DateTime.now().subtract(const Duration(days: 15)),
      status: 'shipped',
      items: [
        _OrderItem(name: 'Nebu Robot - Pink', quantity: 1, price: 149.99),
      ],
    ),
    _Order(
      id: 'ORD-003',
      date: DateTime.now().subtract(const Duration(days: 30)),
      status: 'cancelled',
      items: [_OrderItem(name: 'Accessory Kit', quantity: 1, price: 39.99)],
    ),
  ];
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final _Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = order.items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showOrderDetails(context, order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.id,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(order.status, theme),
                ],
              ),
              const SizedBox(height: 8),

              // Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(order.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Divider(),
              const SizedBox(height: 12),

              // Items
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.name}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(),
              const SizedBox(height: 12),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'orders.total'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    Color color;
    String label;

    switch (status) {
      case 'delivered':
        color = Colors.green;
        label = 'orders.status_delivered'.tr();
        break;
      case 'shipped':
        color = Colors.blue;
        label = 'orders.status_shipped'.tr();
        break;
      case 'processing':
        color = Colors.orange;
        label = 'orders.status_processing'.tr();
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'orders.status_cancelled'.tr();
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'orders.today'.tr();
    } else if (difference.inDays == 1) {
      return 'orders.yesterday'.tr();
    } else if (difference.inDays < 7) {
      return 'orders.days_ago'.tr(args: [difference.inDays.toString()]);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  void _showOrderDetails(BuildContext context, _Order order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _OrderDetailsSheet(order: order),
    );
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  const _OrderDetailsSheet({required this.order});

  final _Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = order.items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          controller: scrollController,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'orders.order_details'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              order.id,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Status timeline (mock)
            _buildStatusTimeline(theme),
            const SizedBox(height: 24),

            // Items
            Text(
              'orders.items'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...order.items.map((item) => _buildItemRow(item, theme)),
            const Divider(height: 32),

            // Summary
            _buildSummaryRow('orders.subtotal'.tr(), total, theme),
            _buildSummaryRow('orders.shipping'.tr(), 0, theme),
            _buildSummaryRow('orders.tax'.tr(), total * 0.1, theme),
            const Divider(height: 32),
            _buildSummaryRow(
              'orders.total'.tr(),
              total + (total * 0.1),
              theme,
              bold: true,
            ),

            const SizedBox(height: 24),

            // Actions
            if (order.status != 'cancelled' && order.status != 'delivered')
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('orders.track_order_coming_soon'.tr()),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('orders.track_order'.tr()),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('orders.support_coming_soon'.tr())),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('orders.contact_support'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(ThemeData theme) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        _buildTimelineItem(
          'orders.timeline_placed'.tr(),
          true,
          theme,
          isFirst: true,
        ),
        _buildTimelineItem('orders.timeline_processing'.tr(), true, theme),
        _buildTimelineItem(
          'orders.timeline_shipped'.tr(),
          order.status == 'shipped' || order.status == 'delivered',
          theme,
        ),
        _buildTimelineItem(
          'orders.timeline_delivered'.tr(),
          order.status == 'delivered',
          theme,
          isLast: true,
        ),
      ],
    ),
  );

  Widget _buildTimelineItem(
    String label,
    bool completed,
    ThemeData theme, {
    bool isFirst = false,
    bool isLast = false,
  }) => Row(
    children: [
      Column(
        children: [
          if (!isFirst)
            Container(
              width: 2,
              height: 20,
              color: completed
                  ? theme.colorScheme.primary
                  : Colors.grey.withValues(alpha: 0.3),
            ),
          Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            color: completed
                ? theme.colorScheme.primary
                : Colors.grey.withValues(alpha: 0.5),
            size: 24,
          ),
          if (!isLast)
            Container(
              width: 2,
              height: 20,
              color: completed
                  ? theme.colorScheme.primary
                  : Colors.grey.withValues(alpha: 0.3),
            ),
        ],
      ),
      const SizedBox(width: 16),
      Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: completed
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    ],
  );

  Widget _buildItemRow(_OrderItem item, ThemeData theme) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: theme.textTheme.bodyMedium),
              Text(
                'orders.quantity'.tr(args: [item.quantity.toString()]),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Text(
          '\$${(item.price * item.quantity).toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _buildSummaryRow(
    String label,
    double amount,
    ThemeData theme, {
    bool bold = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

// Mock models
class _Order {
  _Order({
    required this.id,
    required this.date,
    required this.status,
    required this.items,
  });
  final String id;
  final DateTime date;
  final String status;
  final List<_OrderItem> items;
}

class _OrderItem {
  _OrderItem({required this.name, required this.quantity, required this.price});
  final String name;
  final int quantity;
  final double price;
}
