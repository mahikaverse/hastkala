import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/services/data_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DataService().init();
  runApp(const HastKalaApp());
}
