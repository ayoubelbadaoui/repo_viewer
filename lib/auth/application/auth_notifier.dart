import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reso_coder/auth/domain/auth_failure.dart';
import 'package:reso_coder/auth/infrastructure/github_authenticator.dart';

part 'auth_notifier.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const AuthState._();
  const factory AuthState.initial() = _Initial;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.authenticated() = _Authenticated;
  const factory AuthState.failure(AuthFailure authFailure) = Failure;
}

typedef AuthUriCallBack = Future<Uri> Function(Uri authorizationUrl);

class AuthNotifier extends StateNotifier<AuthState> {
  final GithubAuthenticator _gitubAuthenticator;
  AuthNotifier(this._gitubAuthenticator) : super(const AuthState.initial());

  Future<void> checkAndUpdateState() async {
    state = (await _gitubAuthenticator.isSignedIn())
        ? const AuthState.authenticated()
        : const AuthState.unauthenticated();
  }

  Future<void> signIn(AuthUriCallBack authorizationUriCallBack) async {
    final _grant = _gitubAuthenticator.createGrant();
    final redirectUrl = await authorizationUriCallBack(
        _gitubAuthenticator.getAuthorizationUrl(_grant));

    final failureOrSuccess = await _gitubAuthenticator
        .handleAuthorizationResponse(_grant, redirectUrl.queryParameters);

    state = failureOrSuccess.fold(
        (l) => AuthState.failure(l), (r) => const AuthState.authenticated());

    _grant.close();
  }

  Future<void> signOut() async {
    final failureOrSucces = await _gitubAuthenticator.signOut();
    failureOrSucces.fold(
        (l) => AuthState.failure(l), (r) => AuthState.unauthenticated());
  }
}
