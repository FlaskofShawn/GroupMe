import UIKit
import Firebase

// Course info structure initial constructor
struct CourseInfo {
    var code: String = ""
    var courseName: String = ""
    var crn: String = ""
    var unit: Int = 4
    var current_enrolled: Int = 3
    var id: Int = 0
    var instructor: String = ""
    var lecture_date: String = ""
    var lecture_location: String = ""
    var lecture_time: String = ""
    var discussion_date: String = ""
    var discussion_location: String = ""
    var dicussion_time: String = ""
    var discord_link: String = ""
    var wechat_link: String = ""
    
}

// User info structure initial constructor
struct UserInfo {
    var courses: [String: String] = [:]
    var email: String = ""
    var username: String = ""
}

class HomeVC: UIViewController, UITableViewDataSource, UIViewControllerTransitioningDelegate, UITableViewDelegate {
    
    @IBOutlet weak var classTabelView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    // cache to store user's data and courses information
    var ref: DatabaseReference?
    var user = UserInfo()                                       // array for loading user_info in HomeVC
    var user_course_names = [String]()                          // array for storing user registred courses name only
    var user_course_objects = [CourseInfo]()                    // arrray for loading table view in HomeVC
    
    var selectedCellIndexPath: IndexPath?
    // Color for the bookmark image on the table view cell
    var cellColors = ["AAC9CE","B6B4C2","C9BBCB","E5C1CD","F3DBCF", "85CBCC", "A8DEE0", "F9E2AE", "FBC78D", "A7D676"]

    @IBOutlet weak var refreshButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        fetchData()             // fetch data from server & load course info
        
        classTabelView.dataSource = self
        classTabelView.delegate = self
        classTabelView.register(cardTableViewCell.nib(), forCellReuseIdentifier: cardTableViewCell.identiifer)
        classTabelView.separatorColor = UIColor.clear
        usernameLabel.layer.masksToBounds = true
        usernameLabel.layer.cornerRadius = 10.0
        
