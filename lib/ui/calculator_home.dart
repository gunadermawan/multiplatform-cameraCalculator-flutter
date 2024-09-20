import 'package:flutter/cupertino.dart';
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
              listener: (context, state) {},
              child: BlocBuilder<CalculatorCubit,
                  ({List<Map<String, String>> results, bool isLoading})>(
                builder: (context, state) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: state.isLoading
                        ? const Center(
                            key: ValueKey('loading'),
                            child: CupertinoActivityIndicator(radius: 15),
                          )
                        : ListView.builder(
                            key: const ValueKey('results'),
                            itemCount: state.results.length,
                            itemBuilder: (context, index) {
                              final result = state.results[index];
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 0.1, 8.0, 0.1),
                                child: Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: ListTile(
                                    title:
                                        Text("Input: ${result['expression']}"),
                                    subtitle:
                                        Text("Result: ${result['result']}"),
                                  ),
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: () {
                      _pickImage(context, ImageSource.camera);
                    },
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    borderRadius: BorderRadius.circular(8.0),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.camera, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Take Photo",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: () {
                      _pickImage(context, ImageSource.gallery);
                    },
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    borderRadius: BorderRadius.circular(8.0),
                    child: const Text(
                      "Pick from Gallery",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          )
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
