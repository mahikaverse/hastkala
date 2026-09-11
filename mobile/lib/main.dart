import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/services/api_config.dart';
import 'core/services/auth_service.dart';
import 'core/services/data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.init();
  await AuthService().init();
  await DataService().init();
  runApp(const HastKalaApp());
}
