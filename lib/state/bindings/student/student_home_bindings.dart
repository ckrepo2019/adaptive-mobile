import 'package:get/get.dart';
import '../../../controllers/student/student_home.dart';

class StudentHomeBindings extends Bindings {
  @override
  void dependencies() {
    // Register the controller once; recreated if disposed (fenix).
    Get.lazyPut<StudentHomeController>(
      () => StudentHomeController(),
      fenix: true,
    );

    // If your controller depends on other services, register them here too.
    // Get.lazyPut<ApiClient>(() => ApiClient());
  }
}
