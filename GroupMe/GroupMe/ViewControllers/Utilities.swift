import Foundation
import UIKit

class Utilities {
    
static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$")
        return passwordTest.evaluate(with: password)
    }
    
}
