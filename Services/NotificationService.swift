import Foundation
import UserNotifications

/// Abstraction for scheduling local notifications.
public protocol NotificationService {
    func requestAuthorization() async throws
    func scheduleDailyReports()
}

/// Local implementation using UNUserNotificationCenter.
public final class LocalNotificationService: NotificationService {
    private let center = UNUserNotificationCenter.current()
    
    public init() {}
    
    public func requestAuthorization() async throws {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    public func scheduleDailyReports() {
        let identifiers = ["route-report", "battle-report"]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        
        // 14:00 report
        var components14 = DateComponents()
        components14.hour = 14
        components14.minute = 0
        let trigger14 = UNCalendarNotificationTrigger(dateMatching: components14, repeats: true)
        let content14 = UNMutableNotificationContent()
        content14.title = "Rapport Route"
        content14.body = "Calorie du matin, progression et objectif du boss."
        let request14 = UNNotificationRequest(identifier: identifiers[0], content: content14, trigger: trigger14)
        
        // 23:00 report
        var components23 = DateComponents()
        components23.hour = 23
        components23.minute = 0
        let trigger23 = UNCalendarNotificationTrigger(dateMatching: components23, repeats: true)
        let content23 = UNMutableNotificationContent()
        content23.title = "Rapport Bataille"
        content23.body = "Récapitulatif du jour, XP/HP, boss et récompenses."
        let request23 = UNNotificationRequest(identifier: identifiers[1], content: content23, trigger: trigger23)
        
        center.add(request14) { error in
            if let error = error {
                print("Error scheduling 14h report: \(error)")
            }
        }
        center.add(request23) { error in
            if let error = error {
                print("Error scheduling 23h report: \(error)")
            }
        }
    }
}
