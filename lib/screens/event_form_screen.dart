import 'package:flutter/material.dart';

import '../models/activity_event.dart';
import '../utils/event_store.dart';

/// Yeni kayıt ekleme / var olanı düzenleme ekranı.
/// Basitleştirilmiş modele göre: başlık, açıklama, tür, renk, tarih, tüm gün.
class EventFormScreen extends StatefulWidget {
  final DateTime? initialDate;
  final ActivityEvent? initialEvent;

  const EventFormScreen({super.key, this.initialDate, this.initialEvent});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late EventType _type;
  late Color _color;
  late DateTime _startTime;
  late TimeOfDay _startTimeOfDay;
  late bool _isAllDay;
  late bool _isCompleted;
  late bool _isPinned;

  static const List<Color> _availableColors = [
    Colors.teal,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.brown,
    Colors.pink,
  ];

  bool get _isEditing => widget.initialEvent != null;

  @override
  void initState() {
    super.initState();
    final e = widget.initialEvent;
    _titleController = TextEditingController(text: e?.title ?? '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _type = e?.type ?? EventType.event;
    _color = e?.color ?? Colors.teal;
    _startTime = e?.startTime ?? widget.initialDate ?? DateTime.now();
    _startTimeOfDay = TimeOfDay.fromDateTime(_startTime);
    _isAllDay = e?.isAllDay ?? true;
    _isCompleted = e?.isCompleted ?? false;
    _isPinned = e?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('tr', 'TR'),
      helpText: 'TARİH SEÇİN',
      cancelText: 'İptal',
      confirmText: 'Tamam',
      fieldLabelText: 'Tarih girin',
      errorFormatText: 'Geçersiz tarih formatı',
      errorInvalidText: 'Geçersiz tarih',
    );
    if (picked != null) {
      setState(() {
        _startTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _startTime.hour,
          _startTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTimeOfDay,
      helpText: 'SAAT SEÇİN',
      cancelText: 'İptal',
      confirmText: 'Tamam',
      hourLabelText: 'Saat',
      minuteLabelText: 'Dakika',
      // Türkiye'de 24 saatlik format standarttır.
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('tr', 'TR'),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTimeOfDay = picked;
        _startTime = DateTime(
          _startTime.year,
          _startTime.month,
          _startTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }
  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final event = ActivityEvent(
      id: widget.initialEvent?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _type,
      color: _color,
      startTime: _startTime,
      isAllDay: _isAllDay,
      isCompleted: _isCompleted,
      isPinned: _isPinned,
      createdAt: widget.initialEvent?.createdAt,
    );

    if (_isEditing) {
      EventStore().updateEvent(event);
    } else {
      EventStore().addEvent(event);
    }
    Navigator.pop(context);
  }

  void _delete() {
    if (widget.initialEvent == null) return;
    EventStore().deleteEvent(widget.initialEvent!.id);
    Navigator.pop(context);
  }

  IconData _iconForType(EventType type) {
    switch (type) {
      case EventType.event:
        return Icons.event;
      case EventType.note:
        return Icons.note;
      case EventType.task:
        return Icons.task_alt;
      case EventType.reminder:
        return Icons.notifications;
    }
  }

  String _labelForType(EventType type) {
    switch (type) {
      case EventType.event:
        return 'Etkinlik';
      case EventType.note:
        return 'Not';
      case EventType.task:
        return 'Görev';
      case EventType.reminder:
        return 'Hatırlatıcı';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Kaydı Düzenle' : 'Yeni Kayıt'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Sil',
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Başlık', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Başlık gerekli' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Tür seçimi
            const Text('Tür', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: EventType.values.map((t) {
                final selected = _type == t;
                return ChoiceChip(
                  selected: selected,
                  label: Text(_labelForType(t)),
                  avatar: Icon(_iconForType(t), size: 16),
                  onSelected: (_) => setState(() => _type = t),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Renk seçimi
            const Text('Renk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: _availableColors.map((c) {
                final selected = _color.toARGB32() == c.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected ? Border.all(color: Colors.black, width: 2.5) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Tarih / Saat
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                        '${_startTime.day}.${_startTime.month}.${_startTime.year}'),
                    onPressed: _pickDate,
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isAllDay)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time, size: 16),
                      label: Text(_startTimeOfDay.format(context)),
                      onPressed: _pickTime,
                    ),
                  ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tüm gün'),
              value: _isAllDay,
              onChanged: (v) => setState(() => _isAllDay = v),
            ),

            const Divider(),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sabitlenmiş'),
              secondary: const Icon(Icons.push_pin_outlined),
              value: _isPinned,
              onChanged: (v) => setState(() => _isPinned = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tamamlandı'),
              secondary: const Icon(Icons.check_circle_outline),
              value: _isCompleted,
              onChanged: (v) => setState(() => _isCompleted = v),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(_isEditing ? 'Kaydet' : 'Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}