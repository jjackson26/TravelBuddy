MindMeld IM
===========

This is an instant messaging application that uses our technology to enhance
text-based conversations. It takes the text from the user's conversation and
posts it to our API. Then documents related to the key concepts in the
conversation are fetched and displayed. This app illustrates how multiple
users can provide context to the same session.

![MindMeld IM](screenshot.jpg?raw=true "MindMeld IM")

The only thing you need to do to run this app is to insert your MindMeld API
application ID, Facebook user token and user ID at the top of MMConstants.h.

In this app a conversation is represented as a MindMeld session and a message
is represented as a MindMeld text entry.

The code is fully commented. In order to follow the code, you can follow the
numbers that appear in the comments like this:

    ////    ////    ////
    //1)    //2)    //3)
    ////    ////    ////

These numbers correspond to the following actions in the app:

In MMConversationsViewController.m
1. Create the MMApp and set the user token and active user.
2. Fetch the user's sessions and display them.
3. User selects a session or "conversation".
4. Create and present the conversation view.

In MMConversationViewController.m
1. Set the session associated with this conversation as active.
2. Subscribe to push events for text entries and documents.
3. Display text entries as messages as they arrive.
4. Display documents as they arrive.
5. User types a message and presses send.
6. Create a new text entry and post it.
7. Repeat steps 3-6.
8. User swipes from left to reveal documents. (Not in code)
9. User swipes from right to return to conversation. (Not in code)
10. User taps close and returns to conversation list.