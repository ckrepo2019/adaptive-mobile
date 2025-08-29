import 'package:get/get.dart';
import '../../../controllers/student/student_home.dart';

class StudentHomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentHomeController>(
      () => StudentHomeController(),
      fenix: true,
    );
  }
}
