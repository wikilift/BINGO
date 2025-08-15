import 'package:get/get.dart';
import 'package:flutter_application_1/app/modules/home_module/bingo_binding.dart';
import 'package:flutter_application_1/app/modules/home_module/bingo_page.dart';
import 'package:flutter_application_1/app/modules/splash_module/splash_page.dart';
part './app_routes.dart';

class AppPages {
  AppPages._();
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => BingoView(),
      binding: BingoBinding(),
    ),
    GetPage(name: AppRoutes.initial, page: () => const SplashPage()),
  ];
}
