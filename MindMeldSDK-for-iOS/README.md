MindMeldSDK 2.4 for iOS
=======================

This framework allows you to leverage the MindMeld API in your iOS app.

## Getting Started

### Step 1: Download the SDK
  Get the [MindMeld SDK for iOS](https://www.expectlabs.com/public/sdks/ios/mindmeld-ios-sdk.zip)

### Step 2: Add the framework to your Xcode project
  1. Right-click in the Project Navigator pane and select 'Add Files to "{YOUR-PROJECT-NAME}"...'
  2. Select the MindMeldSDK.framework file.
  3. Repeat for the frameworks in the vendors directory
  4. Confirm that these frameworks are linked by going to your target's "Build Phases" -> "Link Binary With Libraries"

### Step 3: Add the following standard libraries which are required to use the MindMeldSDK
  1. libicucore.dylib
  2. CFNetwork.framework
  3. Security.framework

### Step 4: Add the necessary build settings
  Go to "Targets" -> "Build Settings", find the field "Other Linker Flags" and add `-ObjC` if it is not already there.

### Step 5: Import the SDK by adding the following line to any file from which you wish to access the SDK.

    #import <MindMeldSDK/MindMeldSDK.h>

### Step 6: Start using the SDK

  You can now create an instance of MMApp by providing the App ID you obtained from the MindMeld Developer Center.

    MMApp *app = [[MMApp alloc] initWithAppID:MY_APP_ID];

  Discover more features with the iOS SDK [Reference Docs](https://www.expectlabs.com/docs/sdks/ios/referenceDocs/)


## Support

The MindMeld iOS SDK supports iOS 6.0 and later.

## Samples

We have included a few simple applications demonstrating use of the SDK. They are located in the Samples directory. Before using sample apps, install CocoaPods dependencies with `pod install`.

- MindMeld Quick Start: a simple app that demonstrates using the MindMeld iOS SDK to perform voice search with minimal UI.
- MindMeld Starter App: an app showing a drop in voice search interface for iPad.
- MindMeld Voice: an app showcasing the speech recognition capabilities of the SDK.
- MindMeld Hello World: a very simple app that demonstrates using the MindMeld iOS SDK.
- MindMeld Browser: a browser application which summarizes websites.
- MindMeld IM: a messaging application which presents documents relevant to a conversation.