# Sprint Planning 5

**Members:** 

Weiyi Zhou | Draco Chen | Zhihao Zhang | Xiangyu Li | Yunlin Huang

## Project Summary

GroupMe helps students connect their class groups by sending the WeChat QR code and Discord link to their email. The app contains the following four views: login view; profile view; course search view; course info view. They can search the courses by scanning the schedule builder with the camera or typing the course name in the search bar. After adding the courses, they will see a list of the added courses on the dashboard which they can expand for more details. They will also receive an email that contains the WeChat QR code and Discord link of their added courses. The front-end are mostly completed with a smooth flow in the app. We used the OCR technology to scan a picture and extract the keyword using string pattern matching. We then search our database to return the specific query. All group links are pre-created manually in the database, but we plan to apply web-scraping and APIs to load class information into the database and create group links automatically after the quarter.

Check the group schedule details at [Trello board](https://trello.com/b/upsiiTAh/ecs-189e-project)

## Member Task Report

#### Draco Chen

**What I did**

- Right-to-left animation for the table view in the profile view
- Applied the back-end API to load data into the UI view.
- Designed and polished UI for both the profile view and the course search view.
- Fixed bugs that caused wrong display on the front-end, e.g. delete class, class info display.
- Tested the app and managed part of the merging with backend.

**What's the next**

- Fix the bug that caused overlapping display on the course search view when the user scan multiple times.
- Document the project and discuss future improvement with more features.

**Challenge I have right now**
Fix the bugs that remain on the UI display.

**Commit Link:**

*  [Polished the UI views](https://github.com/ECS189E/project-w21-groupme/commit/f134065a27437fd0f2d6036c18c19f83af41a11d)
*  [Fixed bug of unmatched cell num when delete](https://github.com/ECS189E/project-w21-groupme/commit/efb0fd5881e1ed97035ba7ba434d2bef97eb326b)
*  [Degbug the table view in search course view](https://github.com/ECS189E/project-w21-groupme/commit/db3ad55442ad4e740838a09cc25bbad4f8b84527)
*  [Used API on home, search course, course info views](https://github.com/ECS189E/project-w21-groupme/commit/48a6a507cd2701ac130d3019bb326600d168e33a)
*  [Updated API usage on fetchData() and removeClass()](https://github.com/ECS189E/project-w21-groupme/commit/2f31b143753dcab09f439a7fb5853e3ef4dfd149)



#### Weiyi Zhou 

**What I did**

- Revised the APIs implementation, support fully connection between front-end and back-end
- Implemented the Email sender function with Trigger Email extension. Generate corresponding content and send to user.
- Debug the information loading problem in the front-end
- Merged all front-end and back-end works
- Did high-intensity tests for entire program.

**What's the next**

- Fixed the minor bug in loading information to TableView

**Challenge we have right now**

- Get all the courses information from the schedule builder and store in our database
- Figure out a way to build group in third party platform automatically instead of manually creating the group.

**Commit Link:**

Weiyi:

- [APIs function implementation]([finish SearchCourse func · ECS189E/project-w21-groupme@f1d940c (github.com)](https://github.com/ECS189E/project-w21-groupme/commit/f1d940cf9396ee0f3c2e5006e267103711325736))
- [Merge front-end and back-end](https://github.com/ECS189E/project-w21-groupme/commit/bf41af76353475a4ebf137bdaf2c6c33d3192f5a)
- [Email sending feature implementation](https://github.com/ECS189E/project-w21-groupme/commit/c1baebe7edd54bc23d138c384302ab368e543f0f)



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
- Research how to send an email to users
- Create some discord servers for demo

**What's the next**

- What to put on profile view and settings view

- Make smooth transition animation when switching tabs

**Challenge we have right now**

- May need to abandon the tab controller

#### Xiangyu Li - Front End

**What I did**

- Upgraded the text recognization accuracy and introduced the text automatic correction
- Improve the text recognization speed using different dispatch queues
- Designed and implemented the text match and extraction algorithm
- Tested the scan course feature thoroughly
- Prepared part of the corresponding course data for the back end
- Wrote a validation function to check user input
- Communicated with other group members about the future plan


**What's the next**

- Do final tests to find any potential problems
- Consider adding more options for users to scan courses, which might be Canvas Page.


**Challenge we have right now**

- Get all the course information on UC Davis Schedule Builder
- How to let the user create the first QR code and Discord link



**Commit Link:** 

* [Finished and tested HomeView and ScanCourseView addingspace, user input capitalization and validation, and mapForSendEmail](https://github.com/ECS189E/project-w21-groupme/commit/6e7b281ecd23c9738d88f432357342d9e56294be)
* [Merge Scan and Extraction Feature into Backend](https://github.com/ECS189E/project-w21-groupme/commit/7df3242b5fd5d0d1016dec8cdbf7aa0c1a1d1289)
* [Added course scan feature in SearchCourse View](https://github.com/ECS189E/project-w21-groupme/commit/a6a3848c065ed325e96548de868394a3994aaf2c)





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
