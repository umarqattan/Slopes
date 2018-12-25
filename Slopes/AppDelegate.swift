//
//  AppDelegate.swift
//  Slopes
//
//  Created by Umar Qattan on 11/3/18.
//  Copyright © 2018 ukaton. All rights reserved.
//

import UIKit
import HealthKit
import OAuthSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sharedHealthKitStore = HKHealthStore()
    var sharedOAuth2Swift: OAuth2Swift?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        UNUserNotificationCenter.current().delegate = self
        self.scheduleLocalNotifications()
        self.preparePushNotifications(for: application)
        
        return true
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
        print("ApplicationWillEnterForeground(_:)")
        if let nc = window?.rootViewController as? UINavigationController, let vc = nc.viewControllers.first as? ViewController {
            vc.performGetWeights { (isNew) in
                if isNew {
                    print("A new weight measurement was recorded.")
                }
            }
            vc.performGetBodyFatPercentages { (isNew) in
                if isNew {
                    print("A new bodyfat measurement was recorded.")
                }
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Called when the application is directed to the Slope app from an oauth-callback
        if let host = url.host, host == "oauth-callback" {
            OAuthSwift.handle(url: url)
        }
        
        
        return true
    }
    
//    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        if let vc = window?.rootViewController as? ViewController {
//            vc.performGetWeights { (message) in
//                print(message)
//
//            }
//            completionHandler(.newData)
//        }
//    }
}

// MARK: - UNUserNotificiations

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
 
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.notification.request.identifier {
        case "CHECKIN":
            print("Received a Withings Checkin local notification.")
            if let vc = window?.rootViewController as? ViewController {
                vc.performGetWeights { (isNew) in
                    if isNew {
                        print("A new weight measurement was recorded.")
                    }
                }
                vc.performGetBodyFatPercentages { (isNew) in
                    if isNew {
                        print("A new bodyfat measurement was recorded.")
                    }
                }
            }
        default:
            break
        }
        
        completionHandler()
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let token = deviceToken.map { String(format: "%02.2hhx", $0)}.joined()
//        print(token)
//    }
    
    func preparePushNotifications(for application: UIApplication) {

        UNUserNotificationCenter.current().requestAuthorization(
        options: [.badge, .sound, .alert]) { (success, error) in

            guard success else { return }

            DispatchQueue.main.async {

                application.registerForRemoteNotifications()
            }
        }

    }
    
    func scheduleLocalNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Invitation"
        content.subtitle = "Check Your Weight!"
        content.body = "It's time to step on the Withings Scale"
        
        //Notification Trigger - when the notification should be fired
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        
        //Notification Request
        let request = UNNotificationRequest(identifier: "CHECKIN", content: content, trigger: trigger)
        
        //Scheduling the Notification
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }

    }
}

// MARK: - HealthKit helper methods
extension AppDelegate {

    func authorizeHealthKit() {
        
        if HKHealthStore.isHealthDataAvailable() {
            
            let allTypes = Set([HKObjectType.quantityType(forIdentifier: .bodyMass)!,
                                HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!])
            
            self.sharedHealthKitStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error ) in
                
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func isHealthKitAuthorized() -> Bool {
        return self.sharedHealthKitStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .bodyMass)!) == .sharingAuthorized && self.sharedHealthKitStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!) == .sharingAuthorized
    }
    
    func timeStampToDate(timeStamp: Int) -> Date {
        let date = Date(timeIntervalSince1970: TimeInterval(exactly: timeStamp)!)
        return date
    }
    
    func gramToPound(_ gramValue: Int) -> Double {
        return Double(gramValue) / 453.59237
    }
    
    func valueToPercent(_ percentValue: Int) -> Double {
        return Double(percentValue) * pow(10.0, -5.0)
    }
    
    func saveBodyFat(bodyFatPercentageValue: Int, timeStamp: Int) {
        let date = self.timeStampToDate(timeStamp: timeStamp)
        let bodyFatValue = self.valueToPercent(bodyFatPercentageValue)
        
        if self.isHealthKitAuthorized() {
            if let type = HKSampleType.quantityType(forIdentifier: .bodyFatPercentage) {
                let quantity = HKQuantity(unit: HKUnit.percent(), doubleValue: bodyFatValue)
                let sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
                self.sharedHealthKitStore.save(sample) { (success, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else {
                        print("Success: \(success ? "Saved body fat percentage data" : "Could not save body fat percentage data.")")
                    }
                }
            }
        } else {
            print("Health Kit is not authorized to save any body fat percentage data.")
        }
    }
    
    func saveWeight(gramValue: Int, timeStamp: Int) {
        
        let date = self.timeStampToDate(timeStamp: timeStamp)
        let poundValue = self.gramToPound(gramValue)
        
        if self.isHealthKitAuthorized() {
            if let type = HKSampleType.quantityType(forIdentifier: .bodyMass) {
                let quantity = HKQuantity(unit: HKUnit.pound(), doubleValue: poundValue)
                let sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
                self.sharedHealthKitStore.save(sample) { (success, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else {
                        print("Success: \(success ? "Saved weight data" : "Could not save weight data.")")
                    }
                }
            }
        } else {
            print("Health Kit is not authorized to save any weight data.")
        }
        
    }
}

