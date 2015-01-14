MindMeld Voice
==============

This app uses the speech recognition included with the MindMeld iOS SDK to convert speech to text. The API then analyzes the text and fetches related documents. This app illustrates how speech to text services can be incorporated into our API, so that a user's speech becomes another contextual source.

![MindMeld Voice](screenshot.png?raw=true "MindMeld Voice" =320px)

To run this app you'll need to open the MindMeldSDKSampleCode workspace in XCode, insert your MindMeld API application ID in the constants header, MMConstants.h, and install [CocoaPods](http://cocoapods.org/) dependencies from the Samples directory with the command `pod install`.

The app is fully commented. In order to follow the code, you can follow the numbers that appear in the comments like this:

    /**
     *  (1)
     */

    /**
     *  (2)
     */

    /**
     *  (3)
     */

The core of the application logic is in MMVoiceController. 
These numbers correspond to the following actions in MMVoiceController.m:

1. Create and initialize the MMApp instance.
2. Subscribe to push events for documents.
3. Start listening to the user's speech.
4. When recording begins update the UI.
5. When the speech is processed, display the text on screen and...
6. Create a text entry for final results.
7. Refresh the table view when documents have loaded.
8. Populate the cells per document.
9. When the user selects a document, take them to the source url.
