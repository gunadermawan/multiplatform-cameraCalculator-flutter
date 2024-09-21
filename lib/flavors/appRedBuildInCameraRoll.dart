import 'package:flutter/material.dart';
import '../bloc/calculator_cubit.dart';
import '../ui/calculator_home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRedBuiltInCamera extends StatelessWidget {
  const AppRedBuiltInCamera({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalculatorCubit(useEncryptedStorage: false),
      child: const CalculatorHome(),
    );
  }
}
