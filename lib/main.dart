import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:appsearchjob/amplifyconfiguration.dart';
import 'package:appsearchjob/models/theme_class.dart';
import 'package:appsearchjob/screens/default_screen.dart'; // Màn hình mặc định
import 'package:appsearchjob/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: JobSearchApp(),
    ),
  );
}

Future<void> _configureAmplify() async {
  final authPlugin = AmplifyAuthCognito();

  await Amplify.addPlugins([authPlugin]);

  try {
    await Amplify.configure(amplifyconfig);
    print('Amplify configured successfully');
  } catch (e) {
    print('Amplify configuration failed: $e');
  }
}

class JobSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt banner DEBUG
      theme: ThemeData.light(),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.grey[900], // Màu nền cho chế độ tối
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueAccent,
        ),
      ),
      themeMode: Provider.of<ThemeProvider>(context).isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: FutureBuilder<bool>(
        future: _checkUserSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasData && snapshot.data == true) {
              return HomeScreen(); // Nếu đã đăng nhập, chuyển đến MainScreen
            } else {
              return DefaultScreen(); // Nếu chưa đăng nhập, chuyển đến DefaultScreen
            }
          }
        },
      ),
    );
  }

  Future<bool> _checkUserSession() async {
    try {
      final result = await Amplify.Auth.fetchAuthSession();
      return result.isSignedIn; // Trả về true nếu người dùng đã đăng nhập
    } catch (e) {
      print('Error checking auth session: $e');
      return false; // Mặc định trả về false nếu có lỗi
    }
  }
}