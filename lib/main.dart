import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_onboarding_app/features/core/colors.dart';
import 'package:medical_onboarding_app/features/customer/presentation/screens/customer_list_screen.dart';
import 'package:medical_onboarding_app/features/messaging/presentation/pages/message_screen.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF667467),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(
          child: Text(
            'Modules for the technical test',
            style: TextStyle(
              color: ColorsCore.greenFive,
              fontSize: 52,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 220,
                width: 1020,
                child: Card(
                  color: ColorsCore.greenFour,
                  child: ListTile(
                    title: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.people, size: 60), // si quieres mantenerlo
                          Text(
                            'Module 1: Client Management (CRUD)',
                            style: TextStyle(
                              color: ColorsCore.greenOne,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Go to the client management module',
                            style: TextStyle(
                              color: ColorsCore.greenOne,
                              fontSize: 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerListScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 120),
              SizedBox(
                height: 220,
                width: 1020,
                child: Card(
                  color: ColorsCore.greenFour,
                  child: ListTile(
                    title: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 60),
                          const Text(
                            'Module 2: Chat AI for Documents',
                            style: TextStyle(
                              color: ColorsCore.greenOne,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Go to the chat with AI for documents',
                            style: TextStyle(
                              color: ColorsCore.greenOne,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MessageScreen(
                            customerId: 'ai_customer',
                            customerName: 'Cliente IA',
                            isAi: true,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
