CineTalk Forum - README

Overview

CineTalk Forum is a Flutter-based forum application that allows users to share posts, upvote/downvote content, and comment on discussions. It is intended to create an interactive community for discussing movies, genres, reviews, and filmmaking topics. The app includes features such as creating new posts, adding comments, voting on posts, and categorizing discussions. Users need to be registered and logged in to fully participate, ensuring user accountability and providing personalized content.

Features

User Registration/Login: Users can register or log in to access all functionalities of the app.

Post Creation: Users can create new posts, including rich text content with media attachments.

Voting System: Users can upvote or downvote posts, but each user can only vote once per post.

Commenting System: Registered users can comment on posts.

CRUD Operations: Users can edit or delete their own posts and comments.

Requirements

You can install the desktop version of the project with our installer provided in the repository. for other options you can build the project directly by setting up flutter explained down below.

Flutter: Ensure you have Flutter SDK installed on your system.

Firebase: The application is integrated with Firebase for authentication and Firestore for database functionality. You need to set up a Firebase project and configure it with the appropriate credentials.

Installation

Clone the repository:

git clone <repository-url>
cd flutter_forum

Install dependencies:
Run the following command to install the required Flutter dependencies:

flutter pub get

Configure Firebase:

Set up a Firebase project.

Follow the official Firebase documentation to add Firebase to your Flutter project.

Replace the default configuration files (google-services.json for Android and GoogleService-Info.plist for iOS) with the ones from your Firebase project.

Run the Application:
To run the application on your local device or simulator, execute:

flutter run

Ensure you have a device connected or an emulator running.

Usage

Home Page: Users can browse posts without logging in but need to be registered and logged in to interact.

Post Actions: Logged-in users can create, edit, or delete their own posts and comments.

Voting: Logged-in users can upvote or downvote posts, with each user allowed only one vote per post.

Notes

The app uses Firebase for backend services like user authentication and Firestore database. Make sure your Firebase project is properly set up to avoid runtime errors.

The voting feature allows users to interact with posts but restricts them to one vote per post for accountability.

License

CineTalk Forum is licensed under the MIT License. See LICENSE for more details.
