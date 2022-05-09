//
//  ReminderPresenter.swift
//  Task14PushNotifications
//
//  Created by Tymofii (Work) on 09.11.2021.
//

import Foundation
import NotificationCenter

final class ReminderPresenter {
    
    // MARK: - Configuration
    
    private enum Configuration {
        static let userDefaultsIdentifier = "ReminderDataKey"
    }
    
    // MARK: - Variable
    
    private var model: ReminderModel {
        set {
            do {
                let encoded = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(encoded, forKey: Configuration.userDefaultsIdentifier)
            } catch {
                print(error)
            }
        }
        get {
            guard let savedModel  = UserDefaults.standard.object(forKey: Configuration.userDefaultsIdentifier) as? Data,
                    let loadedModel = try? JSONDecoder().decode(ReminderModel.self, from: savedModel) else { return .init() }
            
            return loadedModel
        }
    }
    let notificationCenter: UNUserNotificationCenter = .current()
    
    var numberOfRows: Int? {
        model.reminders.count
    }
    
    // MARK: - Initialization
    
    init(with model: ReminderModel = .init()) {
        self.model = model
    }
    
    // MARK: - Data source TableView
    
    func getObject(at indexPath: IndexPath) -> Reminder? {
        model.reminders[indexPath.item]
    }
    
    // MARK: - Append an object
    
    func appendObject(object: Reminder) {
        model.reminders.append(object)
        
        switch object.notification {
        case .timeInterval(let identifier, let interval):
            let content = UNMutableNotificationContent()
            content.title = object.task
            content.threadIdentifier = "LocalNotifications"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            notificationCenter.add(request)
        case .dateComponents(let identifier, let date):
            let content = UNMutableNotificationContent()
            content.title = object.task
            content.threadIdentifier = "LocalNotifications"
            
            let trigger = UNCalendarNotificationTrigger.init(dateMatching: date, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            notificationCenter.add(request)
        }
    }
    
    // MARK: - Delete
    
    func handleDeleteItem(at indexPath: IndexPath) {
        let reminder = model.reminders.remove(at: indexPath.item)
        let identifier: String
        switch reminder.notification {
        case .timeInterval(let id, _):
            identifier = id
        case .dateComponents(let id, _):
            identifier = id
        }
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

