import 'package:flutter/material.dart';
import 'package:flutter_lab_1/app/data/data.dart';
import 'package:flutter_lab_1/app/extensions/widget_extensions.dart';
import 'package:flutter_lab_1/di/di.dart';
import 'package:flutter_lab_1/app/widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/content_bloc.dart';

class ContentScreen extends StatefulWidget {
  final String contentId;

  const ContentScreen({super.key, required this.contentId});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final _content = getIt<ContentBloc>();
  bool _reminderEnabled = false;

  void loadContent() => _content.add(ContentLoad(contentId: widget.contentId));

  @override
  void initState() {
    super.initState();
    loadContent();
  }

  @override
  void didUpdateWidget(covariant ContentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contentId != widget.contentId) {
      _reminderEnabled = false;
      loadContent();
    }
  }

  @override
  void dispose() {
    _content.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContentBloc, ContentState>(
      bloc: _content,
      builder: (context, state) => switch (state) {
        ContentInitial() => _buildStatus(const SizedBox.shrink()),
        ContentLoadInProgress() => _buildStatus(const AppProgressIndicator()),
        ContentLoadSuccess() => _buildContent(state.subscription),
        ContentLoadFailure() => _buildStatus(
          state.notFound
              ? const Center(child: Text('Подписка не найдена'))
              : AppError(
                  description: 'Не удалось загрузить подписку',
                  onTap: loadContent,
                ),
        ),
      },
    );
  }

  Widget _buildStatus(Widget body) => Scaffold(
    appBar: AppBar(title: const Text('Подписка')),
    body: body,
  );

  Widget _buildContent(SubscriptionModel sub) {
    return Scaffold(
      appBar: AppBar(title: Text(sub.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Категория
            _CategoryBadge(color: sub.categoryColor, label: sub.categoryName),
            16.ph,

            // Стоимость и дата списания
            _PriceCard(subscription: sub),
            16.ph,

            // Описание
            if (sub.description != null) ...[
              Text(
                'Описание',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              8.ph,
              Text(
                sub.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              16.ph,
            ],

            // Тарифный план
            Text(
              'Тарифный план',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            8.ph,
            _TariffRow(subscription: sub),
            16.ph,

            // История списаний
            Text(
              'История списаний',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            8.ph,
            ..._buildBillingHistory(sub),
            16.ph,

            // Кнопка-напоминание
            _ReminderTile(
              enabled: _reminderEnabled,
              onChanged: (v) {
                setState(() => _reminderEnabled = v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      v
                          ? 'Напомним за 3 дня до списания'
                          : 'Напоминание отключено',
                    ),
                  ),
                );
              },
            ),
            12.ph,

            // Ссылка в личный кабинет
            _ManageLink(subscription: sub),
          ],
        ),
      ),
    );
  }

  /// Простая генерация истории списаний исходя из периода.
  List<Widget> _buildBillingHistory(SubscriptionModel sub) {
    final step = sub.period == 'month'
        ? const Duration(days: 30)
        : const Duration(days: 365);

    final items = <Widget>[];
    for (var i = 1; i <= 3; i++) {
      final date = sub.nextBillingDate.subtract(step * i);
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDate(date)),
              Text(
                '${sub.price.toStringAsFixed(0)} ₽',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }
    return items;
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }
}

// ---------- Вспомогательные виджеты ----------

class _CategoryBadge extends StatelessWidget {
  final Color color;
  final String label;

  const _CategoryBadge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          8.pw,
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final SubscriptionModel subscription;

  const _PriceCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final periodText = subscription.period == 'month' ? 'в месяц' : 'в год';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${subscription.price.toStringAsFixed(0)} ₽',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          4.ph,
          Text(
            periodText,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Colors.grey[700]),
          ),
          12.ph,
          const Divider(height: 1),
          12.ph,
          Row(
            children: [
              const Icon(Icons.event, size: 18),
              8.pw,
              Text(
                'Следующее списание: '
                '${subscription.nextBillingDate.day.toString().padLeft(2, '0')}.'
                '${subscription.nextBillingDate.month.toString().padLeft(2, '0')}.'
                '${subscription.nextBillingDate.year}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TariffRow extends StatelessWidget {
  final SubscriptionModel subscription;

  const _TariffRow({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_outlined),
          12.pw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.period == 'month'
                      ? 'Ежемесячная оплата'
                      : 'Годовая оплата',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Стоимость: ${subscription.price.toStringAsFixed(0)} ₽',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _ReminderTile({required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        value: enabled,
        onChanged: onChanged,
        title: const Text('Напомнить за 3 дня'),
        subtitle: const Text('Уведомление перед следующим списанием'),
        secondary: const Icon(Icons.notifications_active_outlined),
      ),
    );
  }
}

class _ManageLink extends StatelessWidget {
  final SubscriptionModel subscription;

  const _ManageLink({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Открыть личный кабинет «${subscription.name}» для отмены',
              ),
            ),
          );
        },
        icon: const Icon(Icons.open_in_new),
        label: const Text('Управлять подпиской'),
      ),
    );
  }
}
