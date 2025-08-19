import 'package:flutter_lms/views/student/assignments/assignment-quiz/practice_quiz.dart';
import 'package:flutter_lms/views/student/assignments/assignment-quiz/practice_quiz_intro.dart';
import 'package:flutter_lms/views/student/assignments/assignment-quiz/practice_quiz_result.dart';
import 'package:flutter_lms/views/student/assignments/assignment-quiz/quiz_info.dart';
import 'package:flutter_lms/views/student/classes/classes_page.dart';
import 'package:flutter_lms/views/student/classes/join_class.dart';
import 'package:flutter_lms/views/student/classes/join_class_success.dart';
import 'package:flutter_lms/views/student/student_shell.dart';
import 'package:flutter_lms/views/utilities/profile_page.dart';
import 'package:get/get.dart';
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
  static const String signIn = '/sign-in';
  static const String getUser = '/get-user';

  /// student routes
  static const String getStarted = '/get-started';
  static const String introduction = '/introduction';
  static const String analyzing = '/analyzing';
  static const String result = '/result';
  static const String studentShell = '/student';
  static const String studentHome = '/student-home';
  static const String teacherHome = '/teacher-home';
  static const String collaboratorHome = '/collaborator-home';
  static const String resultLearnerType = '/result-learner-type';
  static const String profilePage = '/profile-page';
  static const String studentJoinClass = '/join-class';
  static const String studentJoinClassSuccess = '/join-class-success';
  static const String studentClass = '/student-class-page';
  static const String quizInfo = '/quiz-info';
  static const String practiceQuizIntro = '/practice-quiz-intro';
  static const String practiceQuiz = '/practice-quiz';
  static const String practiceQuizResult = '/practice-quiz-result';
}

/// Use GetX pages so we can attach per-route bindings.
class AppPages {
  static final pages = <GetPage>[
    /// auth
    GetPage(name: AppRoutes.signIn, page: () => const SignInPage()),
    GetPage(name: AppRoutes.getUser, page: () => const GetUserPage()),

    /// student pages
    GetPage(name: AppRoutes.getStarted, page: () => const GetStartedPage()),
    GetPage(name: AppRoutes.analyzing, page: () => const AnalyzingPage()),
    GetPage(
      name: AppRoutes.introduction,
      page: () => const IntroductionPage(),
      binding: StudentHomeBindings(),
    ),
    GetPage(
      name: AppRoutes.studentShell,
      page: () {
        final args = (Get.arguments as Map?) ?? {};
        return StudentShell(
          token: (args['token'] ?? '') as String,
          uid: (args['uid'] ?? '') as String,
          userType: (args['userType'] ?? 4) as int,
        );
      },
    ),
    GetPage(
      name: AppRoutes.studentHome,
      page: () {
        final args = (Get.arguments as Map?) ?? {};
        return StudentHomePage(
          token: (args['token'] ?? '') as String,
          uid: (args['uid'] ?? '') as String,
          userType: (args['userType'] ?? 4) as int,
        );
      },
    ),
    GetPage(name: AppRoutes.teacherHome, page: () => const TeacherHomePage()),
    GetPage(
      name: AppRoutes.collaboratorHome,
      page: () => const CollaboratorHomePage(),
    ),
    GetPage(
      name: AppRoutes.resultLearnerType,
      page: () => const ResultLeanerPage(),
    ),
    GetPage(name: AppRoutes.profilePage, page: () => const ProfilePage()),

    GetPage(name: AppRoutes.studentClass, page: () => StudentClassPage()),
    GetPage(name: AppRoutes.studentClass, page: () => StudentClassPage()),
    GetPage(
      name: AppRoutes.studentJoinClass,
      page: () => StudentJoinClass(),
      transition: Transition.leftToRightWithFade,
    ),
    GetPage(
      name: AppRoutes.studentJoinClassSuccess,
      page: () => const StudentJoinClassSuccess(),
    ),
    GetPage(name: AppRoutes.quizInfo, page: () => const QuizInfoPage()),
    GetPage(
      name: AppRoutes.practiceQuizIntro,
      page: () => const PracticeQuizIntroPage(),
    ),
    GetPage(name: AppRoutes.practiceQuiz, page: () => const PracticeQuizPage()),
    GetPage(
      name: AppRoutes.practiceQuizResult,
      page: () => const PracticeQuizResultPage(score: 0, total: 0),
    ),
  ];
}
