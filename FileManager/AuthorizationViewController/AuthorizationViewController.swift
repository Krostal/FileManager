import UIKit

class AuthorizationViewController: UIViewController {
    
    enum ButtonState {
        case createPassword
        case enterPassword
        case repeatPassword
    }
    
    private let keychainService = KeychainService()
    
    var passwordsMatch: Bool = false
    
    var buttonState: ButtonState = .createPassword
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var passwordStackView: UIStackView!
    
    @IBOutlet weak var passwordImageView: UIImageView!
    
    @IBOutlet weak var passwordTextField: AuthorizationTextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBAction func doneButtonPressed(_ sender: AuthorizationTextField) {
        sender.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showTabBar" {
            return passwordsMatch
        }
        return false
    }
    
    private func setupView() {
        if keychainService.isPasswordExists {
            buttonState = .enterPassword
            titleLabel.text = "Enter your current password"
        } else {
            buttonState = .createPassword
            titleLabel.text = "Create new password"
        }
        updateButtonTitle()
    }
    
    private func updateButtonTitle() {
        switch buttonState {
        case .createPassword:
            signInButton.setTitle("Create a password", for: .normal)
            passwordTextField.placeholder = "Create new password"
            passwordTextField.text = ""
        case .enterPassword:
            signInButton.setTitle("Enter password", for: .normal)
            passwordTextField.placeholder = "Enter your password"
            passwordTextField.text = ""
        case .repeatPassword:
            signInButton.setTitle("Repeat password", for: .normal)
            passwordTextField.placeholder = "Repeat your password"
            passwordTextField.text = ""
        }
    }
    
    private func showAlert(title: String, message: String, completion: @escaping () -> Void = {}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            self.dismiss(animated: true)
            completion()
        }))
        present(alert, animated: true)
    }
    
    private func enterPassword() {
        guard let enteredPassword = passwordTextField.text else { return }
        if enteredPassword.count > 3 {
            if keychainService.checkPassword(enteredPassword) {
                passwordsMatch = true
            } else {
                showAlert(title: "Error", message: "Incorrect password, try again")
            }
        } else {
            showAlert(title: "Error", message: "Password must contain at least 4 characters")
        }
    }
    
    private func createPassword() {
        guard let newPassword = passwordTextField.text else { return }
        if newPassword.count > 3 {
            keychainService.saveTemporaryPassword(newPassword)
            self.buttonState = .repeatPassword
            updateButtonTitle()
        } else {
            showAlert(title: "Error", message: "Password must contain at least 4 characters")
        }
    }
    
    private func repeatPassword() {
        guard let repeatedText = passwordTextField.text else { return }
        if keychainService.checkTemporaryPassword(repeatedText) {
            keychainService.savePassword(repeatedText)
            keychainService.deleteTemporaryPassword()
            passwordsMatch = true
        } else {
            keychainService.deleteTemporaryPassword()
            showAlert(title: "Error", message: "Passwords do not match") { [weak self] in
                guard let self else { return }
                self.buttonState = .createPassword
                self.updateButtonTitle()
            }
        }
    }
    
    @IBAction func buttonPresed(_ sender: UIButton) {
        switch buttonState {
        case .createPassword:
            createPassword()
        case .enterPassword:
            enterPassword()
        case .repeatPassword:
            repeatPassword()
        }
    }
}


