import 'package:flutter/material.dart';

class DropdownSession extends StatelessWidget {
  final Map<String, String> items;
  final String? selectedValue;
  final void Function(String?) onChanged;

  const DropdownSession({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black),
        iconEnabledColor: Colors.black,
        underline: const SizedBox(),
        hint: const Text(
          'Selecione uma sessão',
          style: TextStyle(color: Colors.black),
        ),
        isExpanded: true,
        items:
            items.entries
                .map(
                  (entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
