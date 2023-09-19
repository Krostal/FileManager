
import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var settings: [Settings] = [
        Settings(name: "Sorting"),
        Settings(name: "Change password")
    ]
    
    fileprivate var isSortingEnabled: Bool {
        get {
            if UserDefaults.standard.value(forKey: sortingKey) == nil {
                UserDefaults.standard.set(true, forKey: sortingKey)
            }
            return UserDefaults.standard.bool(forKey: sortingKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: sortingKey)
        }
    }
    
    fileprivate var sortingKey = "isSortingEnabled"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "presentChangePasswordViewController" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if indexPath.section == 1 {
                    return true
                }
            }
        }
        return false
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        isSortingEnabled.toggle()
        UserDefaults.standard.set(isSortingEnabled, forKey: sortingKey)
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath)
        cell.textLabel?.text = settings[indexPath.section].name
        
        if indexPath.section == 0 {
            let switchView = UISwitch(frame: accessibilityFrame)
            cell.accessoryView = switchView
            switchView.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            switchView.isOn = isSortingEnabled
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if isSortingEnabled {
                return "Ascending sort activated"
            } else {
                return "Descending sort activated"
            }
        } else {
            return "Change your current password"
        }
    }
}
