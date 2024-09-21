import 'package:camera_calculator/ui/calculator_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc/calculator_cubit.dart';
import 'config/app_config.dart';
import 'flavors/appRedBuildInCameraRoll.dart';
import 'flavors/appRedCameraRoll.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();

  if (AppConfig.isRedTheme && AppConfig.useCameraRoll) {
    runApp(const AppRedCameraRoll());
  } else if (AppConfig.isRedTheme && AppConfig.useBuiltInCamera) {
    runApp(const AppRedBuiltInCamera());
  } else if (AppConfig.isGreenTheme && AppConfig.useCameraRoll) {
    runApp(const AppGreenCameraRoll());
  } else if (AppConfig.isGreenTheme && AppConfig.useBuiltInCamera) {
    runApp(const AppGreenFilesystem());
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
    return BlocProvider(
      create: (context) =>
          CalculatorCubit(useEncryptedStorage: AppConfig.useEncryptedStorage),
      child: const CalculatorHome(),
    );
  }
}

class AppGreenCameraRoll extends StatelessWidget {
  const AppGreenCameraRoll({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CalculatorCubit(useEncryptedStorage: AppConfig.useEncryptedStorage),
      child: const CalculatorHome(),
    );
  }
}

class AppGreenFilesystem extends StatelessWidget {
  const AppGreenFilesystem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalculatorCubit(useEncryptedStorage: true),
      child: const CalculatorHome(),
    );
  }
}
