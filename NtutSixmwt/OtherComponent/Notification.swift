//
//  Notification.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2022/4/8.
//

import Foundation
import UserNotifications

class Notification{
    var permission: Bool = false

    func getPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){ success, error in
            if success{
                print("All set!")
                self.permission = true
            }else if let error = error{
                print(error.localizedDescription)
                self.permission = false
            }
        }
    }
    
    func hasPermission()->Bool{
        return permission
    }
    
    func addNotification(title: String, subtitile: String, notifedTime: Double){
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitile
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notifedTime, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
