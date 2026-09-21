import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/ticket_card.dart';
import '../../events/data/demo_events.dart';
import '../data/demo_tickets.dart';

/// Everything that has been bought, cancelled tickets included — a cancelled
/// ticket keeps its place in the list.
class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tickets = demoTickets;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.gutter,
                Spacing.md,
                Spacing.gutter,
                Spacing.block,
              ),
              child: Text(
                AppTexts.titleMyTickets,
                style: AppTypography.posterXL.copyWith(color: palette.black),
              ),
            ),
          ),
          if (tickets.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(message: AppTexts.emptyTickets),
            )
          else
            SliverList.separated(
              itemCount: tickets.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: Spacing.md),
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.gutter,
                  ),
                  child: TicketCard(
                    ticket: ticket,
                    event: demoEventById(ticket.eventId),
                  ),
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: Spacing.block)),
        ],
      ),
    );
  }
}
