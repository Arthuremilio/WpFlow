import 'dart:typed_data';
import 'package:excel/excel.dart' as ex;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/user_menu.dart';
import '../components/header.dart';
import '../components/dropdown_session.dart';
import '../models/send_message.dart';
import '../components/excel_import_config.dart';

class BuckMessageExcel extends StatefulWidget {
  const BuckMessageExcel({super.key});

  @override
  State<BuckMessageExcel> createState() => _BuckMessageExcelState();
}

class _BuckMessageExcelState extends State<BuckMessageExcel> {
  String? selectedSession;
  String? nameColumn;
  String? phoneColumn;
  String? messageColumn;
  int startRow = 1;
  List<String> availableColumns = [];
  List<Map<String, String>> records = [];

  @override
  void initState() {
    super.initState();
    availableColumns = ['A', 'B', 'C'];
  }

  Future<void> importExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      Uint8List? bytes = result.files.first.bytes;
      if (bytes == null) return;

      var excel = ex.Excel.decodeBytes(bytes);
      var sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) return;

      int maxCols = 3;
      for (var row in sheet.rows) {
        if (row.length > maxCols) {
          maxCols = row.length;
        }
      }

      setState(() {
        availableColumns = List.generate(
          maxCols,
          (index) => String.fromCharCode(65 + index),
        );
      });

      records.clear();
      for (var row in sheet.rows.skip(startRow - 1)) {
        Map<String, String> record = {};
        for (int i = 0; i < maxCols; i++) {
          String columnLetter = String.fromCharCode(65 + i);
          record[columnLetter] =
              i < row.length && row[i] != null ? row[i]!.value.toString() : '';
        }
        record['Status'] = 'Pendente';
        records.add(record);
      }

      setState(() {});
    }
  }

  Widget columnDropdown(
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
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              dropdownColor: Colors.white,
              underline: const SizedBox(),
              hint: const Text(
                "Selecione",
                style: TextStyle(color: Colors.black),
              ),
              style: const TextStyle(color: Colors.black),
              items:
                  availableColumns.map((col) {
                    return DropdownMenuItem(value: col, child: Text(col));
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget rowInput() {
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
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey),
            ),
            child: TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Ex: 2',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null && parsed >= 1) {
                  setState(() {
                    startRow = parsed;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final provider = Provider.of<SendMessageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2F),
      body: Center(
        child: Container(
          width: deviceSize.width * 0.98,
          height: deviceSize.height * 0.95,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.greenAccent, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Card(
              child: Row(
                children: [
                  const UserMenu(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ListView(
                        children: [
                          const Header(
                            titulo: 'Envio de mensagem em massa via excel!',
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 30,
                            child: DropdownSession(
                              items: provider.sessionLabels,
                              selectedValue: selectedSession,
                              onChanged:
                                  (value) =>
                                      setState(() => selectedSession = value),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Row(
                              children: [
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ExcelImportConfigPanel(
                                        columnOptions: availableColumns,
                                        nameColumn: nameColumn,
                                        phoneColumn: phoneColumn,
                                        messageColumn: messageColumn,
                                        startRow: startRow,
                                        onNameChanged:
                                            (val) => setState(
                                              () => nameColumn = val,
                                            ),
                                        onPhoneChanged:
                                            (val) => setState(
                                              () => phoneColumn = val,
                                            ),
                                        onMessageChanged:
                                            (val) => setState(
                                              () => messageColumn = val,
                                            ),
                                        onStartRowChanged: (val) {
                                          final parsed = int.tryParse(val);
                                          if (parsed != null && parsed >= 1) {
                                            setState(() => startRow = parsed);
                                          }
                                        },
                                        onImport: importExcel,
                                      ),
                                    ],
                                  ),
                                ),
                                if (records.isNotEmpty)
                                  SizedBox(
                                    height: 400,
                                    child: ListView.builder(
                                      itemCount: records.length,
                                      itemBuilder: (context, index) {
                                        final rec = records[index];
                                        return ListTile(
                                          title: Text(
                                            'Nome: ${rec[nameColumn ?? 'A']}, Telefone: ${rec[phoneColumn ?? 'B']}, Msg: ${rec[messageColumn ?? 'C']}',
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                21,
                                                19,
                                                19,
                                              ),
                                            ),
                                          ),
                                          trailing: Text(
                                            rec['Status'] ?? '',
                                            style: TextStyle(
                                              color:
                                                  rec['Status'] == 'Enviado'
                                                      ? Colors.green
                                                      : Colors.orange,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
