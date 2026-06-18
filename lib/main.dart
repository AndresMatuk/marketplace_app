import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'presentation/routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final app = Firebase.app();

  debugPrint('========== FIREBASE CONFIG ==========');
  debugPrint('App Name: ${app.name}');
  debugPrint('Project ID: ${app.options.projectId}');
  debugPrint('App ID: ${app.options.appId}');
  debugPrint('API Key: ${app.options.apiKey}');
  debugPrint('Storage Bucket: ${app.options.storageBucket}');
  debugPrint('====================================');

  debugPrint(
    'Firestore Project ID: '
    '${FirebaseFirestore.instance.app.options.projectId}',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Marketplace App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      routerConfig: router,
    );
  }
}
