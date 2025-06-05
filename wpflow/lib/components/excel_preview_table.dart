import 'package:flutter/material.dart';

class ExcelPreviewTable extends StatelessWidget {
  final List<Map<String, String>> records;
  final String? nameColumn;
  final String? phoneColumn;
  final String? messageColumn;

  const ExcelPreviewTable({
    super.key,
    required this.records,
    required this.nameColumn,
    required this.phoneColumn,
    required this.messageColumn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey[300]),
            columns: const [
              DataColumn(label: Text('Nome')),
              DataColumn(label: Text('Telefone')),
              DataColumn(label: Text('Mensagem')),
              DataColumn(label: Text('Status')),
            ],
            rows:
                records.map((rec) {
                  return DataRow(
                    cells: [
                      DataCell(Text(rec[nameColumn ?? 'A'] ?? '')),
                      DataCell(Text(rec[phoneColumn ?? 'B'] ?? '')),
                      DataCell(Text(rec[messageColumn ?? 'C'] ?? '')),
                      DataCell(
                        Text(
                          rec['Status'] ?? '',
                          style: TextStyle(
                            color:
                                rec['Status'] == 'Enviado'
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
