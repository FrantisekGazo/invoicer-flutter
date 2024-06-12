import 'package:flutter/material.dart';
import 'package:invoicer/src/data/di.dart';
import 'package:invoicer/src/data/service/navigation.dart';
import 'package:invoicer/src/ui/page/home/page.dart';
import 'package:invoicer/src/ui/page/splash/page.dart';

class InvoicerApp extends StatefulWidget {
  const InvoicerApp({super.key});

  @override
  State<InvoicerApp> createState() => _InvoicerAppState();
}

class _InvoicerAppState extends State<InvoicerApp> {
  late final NavigationService _navigatorService;

  bool initialized = false;

  @override
  void initState() {
    _navigatorService = inject();
    _navigatorService.isInitialized.addListener(() {
      setState(() {
        initialized = _navigatorService.isInitialized.value;
      });
    });
    _navigatorService.initializedApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(
        useMaterial3: false,
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: false,
      ),
      home: Navigator(
        pages: [
          initialized
              ? const MaterialPage(child: HomePage())
              : const MaterialPage(child: SplashPage()),
        ],
        onPopPage: (route, result) {
          return route.didPop(result);
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
