import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reso_coder/auth/application/auth_notifier.dart';
import 'package:reso_coder/auth/infrastructure/credentials_storage/credentials_storage.dart';
import 'package:reso_coder/auth/infrastructure/credentials_storage/secure_credentials_storage.dart';
import 'package:reso_coder/auth/infrastructure/github_authenticator.dart';
import 'package:riverpod/riverpod.dart' show Provider, StateNotifierProvider;

final flutterSecureStorageProvider =
    Provider((ref) => const FlutterSecureStorage());

final credentialsStorageProvider = Provider<CredentialsStorage>(
    (ref) => SecureCredentialsStorage(ref.watch(flutterSecureStorageProvider)));

final dioProvider = Provider<Dio>((ref) => Dio());

final githubAuthenticatorProvider = Provider((ref) => GithubAuthenticator(
    ref.watch(credentialsStorageProvider), ref.watch(dioProvider)));

final authotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
    (ref) => AuthNotifier(ref.watch(githubAuthenticatorProvider)));
