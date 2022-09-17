import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:reso_coder/auth/presentation/sign_in_page.dart';
import 'package:reso_coder/splash/presentation/splash_page.dart';
import 'package:reso_coder/starred_repos/presentation/starred_repos_page.dart';

@MaterialAutoRouter(routes: [
  MaterialRoute(page: SplashPage, initial: true),
  MaterialRoute(page: SignInPage, path: 'sign-in'),
  MaterialRoute(page: StarredReposPage, path: 'starred'),
], replaceInRouteName: 'Page,Route')
class $AppRouter {}
