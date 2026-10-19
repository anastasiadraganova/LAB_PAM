import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/formatters.dart';
import '../../../shared/models/event.dart';
import '../../../shared/validation/validators.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/ticket_counter.dart';

/// How many tickets, what it comes to, and the button that says exactly what
/// it will do.
///
/// The count is always a whole number from 1 to 10: the counter cannot step
/// past either end, and the order is checked once more before the summary is
/// shown. The purchase goes through only after the summary is confirmed.
class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({
    super.key,
    required this.event,
    this.initialQty = Validators.minQty,
  });

  final Event event;
  final int initialQty;

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  late int _qty = Validators.qty(widget.initialQty) == null
      ? widget.initialQty
      : Validators.minQty;

  void _setQty(int value) {
    if (Validators.qty(value) != null) return;
    setState(() => _qty = value);
  }

  Future<void> _submit() async {
    final event = widget.event;
    if (Validators.qty(_qty) != null || event.isPast()) return;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _OrderSummary(event: event, qty: _qty),
    );
    if (confirmed != true || !mounted) return;

    // The ticket itself is stored from the next stage on; here the scenario
    // only moves on to the tickets section and reports the result.
    final messenger = ScaffoldMessenger.of(context);
    context.go(AppRoutes.myTickets);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(AppTexts.purchaseResult(isFree: event.isFree))),
      );
  }

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
            minQty: Validators.minQty,
            maxQty: Validators.maxQty,
            onChanged: _setQty,
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
          onPressed: _submit,
        ),
      ),
    );
  }
}

/// The order once more before it goes through: the event, the calculation and
/// the same action as on the screen behind it.
class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.event, required this.qty});

  final Event event;
  final int qty;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.gutter,
          0,
          Spacing.gutter,
          Spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppTexts.checkOrder,
              style: AppTypography.caption.copyWith(color: palette.grey),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              event.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.poster.copyWith(color: palette.black),
            ),
            const SizedBox(height: Spacing.xxs),
            Text(
              '${event.venue} · ${Formatters.dateAndTime(event.dateTime)}',
              style: AppTypography.meta.copyWith(color: palette.grey),
            ),
            const SizedBox(height: Spacing.lg),
            _CalculationRow(
              qty: qty,
              unitPrice: event.price,
              total: event.price * qty,
              isFree: event.isFree,
            ),
            const SizedBox(height: Spacing.block),
            PrimaryButton(
              label: AppTexts.purchaseAction(isFree: event.isFree, qty: qty),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: Spacing.sm),
            SecondaryButton(
              label: AppTexts.changeQty,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
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
