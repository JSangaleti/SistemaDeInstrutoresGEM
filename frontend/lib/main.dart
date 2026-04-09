import 'package:flutter/material.dart';
import 'views/aluno_list/aluno_list_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GEM App',
      home: AlunoListPage(),
    );
  }
}