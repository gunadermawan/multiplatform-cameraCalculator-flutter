import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CalculatorCubit extends Cubit<
    ({
      List<Map<String, String>> results,
      bool isLoading,
      String? errorMessage
    })> {
  CalculatorCubit()
      : super((results: [], isLoading: false, errorMessage: null)) {
    _loadResultsFromStorage();
  }

  final storage = const FlutterSecureStorage();

  Future<void> _loadResultsFromStorage() async {
    emit((results: state.results, isLoading: true, errorMessage: null));
    try {
      String? storedResults = await storage.read(key: 'results');
      if (storedResults != null) {
        List<dynamic> jsonList = jsonDecode(storedResults);
        List<Map<String, String>> resultsList = jsonList.map((item) {
          return Map<String, String>.from(item);
        }).toList();
        emit((results: resultsList, isLoading: false, errorMessage: null));
        // log("Data yang dimuat dari storage: $resultsList");
      } else {
        // log("Tidak ada data yang ditemukan di storage.");
        emit((results: [], isLoading: false, errorMessage: null));
      }
    } catch (e) {
      // log("Gagal memuat hasil: $e");
      emit((
        results: state.results,
        isLoading: false,
        errorMessage: "Error: $e"
      ));
    }
  }

  Future<void> addResult(String expression, String result) async {
    final updatedResults = List<Map<String, String>>.from(state.results);
    updatedResults.add({'expression': expression, 'result': result});
    try {
      await storage.write(key: 'results', value: jsonEncode(updatedResults));
      // log("Berhasil menyimpan hasil ke secure storage: $updatedResults");
      emit((
        results: updatedResults,
        isLoading: state.isLoading,
        errorMessage: null
      ));
    } catch (e) {
      // log("Gagal menyimpan hasil ke secure storage: $e");
      emit((
        results: state.results,
        isLoading: state.isLoading,
        errorMessage: "Error: $e"
      ));
    }
  }

  void clearErrorMessage() {
    emit((
      results: state.results,
      isLoading: state.isLoading,
      errorMessage: null
    ));
  }

  Future<void> detectExpressionFromImage(String imagePath) async {
    emit((results: state.results, isLoading: true, errorMessage: null));

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      String? expression = extractFirstExpression(recognizedText.text);
      if (expression != null) {
        String result = calculateExpression(expression);
        await addResult(expression, result);
      } else {
        throw Exception('No valid expression found.');
      }
      textRecognizer.close();
    } catch (e) {
      emit((
        results: state.results,
        isLoading: false,
        errorMessage: "error: $e"
      ));
      rethrow;
    }
    emit((
      results: state.results,
      isLoading: false,
      errorMessage: "saved to secure local storage"
    ));
  }

  String? extractFirstExpression(String text) {
    final RegExp exp = RegExp(r"(\d+)([+\-*/])(\d+)");
    final match = exp.firstMatch(text);
    return match?.group(0);
  }

  String calculateExpression(String expression) {
    final RegExp exp = RegExp(r"(\d+)([+\-*/])(\d+)");
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
