Original App Design Project
===

# I'm Here! (Name not finalized)

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
I'm Here! is a location based social media app that allows users to share the places they have been to with friends. Posts made by users are tied to specific locations and can contain pictures as well as text descriptions. Each user has a map "feed" where they can view the posts made by themselves and their friends. In this way, users can find new places of interest recommended by friends, connect with friends close by, and share where they have been, whether it be to recommend a restaurant or reminisce on past travels. 

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
* Animations and UI implementation

**Optional Nice-to-have Stories**

* Users can either make public posts or private posts (only to friends)
* Users can favorite and comment/reply to other users' posts
* Ability to add locations not in Google Maps SDK
* Ability to filter posts on map feed by date or location 
* Browse public posts at a given location 
* Direct messaging functionality
* Each user has a profile that shows their posts only 
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
    * If implemented, users will also be able to favorite and comment on posts on this screen 
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
[Add picture of your hand sketched wireframes in this section]
<img src="YOUR_WIREFRAME_IMAGE_URL" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
[This section will be completed in Unit 9]
### Models
[Add table of models]
### Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
