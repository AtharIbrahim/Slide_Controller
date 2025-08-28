import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/slide_controller_bloc.dart';
import 'bloc/slide_controller_event.dart';
import 'screens/slide_control_screen.dart';
import 'models/slide_controller_state.dart';
import 'services/settings_service.dart';
import 'themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences before starting the app
  await SettingsService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SlideControllerBloc()..add(LoadSettings()),
      child: BlocBuilder<SlideControllerBloc, SlideControllerState>(
        builder: (context, state) {
          // Set orientation preferences
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
          
          // Show status bar with proper styling
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
          );
          
          // Set status bar style based on theme
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: state.settings.isDarkMode 
                  ? Brightness.light 
                  : Brightness.dark,
              statusBarBrightness: state.settings.isDarkMode 
                  ? Brightness.dark 
                  : Brightness.light,
              systemNavigationBarColor: state.settings.isDarkMode
                  ? const Color(0xFF121212)
                  : Colors.white,
              systemNavigationBarIconBrightness: state.settings.isDarkMode
                  ? Brightness.light
                  : Brightness.dark,
            ),
          );

          return MaterialApp(
            title: 'Slide Controller Pro',
            theme: AppThemes.buildLightTheme(state.settings.uiScale),
            darkTheme: AppThemes.buildDarkTheme(state.settings.uiScale),
            themeMode: state.settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SlideControlScreen(),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              // Make app responsive by adapting to screen size
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(state.settings.uiScale),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
