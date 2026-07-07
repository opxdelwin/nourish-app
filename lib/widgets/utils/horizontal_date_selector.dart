import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HorizontalDatePicker extends StatefulWidget {
  final ValueChanged<DateTime> onDateIncrement;
  final ValueChanged<DateTime> onDateDecrement;

  const HorizontalDatePicker({
    super.key,
    required this.onDateIncrement,
    required this.onDateDecrement,
  });

  @override
  State<HorizontalDatePicker> createState() => _HorizontalDatePickerState();
}

class _HorizontalDatePickerState extends State<HorizontalDatePicker> {
  DateTime _selectedDate = DateTime.now();

  void _incrementDate() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    widget.onDateIncrement(_selectedDate);
  }

  void _decrementDate() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    widget.onDateDecrement(_selectedDate);
  }

  Future<void> _pickDateFromCalendar() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      final oldDate = _selectedDate;  // Save old date before updating
      setState(() {
        _selectedDate = picked;
      });
      // Compare with oldDate to decide which callback to call
      if (picked.isAfter(oldDate)) {
        widget.onDateIncrement(_selectedDate);
      } else {
        widget.onDateDecrement(_selectedDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
            onPressed: _decrementDate,
          ),
          GestureDetector(
            onTap: _pickDateFromCalendar,
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.black, size: 28),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEE, MMM d').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.black, size: 28),
            onPressed: _incrementDate,
          ),
        ],
      ),
    );
  }
}