        setBackgroundImage()
    }
    
    @IBAction func refreshTable(_ sender: Any) {
        fetchData()             // // fetch data from server & load course info
    }
    
    
    // MARK: - fetch data from server
    func fetchData() {
        
        user_course_names = [String]()
        user_course_objects = [CourseInfo]()
        
        print("Fetching the data!!")
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)
            
        dispatchQueue.async {
            if Auth.auth().currentUser != nil {
            // 1st get the user object and his/her registeredcourse_names
                self.ref?.child("users/\(Auth.auth().currentUser?.uid ?? "none")").getData { (error, snapshot) in
                if let error = error {
                    print("Api Error: can't get data - \(error)")
                } else if snapshot.exists() {
                    guard let userObject = snapshot.value as? NSDictionary else {
                        print("No value")
                        return
                    }
                    let user = UserInfo(courses: userObject["Courses"] as? [String: String] ?? [:],
                                        email: userObject["Email"] as? String ?? "",
                                        username: userObject["username"] as? String ?? "")
                    
                    // sync the global user[]
                    DispatchQueue.main.async {
                        self.user = user
                    }
                    
                    print(" *** user's email: \(user.email)")

                    user.courses.forEach {
                        self.user_course_names.append($0.key)
                    }
                } else {
                    print("No course object available.")
                }
                semaphore.signal()
            }
            semaphore.wait()

            // 2nd load the course objects for these courses.
            for (_,item) in self.user_course_names.enumerated() {
                print("Test in dispatch, names[] = \(item)")
                // call API to fetch the course objects
                self.ref?.child("Courses_info/\(item)").getData { (error, snapshot) in
                    if let error = error {
                        print("Error getting data \(error)")
                    }
                    else if snapshot.exists() {
                        guard let courseInformation = snapshot.value as? NSDictionary else {
                            print("related information")
                            return
                        }
                        
                        var course = CourseInfo(code: courseInformation["course_code"] as? String ?? "",
                                                courseName: courseInformation["course_name"] as? String ?? "",
                                                crn: courseInformation["crn"] as? String ?? "",
                                                unit: courseInformation["unit"] as? Int ?? 0,
                                                current_enrolled: courseInformation["current_users"] as? Int ?? 0,
                                                id: courseInformation["id"] as? Int ?? -1,
                                                instructor: courseInformation["instructor"] as? String ?? "",
                                                lecture_date: courseInformation["lecture_date"] as? String ?? "",
                                                lecture_location: courseInformation["lecture_location"] as? String ?? "",
                                                lecture_time: courseInformation["lecture_time"] as? String ?? "",
                                                discussion_date: courseInformation["discussion_date"] as? String ?? "",
                                                discussion_location: courseInformation["discussion_location"] as? String ?? "",
                                                dicussion_time: courseInformation["dicussion_time"] as? String ?? "",
                                                discord_link: courseInformation["discord_link"] as? String ?? "",
                                                wechat_link: courseInformation["wechat_link"] as? String ?? "")

                        self.user_course_objects.append(course)
                    }
                    else {
                        print("No related information of this course")
                    }
                    semaphore.signal()
                }
            }
            // wait for all the threads to be finish
            for _ in self.user_course_names {
                semaphore.wait()
            }
            
            DispatchQueue.main.async {
                self.classTabelView.reloadData()
            }
        }}
    }
    
    
    // delete course from the list
    func removeClass(courseName:String) {
        DispatchQueue.global(qos: .background).async {
            if Auth.auth().currentUser != nil {
                // update user information
                self.ref?.child("users/\(Auth.auth().currentUser?.uid ?? "none")/Courses/\(courseName)").removeValue()

                // update the course info in DB
                // IMPORTANT: Need to use transaction to prevent multiple user add/delete this course, which may lead to incorrect student number
                self.ref?.child("Courses_info/\(courseName)/current_users").runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                    if var enrolledNum = currentData.value as? Int /*, let uid = Auth.auth().currentUser?.uid */ {
                        enrolledNum -= 1
                        // set value and return success status
                        currentData.value = enrolledNum
                        return TransactionResult.success(withValue: currentData)
                    }
                    return TransactionResult.success(withValue: currentData)
                }) { (error, committed, snapshot) in
                    if let error = error {
                        print("Error when update course info - \(error.localizedDescription)")
                    }
                }
        }}
    }
    
    
    // MARK: - UI Setup
    
    // Setup background image view
    func setBackgroundImage() -> Void {
        // Added gradient color to the background view
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(hexaRGB: "ff9966")?.cgColor as Any, UIColor(hexaRGB: "ff5e62")?.cgColor as Any]
        gradient.startPoint = CGPoint(x: 0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1, y: 0.0)
        gradient.frame = imageView.layer.bounds
        imageView.layer.backgroundColor = UIColor.clear.cgColor
        imageView.layer.cornerRadius = 20
        imageView.layer.insertSublayer(gradient, at: 0)
    }
    
    
    // MARK: - Table View Setup
    
    // Return number of cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user_course_objects.count
    }
    
    // Construct the appearance of each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = classTabelView.dequeueReusableCell(withIdentifier: cardTableViewCell.identiifer, for: indexPath) as? cardTableViewCell
        
        // Assign value to table cell while the index is not out of range
        cell?.classCodeLabel.text = String(user_course_objects[indexPath.row].code.enumerated().map { $0 == 3 ? [" ", $1] : [$1]}.joined())
        cell?.instructorNameLabel.text = user_course_objects[indexPath.row].instructor
        cell?.crnCodeLabel.text = user_course_objects[indexPath.row].crn
        cell?.lectureDateLabel.text = user_course_objects[indexPath.row].lecture_date
        cell?.lectureTimeLabel.text = user_course_objects[indexPath.row].lecture_time
        cell?.lectureLocationLabel.text = user_course_objects[indexPath.row].lecture_location
        cell?.groupNumLabel.text = String(user_course_objects[indexPath.row].current_enrolled)
        
        // Make different color for the book mark image
        cell?.bookMarkImage.tintColor = UIColor(hexaRGB: cellColors[indexPath.row])
        
        // Slide in animation
        let animation = AnimationFactory.makeSlideIn(duration: 0.6, delayFactor: 0.05)
        let animator = Animator(animation: animation)
        animator.animate(cell: cell ?? UITableViewCell(), at: indexPath, in: tableView)
        
        return cell ?? UITableViewCell()
    }
    
    // Keep track of the current index path
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath {
                selectedCellIndexPath = nil
            } else {
                selectedCellIndexPath = indexPath
            }
        
        classTabelView.beginUpdates()
        classTabelView.endUpdates()
        classTabelView.deselectRow(at: indexPath, animated: false)
    }
    
    // Expand the table view cell for class description when the cell is tapped
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = classTabelView.cellForRow(at: indexPath) as? cardTableViewCell
        
        // Expand the description cell
        if selectedCellIndexPath == indexPath {
            // Only round the corners for top left and top right corner for the top view
            cell?.cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell?.infoView.isHidden = false
            cell?.shadowView.isHidden = false
            return 180
        } else {    // Hide the description cell
            // Round all corners for the top view
            cell?.cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell?.infoView.isHidden = true
            cell?.shadowView.isHidden = true
            return 90
        }
    }
    
    // Determine the table view cell editing style as swipe-to-delete
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Implement the swipe-to-delete for table view cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let cell = classTabelView.cellForRow(at: indexPath) as? cardTableViewCell
        if editingStyle == .delete {
            classTabelView.beginUpdates()
            // if the course name match the class in the user_course_objects
            // Remove the element in user_course_objects and remove that class from table view
            for (index, course) in user_course_objects.enumerated() {
                if course.code == cell?.classCodeLabel.text?.replacingOccurrences(of: " ", with: "") ?? "" {
                    user_course_objects.remove(at: index)
                    user_course_names.remove(at: index)
                    removeClass(courseName: course.code)
                    break
                }
            }
            classTabelView.deleteRows(at: [indexPath], with: .fade)
            classTabelView.endUpdates()
        }
    }
    
    
    // MARK: - Side Bar View
    
    @IBAction func MenuButtonPress() {
        let storyboard = UIStoryboard(name: "ProfileSideBar", bundle: nil)
        guard let profileMenuView = storyboard.instantiateViewController(withIdentifier: "profileSideBar") as? ProfileSideBarController else {
            assertionFailure("Couldn't find VC")
            return
        }
        profileMenuView.modalPresentationStyle = .custom
        profileMenuView.transitioningDelegate = self
        present(profileMenuView, animated: true, completion: nil)
    }
    
    
    // MARK: - Implement UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = PresentFromLeftAnimate()
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = DismissToLeftAnimate()
        return transition
    }
}


