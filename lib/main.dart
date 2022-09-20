import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reso_coder/core/presentation/app_widget.dart';

void main(List<String> args) {
  runApp(ProviderScope(child: AppWidget()));
}
