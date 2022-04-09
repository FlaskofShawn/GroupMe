import UIKit
import Vision
import Firebase

class SearchCourseVC: UIViewController, UITableViewDataSource,UITableViewDelegate, UIViewControllerTransitioningDelegate{
    
    var ref: DatabaseReference?
    let email_db = Firestore.firestore()                        // extension for sending email
    var search_course_objects = [CourseInfo]()                  // array for loading table view in searchVC
    var user = UserInfo(courses: [:], email: "", username: "")  // object store user information
    var user_course_names = [String]()                          // array for storing user registred courses name only
    
    // View controller components
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var magnifySymbol: UIImageView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var cameraTakenPhoto: UIImageView!
    @IBOutlet weak var courseListTable: UITableView!
    @IBOutlet weak var scannerButton: UIButton!
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var checkAllButton: UIButton!
    @IBOutlet weak var addClassButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    @IBOutlet var keyboardDismiss: UITapGestureRecognizer!
    
    @IBOutlet weak var instructionLableOr: UILabel!
    @IBOutlet weak var instructionLabelScan: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var request = VNRecognizeTextRequest(completionHandler: nil)
    var courseInfoArray:[String] = []
    var courseNameArray:[String] = []
    var checkAll = false
    var selectedCourseArray:[String] = []
    var mapForSendEmail: [String: [String]] = [:]       // map
    
    let errorMessage_go = "Please enter a valid class name e.g. ECS 150."
    let errorMessage_scan = "Couldn't find any courses on the picture."

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSearchingBar()
        setCheckAullButton()
        setAddClassButton()
        resultView.isHidden = true
        courseListTable.dataSource = self
        courseListTable.register(courseTableViewCell.nib(), forCellReuseIdentifier: courseTableViewCell.identiifer)
        courseListTable.rowHeight = 85
        keyboardDismiss.isEnabled = false
        courseListTable.delegate = self
        self.view.alpha = 1.0
        
        ref = Database.database().reference()
        fetchData()     // processing in the background queue
        
        // Error message setting
        errorMessage.text = errorMessage_go
        errorMessage.isHidden = true
        spinner.isHidden = true
        spinner.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    }
    
