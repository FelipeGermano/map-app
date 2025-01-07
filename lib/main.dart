import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MapEditorApp(),
  ));
}

class MapEditorApp extends StatefulWidget {
  @override
  _MapEditorAppState createState() => _MapEditorAppState();
}

class _MapEditorAppState extends State<MapEditorApp> {
  final List<Map<String, dynamic>> _drawings = [];
  final MapController _mapController = MapController();
  bool _isDrawing = false;
  String _filterType = 'Todos';

  void _addDrawing(LatLng point) async {
    if (_isDrawing) return;

    TextEditingController nameController = TextEditingController();
    String? type;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar Objeto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            DropdownButtonFormField<String>(
              items: [
                DropdownMenuItem(value: 'Ponto', child: Text('Ponto')),
                DropdownMenuItem(value: 'Linha', child: Text('Linha')),
                DropdownMenuItem(value: 'Polígono', child: Text('Polígono')),
              ],
              onChanged: (value) {
                type = value;
              },
              decoration: InputDecoration(labelText: 'Tipo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );

    if (type != null && nameController.text.isNotEmpty) {
      setState(() {
        _isDrawing = (type == 'Linha' || type == 'Polígono');
        _drawings.add({
          'name': nameController.text,
          'type': type,
          'coordinates': [point],
        });
      });
    }
  }

  void _finalizeDrawing() {
    setState(() {
      _isDrawing = false;
    });
  }

  void _addCoordinateToDrawing(LatLng point) {
    if (_isDrawing && _drawings.isNotEmpty) {
      setState(() {
        var lastDrawing = _drawings.last;
        if (lastDrawing['type'] == 'Linha' ||
            lastDrawing['type'] == 'Polígono') {
          lastDrawing['coordinates'].add(point);
        }
      });
    }
  }

  void _exportToCSV() async {
    final List<List<dynamic>> rows = [
      ['Name', 'Type', 'Coordinates']
    ];

    for (var feature in _drawings) {
      rows.add([
        feature['name'],
        feature['type'],
        jsonEncode(feature['coordinates']
            .map((latlng) => [latlng.latitude, latlng.longitude])
            .toList())
      ]);
    }

    final String csvData = const ListToCsvConverter().convert(rows);
    final String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save CSV',
      fileName: 'features.csv',
    );

    if (outputFile != null) {
      File(outputFile).writeAsString(csvData);
    }
  }

  void _importFromCSV() async {
    final FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);

    if (result != null) {
      final File file = File(result.files.single.path!);
      final String csvData = await file.readAsString();
      final List<List<dynamic>> rows =
          const CsvToListConverter().convert(csvData);

      setState(() {
        for (int i = 1; i < rows.length; i++) {
          final coordinates = (jsonDecode(rows[i][2]) as List)
              .map((coord) => LatLng(coord[0], coord[1]))
              .toList();
          _drawings.add({
            'name': rows[i][0],
            'type': rows[i][1],
            'coordinates': coordinates,
          });
        }
      });
    }
  }

  void _deleteDrawing(int index) {
    setState(() {
      _drawings.removeAt(index);
    });
  }

  List<Map<String, dynamic>> _getFilteredDrawings() {
    if (_filterType == 'Todos') {
      return _drawings;
    }
    return _drawings
        .where((drawing) => drawing['type'] == _filterType)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editor de Mapas'),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            tooltip: 'Importar CSV',
            onPressed: _importFromCSV,
          ),
          IconButton(
            icon: Icon(Icons.download),
            tooltip: 'Exportar para CSV',
            onPressed: _exportToCSV,
          ),
          if (_isDrawing)
            IconButton(
              icon: Icon(Icons.done),
              tooltip: 'Finalizar Desenho',
              onPressed: _finalizeDrawing,
            ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(0, 0),
                zoom: 2.0,
                onTap: (tapPosition, point) {
                  if (_isDrawing) {
                    _addCoordinateToDrawing(point);
                  } else {
                    _addDrawing(point);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: _drawings
                      .where((drawing) => drawing['type'] == 'Linha')
                      .map((drawing) => Polyline(
                            points: drawing['coordinates'],
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ))
                      .toList(),
                ),
                PolygonLayer(
                  polygons: _drawings
                      .where((drawing) => drawing['type'] == 'Polígono')
                      .map((drawing) => Polygon(
                            points: drawing['coordinates'],
                            borderStrokeWidth: 2.0,
                            borderColor: Colors.green,
                            color: Colors.green.withOpacity(0.4),
                          ))
                      .toList(),
                ),
                MarkerLayer(
                  markers: _drawings
                      .where((drawing) => drawing['type'] == 'Ponto')
                      .map((drawing) => Marker(
                            point: drawing['coordinates'][0],
                            builder: (ctx) =>
                                Icon(Icons.location_on, color: Colors.red),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          Container(
            width: 200,
            color: Colors.grey[200],
            child: Column(
              children: [
                DropdownButton<String>(
                  value: _filterType,
                  items: ['Todos', 'Ponto', 'Linha', 'Polígono']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterType = value!;
                    });
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _getFilteredDrawings().length,
                    itemBuilder: (context, index) {
                      var drawing = _getFilteredDrawings()[index];
                      return ListTile(
                        title: Text(drawing['name']),
                        subtitle: Text(drawing['type']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _deleteDrawing(_drawings.indexOf(drawing)),
                        ),
                        onTap: () => _mapController.move(
                          drawing['coordinates'][0],
                          15.0,
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
    );
  }
}
