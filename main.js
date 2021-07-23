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
