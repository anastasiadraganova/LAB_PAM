import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/formatters.dart';
import '../../../shared/models/event.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/ticket_counter.dart';

/// How many tickets, what it comes to, and the button that says exactly what
/// it will do.
class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key, required this.event});

  final Event event;

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final event = widget.event;
    final total = event.price * _qty;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.gutter,
          Spacing.xs,
          Spacing.gutter,
          Spacing.block,
        ),
        children: [
          Text(
            event.title,
            style: AppTypography.poster.copyWith(color: palette.black),
          ),
          const SizedBox(height: Spacing.xxs),
          Text(
            '${event.venue} · ${Formatters.dateAndTime(event.dateTime)}',
            style: AppTypography.meta.copyWith(color: palette.grey),
          ),
          const SizedBox(height: Spacing.block),
          TicketCounter(
            qty: _qty,
            onChanged: (value) => setState(() => _qty = value),
          ),
          const SizedBox(height: Spacing.block),
          _CalculationRow(
            qty: _qty,
            unitPrice: event.price,
            total: total,
            isFree: event.isFree,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          Spacing.gutter,
          Spacing.sm,
          Spacing.gutter,
          Spacing.md,
        ),
        child: PrimaryButton(
          label: AppTexts.purchaseAction(isFree: event.isFree, qty: _qty),
        ),
      ),
    );
  }
}

/// "3 × 150 L" on the left, the total on the right. A free event has nothing
/// to multiply, so it states the total alone.
class _CalculationRow extends StatelessWidget {
  const _CalculationRow({
    required this.qty,
    required this.unitPrice,
    required this.total,
    required this.isFree,
  });

  final int qty;
  final double unitPrice;
  final double total;
  final bool isFree;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final style = AppTypography.price.copyWith(color: palette.black);

    if (isFree) {
      return Text(Formatters.price(0), style: style);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            Formatters.calculation(qty, unitPrice),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Text(Formatters.price(total), style: style),
      ],
    );
  }
}
