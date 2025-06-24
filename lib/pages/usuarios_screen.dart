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
      id: json['id'],
      nombre: json['nombre'],
      familia: json['familia'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'familia': familia,
    };
  }
}

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({Key? key}) : super(key: key);

  @override
  State<UsuariosScreen> createState() => _MaquinasScreenState();
}

class _MaquinasScreenState extends State<UsuariosScreen> {
  List<Maquina> _maquinas = [];

  final String baseUrl = 'http://desarrollotecnologicoar.com/api2/maquinas/';

  final List<String> familias = ['Router', 'Láser CO2', 'Láser Fibra Óptica', 'Plasma', 'Dobladora', 'Grua Neumática', 'Externa'];

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
          _maquinas = data.map((item) => Maquina.fromJson(item)).toList();
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
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'familia': familia,
          'created_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          _maquinas.add(Maquina.fromJson(data));
        });
      } else if (response.statusCode == 301 || response.statusCode == 302) {
        // Seguir la redirección manualmente
        final redirectedUrl = response.headers['location'];
        if (redirectedUrl != null) {
          print('Redirigiendo a: $redirectedUrl');
          final newResponse = await http.post(
            Uri.parse(redirectedUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nombre': nombre,
              'familia': familia,
              'created_at': DateTime.now().toIso8601String(),
            }),
          );
          if (newResponse.statusCode == 201) {
            final data = jsonDecode(newResponse.body);
            setState(() {
              _maquinas.add(Maquina.fromJson(data));
            });
          } else {
            print('Error después de redirección: ${newResponse.statusCode} - ${newResponse.body}');
          }
        }
      } else {
        print('Error al crear máquina [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }


    Future<void> _editarMaquina(int id, String nombre, String familia) async {
  try {
    final response = await http.put(
      Uri.parse('${baseUrl}${id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'familia': familia,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        int index = _maquinas.indexWhere((m) => m.id == id);
        if (index != -1) {
          _maquinas[index] = Maquina.fromJson(data);
        }
      });
    } else if (response.statusCode == 301 || response.statusCode == 302) {
      // Seguir la redirección manualmente
      final redirectedUrl = response.headers['location'];
        if (redirectedUrl != null) {
          print('Redirigiendo a: $redirectedUrl');
          final newResponse = await http.put(
            Uri.parse(redirectedUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nombre': nombre,
              'familia': familia,
            }),
          );
          if (newResponse.statusCode == 200) {
            final data = jsonDecode(newResponse.body);
            setState(() {
              int index = _maquinas.indexWhere((m) => m.id == id);
              if (index != -1) {
                _maquinas[index] = Maquina.fromJson(data);
              }
            });
          } else {
            print('Error después de redirección: ${newResponse.statusCode} - ${newResponse.body}');
          }
        }
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

      if (response.statusCode == 200 || response.statusCode == 301) {
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
    final _nombreController = TextEditingController(text: maquina?.nombre ?? '');
    String _familiaSeleccionada = maquina?.familia ?? familias.first; // Selecciona la familia actual o la primera opción

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(maquina == null ? 'Crear Máquina' : 'Editar Máquina'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                 DropdownButtonFormField<String>(
                  value: _familiaSeleccionada,
                  decoration: const InputDecoration(labelText: 'Familia'),
                  items: familias.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _familiaSeleccionada = newValue;
                    }
                  }
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
                ElevatedButton(
              child: Text(maquina == null ? 'Crear' : 'Guardar'),
              onPressed: () async {
                String nombre = _nombreController.text.trim();
                if (nombre.isEmpty) {
                  return;
                }

                if (maquina == null) {
                  await _crearMaquina(nombre, _familiaSeleccionada);
                } else {
                  await _editarMaquina(maquina.id!, nombre, _familiaSeleccionada);
                }

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Máquinas'),
      ),
      body: _maquinas.isEmpty
          ? const Center(child: Text('No hay máquinas registradas'))
          : ListView.builder(
              itemCount: _maquinas.length,
              itemBuilder: (context, index) {
                final maquina = _maquinas[index];
                return ListTile(
                  title: Text(maquina.nombre),
                  subtitle: Text('Familia: ${maquina.familia}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _mostrarDialogo(maquina: maquina);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _eliminarMaquina(maquina.id!);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _mostrarDialogo();
        },
      ),
    );
  }
}
