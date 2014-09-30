Inbox Client Scaffold - iOS
======

The Inbox iOS Client Scaffold is a full-featured mail client built on top of the Inbox API. It leverages the SQLite cache and model layer of the [Inbox iOS SDK](https://github.com/inboxapp/inbox-ios)'s, and adds the pre-packaged views and controllers you need to build a first-class mail experience. We've created a polished composer with tokenizing recipient fields, collection view and table view cells for displaying mail content, and more. Start your next project with the Inbox Client Scaffold and focus on creating delightful interactions!

<a href="https://raw.githubusercontent.com/inboxapp/inbox-client-scaffold-ios/master/Screenshots/hand-threads.png"><img src="https://raw.githubusercontent.com/inboxapp/inbox-client-scaffold-ios/master/Screenshots/hand-threads.png" width="500" /></a>

<a href="://raw.githubusercontent.com/inboxapp/inbox-client-scaffold-ios/master/Screenshots/overview.png"><img src="https://raw.githubusercontent.com/inboxapp/inbox-client-scaffold-ios/master/Screenshots/overview.png" /></a>


## Features

- Thread List: View threads in a table view with support for popular interactions like pull-to-refresh, swipe-to-archive, and infinite scrolling.
- Thread Detail: View messages in a collection view with mobile-optimized HTML message bodies, gravatar support, and draft actions.
- Composer: Create, edit, and send drafts with a beautiful Gmail-style composer. Includes tokenizing recipient fields powered by UICollectionView, autocompletion with the Inbox Contacts API, and support for uploading attachments with progress indicators.
- Tags: Switch tags from the sidebar. Browse your inbox or view built-in tags like Archive or Flagged and custom tags created via Inbox.
- Offline Access: The client scaffold is backed by the iOS SDK's SQLite cache and automatically queues actions like archiving and sending for completion when internet is available, even complex chained interactions like creating a draft, adding an attachment, and then sending it.


## By Developers, For Developers

The Inbox Client Scaffold is intended for developers - to use it, you need an Inbox Developer Program membership or a copy of the open-source [Inbox Sync Engine](http://github.com/inboxapp/inbox). When you download or fork the Inbox Client Scaffold, you'll need to add your Inbox App ID before you can connect your account.

### Environment Setup

The Inbox iOS Client Scaffold uses Cocoapods, a dependency management system for iOS apps similiar to npm and rpm. To set up your local development environment, you'll need to install cocoapods and do a pod install.

1. `sudo gem install cocoapods`

2. `cd <project directory>`

3. `pod install`. After Cocoapods has installed dependencies, open the project's .xcworkspace.

4. Open the app's `Info.plist` file in Xcode. Before you can run the app and authenticate an account with Inbox, you need to create an App ID by signing in to your Inbox Developer Account and creating a new application.
	- Fill in the `INAppID` with a valid App ID.
	- Update the URL Scheme for the `inbox-api` URL Type to be `in-<your app ID>`


### Communication

- If you need help, use **Stack Overflow**. (Tag 'inbox-ios')
- If you'd like to ask a general question, use **Stack Overflow**.
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

### Tips

1. If you're extending the functionality of the Inbox iOS SDK while developing your application, you may want to check out the Inbox-iOS repository and update the client scaffold `Podfile` to point to your local copy of the SDK. We welcome pull requests against the Inbox iOS SDK repository as well as the client scaffold!

```ruby
target "Inbox" do
    pod 'InboxKit', :path => "../Inbox-iOS"
end
```

2. If you're debugging network interaction, check out [the Charles HTTP Proxy](http://www.charlesproxy.com/). You can configure it to [intercept SSL requests](http://www.charlesproxy.com/documentation/faqs/ssl-connections-from-within-iphone-applications/) with the iOS Simulator.

3. If you're debugging view issues, you can save time (and get bonus points) with the [Spark Inspector](http://sparkinspector.com/), developed by the Inbox iOS lead!
