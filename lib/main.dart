import 'package:camera_calculator/ui/calculator_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc/calculator_cubit.dart';
import 'config/app_config.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();

  if (AppConfig.useEncryptedStorage) {
    runApp(const AppGreenFilesystem());
  } else if (AppConfig.useCameraRoll) {
    runApp(const AppGreenCameraRoll());
  } else if (AppConfig.useBuiltInCamera) {
    runApp(const AppBuiltInCameraRoll());
  } else {
    runApp(const MyApp());
  }
}

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
class AppBuiltInCameraRoll extends StatelessWidget {
  const AppBuiltInCameraRoll({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) =>
            CalculatorCubit(useEncryptedStorage: AppConfig.useEncryptedStorage),
        child: const CalculatorHome(),
      ),
    );
  }
}

class AppGreenCameraRoll extends StatelessWidget {
  const AppGreenCameraRoll({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) =>
            CalculatorCubit(useEncryptedStorage: AppConfig.useEncryptedStorage),
        child: const CalculatorHome(),
      ),
    );
  }
}

class AppGreenFilesystem extends StatelessWidget {
  const AppGreenFilesystem({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => CalculatorCubit(useEncryptedStorage: true),
        child: const CalculatorHome(),
      ),
    );
  }
}

