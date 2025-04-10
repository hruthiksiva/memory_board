import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/swipe_screen.dart';
import 'screens/memory_board_screen.dart';
import 'models/memory_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MemoryProvider(),
      child: MaterialApp(
        title: 'Memory Mood Board',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.yellow[50],
          fontFamily: 'Montserrat',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.amber),
            displayMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.amber),
            bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/swipe': (context) => const SwipeScreen(),
          '/memory-board': (context) => const MemoryBoardScreen(),
        },
      ),
    );
  }
}
