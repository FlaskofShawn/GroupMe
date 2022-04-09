import UIKit

class cardTableViewCell: UITableViewCell {
    
    // For table view cell registration
    static let identiifer = "cardTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "cardTableViewCell", bundle: nil)
    }
    
    // Top view and bottom view, hide bottom view first until expand it
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var infoView: UIView! {
        didSet {
            infoView.isHidden = true
        }
    }
    
    // To add shadow on the bottom view
    @IBOutlet weak var shadowView: UIView!
    
    // Table view cell components
    @IBOutlet weak var classCodeLabel: UILabel!
    @IBOutlet weak var instructorNameLabel: UILabel!
    @IBOutlet weak var bookMarkImage: UIImageView!
    @IBOutlet weak var crnCodeLabel: UILabel!
    @IBOutlet weak var lectureDateLabel: UILabel!
    @IBOutlet weak var lectureTimeLabel: UILabel!
    @IBOutlet weak var lectureLocationLabel: UILabel!
    @IBOutlet weak var discDateLabel: UILabel!
    @IBOutlet weak var discTimeLabel: UILabel!
    @IBOutlet weak var discLocationLabel: UILabel!
    @IBOutlet weak var groupNumLabel: UILabel!
    @IBOutlet weak var unitNumLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        instructorNameLabel.layer.masksToBounds = true
        instructorNameLabel.layer.cornerRadius = 5.0
        
        // Top view setting
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        cardView.layer.shadowOpacity = 1.5
        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = 5.0

        // Bottom view setting
        infoView.layer.cornerRadius = 5.0
        infoView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        // Bottom shadow setting
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        shadowView.layer.shadowOpacity = 1.5
        shadowView.layer.masksToBounds = false
        shadowView.layer.cornerRadius = 5.0
        shadowView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        shadowView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