// MARK: - API calls implementation and fetch user data
    
    func fetchData() {
        DispatchQueue.global(qos: .background).async {
            if Auth.auth().currentUser != nil {
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
                        
                        user.courses.forEach {
                            self.user_course_names.append($0.key)
                        }
                    } else {
                        print("No course object available.")
                    }
                }
            }
            
        }
    }
    
    
    // MARK: - serach course in the database
    func searchCourse(courses: [String]) {
        // Reinitialize the search_course_object before fetching and appending to the list
        search_course_objects = [CourseInfo]()

        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)
        
        // load the course objects for given courses.
        dispatchQueue.async {
            for (_,item) in courses.enumerated() {
                // call API to fetch the course objects
                self.ref?.child("Courses_info/\(item)").getData { (error, snapshot) in
                    if let error = error {
                        print("Error getting data \(error)")
                    } else if snapshot.exists() {
                        guard let courseInformation = snapshot.value as? NSDictionary else {
                            print("related information")
                            semaphore.signal()
                            return      // TODO: Double check if we need to return here, maybe we should continue and skip this non exists course
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
                        
                        self.search_course_objects.append(course)
                    } else {
                        print("No related information of this course")
                    }
                    semaphore.signal()
                }
            }   // end - for loop
            
            // wait for all the threads to be finish,
            for _ in courses {
                semaphore.wait()
            }
            
            // load found course to table view
            DispatchQueue.main.async {
                self.courseListTable.reloadData()
            }
            
        }  // end - dispatch
    }
    
    
    // MARK: - add courses to the corresponding user
    
    // Input: Courses in the list are all found in the DB, which handle by searchCourse()
    //        The course list maybe changed due to the check and uncheck from the user
    // Further implementation: User shouldn't add the duplicate courses
    func addCourses(courses: [String]) {
        DispatchQueue.global(qos: .background).async {
            // 1st send email to the user with course group links
            for name in courses {
                self.search_course_objects.forEach {
                    if name == $0.code {
                        let str = String($0.code.enumerated().map{$0 == 3 ? [" ", $1] : [$1]}.joined())
                        self.mapForSendEmail[str] = [$0.wechat_link, $0.discord_link]
                    }
                }
            }
            self.sendEmailToUser()  // API call
            
            // 2nd adding each course by update user's and course's info
            if Auth.auth().currentUser != nil {
                for (_, courseName) in courses.enumerated() {
                    // update the courses inside the user's object
                    // TODO: Double check if every user has "Courses" key in object
                    self.ref?.child("users/\(Auth.auth().currentUser?.uid ?? "none")/Courses").updateChildValues([courseName: "Doing"])
                    
                    // update the course info in DB
                    // IMPORTANT: Need to use transaction to prevent multiple user add/delete this course, which may lead to incorrect student number
                    self.ref?.child("Courses_info/\(courseName)/current_users").runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                        if var enrolledNum = currentData.value as? Int /*, let uid = Auth.auth().currentUser?.uid */ {
                            enrolledNum += 1
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
                }    // end - for loop
            }
        }   // end - DispatchQueue
    }
    
    func sendEmailToUser() {
        if Auth.auth().currentUser != nil {
            email_db.collection("mail").addDocument(data: ["to": "\(user.email)",
                                                           "template": ["name": "sendQR",
                                                                        "data": ["name": "\(user.username)",
                                                                                 "msg": "Welcome to GroupMe",
                                                                                 "course": self.mapForSendEmail]]])}
    }
    
    
    // MARK: - UI components reaction when Tapping
    
    // Show the scanner view
    @IBAction func cameraTap(_ sender: Any) {
        resultView.isHidden = true
        scannerView.isHidden = false
    }
    
    // Check all the cell
    @IBAction func checkallTap(_ sender: Any) {
        checkAll = true
        courseListTable.reloadData()
    }
    
    // Add the selected class to the user
    @IBAction func addClassTap(_ sender: Any) {
        let group = DispatchGroup()
            group.enter()

        // Force to load the data before adding the class
        // Append the class to the selectedCourseArray before
        // adding the class to the user
        DispatchQueue.main.async {
            self.selectedCourseArray = []
            self.courseListTable.reloadData()
            group.leave()
        }

            // does not wait. But the code in notify() gets run
            // after enter() and leave() calls are balanced

        group.notify(queue: .main) {
            self.addCourses(courses: self.selectedCourseArray)
            self.selectedCourseArray = []
        }
    }
    
    
    // MARK: - Add Class Button and Check All Button Setting
    func setAddClassButton() {
        // Added gradient color in the add class button
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(hexaRGB: "ff9966")?.cgColor as Any, UIColor(hexaRGB: "ff5e62")?.cgColor as Any]
        gradient.startPoint = CGPoint(x: 0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1, y: 0.0)
        gradient.frame = addClassButton.bounds
        
        gradient.shadowColor = UIColor.gray.cgColor
        gradient.shadowOffset = CGSize(width: 1.0, height: 1.0)
        gradient.shadowOpacity = 1.0
        gradient.masksToBounds = false
        gradient.cornerRadius = 10.0
        
        addClassButton.layer.cornerRadius = 10.0
        addClassButton.layer.insertSublayer(gradient, at: 0)
    }
    
    // Add the bottom line in the checkAll button
    func setCheckAullButton() {
        let checkAllButtomLine = CALayer()
        checkAllButtomLine.frame = CGRect(x: 0.0, y: checkAllButton.frame.height - 3, width: checkAllButton.frame.width + 5, height: 1.0)
        checkAllButtomLine.backgroundColor = UIColor.black.cgColor
        checkAllButton.layer.addSublayer(checkAllButtomLine)
    }
    
    
    // MARK: - Table View Setting
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return search_course_objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = courseListTable.dequeueReusableCell(withIdentifier: courseTableViewCell.identiifer, for: indexPath) as? courseTableViewCell
        
        // Load the information in the view
        cell?.classNameLabel.text = String(search_course_objects[indexPath.row].code.enumerated().map{$0 == 3 ? [" ", $1] : [$1]}.joined())
        cell?.instructorLabel.text = search_course_objects[indexPath.row].instructor
        
        // If checkAll flag, then make all check mark checked
        if checkAll {
            cell?.uncheckButton.isHidden = true
            cell?.checkButton.isHidden = false
            cell?.checkCell = true
        }
        
        // Append the selected class into the list
        if cell?.checkCell == true {
            let courseCode = cell?.classNameLabel.text?.replacingOccurrences(of: " ", with: "") ?? ""
            selectedCourseArray.append(courseCode)
        }
        
        // Uncheck the check mark
        if !checkAll {
            cell?.checkCell = false
            cell?.checkButton.isHidden = true
            cell?.uncheckButton.isHidden = false
        }
        
        return cell ?? UITableViewCell()
    }
    
    // Display the pop-up view when user click on a class cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let courseInfoVC = storyboard.instantiateViewController(withIdentifier: "CourseInfoView") as? CourseInfoVC else {
            assertionFailure("Couldn't find Home VC")
            return
        }
        
        if !search_course_objects.isEmpty {
            courseInfoVC.courseObj = search_course_objects[indexPath.row]
        }
        
        courseInfoVC.modalPresentationStyle = .custom
        courseInfoVC.transitioningDelegate = self
        navigationController?.present(courseInfoVC, animated: true)
    }
    
    
    // MARK: - UIViewControllerTransitioningDelegate implementation 
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = PresentFromDownAnimate()
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = DismissToDownAnimate()
        return transition
    }
    
    
    // MARK: - searching bar setting
    func setSearchingBar() {
        // searchBar background setting
        searchBar.layer.cornerRadius = 25.0
        searchBar.layer.shadowColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        searchBar.layer.shadowOpacity = 1
        searchBar.layer.shadowOffset = .zero
        searchBar.layer.shadowRadius = 3
        searchBar.layer.backgroundColor = UIColor.clear.cgColor
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(hexaRGB: "ff9966")?.cgColor as Any, UIColor(hexaRGB: "ff5e62")?.cgColor as Any]
        gradient.startPoint = CGPoint(x: 0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1, y: 0.0)
        gradient.frame = searchBar.layer.bounds

        gradient.shadowColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        gradient.shadowOffset = CGSize(width: 1.0, height: 1.0)
        gradient.shadowOpacity = 1.0
        gradient.masksToBounds = false
        gradient.cornerRadius = 25.0

        searchBar.layer.cornerRadius = 10.0
        searchBar.layer.insertSublayer(gradient, at: 0)
        
        // Go button setting
        goButton.layer.cornerRadius = 15.0
        goButton.layer.shadowColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        goButton.layer.shadowOpacity = 1
        goButton.layer.shadowOffset = .zero
        goButton.layer.shadowRadius = 2
        
        // magnify Symbol setting
        magnifySymbol.layer.shadowColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        magnifySymbol.layer.shadowOpacity = 1
        magnifySymbol.layer.shadowOffset = .zero
        magnifySymbol.layer.shadowRadius = 1
        
        // add shadow for scanner button
        scannerButton.layer.shadowColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        scannerButton.layer.shadowOpacity = 1
        scannerButton.layer.shadowOffset = .zero
        scannerButton.layer.shadowRadius = 2
        
    }
    
    
    // MARK: - actition for scanner button
    @IBAction func pressScanner(_ sender: Any) {
        errorMessage.isHidden = true
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    
    // MARK: - action for Go button
    // testing for the Course info View transition
    @IBAction func pressGoButton(_ sender: Any) {
        if searchField.text?.replacingOccurrences(of: " ", with: "") == "" {
            errorMessage.text = errorMessage_go
            errorMessage.isHidden = false
            return
        }
        
        search_course_objects = [CourseInfo]()
        
        // Check if user input is valid
        let pattern = "[A-Z]{3}[ ]{1}[0-9]{3}[A-Z]?"
        let regexOptions: NSRegularExpression.Options = []
        let regex = try? NSRegularExpression(pattern: pattern, options: regexOptions)
        guard let searchFieldString = searchField.text else {
            return
        }
        let searchFieldNSS = searchFieldString as NSString
        // Start match
        if ((regex?.firstMatch(in: searchFieldString, range: NSRange(location: 0, length: searchFieldNSS.length))) != nil) {
            // valid then remove space and call searchCourse()
            let inputClass:[String] = [searchField.text?.replacingOccurrences(of: " ", with: "") ?? ""]
            
            searchCourse(courses: inputClass)
        } else {
                // invalid, stop the program.
            errorMessage.text = errorMessage_go
            errorMessage.isHidden = false
            searchField.text = ""
            courseListTable.reloadData()
            return
        }
        
        scannerView.isHidden = true
        resultView.isHidden = false
        view.endEditing(true)
        self.keyboardDismiss.isEnabled = false
    }
    
    
    // MARK: - action implementation for UI components
    @IBAction func beginEnterCourseCode(_ sender: UITextField) {
        if sender.text == "Enter your course code" {
            sender.text = ""
        }
        scannerView.isHidden = true
        self.keyboardDismiss.isEnabled = true
        errorMessage.isHidden = true
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        if searchField.text?.count ?? 0 == 0 {
            scannerView.isHidden = false
            resultView.isHidden = true
        }
        errorMessage.isHidden = true
        self.keyboardDismiss.isEnabled = false
    }

    // set up text recognization
    private func setupTextRecognization(image: UIImage?) {
        var courseInfoString = ""
        request = VNRecognizeTextRequest(completionHandler: {(request, error) in

            guard let results = request.results as? [VNRecognizedTextObservation] else {
                fatalError("Received Invalid Observation")
            }

            for observation in results {
                let topCandidate = observation.topCandidates(1)[0]
                courseInfoString.append(topCandidate.string)
                courseInfoString.append("\n")
                // store each line into courseInfoArray
                self.courseInfoArray.append(topCandidate.string)
            }

            DispatchQueue.main.async {
                self.extractCourseName()
            }

        })

        // add more properties
        request.minimumTextHeight = 0
        request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
        request.recognitionLanguages = ["en_US"]
        request.usesLanguageCorrection = true

        let requests = [request]

        // set request handler
        DispatchQueue.global(qos: .userInitiated).async {
            guard let courseInfoImage = image?.cgImage else {
                fatalError("Missing image to scan")
            }

            let requestHandler = VNImageRequestHandler(cgImage: courseInfoImage, options: [:])
            try? requestHandler.perform(requests)
        }

    }

    private func extractCourseName() {
        courseNameArray = []
        spinner.isHidden = false
        spinner.startAnimating()
        
        // sanity check
        if courseInfoArray.count == 0 {
            fatalError("Fail to get course information")
        }

        let pattern = "([A-Za-z]{3}[ ]*[0-9]{3}[A-Za-z]?)[ ]*[0-9A-Za-z]{3}[ ]*-?[ ]*.*"
        let regexOptions: NSRegularExpression.Options = []
        let regex = try? NSRegularExpression(pattern: pattern, options: regexOptions)

        for courseInfoString in self.courseInfoArray {
            let courseInfoStringNSS = courseInfoString as NSString
            if let extractedString = regex?.firstMatch(in: courseInfoString, range: NSRange(location: 0, length: courseInfoStringNSS.length)) {
                let courseName = courseInfoStringNSS.substring(with: extractedString.range(at: 1))
                let courseNameWithoutSpace = courseName.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
                self.courseNameArray.append(courseNameWithoutSpace)
            }
        }
        
        if courseNameArray.count == 0 {
            errorMessage.text = errorMessage_scan
            errorMessage.isHidden = false
            spinner.stopAnimating()
            spinner.isHidden = true
            return
        }
        
        // Call API funcs to fetch the courses objects and load to Table view
        searchCourse(courses: self.courseNameArray)
        
        spinner.stopAnimating()
        spinner.isHidden = true
        scannerView.isHidden = true
        resultView.isHidden = false
        
        for string in self.courseNameArray {
            print(string)
        }
        
        // Re-initialize the lists
        self.courseNameArray = []
        self.courseInfoArray = []
    }
 
}


// MARK: - implements the function in the UIPicker
extension SearchCourseVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            instructionLabelScan.text = "No picture found!"
            return
        }
        
        // The image has successfully captured.
        // start analysis image from here.
        setupTextRecognization(image: image)
    }
}

extension UIButton
{
    func applyGradient(colors: [CGColor])
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 10.0
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}


// animation classes
class DismissToDownAnimate: NSObject, UIViewControllerAnimatedTransitioning{
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
        let finalFrameForVC = fromViewController.view.frame.offsetBy(dx:0, dy: bound.height)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {fromViewController.view.alpha = 0.5
            fromViewController.view.frame = finalFrameForVC
        }, completion: {finished in
            transitionContext.completeTransition(true)
            toViewContorller.view.alpha = 1.0
        })
    }
}


class PresentFromDownAnimate: NSObject, UIViewControllerAnimatedTransitioning {
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
        toViewContorller.view.frame = finalFrameForVC.offsetBy(dx: 0, dy: bounds.height)
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
