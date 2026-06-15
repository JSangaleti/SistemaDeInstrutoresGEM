import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../views/home/home_page.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        AuthService().logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      },
      icon: const Icon(Icons.logout),
      tooltip: 'Sair',
    );
  }
}
