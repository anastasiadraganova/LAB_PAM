import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/formatters.dart';
import '../../../shared/models/event.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/date_stamp.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/event_poster.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../events/domain/events_repository.dart';
import '../../events/presentation/events_providers.dart';

/// One event in full: poster, name, where and when, what it costs, and the way
/// to a ticket. Once the event has started, the button gives way to a line
/// saying so.
///
/// The event is read by its identifier from [eventByIdProvider], so a link
/// opened from outside shows the same loading and error states as the list.
class EventDetailsScreen extends ConsumerWidget {
  const EventDetailsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventByIdProvider(eventId));

    return switch (event) {
      AsyncData(value: final event?) => _EventDetailsView(event: event),
      AsyncData() => const _Message(message: AppTexts.eventNotFound),
      AsyncError() => _Message(
        message: AppTexts.listingError,
        action: AppTextButton(
          label: AppTexts.retry,
          onPressed: () => ref.invalidate(eventByIdProvider(eventId)),
        ),
      ),
      _ => Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const LoadingState(),
      ),
    };
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.message, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: EmptyState(message: message, action: action),
    );
  }
}

/// The organizer of the event also gets the way to delete it.
class _EventDetailsView extends ConsumerWidget {
  const _EventDetailsView({required this.event});

  final Event event;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
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
              DangerButton(
                label: AppTexts.deleteEvent,
                note: AppTexts.deleteEventNote,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: Spacing.sm),
              SecondaryButton(
                label: AppTexts.keepEvent,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;

    String message;
    try {
      await ref.read(eventActionsProvider).delete(event.id);
      message = AppTexts.eventDeleted;
      if (context.mounted) context.go(AppRoutes.events);
    } on EventException catch (error) {
      message = error.message;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final today = DateTime.now();
    final isToday = event.day == DateTime(today.year, today.month, today.day);
    final isPast = event.isPast(now: today);
    final user = ref.watch(currentUserProvider);
    final isOrganizer = user != null && event.ownerId == user.id;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              EventPoster(imageUrl: event.imageUrl, title: event.title),
              Positioned(
                top: AppSizes.stampInset,
                right: AppSizes.stampInset,
                child: DateStamp(date: event.dateTime, isToday: isToday),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.gutter,
              Spacing.lg,
              Spacing.gutter,
              Spacing.block,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTypography.posterXL.copyWith(color: palette.black),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  '${event.venue} · ${Formatters.dateAndTime(event.dateTime)}'
                  ' · ${event.category.value}',
                  style: AppTypography.meta.copyWith(color: palette.grey),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  Formatters.price(event.price),
                  style: AppTypography.price.copyWith(color: palette.black),
                ),
                const SizedBox(height: Spacing.block),
                Text(
                  event.description,
                  style: AppTypography.body.copyWith(color: palette.black),
                ),
                if (isOrganizer) ...[
                  const SizedBox(height: Spacing.xxl),
                  DangerButton(
                    label: AppTexts.deleteEvent,
                    note: AppTexts.deleteEventNote,
                    onPressed: () => _delete(context, ref),
                  ),
                ],
              ],
            ),
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
        child: isPast
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                child: Text(
                  AppTexts.eventIsPast,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(color: palette.grey),
                ),
              )
            : PrimaryButton(
                label: AppTexts.purchaseAction(isFree: event.isFree, qty: 1),
                onPressed: () => context.go(AppRoutes.purchase(event.id)),
              ),
      ),
    );
  }
}
