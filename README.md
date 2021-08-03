Original App Design Project
===

# Geotag

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Geotag is a location based social media app that allows users to share the places they have been to with friends. Posts made by users are tied to specific locations and can contain pictures as well as text descriptions. Each user has a map "feed" where they can view the posts made by themselves and their friends. In this way, users can find new places of interest recommended by friends, connect with friends close by, and share where they have been, whether it be to recommend a restaurant or reminisce on past travels. 

### App Evaluation
- **Category:** Social
- **Mobile:** The app uses several functionalities of mobile devices, namely location services and the camera. Location services are used to detect nearby locations as well as locations visited in the past to tie posts to. They are also used to display the user's current location on the map in relation to posts. The camera is used to take pictures at the locations of the posts which can then be uploaded. Push notifications can also be used to detect when a friend has made a post within a certain distance of the user. 
- **Story:** The app is designed to help users uncover new places of interest both close by and further away through the recommendations of their friends. It also allows users to share what they have been doing and see how friends are doing. 
- **Market:** The market of the app would consist of anyone who enjoys going outside and traveling to new places. Users would also be able to find new friends by viewing public posts made at the same places that they frequent.  
- **Habit:** Users can make posts whenever they want. They do not necessarily have to be at the location when they post (they could have already left) to account for the possibility that they may not have had the opportunity while they were at the location. Users can also spend as much time as they like browsing posts made by friends and public posts.  
- **Scope:** The scope of the app is somewhat narrow, as it focuses on sharing locations that the user has been to, but it can be expanded in the future. For instance, direct messaging, commenting, and liking posts can be implemented later on. 

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Users can make posts tied to locations
* Posts can include images and/or text descriptions
* Users can log in and log out of the app
* Users can find other users through a search
* Users can friend/unfriend other users 
* Users have map feeds that show posts made by their friends and themselves
* List of possible locations to post uses Google Maps SDK to suggest places of interest
* Posts are stored in a database and thus saved between logins 
* Zoom in and out of the map using pinch gestures
* Users can like and comment on other users' posts
* Each user has a profile that shows their posts only 
* App uses a custom image picker to choose photos from the Photo Library and take photos with the camera
* Animations and UI implementation

**Optional Nice-to-have Stories**

* Add friend request system
* Users can either make public posts or private posts (only to friends)
* Ability to add locations not in Google Maps SDK
* Ability to filter posts on map feed by date or location 
* Browse public posts at a given location 
* Direct messaging functionality
* View lists of friends
* Filter posts by genre (i.e. entertainment, food, etc.)

### 2. Screen Archetypes

* Login/Register screen 
   * User can make an account or log into an existing account on this screen
   * First screen to appear when starting the app
   * Does not appear if user has already logged in during a previous session
* Search screen
   * User can search for other users on this screen 
   * Can search using username or name of user 
   * Tapping on a search user brings up their profile screen 
* Profile screen 
    * Displays the properties of a user, such as their number of posts, number of friends and profile picture
    * If they are friends with the current user, can view their posts on a map
    * If not, can only view their public posts
    * Can friend/unfriend users on this screen 
    * User can logout of their account from their user profile screen
* Map feed screen - Stream
    * Shows posts of current user and friends on a map centered around the user's current location
    * Can tap on a location to view posts made at that location 
    * Zoom in and out of map using gestures
* Location post screen - Stream
    * Shows all of the posts made at a specific location
    * Tapping on a specific post brings up the view post screen 
* View post screen - Details
    * Shows the properties of a post, such as the location, photos, and text description of the post 
    * Users will also be able to favorite and comment on posts on this screen 
* Make post screen - Creation
    * Asks the user to select a place of interest which can either be searched for or selected from a list of nearby locations
    * User has option to post pictures or add a text description to the post (or both)
    * Once the post is made, it is uploaded to the database 

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Map feed
* Make post screen
* Search users
* User profile

**Flow Navigation** (Screen to Screen)
* Login/Register screen 
   * Map feed
* Search screen
   * Profiles of other users
* Profile screen 
    * View post screen 
* Map feed screen - Stream
    * Location post screen 
* Location post screen - Stream
    * View post screen
* View post screen - Details
    * Location post screen 
    * Profile screen
* Make post screen - Creation
    * Map feed


