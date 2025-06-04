import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class MessageTabs extends StatelessWidget {
  final TabController controller;
  final TextEditingController messageController;
  final PlatformFile? selectedImage;
  final Function(PlatformFile) onImageSelected;

  const MessageTabs({
    super.key,
    required this.controller,
    required this.messageController,
    required this.selectedImage,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: controller,
          labelColor: Colors.greenAccent,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'Texto'), Tab(text: 'Imagem')],
        ),
        SizedBox(
          height: 350,
          child: TabBarView(
            controller: controller,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: messageController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white12,
                    labelText: 'Mensagem',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (selectedImage != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black26,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.memory(
                        selectedImage!.bytes!,
                        fit: BoxFit.cover,
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          withData: true,
                        );
                        if (result != null && result.files.isNotEmpty) {
                          onImageSelected(result.files.first);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        shadowColor: Colors.black,
                        elevation: 7,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Selecionar Imagem'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
