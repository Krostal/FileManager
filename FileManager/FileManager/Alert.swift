
import UIKit

public struct Alert {
    
    typealias NameFormatHandler = (String?) -> Void
    
    static let allowedCharacterSet: CharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
    static let nameFormatErrorMessage: String = "Name contains invalid characters"
    
    func setName(on viewController: UIViewController,
                 title: String,
                 message: String,
                 placeholder: String,
                 allowedCharacterSet: CharacterSet = allowedCharacterSet,
                 nameFormatErrorMessage: String = nameFormatErrorMessage,
                 completion: @escaping NameFormatHandler
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = placeholder
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [ weak alert ] _ in
            guard let textField = alert?.textFields?.first else {
                completion(nil)
                return
            }
            let inputText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let enteredName = inputText, !enteredName.isEmpty, allowedCharacterSet.isSuperset(of: CharacterSet(charactersIn: enteredName)) {
                completion(enteredName)
            } else {
                let errorAlert = UIAlertController(title: "Error", message: nameFormatErrorMessage, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.setName(on: viewController, title: title, message: message, placeholder: placeholder, completion: completion)
                }))
                viewController.present(errorAlert, animated: true)
            }
        }))
        
        viewController.present(alert, animated: true, completion: nil)
        
    }
}
