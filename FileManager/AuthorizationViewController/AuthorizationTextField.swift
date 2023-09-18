import UIKit

@IBDesignable
class AuthorizationTextField: UITextField {
    
    @IBInspectable var borderColor: UIColor = .systemRed {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 16 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
        
    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
}


