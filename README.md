BigSur
======

BigSur is the flagship Inbox mail client.

#### Environment Setup

**BigSur does not include the core Inbox iOS framework.**

To build BigSur, you need to check out the [Inbox-iOS](http://github.com/inboxapp/inbox-ios) repository in the directory above the BigSur workspace:

	- Inbox-iOS
		- InboxExamples
		- InboxFramework
		...
	- BigSur
		- BigSur.xcworkspace
		...
		
#### Cocoapods

BigSur uses Cocoapods, a dependency management system for iOS apps similiar to npm and rpm. To set up your local development environment, you'll need to install cocoapods and do a pod install:

1. `sudo gem install cocoapods`

2. `cd <project directory>`

3. `pod install`

After Cocoapods has installed dependencies, open the project's .xcworkspace (not the .xcproj). Have fun.

