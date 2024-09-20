import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/calculator_cubit.dart';

class CalculatorHome extends StatelessWidget {
  const CalculatorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Calculator")),
      body: Column(
        children: [
          Expanded(
            child: BlocListener<CalculatorCubit,
                ({List<Map<String, String>> results, bool isLoading})>(
              listener: (context, state) {
                if (state.isLoading) {
                  // Handle loading state if needed
                }
              },
              child: BlocBuilder<CalculatorCubit,
                  ({List<Map<String, String>> results, bool isLoading})>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final results = state.results;
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
          ),
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
      try {
        await context
            .read<CalculatorCubit>()
            .detectExpressionFromImage(pickedFile.path);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
