MindMeld Browser
================

This is a web browser application that analyzes the content the user is viewing and finds the key concepts. If the user is reading a news article, for example, our API will extract the most important entities from the text and show them to the user in an attempt to summarize the article. This app illustrates how our API can analyze large pieces of text to find the key concepts contained in the text, which can then be used to show the user relevant information about the text.

![MindMeld Browser](screenshot.jpg?raw=true "MindMeld Browser")

To run this app is to insert your MindMeld API application ID, user token and user ID at the top of MMConstants.h.

In addition, we are using [DiffBot](http://www.diffbot.com/pricing/) to find
text from websites. Follow their instructions to get free trial account
and a DiffBot API token. Insert the token in MMConstants.h as well.

The app is fully commented. In order to follow the code, you can follow the
numbers that appear in the comments like this:

    ////    ////    ////
    //1)    //2)    //3)
    ////    ////    ////

These numbers correspond to the following actions in the app:

1. Create the MMApp and set the user token and active user.
2. Create a new session for this user.
3. Set the newly created session as the active session.
4. User navigates via links, or entering a new url.
5. User touches get entities button
6. Crawl the current url for text
7. Post the text as a text entry.
8. Fetch entities extracted from the text entry.
9. Display entities.
