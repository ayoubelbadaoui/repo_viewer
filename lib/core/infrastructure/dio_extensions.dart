import 'dart:io';

import 'package:dio/dio.dart';

extension DioEroorX on DioError {
  bool get isNoConnenctionError {
    return type == DioErrorType.other && error is SocketException;
  }
}
