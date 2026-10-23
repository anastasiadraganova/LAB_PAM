import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/ticket.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/ticket_card.dart';
import '../../events/presentation/events_providers.dart';
import '../domain/tickets_repository.dart';
import 'tickets_controller.dart';

/// Everything that has been bought, cancelled tickets included — a cancelled
/// ticket keeps its place in the list.
///
/// The tickets come from [ticketsControllerProvider], the events they refer to
/// from the listing. Tapping an active ticket offers to cancel it.
class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final tickets = ref.watch(ticketsControllerProvider);
    final events = {
      for (final event in ref.watch(eventsProvider).value ?? const <Event>[])
        event.id: event,
    };

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(ticketsControllerProvider.future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
            switch (tickets) {
              AsyncValue(:final value?) when value.isEmpty =>
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(message: AppTexts.emptyTickets),
                ),
              AsyncValue(:final value?) => SliverList.separated(
                itemCount: value.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: Spacing.md),
                itemBuilder: (context, index) {
                  final ticket = value[index];
                  final event = events[ticket.eventId];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.gutter,
                    ),
                    child: TicketCard(
                      ticket: ticket,
                      event: event,
                      onTap: ticket.isActive
                          ? () => _offerCancel(context, ref, ticket, event)
                          : null,
                    ),
                  );
                },
              ),
              AsyncError() => SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  message: AppTexts.ticketsError,
                  action: AppTextButton(
                    label: AppTexts.retry,
                    onPressed: () => ref.invalidate(ticketsControllerProvider),
                  ),
                ),
              ),
              _ => const SliverFillRemaining(
                hasScrollBody: false,
                child: LoadingState(),
              ),
            },
            const SliverToBoxAdapter(child: SizedBox(height: Spacing.block)),
          ],
        ),
      ),
    );
  }

  Future<void> _offerCancel(
    BuildContext context,
    WidgetRef ref,
    Ticket ticket,
    Event? event,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CancelSheet(event: event),
    );
    if (confirmed != true) return;

    String message;
    try {
      await ref.read(ticketsControllerProvider.notifier).cancel(ticket.id);
      message = AppTexts.ticketCancelled;
    } on TicketException catch (error) {
      message = error.message;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// The question before a cancellation, with the way back as the quiet option.
class _CancelSheet extends StatelessWidget {
  const _CancelSheet({required this.event});

  final Event? event;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final event = this.event;

    return SafeArea(
      child: Padding(
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
            if (event != null) ...[
              Text(
                event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.poster.copyWith(color: palette.black),
              ),
              const SizedBox(height: Spacing.lg),
            ],
            DangerButton(
              label: AppTexts.cancelAction,
              note: AppTexts.cancelNote,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: Spacing.sm),
            SecondaryButton(
              label: AppTexts.keepTicket,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
