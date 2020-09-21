//
//  AppDelegate.swift
//  NeoUI
//
//  Created by Carl Peto on 09/09/2020.
//  Copyright © 2020 Carl Peto. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // background disconnect...
    // when we enter the background, request app processing time using beginBackgroundTask
    // and start a timer immediately, timeout N seconds (e.g. 30)
    // when the timer expires, disconnect from bluetooth
    // if the app comes to foreground before the timer expires, cancel the timer
    // if the background execution time expires, cancel the timer and disconnect from bluetooth immediately
    var disconnectionTimerTask: UIBackgroundTaskIdentifier?
    var disconnectionTimer: Timer?

    func applicationDidEnterBackground(_ application: UIApplication) {
        startBluetoothInactivityTimeout(application: application, timeout: 10)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        cancelBluetoothInactivityTimeout(application: application)
    }
}

extension AppDelegate {
    // pull the bluetooth to background methods into here and call it from app go to background/foreground and from
    // scene go to background/foreground
    func startBluetoothInactivityTimeout(application: UIApplication, timeout: TimeInterval) {
        // request additional background time, to allow the disconnection timer to run
        self.disconnectionTimerTask = application.beginBackgroundTask(expirationHandler:{
            // timeslot ran out, stop timer, disconnect, end task
            self.bluetoothDisconnect(application: application)
        })

        // start a disconnection timer
        disconnectionTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { _ in
            self.bluetoothDisconnect(application: application)
        }
    }

    func cancelBluetoothInactivityTimeout(application: UIApplication) {
        if let disconnectionTimer = self.disconnectionTimer {
            disconnectionTimer.invalidate()
            self.disconnectionTimer = nil
        }

        // if we had already disconnected, set it back up
        Bluetooth.shared.shouldReconnect = true
    }

    private func bluetoothDisconnect(application: UIApplication) {
        if let disconnectionTimer = self.disconnectionTimer {
            disconnectionTimer.invalidate()
            self.disconnectionTimer = nil
        }

        Bluetooth.shared.shouldReconnect = false
        Bluetooth.shared.disconnect()

        if let disconnectionTimerTask = self.disconnectionTimerTask {
            application.endBackgroundTask(disconnectionTimerTask)
        }
    }
}
