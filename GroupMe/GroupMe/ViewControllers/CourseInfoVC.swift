import UIKit

class CourseInfoVC: UIViewController {
    
    // View controller components
    @IBOutlet weak var courseInfoView: UIView!
    @IBOutlet weak var courseCode: UILabel!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var crn: UILabel!
    @IBOutlet weak var instructor: UILabel!
    @IBOutlet weak var lectureDate: UILabel!
    @IBOutlet weak var lectureTime: UILabel!
    @IBOutlet weak var lectureLocation: UILabel!
    @IBOutlet weak var discDate: UILabel!
    @IBOutlet weak var discTime: UILabel!
    @IBOutlet weak var discLocation: UILabel!
    @IBOutlet weak var groupMember: UILabel!
    
    // button text will dynamically change
    var searchView = SearchCourseVC()
    var courseObj = CourseInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the shadow for the view
        courseInfoView.layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        courseInfoView.layer.shadowOffset = .zero
        courseInfoView.layer.shadowOpacity = 1.5
        courseInfoView.layer.masksToBounds = false
        courseInfoView.layer.cornerRadius = 10.0
        setupLabel()
    }
    
    func setupLabel() -> Void {
        
        // Add space for the course code before displaying it on the view
        courseCode.text = String(courseObj.code.enumerated().map{$0 == 3 ? [" ", $1] : [$1]}.joined())
        courseName.text = courseObj.courseName
        crn.text = courseObj.crn
        instructor.text = courseObj.instructor
        lectureDate.text = courseObj.lecture_date
        lectureTime.text = courseObj.lecture_time
        lectureLocation.text = courseObj.lecture_location
        groupMember.text = String(courseObj.current_enrolled)
    }
    
    @IBAction func swipeToDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapOutsideToDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
