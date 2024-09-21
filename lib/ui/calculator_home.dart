import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../bloc/calculator_cubit.dart';
import '../config/app_config.dart';

class CalculatorHome extends StatelessWidget {
  const CalculatorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Calculator")),
      body: Column(
        children: [
          Expanded(
            child: BlocListener<
                CalculatorCubit,
                ({
                  List<Map<String, String>> results,
                  bool isLoading,
                  String? errorMessage,
                })>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  context.read<CalculatorCubit>().clearErrorMessage();
                }
              },
              child: BlocBuilder<
                  CalculatorCubit,
                  ({
                    List<Map<String, String>> results,
                    bool isLoading,
                    String? errorMessage,
                  })>(
                builder: (context, state) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: state.isLoading
                        ? const Center(
                            key: ValueKey('loading'),
                            child: CupertinoActivityIndicator(radius: 15),
                          )
                        : state.results.isEmpty
                            ? Center(
                                key: const ValueKey('no_data'),
                                child: Text(
                                  state.errorMessage ?? "No data found",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
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
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                            "Input: ${result['expression']}"),
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
          if (_shouldShowGalleryButton(context))
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
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
            ),
        ],
      ),
    );
  }

  bool _shouldShowGalleryButton(BuildContext context) {
    return AppConfig.useCameraRoll; // Determine based on the AppConfig
  }

  void _pickImage(BuildContext context, ImageSource source) async {
    Permission permission =
        source == ImageSource.camera ? Permission.camera : Permission.storage;
    await _checkAndRequestPermission(context, permission);
    final status = await permission.status;
    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        try {
          await context
              .read<CalculatorCubit>()
              .detectExpressionFromImage(pickedFile.path);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      _showPermissionDeniedSnackBar(context);
    }
  }

  Future<void> _checkAndRequestPermission(
      BuildContext context, Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return;
    } else {
      final requestStatus = await permission.request();
      if (requestStatus.isPermanentlyDenied) {
        _showPermissionDeniedSnackBar(context);
      }
    }
  }

  void _showPermissionDeniedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Permission denied. Please enable it in settings."),
        action: SnackBarAction(
          label: "Open Settings",
          onPressed: () {
            openAppSettings();
          },
        ),
      ),
    );
  }
}
