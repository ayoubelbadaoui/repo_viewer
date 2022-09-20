import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:oauth2/oauth2.dart';
import 'package:reso_coder/auth/domain/auth_failure.dart';
import 'package:reso_coder/auth/infrastructure/credentials_storage/credentials_storage.dart';
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:reso_coder/core/infrastructure/dio_extensions.dart';

import '../../core/shared/encoders.dart';

class GithubOauthHttpClient extends http.BaseClient {
  final httpClient = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return httpClient.send(request);
  }
}

class GithubAuthenticator {
  final CredentialsStorage _credentialsStorage;
  final Dio _dio;

  GithubAuthenticator(this._credentialsStorage, this._dio);

  static const clientId = 'a92e4b7fa8c5af2a87f0';
  static const clientSecret = '773748e89985fbc3d4a3b9e85ce91fa7978330ff';
  static const scopes = ['read:user', 'repo'];
  static final authorizationEndpoint =
      Uri.parse('https://github.com/login/oauth/authorize');
  static final tokenEndpoint =
      Uri.parse('https://github.com/login/oauth/acces_token');

  static final revocationEndPoint =
      Uri.parse('https://api.github.com/applications/$clientId/token');

  static final redirectUrl = Uri.parse('http://localhost:3000/callback');

  Future<Credentials?> getSignedInCredentials() async {
    try {
      final storedCredentials = await _credentialsStorage.read();
      // if (storedCredentials!.isExpired && storedCredentials.canRefresh) {
      //   //TODO : refresh
      // }
      return storedCredentials;
    } on PlatformException {
      return null;
    }
  }

  Future<bool> isSignedIn() =>
      getSignedInCredentials().then((credentials) => credentials != null);

  AuthorizationCodeGrant createGrant() {
    return AuthorizationCodeGrant(
        clientId, authorizationEndpoint, tokenEndpoint,
        secret: clientSecret, httpClient: GithubOauthHttpClient());
  }

  Uri getAuthorizationUrl(AuthorizationCodeGrant grant) {
    return grant.getAuthorizationUrl(redirectUrl, scopes: scopes);
  }

  Future<Either<AuthFailure, Unit>> handleAuthorizationResponse(
    AuthorizationCodeGrant grant,
    Map<String, String> queryParams,
  ) async {
    try {
      final httpClient = await grant.handleAuthorizationResponse(queryParams);
      await _credentialsStorage.save(httpClient.credentials);
      return right(unit);
    } on FormatException {
      return left(const AuthFailure.server());
    } on AuthorizationException catch (e) {
      return left(AuthFailure.server('${e.error} : ${e.description}'));
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }

  Future<Either<AuthFailure, Unit>> signOut() async {
    final accessToken = _credentialsStorage
        .read()
        .then((credentials) => credentials?.accessToken);

    final userNameAndPassword =
        stringToBase64.encode('$clientId:$clientSecret');

    try {
      try {
        _dio.deleteUri(revocationEndPoint,
            data: {'access_token': accessToken},
            options: Options(
                headers: {'Authorization': 'basic $userNameAndPassword'}));
      } on DioError catch (e) {
        if (e.isNoConnenctionError) {
          print('ma9drtx n revoki lik tokens ^^');
        }
      }
      _credentialsStorage.clear();
      return right(unit);
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }
}
