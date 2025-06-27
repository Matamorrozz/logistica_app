import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Operador {
  final int? id;
  final String? nombre;

  Operador({
    this.id,
     this.nombre,
  });

  factory Operador.fromJson(Map<String, dynamic> json) {
    return Operador(
      id: json['id'],
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
    };
  }
}

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({Key? key}) : super(key: key);

  @override
  State<UsuariosScreen> createState() => _OperadoresScreenState();
}

class _OperadoresScreenState extends State<UsuariosScreen> {
  List<Operador> _operadores = [];
  final String baseUrl = 'http://desarrollotecnologicoar.com/api2/operadores_logistica/';

  @override
  void initState() {
    super.initState();
    _fetchOperadores();
  }

  Future<void> _fetchOperadores() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _operadores = data.map((item) => Operador.fromJson(item)).toList();
        });
      } else {
        print('Error al obtener operadores [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  Future<void> _crearOperador(String nombre) async {
    try {
      final uri = Uri.parse(baseUrl);
      final payload = jsonEncode({'operador': nombre});

      // Intento inicial
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          _operadores.add(Operador.fromJson(data));
        });
      } else if (response.statusCode == 301 || response.statusCode == 302) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          final redirectedResponse = await http.post(
            Uri.parse(redirectUrl),
            headers: {'Content-Type': 'application/json'},
            body: payload,
          );
          if (redirectedResponse.statusCode == 201) {
            final data = jsonDecode(redirectedResponse.body);
            setState(() {
              _operadores.add(Operador.fromJson(data));
            });
          } else {
            print('Error al crear operador tras redirección [${redirectedResponse.statusCode}]: ${redirectedResponse.body}');
          }
        } else {
          print('Redirección sin ubicación');
        }
      } else {
        print('Error al crear operador [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  Future<void> _editarOperador(int id, String nombre) async {
    try {
      final uri = Uri.parse('$baseUrl$id');
      final payload = jsonEncode({'operador': nombre});

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final index = _operadores.indexWhere((o) => o.id == id);
          if (index != -1) {
            _operadores[index] = Operador.fromJson(data);
          }
        });
      } else {
        print('Error al editar operador [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  Future<void> _eliminarOperador(int id) async {
    try {
      final uri = Uri.parse('$baseUrl$id');
      final response = await http.delete(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _operadores.removeWhere((o) => o.id == id);
        });
      } else {
        print('Error al eliminar operador [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  void _mostrarDialogo({Operador? operador}) {
    final _nombreController = TextEditingController(text: operador?.nombre ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(operador == null ? 'Crear Operador' : 'Editar Operador'),
          content: TextField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'Nombre de Operador'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text(operador == null ? 'Crear' : 'Guardar'),
              onPressed: () async {
                final nombre = _nombreController.text.trim();
                if (nombre.isEmpty) return;

                if (operador == null) {
                  await _crearOperador(nombre);
                } else {
                  await _editarOperador(operador.id!, nombre);
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
        title: const Text('Operadores Logística'),
      ),
      body: _operadores.isEmpty
          ? const Center(child: Text('No hay operadores registrados'))
          : ListView.builder(
              itemCount: _operadores.length,
              itemBuilder: (context, index) {
                final operador = _operadores[index];
                return ListTile(
                  title: Text(operador.nombre ?? 'Sin nombre'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _mostrarDialogo(operador: operador),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarOperador(operador.id!),
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