class PresentFromLeftAnimate: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from)
        else{
            assertionFailure("Cannot find fromViewController")
            return
        }
        guard let toViewContorller = transitionContext.viewController(forKey: .to)
        else {
            assertionFailure("Cannot find toViewController")
            return
        }
        let finalFrameForVC = transitionContext.finalFrame(for: toViewContorller)
        let bounds = UIScreen.main.bounds
        let containerView = transitionContext.containerView
        toViewContorller.view.frame = finalFrameForVC.offsetBy(dx: -bounds.width, dy: 0)
        containerView.addSubview(toViewContorller.view)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations:{
            fromViewController.view.alpha = 0.5
            toViewContorller.view.frame = finalFrameForVC
        },
        completion: {
            finished in
            transitionContext.completeTransition(true)
            fromViewController.view.alpha = 0.5
        })
    }
}


class DismissToLeftAnimate: NSObject, UIViewControllerAnimatedTransitioning{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from)
        else{
            assertionFailure("Cannot find fromViewController")
            return
        }
        guard let toViewContorller = transitionContext.viewController(forKey: .to)
        else {
            assertionFailure("Cannot find toViewController")
            return
        }
        let bound = UIScreen.main.bounds
        let finalFrameForVC = fromViewController.view.frame.offsetBy(dx: -bound.width, dy: 0)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {fromViewController.view.alpha = 0.5
            fromViewController.view.frame = finalFrameForVC
        }, completion: {finished in
            transitionContext.completeTransition(true)
            toViewContorller.view.alpha = 1.0
        })
    }
}


// MARK: - Added the ability to parse color hex string

// The color hex below are learned from the online implementation

extension UIColor {
    convenience init?(hexaRGB: String, alpha: CGFloat = 1) {
        var chars = Array(hexaRGB.hasPrefix("#") ? hexaRGB.dropFirst() : hexaRGB[...])
        switch chars.count {
        case 3: chars = chars.flatMap { [$0, $0] }
        case 6: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[0...1]), nil, 16)) / 255,
                green: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                 blue: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                alpha: alpha)
    }

    convenience init?(hexaRGBA: String) {
        var chars = Array(hexaRGBA.hasPrefix("#") ? hexaRGBA.dropFirst() : hexaRGBA[...])
        switch chars.count {
        case 3: chars = chars.flatMap { [$0, $0] }; fallthrough
        case 6: chars.append(contentsOf: ["F","F"])
        case 8: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[0...1]), nil, 16)) / 255,
                green: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                 blue: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                alpha: .init(strtoul(String(chars[6...7]), nil, 16)) / 255)
    }

    convenience init?(hexaARGB: String) {
        var chars = Array(hexaARGB.hasPrefix("#") ? hexaARGB.dropFirst() : hexaARGB[...])
        switch chars.count {
        case 3: chars = chars.flatMap { [$0, $0] }; fallthrough
        case 6: chars.append(contentsOf: ["F","F"])
        case 8: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                green: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                 blue: .init(strtoul(String(chars[6...7]), nil, 16)) / 255,
                alpha: .init(strtoul(String(chars[0...1]), nil, 16)) / 255)
    }
}


// MARK: - Animation implementation for table view

// The animation implementation below was learned from online
typealias Animation = (UITableViewCell, IndexPath, UITableView) -> Void

final class Animator {
    private var hasAnimatedAllCells = false
    private let animation: Animation

    init(animation: @escaping Animation) {
        self.animation = animation
    }

    func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        guard !hasAnimatedAllCells else {
            return
        }

        animation(cell, indexPath, tableView)

        hasAnimatedAllCells = tableView.isLastVisibleCell(at: indexPath)
    }
}

enum AnimationFactory {
    static func makeFadeAnimation(duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, _ in
            cell.alpha = 0

            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                animations: {
                    cell.alpha = 1
            })
        }
    }
    
    static func makeMoveUpWithBounce(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, tableView in
            cell.transform = CGAffineTransform(translationX: 0, y: rowHeight)

            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 0.1,
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }
    }
    
    static func makeMoveUpWithFade(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, _ in
            cell.transform = CGAffineTransform(translationX: 0, y: rowHeight / 2)
            cell.alpha = 0

            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
                    cell.alpha = 1
            })
        }
    }
    
    static func makeSlideIn(duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, tableView in
            cell.transform = CGAffineTransform(translationX: tableView.bounds.width, y: 0)

            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }
    }
}

extension UITableView {
    func isLastVisibleCell(at indexPath: IndexPath) -> Bool {
        guard let lastIndexPath = indexPathsForVisibleRows?.last else {
            return false
        }

        return lastIndexPath == indexPath
    }
}
