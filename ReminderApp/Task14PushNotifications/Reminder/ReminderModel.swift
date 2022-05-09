//
//  ReminderModel.swift
//  Task14PushNotifications
//
//  Created by Tymofii (Work) on 09.11.2021.
//

import Foundation

struct ReminderModel: Codable {
    var reminders: [Reminder] = []
}

struct Reminder: Codable {
    var task: String
    var notification: NotificationType
}

enum NotificationType: Codable {
    case timeInterval(identifier: String, interval: TimeInterval)
    case dateComponents(identifier: String, date: DateComponents)
}
