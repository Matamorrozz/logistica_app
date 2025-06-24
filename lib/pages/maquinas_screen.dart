import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Maquina {
  final int? id;
  final String nombre;
  final String familia;

  Maquina({
    this.id,
    required this.nombre,
    required this.familia,
  });

  factory Maquina.fromJson(Map<String, dynamic> json) {
    return Maquina(
      id: json['id'] as int?,
      // El API devuelve el nombre bajo la clave 'maquina'
      nombre: (json['maquina'] as String).trim(),
      // Si no viene 'familia', lo inicializamos vacío
      familia: (json['familia'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      // Para POST/PUT enviamos 'maquina'
      'maquina': nombre,
    };
    // Solo agregamos 'familia' si no está vacía
    if (familia.isNotEmpty) {
      map['familia'] = familia;
    }
    return map;
  }
}

class MaquinasScreen extends StatefulWidget {
  const MaquinasScreen({Key? key}) : super(key: key);

  @override
  State<MaquinasScreen> createState() => _MaquinasScreenState();
}

class _MaquinasScreenState extends State<MaquinasScreen> {
  List<Maquina> _maquinas = [];
  final String baseUrl = 'http://desarrollotecnologicoar.com/api2/maquinas/';
  final List<String> familias = [
    'Router',
    'Láser CO2',
    'Láser Fibra Óptica',
    'Plasma',
    'Dobladora',
    'Grua Neumática',
    'Externa'
  ];

  @override
  void initState() {
    super.initState();
    _fetchMaquinas();
  }

  Future<void> _fetchMaquinas() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _maquinas = data.map((e) => Maquina.fromJson(e)).toList();
        });
      } else {
        print('Error al obtener máquinas [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  Future<void> _crearMaquina(String nombre, String familia) async {
    try {
      final body = {
        'maquina': nombre,
        'familia': familia,
        'created_at': DateTime.now().toIso8601String(),
      };
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          _maquinas.add(Maquina.fromJson(data));
        });
      } else {
        print('Error al crear máquina [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  Future<void> _editarMaquina(int id, String nombre, String familia) async {
    try {
      final body = {
        'maquina': nombre,
        'familia': familia,
      };
      final response = await http.put(
        Uri.parse('$baseUrl$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final idx = _maquinas.indexWhere((m) => m.id == id);
          if (idx != -1) _maquinas[idx] = Maquina.fromJson(data);
        });
      } else {
        print('Error al editar máquina [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  Future<void> _eliminarMaquina(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$id'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _maquinas.removeWhere((m) => m.id == id);
        });
      } else {
        print('Error al eliminar máquina [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  void _mostrarDialogo({Maquina? maquina}) {
    final nombreCtrl = TextEditingController(text: maquina?.nombre ?? '');
    String familiaSel = maquina?.familia.isNotEmpty == true
        ? maquina!.familia
        : familias.first;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(maquina == null ? 'Crear Máquina' : 'Editar Máquina'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre de máquina'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: familiaSel,
              decoration: const InputDecoration(labelText: 'Familia'),
              items: familias
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) {
                if (v != null) familiaSel = v;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            child: Text(maquina == null ? 'Crear' : 'Guardar'),
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              if (nombre.isEmpty) return;
              if (maquina == null) {
                await _crearMaquina(nombre, familiaSel);
              } else {
                await _editarMaquina(maquina.id!, nombre, familiaSel);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Máquinas')),
      body: _maquinas.isEmpty
          ? const Center(child: Text('No hay máquinas registradas'))
          : ListView.builder(
              itemCount: _maquinas.length,
              itemBuilder: (_, i) {
                final m = _maquinas[i];
                return ListTile(
                  title: Text(m.nombre),
                  subtitle: m.familia.isNotEmpty ? Text('Familia: ${m.familia}') : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _mostrarDialogo(maquina: m),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarMaquina(m.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _mostrarDialogo(),
      ),
    );
  }
}
