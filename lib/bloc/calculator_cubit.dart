import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorCubit extends Cubit<
    ({
      List<Map<String, String>> results,
      bool isLoading,
      String? errorMessage,
    })> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final bool useEncryptedStorage;

  CalculatorCubit({this.useEncryptedStorage = false})
      : super((results: [], isLoading: false, errorMessage: null)) {
    _loadResultsFromStorage();
  }

  Future<void> _loadResultsFromStorage() async {
    emit((results: state.results, isLoading: true, errorMessage: null));
    try {
      String? storedResults;
      if (useEncryptedStorage) {
        storedResults = await storage.read(key: 'results');
      } else {
        storedResults = await SharedPreferences.getInstance()
            .then((prefs) => prefs.getString('results'));
      }

      if (storedResults != null) {
        List<dynamic> jsonList = jsonDecode(storedResults);
        List<Map<String, String>> resultsList = jsonList.map((item) {
          return Map<String, String>.from(item);
        }).toList();
        emit((results: resultsList, isLoading: false, errorMessage: null));
      } else {
        emit((results: [], isLoading: false, errorMessage: null));
      }
    } catch (e) {
      emit((results: state.results, isLoading: false, errorMessage: "$e"));
      // log("error _loadResultsFromStorage $e");
    }
  }

  Future<void> addResult(String expression, String result) async {
    final updatedResults = List<Map<String, String>>.from(state.results);
    updatedResults.add({'expression': expression, 'result': result});
    try {
      final String encodedResults = jsonEncode(updatedResults);
      if (useEncryptedStorage) {
        await storage.write(key: 'results', value: encodedResults);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('results', encodedResults);
      }
      emit((
        results: updatedResults,
        isLoading: state.isLoading,
        errorMessage: null
      ));
    } catch (e) {
      emit((
        results: state.results,
        isLoading: state.isLoading,
        errorMessage: "$e"
      ));
      // log("error addResult $e");
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
      emit((results: state.results, isLoading: false, errorMessage: null));
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
