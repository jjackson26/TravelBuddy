MindMeld Starter App
================

This app is an example of a refined iPad user interface for voice search built on the MindMeld SDK for iOS. It leverages the MindMeld SDK's Listener for speech recognition, and takes care of fetching and displaying documents. You can use this in your own app with minimal modification, or use it as inspiration.

![MindMeld Starter App](screenshot.png?raw=true "MindMeld Starter App" =512px)

To run this app you'll need to use the MindMeldSDKSampleApps to insert your MindMeld API application ID in the constants header, MMConstants.h, and install [CocoaPods](http://cocoapods.org/) dependencies from the Samples directory with the command `pod install`.

If you would like to use this code, you can easily customize the colors of the voice search controller using the documented color properties of MMVoiceSearchBarView, MMActivityIndicator and MMMicrophoneButton.

The app is fully commented. In order to follow the code, you can follow the
numbers that appear in the comments like this:

    /*****  /*****  /*****
     *  (1)  *  (2)  *  (3)
     *****/  *****/  *****/

### Below is a summary of the important code in this application.

#### MMStarterAppDelegate
1. Configure the Audio Session for MMListener when the app launches.
2. Configure the Audio Session when the app returns from the background.

#### MMStarterViewController
1. Create and modally present the voice search controller.

#### MMVoiceSearchController
1. Set the colors for the voice search controller.
2. Create and initialize the MMApp using [MMApp start].
3. Clear context when a new search begins.
4. Post a text entry when the user submits one via the voice search bar.
5. Get documents based on the active text entries.
6. Pass the documents to the documents controller.

#### MMVoiceSearchBarView
This view handles the listener state and displaying transcripts as they come in as interim and transition to final.

#### MMDocumentsController
This view controller displays the search results using a UICollectionView.

#### MMBasicDocumentCollectionViewCell
1. Apply document title and description.
2. Add any additional details about the document you'd like to display.

