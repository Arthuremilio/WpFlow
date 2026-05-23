import 'package:flutter/material.dart';

class ExcelImportConfigPanel extends StatelessWidget {
  final List<String> columnOptions;
  final String? nameColumn;
  final String? phoneColumn;
  final String? messageColumn;
  final int startRow;
  final Function(String?) onNameChanged;
  final Function(String?) onPhoneChanged;
  final Function(String?) onMessageChanged;
  final Function(String) onStartRowChanged;
  final VoidCallback onImport;

  const ExcelImportConfigPanel({
    super.key,
    required this.columnOptions,
    required this.nameColumn,
    required this.phoneColumn,
    required this.messageColumn,
    required this.startRow,
    required this.onNameChanged,
    required this.onPhoneChanged,
    required this.onMessageChanged,
    required this.onStartRowChanged,
    required this.onImport,
  });

  Widget _buildDropdown(
    String label,
    String? value,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Container(
            width: 160,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              dropdownColor: Colors.white,
              underline: const SizedBox(),
              hint: const Text(
                'Selecione',
                style: TextStyle(color: Colors.black),
              ),
              style: const TextStyle(color: Colors.black),
              items:
                  columnOptions.map((col) {
                    return DropdownMenuItem(value: col, child: Text(col));
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const SizedBox(
            width: 80,
            child: Text('Linha:', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Container(
            width: 160,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Ex: 2',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: onStartRowChanged,
              controller: TextEditingController(text: startRow.toString()),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown("Nome", nameColumn, onNameChanged),
        _buildDropdown("Telefone", phoneColumn, onPhoneChanged),
        _buildDropdown("Mensagem", messageColumn, onMessageChanged),
        _buildRowInput(),
        const SizedBox(height: 16),
        SizedBox(
          width: 250,
          child: ElevatedButton(
            onPressed: onImport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              elevation: 7,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Selecionar arquivo Excel"),
          ),
        ),
      ],
    );
  }
}
