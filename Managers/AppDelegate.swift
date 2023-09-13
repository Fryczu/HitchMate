//
//  AppDelegate.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 12/09/2023.
//

import Foundation
import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Konfiguracja Firebase
        FirebaseApp.configure()

        // Prośba o pozwolenie na powiadomienia
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, _) in }
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()

        // Ustawienie delegata dla Messaging
        Messaging.messaging().delegate = self

        return true
    }

    // Otrzymywanie powiadomień w tle oraz na pierwszym planie
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([[.banner, .sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    // Otrzymywanie FCM tokena
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "")")
    }

    // Jeśli chcesz obsłużyć tokeny w inny sposób, możesz to zrobić tutaj
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

