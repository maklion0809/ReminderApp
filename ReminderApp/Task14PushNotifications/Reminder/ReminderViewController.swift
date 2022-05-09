//
//  ReminderViewController.swift
//  Task14PushNotifications
//
//  Created by Tymofii (Work) on 09.11.2021.
//

import UIKit

final class ReminderViewController: UIViewController {
    
    // MARK: - Configuration
    
    private enum Configuration {
        static let cellIdentifier = "ReminderCell"
    }
    
    // MARK: - UI element
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Configuration.cellIdentifier)
        
        return tableView
    }()
    
    private lazy var addBarButton: UIBarButtonItem = {
        let addButtonItem = UIBarButtonItem(image: UIImage(systemName: "note.text.badge.plus"), style: .plain, target: self, action: #selector(wasAddButtonTapped(_:)))
        addButtonItem.tintColor = .black
        
        return addButtonItem
    }()
    
    private lazy var datePicker = UIDatePicker()
    
    private lazy var alert = UIAlertController()
    
    // MARK: - Variable
    
    var presenter: ReminderPresenter?
    private var notificationType: NotificationType?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupSubview()
        setupConstraint()
    }
    
    // MARK: - Setting up the navigation
    
    private func setupNavigation() {
        title = "Reminder"
        navigationItem.rightBarButtonItem = addBarButton
    }
    
    // MARK: - Setting up the subview
    
    private func setupSubview() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        datePicker.preferredDatePickerStyle = .wheels
        
        presenter?.notificationCenter.delegate = self
    }
    
    // MARK: - Setting up the constraint
    
    private func setupConstraint() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Display add new task
    
    private func displayAddNewTask(with type: NotificationType) {
        alert = UIAlertController(title: "Reminder", message: "add reminder", preferredStyle: .alert)
        
        // task textFiled setting
        alert.addTextField { textField in
            textField.placeholder = "Enter name task"
        }
        
        alert.addTextField { [weak self] textField in
            guard let self = self else { return }
            textField.inputView = self.datePicker
            let toolBar = UIToolbar()
            toolBar.sizeToFit()
            
            switch type {
            case .timeInterval(_, _):
                textField.placeholder = "Choose interval"
                self.datePicker.datePickerMode = .countDownTimer
                let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressedInterval))
                toolBar.setItems([doneButton], animated: true)
            case .dateComponents(_, _):
                textField.placeholder = "Choose date"
                self.datePicker.datePickerMode = .dateAndTime
                let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressedDate))
                toolBar.setItems([doneButton], animated: true)
            }
            
            textField.delegate = self
            textField.inputAccessoryView = toolBar
        }
        
        // cancel alert and data storage
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] action in
            guard let self = self,
                  let task = self.alert.textFields?.first?.text,
                  let date = self.alert.textFields?.last?.text,
                  !task.isEmpty,
                  !date.isEmpty,
                  let type = self.notificationType else { return }
            
            let reminder = Reminder(task: task, notification: type)
            self.presenter?.appendObject(object: reminder)
            self.tableView.reloadData()
        }))
        
        // cancel alert
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // present alert
        present(alert, animated: true)
    }
    
    // MARK: - Convert interval to string
    
    private func convertIntervalToString(with interval: TimeInterval) -> String {
        let hours = Int(interval / 3600)
        let minutes = Int(interval - TimeInterval(hours * 3600)) / 60
        var text = "in "
        if hours > 0 {
            text += "\(hours) hour \(hours > 1 ? "s" : "")"
        }
        if minutes > 0 {
            text += "\(minutes) minute \(minutes > 1 ? "s" : "")"
        }
        
        return text
    }
    
    // MARK: - UIAction
    
    @objc private func wasAddButtonTapped(_ sender: UITabBarItem) {
        
        let alertSheet = UIAlertController(title: "Type", message: "Choose type", preferredStyle: .actionSheet)
        
        alertSheet.addAction(UIAlertAction(title: "Time interval", style: .default, handler: { [weak self] action in
            guard let self = self else { return }
            self.displayAddNewTask(with: .timeInterval(identifier: "", interval: .zero))
            
        }))
        
        alertSheet.addAction(UIAlertAction(title: "Date components", style: .default, handler: { [weak self] action in
            guard let self = self else { return }
            self.displayAddNewTask(with: .dateComponents(identifier: "", date: DateComponents()))
        }))
        
        alertSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertSheet, animated: true)
    }
    
    @objc private func donePressedInterval() {
        guard let textField = alert.textFields?.last else { return }
        textField.text = convertIntervalToString(with: datePicker.countDownDuration)
        
        notificationType = .timeInterval(identifier: UUID().uuidString, interval: TimeInterval(datePicker.countDownDuration))
        
        self.alert.view.endEditing(true)
    }
    
    @objc private func donePressedDate() {
        guard let textField = alert.textFields?.last else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        textField.text = dateFormatter.string(from: datePicker.date)
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: datePicker.date)
        
        notificationType = .dateComponents(identifier: UUID().uuidString, date: dateComponents)
        
        self.alert.view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource

extension ReminderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.numberOfRows ?? .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let reminder = presenter?.getObject(at: indexPath) else { return UITableViewCell()}
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: Configuration.cellIdentifier)
        cell.textLabel?.text = reminder.task
        cell.detailTextLabel?.textColor = .lightGray
        switch reminder.notification {
        case .timeInterval(_, let interval):
            cell.detailTextLabel?.text = convertIntervalToString(with: interval)
        case .dateComponents(_, let date):
            if let year = date.year,
               let month = date.month,
               let day = date.day,
               let hour = date.hour,
               let minute = date.minute {
                cell.detailTextLabel?.text = "\(year)-\(month)-\(day) \(hour):\(minute)"
            }
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ReminderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter?.handleDeleteItem(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension ReminderViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            print("UNNotificationDefaultActionIdentifier")
        case UNNotificationDismissActionIdentifier:
            print("UNNotificationDismissActionIdentifier")
        default: break
        }
    }
}

// MARK: - UITextFieldDelegate

extension ReminderViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= .zero
    }
}
