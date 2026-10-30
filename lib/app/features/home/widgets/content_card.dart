import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lab_1/app/data/data.dart';

class ContentCard extends StatelessWidget {
  final SubscriptionModel subscription;

  const ContentCard({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final imageSize = 100.0;
    final periodText = subscription.period == 'month' ? 'мес.' : 'год';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      // Переход на детальный экран
      onTap: () => context.push('/content/${subscription.id}'),
      child: SizedBox(
        height: imageSize,
        child: Row(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/test_image.jpg',
                height: imageSize,
                width: imageSize,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${subscription.price.toStringAsFixed(0)} ₽ / $periodText',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      subscription.description ??
                          'Категория: ${subscription.categoryName}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
