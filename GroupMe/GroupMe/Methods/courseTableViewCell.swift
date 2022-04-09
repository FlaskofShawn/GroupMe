import UIKit

class courseTableViewCell: UITableViewCell {
    
    // For table view cell registration
    static let identiifer = "courseTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "courseTableViewCell", bundle: nil)
    }
    
    // Table view cell components
    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var instructorLabel: UILabel!
    @IBOutlet weak var uncheckButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    // Used to check if the cell has been selected
    var checkCell = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkButton.isHidden = true
        uncheckButton.isHidden = false
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // Check this cell
    @IBAction func uncheckTapped(_ sender: Any) {
        print("Tapped uncheck!")
        uncheckButton.isHidden = true
        checkButton.isHidden = false
        checkCell = true
    }
    
    // Uncheck this cell
    @IBAction func checkTapped(_ sender: Any) {
        print("Tapped check!")
        checkButton.isHidden = true
        uncheckButton.isHidden = false
        checkCell = false
    }
}
