import 'dart:typed_data';
import 'package:excel/excel.dart' as ex;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wpflow/models/session_manager.dart';
import 'package:wpflow/models/user.dart';
import '../components/user_menu.dart';
import '../components/header.dart';
import '../components/dropdown_session.dart';
import '../models/send_buck_message_excel.dart';
import '../components/excel_import_config.dart';
import '../components/excel_preview_table.dart';

class BuckMessageExcel extends StatefulWidget {
  const BuckMessageExcel({super.key});

  @override
  State<BuckMessageExcel> createState() => _BuckMessageExcelState();
}

class _BuckMessageExcelState extends State<BuckMessageExcel> {
  String? nameColumn;
  String? phoneColumn;
  String? messageColumn;
  int startRow = 1;
  late List<String> availableColumns;
  List<Map<String, String>> records = [];

  @override
  void initState() {
    super.initState();
    availableColumns = List.generate(702, (index) => getExcelColumnName(index));
    Future.microtask(() {
      context.read<SessionManagerProvider>().fetchSessionsForContext(context);
    });
  }

  String getExcelColumnName(int index) {
    String name = '';
    while (index >= 0) {
      name = String.fromCharCode(index % 26 + 65) + name;
      index = (index ~/ 26) - 1;
    }
    return name;
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
          (index) => getExcelColumnName(index),
        );
      });

      records.clear();
      for (var row in sheet.rows.skip(startRow - 1)) {
        Map<String, String> record = {};
        for (int i = 0; i < maxCols; i++) {
          String columnLetter = getExcelColumnName(i);
          record[columnLetter] =
              i < row.length && row[i] != null ? row[i]!.value.toString() : '';
        }

        final phone = record[phoneColumn ?? ''] ?? '';
        final message = record[messageColumn ?? ''] ?? '';

        if (phone.isEmpty || message.isEmpty) {
          continue;
        }

        record['Status'] = 'Pendente';
        records.add(record);
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SendBuckMessageExcelProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2F),
      body: Center(
        child: Container(
          width: size.width * 0.98,
          height: size.height * 0.95,
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
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Header(
                              titulo: 'Envio de mensagem em massa via excel!',
                            ),
                            const SizedBox(height: 20),
                            Consumer<SessionManagerProvider>(
                              builder: (context, sessionProvider, _) {
                                final sessionLabels =
                                    sessionProvider.sessionLabels;
                                final selected =
                                    sessionLabels.containsKey(
                                          sessionProvider.selectedSession,
                                        )
                                        ? sessionProvider.selectedSession
                                        : null;

                                return SizedBox(
                                  height: 30,
                                  child: DropdownSession(
                                    items: sessionLabels,
                                    selectedValue: selected,
                                    onChanged: (value) {
                                      sessionProvider.setSelectedSession(value);
                                    },
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 20),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isSmallScreen =
                                    constraints.maxWidth < 950;

                                final tableWidget = Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 400,
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth:
                                            isSmallScreen
                                                ? constraints.maxWidth
                                                : 600,
                                      ),
                                      child: ExcelPreviewTable(
                                        records: records,
                                        nameColumn: nameColumn,
                                        phoneColumn: phoneColumn,
                                        messageColumn: messageColumn,
                                      ),
                                    ),
                                  ),
                                );

                                if (isSmallScreen) {
                                  return Column(
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
                                      const SizedBox(height: 20),
                                      if (records.isNotEmpty) tableWidget,
                                    ],
                                  );
                                } else {
                                  return Row(
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
                                      const SizedBox(width: 20),
                                      if (records.isNotEmpty)
                                        Expanded(child: tableWidget),
                                    ],
                                  );
                                }
                              },
                            ),

                            if (records.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 24,
                                runSpacing: 16,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 250,
                                    child: ElevatedButton.icon(
                                      icon:
                                          provider.isSending
                                              ? const Icon(Icons.cancel)
                                              : const Icon(Icons.send),
                                      label: Text(
                                        provider.isSending
                                            ? "Cancelar mensagens"
                                            : "Enviar mensagens",
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            provider.isSending
                                                ? Colors.red
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                        foregroundColor: Colors.white,
                                        elevation: 7,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onPressed:
                                          provider.isSending
                                              ? () async {
                                                final confirm = await showDialog<
                                                  bool
                                                >(
                                                  context: context,
                                                  builder:
                                                      (context) => AlertDialog(
                                                        title: const Text(
                                                          'Cancelar envio',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        content: const Text(
                                                          'Tem certeza que deseja cancelar o envio de mensagens?',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            style: TextButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              foregroundColor:
                                                                  Colors.white,
                                                            ),
                                                            onPressed:
                                                                () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(
                                                                      false,
                                                                    ),
                                                            child: const Text(
                                                              'Não',
                                                            ),
                                                          ),
                                                          TextButton(
                                                            style: TextButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.green,
                                                              foregroundColor:
                                                                  Colors.white,
                                                            ),
                                                            onPressed:
                                                                () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(true),
                                                            child: const Text(
                                                              'Sim',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                );
                                                if (confirm == true) {
                                                  provider.stopSending();
                                                  provider.reset();
                                                  setState(() {
                                                    records.clear();
                                                  });
                                                }
                                              }
                                              : () async {
                                                final sessionProvider =
                                                    context
                                                        .read<
                                                          SessionManagerProvider
                                                        >();
                                                final selectedSession =
                                                    sessionProvider
                                                        .selectedSession;

                                                if (selectedSession == null) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Selecione uma sessão válida.',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                  return;
                                                }

                                                final token = sessionProvider
                                                    .getToken(selectedSession);
                                                if (token == null) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Token não encontrado para a sessão.',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                  return;
                                                }
                                                final userProvider =
                                                    Provider.of<UserProvider>(
                                                      context,
                                                      listen: false,
                                                    );
                                                final userId =
                                                    userProvider.userId ?? '';
                                                final sessionName =
                                                    '${userId}$selectedSession';

                                                await provider
                                                    .sendMessagesFromExcel(
                                                      session: sessionName,
                                                      token: token,
                                                      records: records,
                                                      nameColumn: nameColumn!,
                                                      phoneColumn: phoneColumn!,
                                                      messageColumn:
                                                          messageColumn!,
                                                      onProgress:
                                                          () => setState(() {}),
                                                    );
                                              },
                                    ),
                                  ),
                                  if (provider.isSending)
                                    SizedBox(
                                      width: 500,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${provider.messagesSent} / ${provider.totalMessages} mensagens enviadas',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          LinearProgressIndicator(
                                            value:
                                                provider.totalMessages > 0
                                                    ? provider.messagesSent /
                                                        provider.totalMessages
                                                    : 0,
                                            backgroundColor: Colors.greenAccent,
                                            color: Colors.black,
                                            minHeight: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(width: 16),
                                  if (records.isNotEmpty &&
                                      records[0]['Status'] != 'Pendente')
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      onPressed: () {
                                        if (provider.isPaused) {
                                          provider.resumeSending();
                                        } else {
                                          provider.pauseSending();
                                        }
                                      },
                                      child: Icon(
                                        provider.isPaused
                                            ? Icons.play_arrow
                                            : Icons.pause,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
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
