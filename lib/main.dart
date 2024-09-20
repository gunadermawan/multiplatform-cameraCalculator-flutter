import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

// BLoC State Management
class CalculatorCubit extends Cubit<List<Map<String, String>>> {
  CalculatorCubit() : super([]);

  final storage = const FlutterSecureStorage();

  Future<void> addResult(String expression, String result) async {
    state.add({'expression': expression, 'result': result});
    emit(List.from(state));
  }

  Future<void> saveResultEncrypted(String expression, String result) async {
    await storage.write(key: expression, value: result);
    addResult(expression, result);
  }

  Future<void> saveResultDatabase(String expression, String result) async {
    final database = await openDatabase(
      join((await getApplicationDocumentsDirectory()).path, 'calculator.db'),
      onCreate: (db, version) {
        return db.execute('CREATE TABLE results(expression TEXT, result TEXT)');
      },
      version: 1,
    );
    await database
        .insert('results', {'expression': expression, 'result': result});
    addResult(expression, result);
  }

  Future<void> detectExpressionFromImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(); // Plugin baru
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    String? expression = extractFirstExpression(recognizedText.text);
    if (expression != null) {
      String result = calculateExpression(expression);
      await addResult(expression, result);
    }

    textRecognizer.close();
  }

  String? extractFirstExpression(String text) {
    final RegExp exp = RegExp(r"(\d+)([\+\-\*\/])(\d+)");
    final match = exp.firstMatch(text);
    return match != null ? match.group(0) : null;
  }

  String calculateExpression(String expression) {
    final RegExp exp = RegExp(r"(\d+)([\+\-\*\/])(\d+)");
    final match = exp.firstMatch(expression);
    if (match != null) {
      int num1 = int.parse(match.group(1)!);
      int num2 = int.parse(match.group(3)!);
      String operator = match.group(2)!;

      switch (operator) {
        case '+':
          return (num1 + num2).toString();
        case '-':
          return (num1 - num2).toString();
        case '*':
          return (num1 * num2).toString();
        case '/':
          return (num1 / num2).toString();
      }
    }
    return 'Error';
  }
}

// UI Utama
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (_) => CalculatorCubit(),
        child: const CalculatorHome(),
      ),
    );
  }
}

class CalculatorHome extends StatelessWidget {
  const CalculatorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Calculator")),
      body: Column(
        children: [
          // Menampilkan hasil terakhir
          Expanded(
            child: BlocBuilder<CalculatorCubit, List<Map<String, String>>>(
              builder: (context, results) {
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return ListTile(
                      title: Text("Input: ${result['expression']}"),
                      subtitle: Text("Result: ${result['result']}"),
                    );
                  },
                );
              },
            ),
          ),
          // Tombol input dari kamera atau file
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _pickImage(context, ImageSource.camera);
                },
                child: const Text("Take photo"),
              ),
              ElevatedButton(
                onPressed: () {
                  _pickImage(context, ImageSource.gallery);
                },
                child: const Text("Pick from file"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickImage(BuildContext context, ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      context
          .read<CalculatorCubit>()
          .detectExpressionFromImage(pickedFile.path);
    }
  }
}
