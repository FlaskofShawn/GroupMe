import UIKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate {
    var ref:DatabaseReference?

    // View components
    @IBOutlet weak var signinGoogle: GIDSignInButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        welcomeLabel.textColor = #colorLiteral(red: 0.938929975, green: 0.3449972868, blue: 0.2634683549, alpha: 1)
        backLabel.textColor = #colorLiteral(red: 0.938929975, green: 0.3449972868, blue: 0.2634683549, alpha: 1)
        nextButton.imageEdgeInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        setupTextField()
        errorMessage.isHidden = true
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    // MARK: - Google sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
            return
        }
        
        self.ref = Database.database().reference()
        guard let authentication = user?.authentication else { return }

        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)

        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Firebase sign in error")
                print(error)
                return
            }
            
            print("User is signed in with \(user?.profile.email ?? "")")
   
            guard let authInfor = authResult else {
                return
            }
            
            self.ref?.child("users/\(authInfor.user.uid)").getData { (error, snapshot) in
                if let error = error {
                    print("Error getting data \(error)")
                }
                else if snapshot.exists() {
                }
                else {
                    print("No data available")
                    self.ref?.child("users").child(authInfor.user.uid).setValue(["username": (user?.profile.name ?? "") as String, "Email":(user?.profile.email ?? "") as String, "Courses":[]])
                }
            }
            
            DispatchQueue.main.async {
                print(" Ready to transit the page!!! SignIn VC")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let profileVC = storyboard.instantiateViewController(withIdentifier: "homeView") as? TabBarController else {
                    assertionFailure("couldn't find SignUpView")
                    return
                }
                self.navigationController?.setViewControllers([profileVC], animated: true)
            }
        }
    }
    
    
    // MARK: - action implementation
    
    @IBAction func signinWIthGoogle(_ sender: GIDSignInButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func signupTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let signupVC = storyboard.instantiateViewController(withIdentifier: "SignUpView") as? SignUpVC else {
            assertionFailure("couldn't find SignUpView")
            return
        }
        navigationController?.setViewControllers([signupVC], animated: true)
    }
    
    // Resign the keyboard
    @IBAction func screenTap(_ sender: Any) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    
    // MARK: - action of next button
    
    @IBAction func pressNext(_ sender: Any) {
        guard let email = emailTextField.text else {
            print("need do warning here...")
            return
        }
        
        
        guard let password = passwordTextField.text else {
            print("need do warning here...")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            if (error != nil) {
                self?.errorMessage.text = "Please validate your input."
                self?.errorMessage.isHidden = false
                return
            }
            //print("logined!")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let userProfileVC = storyboard.instantiateViewController(withIdentifier: "homeView") as? TabBarController else {
                assertionFailure("couldn't find SignUpView")
                return
            }
            self?.navigationController?.setViewControllers([userProfileVC], animated: true)
        }
        
    }
    
    
    // MARK: - Text field setting
    
    func setupTextField() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.clearButtonMode = .whileEditing
        passwordTextField.clearButtonMode = .whileEditing
        
        let emailBottomLine = CALayer()
        emailBottomLine.frame = CGRect(x: 0.0, y: emailTextField.frame.height + 7, width: emailTextField.frame.width - 40, height: 1.0)                                            // Bottom line setting
        emailBottomLine.backgroundColor = UIColor.systemGray4.cgColor
        emailTextField.returnKeyType = UIReturnKeyType.done
        emailTextField.borderStyle = UITextField.BorderStyle.none
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        emailTextField.layer.addSublayer(emailBottomLine)           // Added bottom line
        
        let passwordBottomLine = CALayer()
        passwordBottomLine.frame = CGRect(x: 0.0, y: passwordTextField.frame.height + 7, width: passwordTextField.frame.width - 40, height: 1.0)                                        // Bottom line setting
        passwordBottomLine.backgroundColor = UIColor.systemGray4.cgColor
        passwordTextField.returnKeyType = UIReturnKeyType.done
        passwordTextField.borderStyle = UITextField.BorderStyle.none
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true
        passwordTextField.layer.addSublayer(passwordBottomLine)     // Added bottom line
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorMessage.isHidden = true
    }
}

