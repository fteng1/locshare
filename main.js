Parse.Cloud.define('friendUser', async (request) => {
    const userQuery = new Parse.Query(Parse.User);
    userQuery.equalTo("objectId", request.params.userToEditID);
    const userToEdit = await userQuery.first({ useMasterKey: true });

    if (request.params.friend) {
        // code to friend a user
        userToEdit.add("friends", request.params.currentUserID);
        userToEdit.increment("numFriends");
    }
    else {
        // code to unfriend a user
        userToEdit.remove("friends", request.params.currentUserID);
        userToEdit.increment("numFriends", -1);
    }

    // Use master key to save user information in cloud
    userToEdit.save(null, { useMasterKey: true });
});

Parse.Cloud.define('sendFriendRequest', async (request) => {
    const userQuery = new Parse.Query(Parse.User);
    userQuery.equalTo("objectId", request.params.userToEditID);
    // user that current user is trying to friend
    const userToEdit = await userQuery.first({ useMasterKey: true });

    if (request.params.friend) {
        // code to send a friend request to a user
        userToEdit.add("pendingFriends", request.params.currentUserID);
    }
    else {
        // code to unsend a friend request to a user
        userToEdit.remove("pendingFriends", request.params.currentUserID);
    }

    // Use master key to save user information in cloud
    userToEdit.save(null, { useMasterKey: true });
});

// Code to remove current user from other user's requestsSent
Parse.Cloud.define('respondToFriendRequest', async (request) => {
    const userQuery = new Parse.Query(Parse.User);
    userQuery.equalTo("objectId", request.params.userToEditID);
    // user that current user responded to
    const userToEdit = await userQuery.first({ useMasterKey: true });
    userToEdit.remove("requestsSent", request.params.currentUserID);

    // Use master key to save user information in cloud
    userToEdit.save(null, { useMasterKey: true });
});
