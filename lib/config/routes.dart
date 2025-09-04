import 'package:flutter_lms/views/collab/home_page.dart';
import 'package:flutter_lms/views/components/announcements.dart';
import 'package:flutter_lms/views/student/assignments/achievement-top.dart';
import 'package:flutter_lms/views/student/assignments/achievement_quiz_streak.dart';
import 'package:flutter_lms/views/student/assignments/achievements.dart';
import 'package:flutter_lms/views/student/assignments/assignment-quiz/quiz.dart';
import 'package:flutter_lms/views/student/assignments/assignment-quiz/quiz_result.dart';
import 'package:flutter_lms/views/student/assignments/assignment-quiz/quiz_info.dart';
import 'package:flutter_lms/views/student/assignments/assignment-quiz/quiz_intro.dart';
import 'package:flutter_lms/views/student/assignments/assignment-quiz/quiz_summary.dart';
import 'package:flutter_lms/views/student/assignments/assignment-remedial/remedial_result.dart';
import 'package:flutter_lms/views/student/assignments/your_achievements.dart';
import 'package:flutter_lms/views/student/classes/class_page.dart';
import 'package:flutter_lms/views/student/classes/class_subject_book_content.dart';
import 'package:flutter_lms/views/student/classes/class_subject_overview.dart';
import 'package:flutter_lms/views/student/classes/classes_page.dart';
import 'package:flutter_lms/views/student/classes/join_class.dart';
import 'package:flutter_lms/views/student/classes/join_class_success.dart';
import 'package:flutter_lms/views/student/classmates/my_classmates.dart';
import 'package:flutter_lms/views/student/profile/student_profile.dart';
import 'package:flutter_lms/views/student/student_shell.dart';
import 'package:flutter_lms/views/teacher/classes/subject_classes.dart';
import 'package:flutter_lms/views/teacher/classes/teacher_sections.dart';
import 'package:flutter_lms/views/teacher/teacher_shell.dart';
import 'package:get/get.dart';
import 'package:flutter_lms/views/auth/get_user.dart';
import 'package:flutter_lms/views/auth/sign_in.dart';
import 'package:flutter_lms/views/student/home/home_page.dart';
import 'package:flutter_lms/views/student/intro/analyzing_page.dart';
import 'package:flutter_lms/views/student/intro/introduction_page.dart';
import 'package:flutter_lms/views/student/intro/result_page.dart';
import 'package:flutter_lms/views/teacher/home/home_page.dart';
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
  static const String myClassmates = '/my-classmates';
  static const String quizInfo = '/quiz-info';
  static const String quizIntro = '/quiz-intro';
  static const String quiz = '/quiz';
  static const String quizResult = '/quiz-result';
  static const String subjectClassPage = '/subject-class-page';
  static const String classSubjectOverview = '/class-subject-overview';
  static const String classSubjectBookContent = '/book-content';
  static const String quizSummary = '/quiz-summary/';
  static const String remedialIntro = '/remedial-intro';
  static const String remedialQuiz = '/remedial-quiz';
  static const String remedialQuizResult = '/remedial-quiz-result';
  static const String achievements = '/achievements';
  static const String achievementsTop = '/achievements-top';
  static const String achievementQuizStreak = '/achievement-quiz-streak';
  static const String yourAchievements = '/your-achievements';

  // teacher routes
  static const teacherShell = '/teacher-shell';
  static const teacherSubjects = '/teacher-classes';
  static const teacherSections = '/teacher-sections';

  // utilities
  static const announcement = '/announcement';
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
    GetPage(
      name: AppRoutes.studentHome,
      page: () {
        final args = (Get.arguments as Map?) ?? {};
        return TeacherHomePage(
          token: (args['token'] ?? '') as String,
          uid: (args['uid'] ?? '') as String,
          userType: (args['userType'] ?? 4) as int,
        );
      },
    ),
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
    GetPage(name: AppRoutes.myClassmates, page: () => MyClassmatesPage()),
    GetPage(
      name: AppRoutes.studentJoinClass,
      page: () => StudentJoinClass(),
      transition: null,
    ),
    GetPage(
      name: AppRoutes.studentJoinClassSuccess,
      page: () => const StudentJoinClassSuccess(),
    ),
    GetPage(name: AppRoutes.quizInfo, page: () => const QuizInfoPage()),
    GetPage(name: AppRoutes.quizIntro, page: () => const QuizIntroPage()),
    GetPage(name: AppRoutes.quiz, page: () => const QuizPage()),
    GetPage(name: AppRoutes.quizResult, page: () => const QuizResultPage()),
    GetPage(
      name: AppRoutes.remedialIntro,
      page: () => const RemedialIntroPage(),
    ),
    GetPage(name: AppRoutes.remedialQuiz, page: () => const RemedialQuizPage()),
    GetPage(
      name: AppRoutes.remedialQuizResult,
      page: () => const RemedialQuizResultPage(),
    ),
    GetPage(
      name: AppRoutes.subjectClassPage,
      page: () => const SubjectClassPage(),
    ),
    GetPage(
      name: AppRoutes.classSubjectOverview,
      page: () => const ClassSubjectOverviewPage(),
    ),
    GetPage(
      name: AppRoutes.classSubjectBookContent,
      page: () => const SubjectBookContent(),
    ),
    GetPage(name: AppRoutes.quizSummary, page: () => const QuizSummaryPage()),
    GetPage(name: AppRoutes.achievements, page: () => const AchievementsPage()),
    GetPage(
      name: AppRoutes.achievementsTop,
      page: () => const AchievementTopPage(),
    ),
    GetPage(
      name: AppRoutes.achievementQuizStreak,
      page: () => const AchievementQuizStreakPage(),
    ),
    GetPage(
      name: AppRoutes.yourAchievements,
      page: () => const YourAchievementsPage(),
    ),
    GetPage(
      name: AppRoutes.announcement,
      page: () => const AnnouncementsPage(),
    ),
    GetPage(name: AppRoutes.teacherSubjects, page: () => const TeacherSubjectClasses(sectionName: '',)),
    GetPage(name: AppRoutes.teacherSections, page: () => const TeacherSectionsPage()),
    GetPage(
      name: AppRoutes.teacherShell,
      page: () {
        final args = (Get.arguments as Map?) ?? {};
        return TeacherShell(
          token: (args['token'] ?? '') as String,
          uid: (args['uid'] ?? '') as String,
          userType: (args['userType'] ?? 5) as int,
        );
      },
    ),
  ];
}