## Wireframes
![Wireframes-1 2](https://user-images.githubusercontent.com/41344374/125110904-15303b80-e09a-11eb-90b7-db9ea852ec85.jpg)
![Wireframes-2](https://user-images.githubusercontent.com/41344374/125111151-69d3b680-e09a-11eb-8180-e7b7da7cf712.jpg)


## Schema 

### Models
User
|Property|Type|Description|
|--------|----|-----------|
|username|String|Screen name displayed for user|
|password|String|Password used to sign in|
|tagline|String|Description of user displayed in profile|
|numPosts|Number|Number of posts made by user|
|numFriends|Number|Number of friends of user|
|friends|Array|Array of objectIds of users that are friends with current user|
|likedPosts|Array|Array of objectIds of posts that the user liked|
|profilePicture|File|Profile picture of user|
|pendingFriends|Array|Array of objectIds of users with friend requests to respond to|
|requestsSent|Array|Array of objectIds of users that this user sent a request to (awaiting response)|
|objectId|String|Unique identifier for user (default field)|

Post 
|Property|Type|Description|
|--------|----|-----------|
|location|String|Place ID of Location that post is tied to|
|photos|Array|Array of Files of photos attached to the post|
|caption|String|Text caption of post|
|author|Pointer to User|User that created the post|
|authorUsername|String|Username of author that created the post|
|createdAt|DateTime|Time at which post was created|
|numLikes|Number|Number of users that liked the post|
|private|Boolean|Indicates whether the post is public (visible to everyone) or private (only visible to friends)|
|objectId|String|Unique identifier for post (default field)|

Location
|Property|Type|Description|
|--------|----|-----------|
|name|String|Name of location|
|coordinate|GeoPoint|Geographic coordinate of location|
|numPosts|Number|Number of posts tied to this location|
|placeID|String|ID of location to look up place details|
|usersWithPosts|Array|objectIds of users with posts at this location|
|objectId|String|Unique identifier for location (default field)|

Comment
|Property|Type|Description|
|--------|----|-----------|
|author|Pointer to User|User that made the comment|
|username|String|Username of author of comment|
|text|String|Contents of the comment|
|createdAt|DateTime|Time at which the comment was made|
|postID|String|objectId of post the comment was made on|

### Networking
* Login/Register screen 
   * (Read/GET) Check if the inputted username and password match to an existing user
  ```
  NSString *username = self.usernameField.text;
  NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
        } else {
            NSLog(@"User logged in successfully");
            // go to map feed page
        }
    }];
  ```
   * (Create/POST) Create a new user in the database when signing up
  ```
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User registered successfully");
            // go to map feed page
        }
    }];

  ```
* Search screen
   * (Read/GET) Query users with a username matching the search term
   ```
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"username" equalTo:searchBar.text];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            // display fetched users on screen
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
   ```
* Profile screen 
    * (Read/GET) Display profile information about user 
    ```
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"objectId" equalTo:profile.user];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            // display information about user on screen
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
   ```
    * (Update/PUT) Change profile picture of user
   ```
    UIImage *editedImage = // selected image 
    [self.user setValue:[Post getPFFileFromImage:editedImage] forKey:@"profilePicture"];
    [self.user saveInBackground];
   ```
    * (Update/PUT) Change description of user
   ```
    NSString *newDesc = // new description
    [self.user setValue:newDesc forKey:@"description"];
    [self.user saveInBackground];
   ```
* Map feed screen - Stream
    * (Read/GET) Query locations with posts that are in view of the current map display and show them on the map
   ```
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"longitude" greaterThan: // lower boundary of map on screen ];
    [query whereKey:@"longitude" lessThan: // upper boundary of map on screen ];
    [query whereKey:@"latitude" greaterThan: // lower boundary of map on screen ];
    [query whereKey:@"latitude" lessThan: // upper boundary of map on screen ];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            // display fetched locations on map
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
   ```
* Location post screen - Stream
    * (Read/GET) Query posts that are associated with the chosen location
     ```
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"location" equalTo: // selected location ];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            // display fetched posts on screen
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
   ```
* View post screen - Details
    * (Create/POST) Make a comment on the post
   ```
    Comment *newComment = // Initialize comment's fields
    [newComment saveInBackground];
   ```
    * (Update/PUT) Change the number of likes on a post by liking it
   ```
    [currentPost incrementKey:@"numLikes"];
    [currentPost saveInBackground];
   ```
    * (Delete/DELETE) Unlike a post to remove a like 
    ```
    [currentPost decrementKey:@"numLikes"];
    [currentPost saveInBackground];
   ```
    * (Delete/DELETE) Delete a comment from a post 
   ```
    [comment deleteInBackground];
   ```
* Make post screen - Creation
    * (Create/POST) Make a new post with associated location, photos, and caption
   ```
    Post *newPost = // initialize post with inputted details
    [Post postUserImage:newPost withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Post share failed: %@", error.localizedDescription);
        }
        else {
            NSLog(@"Post shared successfully");
            PFUser *currentUser = [PFUser currentUser];
            [currentUser incrementKey:@"numPosts"];
            [currentUser saveInBackground];
        }
    }];
   ```
