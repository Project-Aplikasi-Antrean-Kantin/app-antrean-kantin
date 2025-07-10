import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class TimePicker extends StatelessWidget {
  final String label;
  final String selectedTime;
  final Function(String) onTimeChanged;

  const TimePicker({
    super.key,
    required this.label,
    required this.selectedTime,
    required this.onTimeChanged,
  });

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(selectedTime.split(":")[0]),
        minute: int.parse(selectedTime.split(":")[1]),
      ),
    );

    if (timeOfDay != null) {
      final formattedTime =
          "${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}:00";
      onTimeChanged(formattedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("$label: $selectedTime"),
        ElevatedButton(
          onPressed: () => _pickTime(context),
          child: Text("Pick $label"),
        ),
      ],
    );
  }
}
