# GroupMe - Find your class group

**Installation tips**: Before you run the program, change your bundle id to your individual choice, e.g. ta_bundle_id. For your first run, you might need to wait to install the database and indexing in the background about 8 to 10 minutes.

**Before you scan:** We manually inputted the course info in our database. Before you scan your schedule builder or a list of class names, please use the following classes, otherwise, the app won't return class not in the database. We support [ECS 150, ECS 153, ASA 002, ECS 162, ECS 152A, ECS 188, ECS 132, MAT 108, PHI 005, PHI 031].

### **Developers**

[Draco Chen](https://github.com/drachenzh)  |  [Weiyi Zhou](https://github.com/WeiyiZ-008)  |  [Xiangyu Li](https://github.com/FlaskofShawn)  |  [Yunlin Huang](https://github.com/RainyFox)  |  [Zhihao Zhang](https://github.com/OnjoujiToki) 

​    <img src="https://github.com/ECS189E/project-w21-groupme/blob/main/team%20picts/20210222232647_200x200_1_100x100.png" style="zoom:33%;" />    	<img src="https://github.com/ECS189E/project-w21-groupme/blob/main/team%20picts/20210222230618_200x200_2_100x100.png" style="zoom:33%;" />	      <img src="https://github.com/ECS189E/project-w21-groupme/blob/main/team%20picts/20210222231733_200x200_1_100x100.png" style="zoom:33%;" />	     <img src="https://github.com/ECS189E/project-w21-groupme/blob/main/team%20picts/20210223100829_100x100.png" style="zoom:33%;" />	       <img src="https://github.com/ECS189E/project-w21-groupme/blob/main/team%20picts/20210222234441_100x100.jpg" style="zoom:33%;" />	 	  

### Project Summary

GroupMe connects users to their class groups by sending the WeChat QR code and Discord link to their email. This app contains the following five views: login view; sign up view; profile view; course search view; course info view. Users will be promoted to login with their email and/ or password. They can search the courses by scanning their schedule builder with the camera or typing the course name in the search bar. They can click on the course cell to review the course information in a pop-up view. Once they add the selected courses, they can refresh the schedule in their profile to review a list of added courses and expand the course cell for more information. The app will email the users with the WeChat QR codes and Discord links of their added courses. The user can then open their email and join the class groups from their preferred social media.

For more information, please review the documentation in the sprint planning folder.

### Member Responsibility

Review our quarter-long progress at [Trello](https://trello.com/b/upsiiTAh/ecs-189e-groupme)

Draco Chen

* Design and implement the front-end components.
* Control the UI/ UX quality of each view.
* Document the progress and reports.
* Collaborate with backend to design the API framework.
* Manage the team workflow and communication with Weiyi.

Weiyi Zhou

- Designed the App features and transition flow.
- Cooperated with Draco to design the UI/UX.
- Came up with idea for magic moment - scan schedule builder.
- Implemented APIs and merged front-end and back-end code.
- Cooperated with Draco to control the project development pace.

Xiangyu Li

* Implemented text recognization of the Majic moment feature: scanning the schedule builder using the Vision framework
* Designed and implemented the text extraction algorithm to process text recognization results based on Swift regular expression
* Processed part of course data for the back end usage and wrote some validation functions to check user inputs
* Designed and Upgraded 3 screens using Balsamiq based on the earlier version draw on the whiteboard
* Wrote a testing plan about how to thoroughly test the whole project before and after the launching stage

Yunlin Huang
* Implement pop up view and its animation
* Implement tab bar
* Implement email template for auto-send email
* Designed html for email   

Zhihao Zhang

* Design and implement Database data structure.
* Authentication of Email-Password and Google.
* Implementing APIs of adding/removing classes, creating new users, etc. Connect database with front-end functionality.
* Adding WeChat pictures and connect with front-end functionality.

### Third Party libraries

GoogleSignIn

Firebase Packages

Firebase - Trigger Email

### Server and APIs

#### Backend Features

- A database to store users' account information and  comments about classes, course list and courses registration details. Multiple tables may required to store different information. Implemented by Firebase Real Time Database and stored as JSON.
- Google Account login and register, restricted with ucdavis.edu student accounts using Firebase.
- Function that regularly sending message regarding campus warnings/news.

#### List of API Calls

- ##### *fetchData()*

  Get current login user object and load his/her corresponding course objects as well.

- ##### *removeClass(courseName: String)*

  By course code, delete course from main menu of user database. Update corresponding course objects with enroll number.

- ##### *addCourses(courses: [String])* 

  Input is array of course codes, add these course to current login user's object. Update corresponding course objects with enroll number.

- ##### *searchCourse(courses: [String])*

  Give a list of course codes from the user input or scanner results, load these course objects from server.

- ##### *sendEmailToUser()*

  Generate the email document with templates, filling with information about user's and his/her adding courses invitation.


### Models

No data model needed for current stage. Will Update if later needed.

### ViewControllers

- **LoginView** :  
  
  User can login with their gmail, perosnal email, or navigate to the sign up view. The app will collect the user entered email address and password, send to the server by API call and do verification.

- **SignUpView**: 

  User will register an account with email verification, and he will be navigated to Home view after succeeding creation. Similar as `LoginView`, API call is needed to create account with entered information to server and database.

- **HomeView**:  

  Display the user added courses. The course list and username will be dynamically loaded based on the login user. The user can click the refresh button to reload the course info. He can also navigate to the `SearchCourserView` by tapping the search course button in the bottom bar.

- **SearchCourserView**
  
  The user can search the classes by typing the class name (e.g. ECS 189E) in the search bar or scanning the their schedule builder with the camera. The app will display the corresponding classess found in the database. The user can check or uncheck the classes before adding the course, and he can click on the class to review the details in a pop-up view. He can then navigate back to the `HomeView` to refresh the course list.

- **CourseInfoView**

  A pop-up view when user click on a class cell in the `SearchCourseView`, a pop-up view will dipslay the details like the date and time of the class.
