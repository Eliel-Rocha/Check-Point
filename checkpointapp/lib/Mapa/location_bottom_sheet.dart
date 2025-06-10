import 'package:flutter/material.dart';
import 'package:checkpointapp/BancoDeDados/localizacoes.dart';

// Widget que representa o BottomSheet com a lista de localizações salvas
class LocationBottomSheet extends StatelessWidget {
  final List<LocationModel> localizacoes; // Lista de localizações salvas
  final TextEditingController
  descriptionController; // Controller do campo de texto para nova descrição
  final Future<void> Function(String descricao)
  onAdd; // Função para adicionar nova localização
  final Future<void> Function(LocationModel loc, String novaDescricao)
  onEdit; // Função para editar
  final Future<void> Function(int id) onDelete; // Função para deletar
  final ScrollController scrollController;

  const LocationBottomSheet({
    super.key,
    required this.localizacoes,
    required this.descriptionController,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Cor de fundo do bottom sheet
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text("Adicionar Localização"), // Título da seção de adicionar
          // Campo de texto para digitar a nova descrição
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: "Descrição"),
          ),

          const SizedBox(height: 16),

          // Botão para salvar uma nova localização
          ElevatedButton(
            onPressed: () async {
              final desc = descriptionController.text.trim(); // Remove espaços
              if (desc.isEmpty) {
                // Se o campo estiver vazio, mostra um aviso
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Por favor, insira uma descrição."),
                  ),
                );
                return;
              }

              // Chama a função de salvar passando a descrição
              await onAdd(desc);

              // Limpa o campo de texto depois de salvar
              descriptionController.clear();
            },
            child: const Text("Salvar Localização"),
          ),

          const SizedBox(height: 16),

          // Mapeia a lista de localizações e gera um ListTile pra cada uma
          ...localizacoes.map((loc) {
            return ListTile(
              title: Text(loc.description), // Descrição principal
              subtitle: Text(
                'Lat: ${loc.latitude.toStringAsFixed(5)}, '
                'Lng: ${loc.longitude.toStringAsFixed(5)}\n'
                'Data: ${loc.timestamp.toLocal()}', // Info secundária
              ),
              isThreeLine: true, // Deixa o espaço do ListTile mais alto
              // Ícones de editar e deletar no canto direito
              trailing: Row(
                mainAxisSize: MainAxisSize.min, // Evita ocupar muito espaço
                children: [
                  // Botão de editar
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      // Cria um controller com a descrição atual
                      final controller = TextEditingController(
                        text: loc.description,
                      );

                      // Abre um AlertDialog pra editar a descrição
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Editar Descrição"),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: "Nova descrição",
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancelar"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final nova = controller.text.trim();
                                  if (nova.isNotEmpty) {
                                    // Chama a função de editar com a nova descrição
                                    await onEdit(loc, nova);
                                    Navigator.pop(context); // Fecha o diálogo
                                  }
                                },
                                child: const Text("Salvar"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  // Botão de deletar
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async => await onDelete(loc.id!),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 50), // Espaço extra no final da lista
        ],
      ),
    );
  }
}
