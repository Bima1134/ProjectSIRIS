import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

// Initialize logger
final loggerRuang = Logger('MyAddJadwalBatchPage');

void main() {
  // Configure logging output
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(AddJadwalBatch());
}

class AddJadwalBatch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyAddJadwalBatchPage(
        onCsvUploaded: () {
          loggerRuang.info('CSV uploaded successfully and callback executed.');
        },
      ),
    );
  }
}

class MyAddJadwalBatchPage extends StatefulWidget {
  final VoidCallback onCsvUploaded; // Callback to notify CSV upload success

  MyAddJadwalBatchPage({required this.onCsvUploaded});
  @override
  _MyAddJadwalBatchPageState createState() => _MyAddJadwalBatchPageState();
}

class _MyAddJadwalBatchPageState extends State<MyAddJadwalBatchPage> {
  String _statusMessage = "No file selected";

  void uploadCSV() async {
    loggerRuang.info('Opening file selector...');
    final input = html.FileUploadInputElement();
    input.accept = '.csv'; // Accept only CSV files
    input.click();

    input.onChange.listen((e) async {
      final file = input.files?.first;
      if (file == null) {
        loggerRuang.warning('No file selected.');
        return;
      }

      loggerRuang.info('File selected: ${file.name}');
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((e) async {
        final bytes = reader.result as Uint8List;
        loggerRuang.info('File read successfully: ${file.name}');
        final url =
            Uri.parse('http://localhost:8080/kaprodi/upload-csv-jadwal');

        final request = http.MultipartRequest('POST', url)
          ..files.add(
              http.MultipartFile.fromBytes('file', bytes, filename: file.name));

        try {
          loggerRuang.info('Sending file to server...');
          final response = await request.send();
          final responseBody = await response.stream.bytesToString();
          loggerRuang
              .info('Server responded with status: ${response.statusCode}');
          loggerRuang.info('Response body: $responseBody');

          if (response.statusCode == 200) {
            setState(() {
              _statusMessage = 'CSV uploaded successfully!';
            });
            widget.onCsvUploaded();
          } else {
            setState(() {
              _statusMessage = 'Failed to upload CSV';
            });
            loggerRuang.warning(
                'Failed to upload CSV. Server responded with status: ${response.statusCode}');
          }
        } catch (e) {
          setState(() {
            _statusMessage = 'Error occurred: $e';
          });
          loggerRuang.severe('Error occurred during file upload: $e');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CSV Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Select a CSV file to upload:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadCSV,
              child: Text('Select and Upload CSV'),
            ),
            SizedBox(height: 20),
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 16,
                color: _statusMessage.contains('Error') ||
                        _statusMessage.contains('Failed')
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
