import 'package:flutter/material.dart';
import '../../core/constants/categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback? onTap;
  final Widget? trailingAction;
  final bool showDate;
  const TransactionTile({
    super.key,
    required this.tx,
    this.onTap,
    this.trailingAction,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isIncome = tx.type == TxType.income;
    final amountColor = isIncome ? p.income : p.expense;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Gap.m),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: p.tint, borderRadius: BorderRadius.circular(12)),
              child: Icon(categoryIcon(tx.category), size: 22, color: p.primary),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.bodyStrong(context)),
                  const SizedBox(height: 2),
                  Text(
                    showDate ? '${tx.category} · ${Fmt.date(tx.date)}' : tx.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption(context),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Gap.s),
            Text(
              '${isIncome ? '+' : '−'} ${Fmt.rupiah(tx.amount)}',
              style: AppText.bodyStrong(context).copyWith(color: amountColor, fontSize: 14),
            ),
            if (trailingAction != null) trailingAction!,
          ],
        ),
      ),
    );
  }
}
