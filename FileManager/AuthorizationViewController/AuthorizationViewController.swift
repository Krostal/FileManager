import UIKit

class AuthorizationViewController: UIViewController {
    
    enum ButtonState {
        case createPassword
        case enterPassword
        case repeatPassword
    }
    
    var hasPassword: Bool = false
    var passwordIsValid: Bool = false
    
    var firstPassword: String = ""
    var secondPassword: String = ""
    
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
            return passwordIsValid
        }
        return false
    }
    
    private func setupView() {
        titleLabel.text = "Has password: \(hasPassword)"
        updateButtonTitle()
    }
    
    private func updateButtonTitle() {
        switch buttonState {
        case .createPassword:
            signInButton.setTitle("Create a password", for: .normal)
            passwordTextField.placeholder = "Create new password"
        case .enterPassword:
            signInButton.setTitle("Enter password", for: .normal)
            passwordTextField.placeholder = "Enter your password"
        case .repeatPassword:
            signInButton.setTitle("Repeat password", for: .normal)
            passwordTextField.placeholder = "Repeat your password"
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            self.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }
    
    private func createPassword() {
        if let newPassword = passwordTextField.text {
            firstPassword = newPassword
        }
        if firstPassword.count > 3 {
            buttonState = .repeatPassword
            updateButtonTitle()
            passwordTextField.text = ""
        } else {
            showAlert(title: "Error", message: "Password must contain at least 4 characters")
        }
    }
    
    private func enterPassword() {
    }
    
    
    private func repeatPassword() {
        if let repeatedText = passwordTextField.text {
            secondPassword = repeatedText
        }
        if secondPassword == firstPassword {
            passwordIsValid = true
        } else {
            showAlert(title: "Error", message: "Passwords do not match")
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


