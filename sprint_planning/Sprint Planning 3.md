# Sprint Planning 3

**Members:** 

Weiyi Zhou | Draco Chen | Zhihao Zhang | Xiangyu Li | Yunlin Huang

## Project Summary

GroupMe helps colleges students find and join the online group on WeChat or Discord for their classes. This app contains the following four views: LoginView; ProfileView; CourseSearchView; CourseInfoView. Users can login the app using one of their Google, Facebook, GitHub accounts, and they will see a list of the added courses on the profile view. When the user searches for a class in the course search view, he can use the phone camera to scan his courses on either schedule builder or Canvas. The app will retrieve the corresponding class information from the database and return the result to the search list. The user can review the class information, add the class to his profile view, or ask for the online group link. The app will return the picture of the QR code for WeChat or a Discord link on a pop-up view for the user to save and connect to the online groups later.

Check the group schedule details at [Trello board](https://trello.com/b/upsiiTAh/ecs-189e-project)

## Member Task Report

#### Weiyi Zhou / Draco Chen - UI Design, Front End

**What we did**

- Announced new features for the app and communicate with the team for the new direction.
- Brainstormed ideas to predict the user's schedule without having the user to type in their classes, improving user experience on course search.
- Complete the UserPorfileView and the CourseInfoView
  - Draco worked on the course display on the user profile view.
  - Weiyi worked on the course info layout on the course info view. Implemented the scanner feature in the CourseSearchingView.
- Manage the transition flow among view controllers.

**What's the next**

- Implement swipe to delete gesture on the table view cell on profile view
- Use the default data and display different user info dynamically on the views.
- Start working on scanning feature with machine model and communication with backend.

**Challenge we have right now**

- Dynamically display the content based on the user information.
- Artistic UI/UX design.
- Accurately extract course name from the user token photo on Schedule Builder.

**Commit Link:**

Draco:

*  [Expandable table view cell with card style](https://github.com/ECS189E/project-w21-groupme/commit/1f549536f3a99c5d947fd14b5b01eb34b958218f)

Weiyi:

- [Added camera scan components in SearchCourse View](https://github.com/ECS189E/project-w21-groupme/commit/4d2f2b2c9e3f50ebde14e54369f39928c3513bbf)

<br/>
<br/>

#### Yunlin Huang - Front End

**What I did**

- Designed and Upgraded all 6 screens using Balsamiq based on the earlier version draw on the whiteboard
- Reviewed the finished UI Design work(2 screens)
- Communicated with professor and TAs about implementation of some features we can potentially include.
- - Communicate with other members to decide the next step for the Milestone 1
- Reconsider the weight of web and server work and the contribubtion of iOS side
- Implement the view controllers of those 6 screens and wire them up
- Implement the profile side bar

**What's the next**

- Review the remaining draft of the view controllers and decide if all members can accept the design work and styles this 
    Friday
- Implement more features on profile side bar
- Implement the buttom navigation bar
- Implement the top navigation bar

**Challenge we have right now**
- Decide the way of transitions between different views
- How to add or remove the components to achieve the functionality as expected and not hurt user experience
- What should be on the buttom navigation bar 

**Commit Link:** Designed and Upgraded all 6 screens using Balsamiq based on the earlier version draw on the whiteboard. 
<br/>
<br/>

#### Xiangyu Li - Front End

**What I did**

- Researched recognizing text in images or photos
- Designed and Upgraded all 6 screens using Balsamiq based on the earlier version draw on the whiteboard
- Wrote a testing plan about how to thoroughly test the whole project before and after the launching stage
- Communicated with other group members about creating new features and deleting old features

**What's the next**
- Implement recognizing text in images or photos 
- Combine recognization with the camera to scan the picture or photo to reduce user's input and improve user experience
- Reduce the weight of web and server work and make more contributions to the iOS side
- Brainstorm any possible improvement to simplify user input process such as login verification process

**Challenge I have right now**

- The ML model needs too much disk space, which is more than 200MB
- Extract separate fields from string processed by ML model needs to be familiar with regular expression, which I will focus on
- How to add or remove the components to achieve the functionality as expected and not hurt user experience

**Commit Link:** Researched recognizing text in images and wrote a testing plan about how to thoroughly test the whole project before and after the launching stage.   
<br/>
<br/>


#### Zhihao Zhang - Backend

**What I did**

- Brainstormed a project idea and discussed it with other members
- Picked 2 ideas out of 5 and combined them as our final project idea
- Designed the basic view controllers. 
- Databased logic designed.
- Firebased Connected
- Database Backend established
- Google Login implementation
- Database of Users and Courses designed
- Email/Password Implementation

**What's the next**

* Api of Database implementation 
* Message functionality implementation

**Challenge I have right now**

* Restricting Google login to UCDavis

**Commit Link:** N/A
