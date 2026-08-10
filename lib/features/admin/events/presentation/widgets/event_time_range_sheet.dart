import 'package:flutter/material.dart';

import 'event_form_widgets.dart';

class EventTimeRange {
  const EventTimeRange({required this.start, required this.end});

  final TimeOfDay start;
  final TimeOfDay end;

  bool get endsNextDay => _minutes(end) <= _minutes(start);

  static int _minutes(TimeOfDay value) => value.hour * 60 + value.minute;
}

Future<EventTimeRange?> showEventTimeRangeSheet({
  required BuildContext context,
  EventTimeRange? initialRange,
}) {
  return showModalBottomSheet<EventTimeRange>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _EventTimeRangeSheet(initialRange: initialRange),
  );
}

class _EventTimeRangeSheet extends StatefulWidget {
  const _EventTimeRangeSheet({this.initialRange});

  final EventTimeRange? initialRange;

  @override
  State<_EventTimeRangeSheet> createState() => _EventTimeRangeSheetState();
}

class _EventTimeRangeSheetState extends State<_EventTimeRangeSheet> {
  late TimeOfDay _start;
  late TimeOfDay _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initialRange?.start ?? TimeOfDay.now();
    _end = widget.initialRange?.end ?? _addMinutes(_start, 60);
  }

  @override
  Widget build(BuildContext context) {
    final range = EventTimeRange(start: _start, end: _end);

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: eventFormOutline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Waktu Kegiatan',
              style: TextStyle(
                color: eventFormInk,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tentukan waktu mulai dan selesai kegiatan.',
              style: TextStyle(
                color: eventFormMuted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _TimeSelectionTile(
                    key: const ValueKey('event-start-time-option'),
                    label: 'Mulai',
                    value: _start.format(context),
                    onTap: () => _pickTime(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeSelectionTile(
                    key: const ValueKey('event-end-time-option'),
                    label: 'Selesai',
                    value: _end.format(context),
                    onTap: () => _pickTime(isStart: false),
                  ),
                ),
              ],
            ),
            if (range.endsNextDay) ...[
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: eventFormMuted,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Waktu selesai dihitung pada hari berikutnya.',
                      style: TextStyle(color: eventFormMuted, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                key: const ValueKey('confirm-event-time-range'),
                onPressed: () => Navigator.of(context).pop(range),
                style: FilledButton.styleFrom(
                  backgroundColor: eventFormBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Gunakan Waktu',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (selected == null || !mounted) return;

    setState(() {
      if (isStart) {
        _start = selected;
      } else {
        _end = selected;
      }
    });
  }

  static TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    final total = (time.hour * 60 + time.minute + minutes) % (24 * 60);
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }
}

class _TimeSelectionTile extends StatelessWidget {
  const _TimeSelectionTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: eventFormFill,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: eventFormMuted, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: eventFormBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      color: eventFormInk,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
