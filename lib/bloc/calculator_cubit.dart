import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CalculatorCubit
    extends Cubit<({List<Map<String, String>> results, bool isLoading})> {
  CalculatorCubit() : super((results: [], isLoading: false));

  final storage = const FlutterSecureStorage();

  Future<void> addResult(String expression, String result) async {
    final updatedResults = List<Map<String, String>>.from(state.results);
    updatedResults.add({'expression': expression, 'result': result});
    emit((results: updatedResults, isLoading: state.isLoading));
  }

  Future<void> detectExpressionFromImage(String imagePath) async {
    emit((results: state.results, isLoading: true));

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
      emit((results: state.results, isLoading: false)); // Set loading to false
      throw e;
    }

    emit((results: state.results, isLoading: false)); // Set loading to false
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
