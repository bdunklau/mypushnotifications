import UIKit
import Flutter
import Firebase
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure() //add this before the code below
      GeneratedPluginRegistrant.register(with: self)
//    if #available(iOS 10.0, *) {
//      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
//    }
      
      
      if #available(iOS 10.0, *) {
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
      } else {
        let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
      }
      
      Messaging.messaging().delegate = self
      
      Messaging.messaging().token { token, error in
        if let error = error {
          print("Error fetching FCM registration token: \(error)")
        } else if let token = token {
          print("FCM registration token: \(token)")
          //self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
        }
      }

      application.registerForRemoteNotifications()
      
      
      
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
      
      
  }
    
}


