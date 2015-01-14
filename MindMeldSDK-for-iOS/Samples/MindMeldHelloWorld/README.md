HelloWorld
======

This is a very simple iOS App that shows how to use the MindMeld iOS SDK.

![Hello World](screenshot.jpg?raw=true "Hello World")

The only thing you need to do to run this app is to insert your MindMeld API
application ID, user token and user ID in MMConstants.h.

The app is fully commented. In order to follow the code, you can follow the
numbers that appear in the comments like this:

    ////    ////    ////
    //1)    //2)    //3)
    ////    ////    ////

These numbers correspond to the following actions in the app:

1. Create the MMApp and set the user token and active user.
2. When the active user is updated...
3. Create a new session for this user.
4. Set the newly created session as the active session.
5. When the active session is updated...
6. Post a new text entry for the session.
7. When entities are updated from the text entry, print them.
8. When documents are updated, print them.
9. Subscribe to a custom push update, and send an event on this channel.
10. Receive the push event generated on step 9.
