import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:map_in_flutter/MapScreen.dart';

void main() => runApp(const InitApp());

class InitApp extends StatelessWidget {
  const InitApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NewAddressPage(),
    );
  }
}