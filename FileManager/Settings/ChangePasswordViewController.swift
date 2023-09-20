import UIKit

class ChangePasswordViewController: UIViewController {
    
    private let keychainService = KeychainService()
    
    @IBOutlet weak var currentPasswordLabel: UILabel!
    
    @IBOutlet weak var currentPasswordTextField: AuthorizationTextField!
    
    @IBOutlet weak var newPasswordLabel: UILabel!
    
    @IBOutlet weak var newPasswordTextField: AuthorizationTextField!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPasswordTextField.delegate = self
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            self.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }
    
    @IBAction func doneButtonPressed(_ sender: AuthorizationTextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let currentPassword = currentPasswordTextField.text else { return }
        guard let newPassword = newPasswordTextField.text else { return }
        
        if newPassword == currentPassword {
            showAlert(title: "Password change error", message: "The password must be different from the current one")
        }
        
        if newPassword.count > 3 && keychainService.isPasswordExists {
            keychainService.deletePassword()
            keychainService.savePassword(newPassword)
            showSuccessAlert(title: "Success", message: "Password successfully changed")
        } else {
            showAlert(title: "Password length", message: "New password must contains at least 4 characters")
        }
    }
}
        
extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let enteredPassword = currentPasswordTextField.text else { return }
        if enteredPassword.count < 4 {
            showAlert(title: "Password length", message: "Password contains at least 4 characters")
        } else if !keychainService.checkPassword(enteredPassword) {
            showAlert(title: "Password mismatch", message: "Incorrect password! Please try again")
        }
    }
}
