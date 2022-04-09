import UIKit
import Firebase
import FirebaseDatabase

class SignUpVC: UIViewController, UITextFieldDelegate {
    var ref:DatabaseReference?
    
    // View controller components
    @IBOutlet weak var createLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createLabel.textColor = #colorLiteral(red: 0.2391340733, green: 0.5690647364, blue: 0.5953814387, alpha: 1)
        accountLabel.textColor = #colorLiteral(red: 0.2391340733, green: 0.5690647364, blue: 0.5953814387, alpha: 1)
        nextButton.tintColor = #colorLiteral(red: 0.2391340733, green: 0.5690647364, blue: 0.5953814387, alpha: 1)
        signinButton.tintColor = #colorLiteral(red: 0.2391340733, green: 0.5690647364, blue: 0.5953814387, alpha: 1)
        
        setupTextField()
        errorMessage.isHidden = true
    }
    
    // Resign keyboard
    @IBAction func screenTap(_ sender: Any) {
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func validateFileds() -> String? {
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
          passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
          emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                 return "Please fill in all fields."
        }
        let trimedPassword = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if Utilities.isPasswordValid(trimedPassword) == false {
            return "Invalid passowrd."
        }
        return nil
    }
    
    @IBAction func nextTap(_ sender: Any) {
        let signupError = validateFileds()
        if signupError != nil {
            errorMessage.text = signupError
            errorMessage.isHidden = false
        } else {
            guard let email = emailTextField.text else {
                print("need do warning here...")
                return
            }
            
            guard let userName = usernameTextField.text else {
                print("need do warning here...")
                return
            }
            
            guard let password = passwordTextField.text else {
                print("need do warning here...")
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if (error != nil) {
                    print(error)
                    return
                }
                print("created!")
                self.ref = Database.database().reference()
                guard let userRes = authResult else {
                    print("no uid received")
                    return
                }
                self.ref?.child("users").child(userRes.user.uid).setValue(["username": userName,"Email":email])
                self.ref?.child("users").child(userRes.user.uid).child("Courses").setValue([])
            }
             
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginView") as? ViewController else {
                assertionFailure("couldn't find SignUpView")
                return
            }
            navigationController?.setViewControllers([loginVC], animated: true)
        }
    }
    
    @IBAction func signinTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginView") as? ViewController else {
            assertionFailure("couldn't find SignUpView")
            return
        }
        navigationController?.setViewControllers([loginVC], animated: true)
    }
    
    
    // MARK: - Textfield setting
    
    func setupTextField() {
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.clearButtonMode = .whileEditing
        passwordTextField.clearButtonMode = .whileEditing
        
        // Bottom line setting and add bottom line under the text fields.
        // Create a frame with only the bottom line and add sublayer to the textfield
        
        let usernameBottomLine = CALayer()
        usernameBottomLine.frame = CGRect(x: 0.0, y: usernameTextField.frame.height + 7, width: usernameTextField.frame.width - 40, height: 1.0)
        usernameBottomLine.backgroundColor = UIColor.systemGray4.cgColor
        usernameTextField.returnKeyType = UIReturnKeyType.done
        usernameTextField.borderStyle = UITextField.BorderStyle.none
        usernameTextField.autocorrectionType = .no
        usernameTextField.autocapitalizationType = .none
        usernameTextField.layer.addSublayer(usernameBottomLine)
        
        let emailBottomLine = CALayer()
        emailBottomLine.frame = CGRect(x: 0.0, y: emailTextField.frame.height + 7, width: emailTextField.frame.width - 40, height: 1.0)
        emailBottomLine.backgroundColor = UIColor.systemGray4.cgColor
        emailTextField.returnKeyType = UIReturnKeyType.done
        emailTextField.borderStyle = UITextField.BorderStyle.none
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        emailTextField.layer.addSublayer(emailBottomLine)
        
        let passwordBottomLine = CALayer()
        passwordBottomLine.frame = CGRect(x: 0.0, y: passwordTextField.frame.height + 7, width: passwordTextField.frame.width - 40, height: 1.0)
        passwordBottomLine.backgroundColor = UIColor.systemGray4.cgColor
        passwordTextField.returnKeyType = UIReturnKeyType.done
        passwordTextField.borderStyle = UITextField.BorderStyle.none
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true
        passwordTextField.layer.addSublayer(passwordBottomLine)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorMessage.isHidden = true
    }
    
}
