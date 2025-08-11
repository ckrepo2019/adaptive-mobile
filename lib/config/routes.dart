import 'package:flutter/material.dart';
import 'package:flutter_lms/views/auth/get_user.dart';
import 'package:flutter_lms/views/auth/sign_in.dart';
import 'package:flutter_lms/views/collab/home_page.dart';
import 'package:flutter_lms/views/student/home/home_page.dart';
import 'package:flutter_lms/views/student/intro/analyzing_page.dart';
import 'package:flutter_lms/views/student/intro/introduction_page.dart';
import 'package:flutter_lms/views/student/intro/result_page.dart';
import 'package:flutter_lms/views/teacher/home_page.dart';

import '../views/student/intro/get_started.dart';

class AppRoutes {
  static const String getStarted = '/get-started';
  static const String introduction = '/introduction';
  static const String signIn = '/sign-in';
  static const String analyzing = '/analyzing';
  static const String result = '/result';
  static const String studentHome = '/student-home';
  static const String teacherHome = '/teacher-home';
  static const String collaboratorHome = '/collaborator-home';
  static const String getUser = '/get-user';

  static Map<String, WidgetBuilder> routes = {
    getStarted: (context) => const GetStartedPage(),
    signIn: (context) => const SignInPage(),
    analyzing: (context) => const AnalyzingPage(),
    result: (context) => const ResultPage(),
    introduction: (context) => const IntroductionPage(),
    studentHome: (context) => const StudentHomePage(),
    teacherHome: (context) => const TeacherHomePage(),
    collaboratorHome: (context) => const CollaboratorHomePage(),
    getUser: (context) => const GetUserPage(),
  };
}
