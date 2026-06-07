import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chrome_cast/cast_context.dart';
import 'package:flutter_chrome_cast/discovery.dart';
import 'package:flutter_chrome_cast/entities/discovery_criteria.dart';
import 'package:flutter_chrome_cast/models/android/android_cast_options.dart';
import 'package:flutter_chrome_cast/models/ios/ios_cast_options.dart';

import 'blocs/cast_session/cast_session_bloc.dart';
import 'blocs/cast_timer/cast_timer_bloc.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initCast();
  runApp(const MyApp());
}

void _initCast() {
  const appId = GoogleCastDiscoveryCriteria.kDefaultApplicationId;

  if (Platform.isAndroid) {
    GoogleCastContext.instance.setSharedInstanceWithOptions(
      GoogleCastOptionsAndroid(appId: appId),
    );
  } else if (Platform.isIOS) {
    GoogleCastContext.instance.setSharedInstanceWithOptions(
      IOSGoogleCastOptions(
        GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(appId),
      ),
    );
  }
  GoogleCastDiscoveryManager.instance.startDiscovery();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CastSessionBloc()..add(CastSessionStarted()),
        ),
        BlocProvider(create: (_) => CastTimerBloc()),
      ],
      child: MaterialApp(
        title: 'Chromecast Timer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
