import 'package:get/get.dart';
import 'package:newapp/presentation/bindings/auth_bindings.dart';
import 'package:newapp/presentation/bindings/dashboard_bindings.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    AuthBinding().dependencies();
    DashboardBinding().dependencies();
  }
}
