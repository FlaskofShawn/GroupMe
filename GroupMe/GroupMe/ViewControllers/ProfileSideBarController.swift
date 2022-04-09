import UIKit

class ProfileSideBarController: UIViewController {
    @IBOutlet weak var dismissArea: UIView!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var account: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap=UITapGestureRecognizer(target: self,
                                       action: #selector(ProfileSideBarController.Dismiss))
        dismissArea.addGestureRecognizer(tap)
        
        sideView.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        sideView.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        sideView.layer.shadowOpacity = 1.5
        sideView.layer.masksToBounds = false
        
    }
    
    @objc func Dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonPress() {
        print("logout")
    }
    
    @IBAction func settingButtonPress(_ sender: Any) {
        print("Setting button press")
    }
}
