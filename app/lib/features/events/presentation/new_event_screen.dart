import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/app_texts.dart';
import '../../../shared/formatters.dart';
import '../../../shared/models/event_category.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../domain/events_repository.dart';
import 'events_providers.dart';

/// A new event: what, where, when, for how much, and a poster.
///
/// The form is screen-local state; publishing goes through [EventActions],
/// which uploads the poster with `POST /files` and then creates the event.
/// As on the sign-in screen, errors show after the first attempt to publish.
class NewEventScreen extends ConsumerStatefulWidget {
  const NewEventScreen({super.key});

  @override
  ConsumerState<NewEventScreen> createState() => _NewEventScreenState();
}

class _NewEventScreenState extends ConsumerState<NewEventScreen> {
  /// The backend accepts files up to 5 MB.
  static const int _maxPosterBytes = 5 * 1024 * 1024;

  final _title = TextEditingController();
  final _venue = TextEditingController();
  final _price = TextEditingController(text: '0');
  final _description = TextEditingController();

  EventCategory? _category;
  DateTime? _dateTime;
  Uint8List? _poster;
  String _posterName = 'poster.jpg';

  bool _showErrors = false;
  bool _isSubmitting = false;
  String? _refusal;

  String? get _titleError =>
      _title.text.trim().isEmpty ? AppTexts.titleRequired : null;
  String? get _venueError =>
      _venue.text.trim().isEmpty ? AppTexts.venueRequired : null;
  String? get _categoryError =>
      _category == null ? AppTexts.categoryRequired : null;

  String? get _dateError {
    final dateTime = _dateTime;
    if (dateTime == null) return AppTexts.dateRequired;
    if (!dateTime.isAfter(DateTime.now())) return AppTexts.dateInPast;
    return null;
  }

  double? get _parsedPrice =>
      double.tryParse(_price.text.trim().replaceAll(',', '.'));

  String? get _priceError {
    final price = _parsedPrice;
    return price == null || price < 0 ? AppTexts.priceInvalid : null;
  }

  String? get _posterError =>
      (_poster?.length ?? 0) > _maxPosterBytes ? AppTexts.posterTooLarge : null;

  bool get _isValid => [
    _titleError,
    _venueError,
    _categoryError,
    _dateError,
    _priceError,
    _posterError,
  ].every((error) => error == null);

  @override
  void dispose() {
    _title.dispose();
    _venue.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  void _changed([Object? _]) {
    if (_showErrors || _refusal != null) setState(() => _refusal = null);
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initial = _dateTime ?? now.add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;

    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _refusal = null;
    });
  }

  Future<void> _pickPoster() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _poster = bytes;
      _posterName = file.name;
      _refusal = null;
    });
  }

  Future<void> _publish() async {
    FocusScope.of(context).unfocus();
    if (!_isValid) {
      setState(() => _showErrors = true);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _refusal = null;
    });

    final draft = EventDraft(
      title: _title.text.trim(),
      category: _category!,
      venue: _venue.text.trim(),
      dateTime: _dateTime!,
      price: _parsedPrice!,
      description: _description.text.trim(),
    );

    try {
      final event = await ref
          .read(eventActionsProvider)
          .publish(draft, posterBytes: _poster, posterName: _posterName);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      context.go(AppRoutes.event(event.id));
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text(AppTexts.eventPublished)));
    } on EventException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _refusal = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final showErrors = _showErrors;
    final dateTime = _dateTime;
    final refusal = _refusal;

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
            AppTexts.newEvent,
            style: AppTypography.posterXL.copyWith(color: palette.black),
          ),
          const SizedBox(height: Spacing.block),
          AppTextField(
            label: AppTexts.fieldTitle,
            controller: _title,
            errorText: showErrors ? _titleError : null,
            textInputAction: TextInputAction.next,
            onChanged: _changed,
          ),
          const SizedBox(height: Spacing.md),
          _Label(AppTexts.fieldCategory),
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: [
              for (final category in EventCategory.values)
                ChoiceChip(
                  label: Text(category.value),
                  selected: _category == category,
                  onSelected: (_) {
                    setState(() => _category = category);
                    _changed();
                  },
                ),
            ],
          ),
          if (showErrors && _categoryError != null) _Error(_categoryError!),
          const SizedBox(height: Spacing.md),
          AppTextField(
            label: AppTexts.fieldVenue,
            controller: _venue,
            errorText: showErrors ? _venueError : null,
            textInputAction: TextInputAction.next,
            onChanged: _changed,
          ),
          const SizedBox(height: Spacing.md),
          _Label(AppTexts.fieldDateTime),
          SecondaryButton(
            label: dateTime == null
                ? AppTexts.pickDateTime
                : Formatters.dateAndTime(dateTime),
            onPressed: _pickDateTime,
          ),
          if (showErrors && _dateError != null) _Error(_dateError!),
          const SizedBox(height: Spacing.md),
          AppTextField(
            label: AppTexts.fieldPrice,
            controller: _price,
            errorText: showErrors ? _priceError : null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            onChanged: _changed,
          ),
          const SizedBox(height: Spacing.md),
          AppTextField(
            label: AppTexts.fieldDescription,
            controller: _description,
            maxLines: 5,
            onChanged: _changed,
          ),
          const SizedBox(height: Spacing.md),
          _Label(AppTexts.fieldPoster),
          if (_poster != null) ...[
            ClipRRect(
              borderRadius: AppRadius.print,
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Image.memory(_poster!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: Spacing.sm),
          ],
          SecondaryButton(
            label: _poster == null
                ? AppTexts.pickPoster
                : AppTexts.changePoster,
            onPressed: _pickPoster,
          ),
          if (showErrors && _posterError != null) _Error(_posterError!),
          if (refusal != null) ...[
            const SizedBox(height: Spacing.md),
            Text(
              refusal,
              style: AppTypography.body.copyWith(color: palette.black),
            ),
          ],
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
          label: AppTexts.publish,
          onPressed: _isSubmitting ? null : _publish,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xxs),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(color: context.palette.grey),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xxs),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(color: context.palette.black),
      ),
    );
  }
}
