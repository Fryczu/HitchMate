//
//  HitchMate_3_0App.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 06/09/2023.
//

import SwiftUI
import Foundation
import UIKit
import Firebase
import FirebaseCore
import UserNotifications
import FirebaseMessaging
import Alamofire



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
    
    func saveFCMTokenToFirestore(fcmToken: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userID).setData(["fcmToken": fcmToken], merge: true) { (error) in
            if let error = error {
                print("Error saving FCM token: \(error)")
            } else {
                print("FCM token saved successfully!")
            }
        }
    }


    // Otrzymywanie FCM tokena
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "")")
        guard let token = fcmToken else { return }
        saveFCMTokenToFirestore(fcmToken: token)

        // Wysyłanie tokena na serwer
        sendTokenToServer(token)
    }
    
    func sendTokenToServer(_ token: String) {
        let serverURL = "http://twój-adres-serwera.com/api/save-token"
        let parameters: [String: Any] = [
            "token": token
        ]
        
        AF.request(serverURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
            switch response.result {
            case .success:
                print("Token wysłany pomyślnie na serwer!")
            case .failure(let error):
                print("Błąd podczas wysyłania tokena: \(error)")
            }
        }
    }

    // Jeśli chcesz obsłużyć tokeny w inny sposób, możesz to zrobić tutaj
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

@main
struct HitchMate_3_0App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
