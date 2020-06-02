//
//  AppDelegate.swift
//  TheGreenProgram
//
//  Created by Jose Alonso Alfaro Perez on 11/27/19.
//  Copyright © 2019 Jose Alonso Alfaro Perez. All rights reserved.
//

import UIKit
import CoreData
import Amplify
import AWSMobileClient
import AmplifyPlugins
import GoogleMaps
import GooglePlaces
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storyboard: UIStoryboard?
    

    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        registerForPushNotifications()

        // [END register_for_notifications]
        
        
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        // [END set_messaging_delegate]
        
        
        InstanceID.instanceID().instanceID { (result, error) in
          if let error = error {
            print("Error fetching remote instance ID: \(error)")
          } else if let result = result {
            print("Remote instance ID token: \(result.token)")
          }
        }
        
        GMSServices.provideAPIKey("AIzaSyAxBMhomUknxqnPM4MVlaLohCIXWCoUwUM")
        GMSPlacesClient.provideAPIKey("AIzaSyAxBMhomUknxqnPM4MVlaLohCIXWCoUwUM")
        
        //MARK:- AWS stuff
        AWSMobileClient.default().initialize { (userState, error) in
            if let err = error {
                print(err)
            } else {
                self.userStateHandler(userState!)
            }
        }
        
        AWSMobileClient.default().addUserStateListener(self) { (userState, info) in
            self.userStateHandler(userState)
        }
        
        
        return true
    }
    
    private func userStateHandler(_ userState: UserState) {
        switch (userState) {
        case .guest:
            print("user is in guest mode.")
        case .signedOut:
            storyboard = UIStoryboard(name: "Main", bundle: nil)
            DispatchQueue.main.async {
                let view = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                self.window?.rootViewController = view
                self.window?.makeKeyAndVisible()
            }
            Map.signUpMode = true
            print("user signed out")
        case .signedIn:
            
            let accountUrl = "https://thegreenmarket.tk/api/accounts"
            let semaphore = DispatchSemaphore(value: 0)
            let request = RequestManager().getRequest(
                url: accountUrl,
                headers: [],
                params: [:],
                method: "GET")
            let session = URLSession.shared
            session.dataTask(with: request){ (data, response, error) in
                if let data = data{
                    do{
                        let response = try JSONDecoder().decode(AccountResponse.self, from: data)
                        let account = response.data?.item
                        Profile.name = account?.name ?? ""
                        Profile.surname = account?.lastname ?? ""
                        Profile.email = account?.email ?? ""
                        Profile.gender = account?.gender ?? ""
                        Profile.birthday = account?.date_birth ?? ""
                        Profile.phone_number = account?.phone_number ?? ""
                        Profile.address = account?.address ?? ""
                        Profile.latitude = account?.latitude ?? 0
                        Profile.longitude = account?.longitude ?? 0
                        Profile.loyaltyLevelID = account?.loyaltyLevel?.id ?? -1
                        Profile.total_points = account?.loyaltyPoints?.total_points ?? -1
                        Profile.current_points = account?.loyaltyPoints?.current_points ?? -1
                    }catch let error {
                        print(error)
                    }
                    semaphore.signal()
                }
                if error != nil {
                    semaphore.signal()
                }
            }.resume()
            semaphore.wait()
            
            AWSMobileClient.default().getUserAttributes { (attributes, error) in
                        if let attributes = attributes {
                            
                            Profile.name = attributes["name"] ?? ""
                            Profile.surname = attributes["family_name"] ?? ""
                            Profile.email = attributes["email"] ?? ""
                            Profile.gender = attributes["gender"] ?? ""
                            Profile.birthday = attributes["birthdate"] ?? ""
                            Profile.phone_number = attributes["phone_number"] ?? ""
                            Profile.address = attributes["address"] ?? ""
                            Profile.latitude = Double(attributes["custom:latitude"] ?? "")!
                            Profile.longitude = Double(attributes["custom:longitude"] ?? "")!
                            
                        }else if error != nil {
                        }
            }
            storyboard = UIStoryboard(name: "Controller", bundle: nil)
            DispatchQueue.main.async {
                let view = self.storyboard?.instantiateViewController(withIdentifier: "Controller")
                self.window?.rootViewController = view
                self.window?.makeKeyAndVisible()
            }
            Map.signUpMode = false
            print("user is signed in.")
        case .signedOutUserPoolsTokenInvalid:
            print("need to login again.")
        case .signedOutFederatedTokensInvalid:
            print("user logged in via federation, but currently needs new tokens")
        default:
            AWSMobileClient.default().signOut()
            print("unsupported")
        }
    }
    
    func configureAmplifyWithStorage() {
        let storagePlugin = AWSS3StoragePlugin()
        do {
            try Amplify.add(plugin: storagePlugin)
            try Amplify.configure()
            print("Amplify configured with storage plugin")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
        saveContext()
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification
      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)
      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID 1: \(messageID)")
      }

      // Print full message.
      print(userInfo)
      pushNotification(remoteMessage: userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification
      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)
      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID 2: \(messageID)")
      }

      // Print full message.
      print(userInfo)
      pushNotification(remoteMessage: userInfo)
      completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "TheGreenProgram")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK:-Notifications
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
    
    func registerForPushNotifications() {
      UNUserNotificationCenter.current() // 1
        .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
          granted, error in
          print("Permission granted: \(granted)") // 3
        guard granted else { return }
            self.getNotificationSettings()
      }
    }
    
    func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData
    ) {
        //Messaging.messaging().apnsToken = deviceToken
        let tokenParts = deviceToken
        
      print("Device Token: ")
    }

    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Failed to register: \(error)")
    }
    
    func pushNotification(remoteMessage: [AnyHashable:Any]){
        let type = remoteMessage["type"] as! String
        var title = ""
        var body = ""
        if type == "Offer"{
            title = "Nueva Oferta Creada!"
            body = remoteMessage["name"] as! String
        }
        if type == "Order"{
             title = "Orden cambio de estatus"
            let id = remoteMessage["id"] as! String
            
            let status = remoteMessage["status"] as! String
             body = "Orden #" + id + " cambia de estatus a: " + status
            
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "notificationIdentifier", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler:nil)
    }

}

//MARK:- UNUserNotificationCenterDelegate
// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)
    // Print message ID.
    print("Message ID 3:")
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID 3: \(messageID)")
      pushNotification(remoteMessage: userInfo)
    }

    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    completionHandler([.alert, .sound])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    // Print message ID.
    print("Message ID 4:")
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID 4: \(messageID)")
      pushNotification(remoteMessage: userInfo)
    }

    // Print full message.
    print("userinfo: ",userInfo)

    completionHandler()
  }
}

//MARK:-MessagingDelegate
extension AppDelegate : MessagingDelegate {
  // [START refresh_token]
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    print("Firebase registration token: \(fcmToken)")
    
    let dataDict:[String: String] = ["token": fcmToken]
    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
  }
  // [END refresh_token]
  // [START ios_10_data_message]
  // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
  // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    print("Received data message: \(remoteMessage.appData)")
    pushNotification(remoteMessage: remoteMessage.appData)
    }
  // [END ios_10_data_message]
    
    
}


