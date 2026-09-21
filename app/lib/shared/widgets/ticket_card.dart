import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';
import '../app_texts.dart';
import '../formatters.dart';
import '../models/event.dart';
import '../models/ticket.dart';
import 'stamp.dart';

/// A ticket in "Мои билеты".
///
/// The ink stub down the left edge is the ticket itself; the status sits at the
/// bottom, except for a spent one, where the stamp across the card says it.
class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.ticket,
    required this.event,
    this.onTap,
  });

  final Ticket ticket;

  /// The event the ticket was bought for, if it is known.
  final Event? event;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isUsed = ticket.status == TicketStatus.used;
    final isCancelled = ticket.status == TicketStatus.cancelled;

    final card = Material(
      color: palette.surface,
      borderRadius: AppRadius.print,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.print,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.print,
            border: Border.all(color: palette.rule, width: AppSizes.hairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: AppSizes.ticketSpine,
                  color: isCancelled ? palette.rule : palette.ink,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.sm),
                    child: _TicketBody(ticket: ticket, event: event),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!isUsed) return card;

    // The card fades, the stamp on top of it does not.
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: 0.5, child: card),
        IgnorePointer(
          child: StampFrame(
            color: palette.grey,
            tilt: AppSizes.usedStampTilt,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            child: Text(
              AppTexts.statusUsed,
              style: AppTypography.stamp.copyWith(color: palette.grey),
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketBody extends StatelessWidget {
  const _TicketBody({required this.ticket, required this.event});

  final Ticket ticket;
  final Event? event;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final event = this.event;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          event?.title ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.poster.copyWith(color: palette.black),
        ),
        if (event != null) ...[
          const SizedBox(height: Spacing.xxs),
          Text(
            '${event.venue} · ${Formatters.dateAndTime(event.dateTime)}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.meta.copyWith(color: palette.grey),
          ),
        ],
        const SizedBox(height: Spacing.xs),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.xxs,
          children: [
            Text(
              Formatters.tickets(ticket.qty),
              style: AppTypography.price.copyWith(color: palette.black),
            ),
            Text(
              Formatters.price(ticket.totalPrice),
              style: AppTypography.price.copyWith(color: palette.black),
            ),
          ],
        ),
        if (ticket.status != TicketStatus.used) ...[
          const SizedBox(height: Spacing.xs),
          _TicketStatus(status: ticket.status),
        ],
      ],
    );
  }
}

class _TicketStatus extends StatelessWidget {
  const _TicketStatus({required this.status});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    switch (status) {
      case TicketStatus.active:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.statusDot,
              height: AppSizes.statusDot,
              decoration: BoxDecoration(
                color: palette.fluo,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Text(
              AppTexts.statusActive,
              style: AppTypography.meta.copyWith(color: palette.black),
            ),
          ],
        );
      case TicketStatus.cancelled:
        return Text(
          AppTexts.statusCancelled,
          style: AppTypography.meta.copyWith(
            color: palette.grey,
            decoration: TextDecoration.lineThrough,
            decorationColor: palette.grey,
          ),
        );
      case TicketStatus.used:
        // The stamp across the card carries this status instead.
        return const SizedBox.shrink();
    }
  }
}
