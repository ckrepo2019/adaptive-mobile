import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lms/views/auth/get_user.dart';
import 'package:flutter_lms/views/auth/sign_in.dart';
import 'package:flutter_lms/views/collab/home_page.dart';
import 'package:flutter_lms/views/student/home/home_page.dart';
import 'package:flutter_lms/views/student/intro/analyzing_page.dart';
import 'package:flutter_lms/views/student/intro/introduction_page.dart';
import 'package:flutter_lms/views/student/intro/result_page.dart';
import 'package:flutter_lms/views/teacher/home_page.dart';
import 'package:flutter_lms/views/student/intro/get_started.dart';

import 'package:flutter_lms/state/bindings/student/student_home_bindings.dart';

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
}

/// Use GetX pages so we can attach per-route bindings.
class AppPages {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.getStarted, page: () => const GetStartedPage()),
    GetPage(name: AppRoutes.signIn, page: () => const SignInPage()),
    GetPage(name: AppRoutes.analyzing, page: () => const AnalyzingPage()),
    GetPage(name: AppRoutes.result, page: () => const ResultPage()),
    // 👇 Bind StudentHomeController only when visiting the intro page
    GetPage(
      name: AppRoutes.introduction,
      page: () => const IntroductionPage(),
      binding: StudentHomeBindings(),
    ),
    GetPage(name: AppRoutes.studentHome, page: () => const StudentHomePage()),
    GetPage(name: AppRoutes.teacherHome, page: () => const TeacherHomePage()),
    GetPage(
      name: AppRoutes.collaboratorHome,
      page: () => const CollaboratorHomePage(),
    ),
    GetPage(name: AppRoutes.getUser, page: () => const GetUserPage()),
  ];
}
