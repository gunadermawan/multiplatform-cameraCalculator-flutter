import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/calculator_cubit.dart';
import '../ui/calculator_home.dart';

class AppGreenCameraRoll extends StatelessWidget {
  const AppGreenCameraRoll({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalculatorCubit(useEncryptedStorage: true),
      child: const CalculatorHome(),
    );
  }
}
