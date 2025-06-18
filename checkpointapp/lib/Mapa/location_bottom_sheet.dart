import 'package:flutter/material.dart';
import 'package:checkpointapp/BancoDeDados/localizacoes.dart';

class LocationBottomSheet extends StatelessWidget {
  final List<LocationModel> localizacoes;
  final TextEditingController descriptionController;
  final Future<void> Function(String descricao) onAdd;
  final Future<void> Function(LocationModel loc, String novaDescricao) onEdit;
  final Future<void> Function(int id) onDelete;
  final ScrollController scrollController;
  final LocationModel? selectedLocation;
  final VoidCallback onDeselect;

  const LocationBottomSheet({
    super.key,
    required this.localizacoes,
    required this.descriptionController,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.scrollController,
    // ADICIONE-OS AO CONSTRUTOR:
    required this.selectedLocation,
    required this.onDeselect,
  });

  @override
  Widget build(BuildContext context) {
    // Se uma localização foi selecionada, mostra apenas os detalhes dela.
    if (selectedLocation != null) {
      return _buildSelectedView(context, selectedLocation!);
    }

    // Caso contrário, mostra a visão padrão com a lista e o formulário de adição.
    return _buildDefaultView(context);
  }

  // Mostra apenas o item selecionado.
  Widget _buildSelectedView(BuildContext context, LocationModel loc) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        controller: scrollController,
        children: [
          ListTile(
            title: Text(loc.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text(
              'Lat: ${loc.latitude.toStringAsFixed(5)}, Lng: ${loc.longitude.toStringAsFixed(5)}\nData: ${loc.timestamp.toLocal()}',
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditButton(context, loc),
                _buildDeleteButton(loc.id!),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onDeselect, // Botão para limpar a seleção e voltar
            icon: const Icon(Icons.arrow_back),
            label: const Text("Mostrar Todos"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white70),
          ),
        ],
      ),
    );
  }

  // Mostra o formulário e a lista completa.
  Widget _buildDefaultView(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        controller: scrollController,
        children: [
          const Text("Adicionar Localização"),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: "Descrição"),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final desc = descriptionController.text.trim();
              if (desc.isNotEmpty) {
                await onAdd(desc);
                descriptionController.clear();
              }
            },
            child: const Text("Salvar Localização"),
          ),
          const Divider(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Locais Salvos", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...localizacoes.map((loc) {
            return ListTile(
              title: Text(loc.description),
              subtitle: Text('Lat: ${loc.latitude.toStringAsFixed(5)}, Lng: ${loc.longitude.toStringAsFixed(5)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEditButton(context, loc),
                  _buildDeleteButton(loc.id!),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Funções de botão reutilizadas para não repetir código.
  IconButton _buildEditButton(BuildContext context, LocationModel loc) {
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.blue),
      onPressed: () async {
        final controller = TextEditingController(text: loc.description);
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Editar Descrição"),
            content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Nova descrição")),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
              ElevatedButton(
                onPressed: () async {
                  final nova = controller.text.trim();
                  if (nova.isNotEmpty) {
                    await onEdit(loc, nova);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Salvar"),
              ),
            ],
          ),
        );
      },
    );
  }

  IconButton _buildDeleteButton(int id) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () async => await onDelete(id),
    );
  }
}