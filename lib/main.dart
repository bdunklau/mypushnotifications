import 'package:flutter/material.dart';
import 'package:mypushnotifications/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


//   https://www.dbestech.com/tutorials/flutter-firebase-ios-push-notification
import 'package:overlay_support/overlay_support.dart';


///  Send push notifications to an iOS simulator BUT NOT to an actual iPhone
///    -->  https://www.youtube.com/watch?v=kRf_uB49Iuo
///
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  //
  // await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );

  ///  4:35  of  https://www.youtube.com/watch?v=4Cwp1iA8BaQ&t=88s
  // bug!  https://github.com/firebase/flutterfire/issues/9689
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  runApp(const MyApp());
}


//   https://headsupvideo.atlassian.net/browse/HOAPP-109
//  must be a top-level function  per this:  https://firebase.google.com/docs/cloud-messaging/flutter/receive
Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message =======================================");
  // print("message.notification?.title: ${message.notification?.title}");
  // print("message.notification?.body: ${message.notification?.body}");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('_firebaseMessagingBackgroundHandler:  Handling a background message ${message.messageId}');
  print('_firebaseMessagingBackgroundHandler:  message.data = ${message.data}');
  flutterLocalNotificationsPlugin.show(
      message.data.hashCode,
      message.data['title'],
      message.data['body'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          //channel.description
        ),
      )
  );
}

///  https://github.com/Amanullahgit/Flutter-v2-FCM-Notifications/blob/master/lib/main.dart
///  3:30  of  https://www.youtube.com/watch?v=4Cwp1iA8BaQ&t=88s
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  //'This channel is used for important notifications.', // description
  importance: Importance.high,
);

///  https://github.com/Amanullahgit/Flutter-v2-FCM-Notifications/blob/master/lib/main.dart
///  3:30  of  https://www.youtube.com/watch?v=4Cwp1iA8BaQ&t=88s
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var materialApp = MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
    return OverlaySupport(child: materialApp);
    // return materialApp;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? token;
  List subscribed = [];
  List topics = [
    'Samsung',
    'Apple',
    'Huawei',
    'Nokia',
    'Sony',
    'HTC',
    'Lenovo'
  ];
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    // registerNotification();
    // super.initState();

    //   https://github.com/Amanullahgit/Flutter-v2-FCM-Notifications/blob/master/lib/main.dart
    //   https://www.youtube.com/watch?v=4Cwp1iA8BaQ   5:10
    super.initState();
    var initialzationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
    InitializationSettings(android: initialzationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('FirebaseMessaging.onMessage.listen :   got a message');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    flutterLocalNotificationsPlugin.show(
        message.data.hashCode,
        message.data['title'],
        message.data['body'],
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            //channel.description,
            icon: android?.smallIcon,
          ),
        ));
      // if (notification != null && android != null) {
      //   flutterLocalNotificationsPlugin.show(
      //       message.data.hashCode,
      //       message.data['title'],
      //       message.data['body'],
      //       NotificationDetails(
      //         android: AndroidNotificationDetails(
      //           channel.id,
      //           channel.name,
      //           //channel.description,
      //           icon: android?.smallIcon,
      //         ),
      //       ));
      // }
    });
    getToken();
    // getTopics();
  }

  // see login.dart for complete example
  // void registerNotification() async {
  //
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;
  //
  //   // 2. Instantiate Firebase Messaging
  //   NotificationSettings settings = await messaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );
  //
  //
  //
  //
  //   //   https://www.dbestech.com/tutorials/flutter-firebase-ios-push-notification
  //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //     var token = await messaging.getToken();
  //     print("token:  $token");
  //     //  eb8-LN6qRwuUrSV3_rnOE1:APA91bE-eK1lKpNNDKSV8KkQ2AWTOB21QfItHRqH3WF80eMQP4Qza9xbQo9GaE1fkXZkBzTKwItnE3EnlE37-HZqQ7eStW5dES2gJJk0oRkvCuOvEPknvmTNDix-IhnQD00Qanb_TCUz
  //
  //     /**
  //      * this works on iOS because we did the Firebase.initializeApp() in AppDelegate.swift
  //      * I don't know if this works on Android.  I'm guessing it doesn't
  //      */
  //     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //       print("FirebaseMessaging.onMessage.listen: ${message.toString()}");
  //       //  see this for more complete code example  -->  https://www.dbestech.com/tutorials/flutter-firebase-ios-push-notification
  //       showNotification(message);
  //     });
  //
  //   }
  //
  // }


  showNotification(RemoteMessage message) {
    showSimpleNotification(
      Text(message.notification!.title!),
      leading: NotificationBadge(totalNotifications: 99),
      subtitle: Text(message.notification!.body!),
      background: Colors.cyan.shade700,
      duration: Duration(seconds: 2),
    );
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    var scaffold = Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );

    return scaffold;
  }


  //   https://github.com/Amanullahgit/Flutter-v2-FCM-Notifications/blob/master/lib/main.dart#L141
  getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    setState(() {
      token = token;
    });
    print("token:  $token");
  }

  // getTopics() async {
  //   await FirebaseFirestore.instance
  //       .collection('topics')
  //       .get()
  //       .then((value) => value.docs.forEach((element) {
  //     if (token == element.id) {
  //       subscribed = element.data().keys.toList();
  //     }
  //   }));
  //
  //   setState(() {
  //     subscribed = subscribed;
  //   });
  // }


}


class NotificationBadge extends StatelessWidget {
  final int totalNotifications;

  const NotificationBadge({required this.totalNotifications});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: new BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$totalNotifications',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
