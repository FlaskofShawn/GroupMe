# Sprint Planning 4

**Members:** 

Weiyi Zhou | Draco Chen | Zhihao Zhang | Xiangyu Li | Yunlin Huang

## Project Summary

GroupMe sends the WeChat QR code and Discord Link of classes to the users. The app contains the following four views: LoginView; ProfileView; CourseSearchView; CourseInfoView. The user can scan their classes on the schedule builder by using the phone camera, and the app will send an email containing the QR codes and Discord links to the user. We have almost completed the login view and profile view, and we are ready to implement the course search view and course info view by connecting with the API calls from the backend. We also implemented the scanning feature with machine learning model and the pattern searching algorithm. What we need to do next is building the API calls based on the information needed from the front end, design the workflow and database interaction for adding classes, and merge our branches to make sure everything works. The challenge will definitely come up when we merge our work together to make a running app.

Check the group schedule details at [Trello board](https://trello.com/b/upsiiTAh/ecs-189e-project)

## Member Task Report

#### Draco Chen

**What I did**

- Implemented expandable table view on the profile view.
- Style the table view cell with card-like effect.
- Implemented swipe-to-delete gesture recognizer on the table view cell.
- Make transition flow between various view controllers.
- Discuss storage and delivery of QR codes and Discord links.
- Merged with another member for the profile view.

**What's the next**

- Implement table view for the course search view.
- Complete the UI design for the course search view and course info view.
- Design the API calls logic with Weiyi.
- Use API calls to extract information from the database and display them on the view.
- Merge my work with other member's branch.

**Challenge I have right now**

- Improve the UI display across the view controllers.
- Use animation on different UI components.

**Commit Link:**

*  [Completed the profile view](https://github.com/ECS189E/project-w21-groupme/commit/a330889112a194fcb7d2da1593425d3a70bde4cc)

#### Weiyi Zhou

**What I did**

- Designed the procedures of inviting user to the course group.
- Discuss storage and delivery of QR codes and Discord links.
- Implemented the scanner feature in the CourseSearchingView.

**What's the next**

- Design the API functions for front-end and back-end connection. 
- Write pseudocode for these APIs.
- Polish the UI design for profile view.

**Challenge we have right now**

- Merge the back-end and front-end work.
- Artistic UI/UX design.

**Commit Link:**

Weiyi:

- [Added camera scan components in SearchCourse View](https://github.com/ECS189E/project-w21-groupme/commit/4d2f2b2c9e3f50ebde14e54369f39928c3513bbf)



#### Xiangyu Li - Front End

**What I did**

- Designed and Upgraded all 6 screens using Balsamiq based on the earlier version draw on the whiteboard
- Reviewed the finished UI Design work(2 screens)
- Wrote a testing plan about how to thoroughly test the whole project before and after the launching stage
- Communicated with other group members about creating new features and deleting old features
- Implemented the scan feature and displayed the output on the screen using Vision framework

**What's the next**

- Implement extracting text in images or photos
- Combine recognization with the camera to scan the picture or photo to reduce user's input and improve user experience
- Reduce the weight of web and server work and make more contributions to the iOS side
- Brainstorm any possible improvement to simplify user input process such as login verification process

**Challenge we have right now**

- The string got from the vision framework is not accurate and exactly same every time
- Extract separate fields from string processed by ML model needs to be familiar with regular expression, which I will focus on
- How to add or remove the components to achieve the functionality as expected and not hurt user experience


**Commit Link:** Researched recognizing text in images and wrote a testing plan about how to thoroughly test the whole project before and after the launching stage. [Added course scan feature in SearchCourse View](https://github.com/ECS189E/project-w21-groupme/commit/a6a3848c065ed325e96548de868394a3994aaf2c)

#### Yunlin Huang - Front End

**What I did**

- Designed and Upgraded all 6 screens using Balsamiq based on the earlier version draw on the whiteboard
- Reviewed the finished UI Design work(2 screens)
- Communicated with professor and TAs about implementation of some features we can potentially include.
- - Communicate with other members to decide the next step for the Milestone 1
- Reconsider the weight of web and server work and the contribubtion of iOS side
- Implement the view controllers of those 6 screens and wire them up
- Implement the profile side bar
- Implement the tab bar

**What's the next**

- Research how to send an email to users
- Create some discord servers for demo

**Challenge we have right now**
- Not sure should send email by application itself or by server side



#### Zhihao Zhang - Backend

**What I did**

- Brainstormed a project idea and discussed it with other members
- Picked 2 ideas out of 5 and combined them as our final project idea
- Designed the basic view controllers. 
- Databased logic designed.

**What's the next**

* Use database knowledge to make stable user performance.
* Design and code Login/Log out/Data collection functionality
* More tasks are under discussing

**Challenge I have right now**

* May need more knowledge to design a database.
* Having trouble accessing course catalog of UCDavis.
* Having trouble accessing UCDavis staffs and students login information.

**Commit Link:** N/A
