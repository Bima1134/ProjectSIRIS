import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

// import 'package:siris/BA_list_ruang_page.dart';
final loggerRuang = Logger('MyHomePage');

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
           onCsvUploaded: () {
            // _ListRuangPageState.fetchRuangData();
          // Empty function or replace with a function to refresh your data
          loggerRuang.info('CSV Uploaded');
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback onCsvUploaded; // Callback to notify CSV upload success

  MyHomePage({required this.onCsvUploaded}); 
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _statusMessage = "No file selected";

  void uploadCSV() async {
    final input = html.FileUploadInputElement();
    input.accept = '.csv'; // Accept only CSV files
    input.click();

    input.onChange.listen((e) async {
      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) async {
        final bytes = reader.result as Uint8List;
        final url = Uri.parse('http://localhost:8080/upload-csv');
        final request = http.MultipartRequest('POST', url)
          ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: file.name));

        try {
          final response = await request.send();

          if (response.statusCode == 200) {
            setState(() {
              _statusMessage = 'CSV uploaded successfully!';
            });
            // Call the callback to refresh the data in ListRuangPage
            widget.onCsvUploaded();
          } else {
            setState(() {
              _statusMessage = 'Failed to upload CSV';
            });
          }
        } catch (e) {
          setState(() {
            _statusMessage = 'Error occurred: $e';
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('CSV File Upload'),
      ),
      body: Center( // Use Center widget to center the content
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
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      ),
    );

  }
}
