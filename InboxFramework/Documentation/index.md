Inbox iOS SDK
======
---------

The Inbox iOS framework provides a native interface to the Inbox API, with additional features that make it easy to build full-fledged mail apps for iOS or add the email functionality you need to existing applications.

The Inbox Framework:

- Includes pre-built view controllers for common tasks such as composing email, viewing a list of threads, and authorizing an account.

- Provides native, Objective-C models for threads, messages, contacts, and attachments, and high-level methods for interacting with them.

- Automatically caches data in an SQLite store, allowing you to create applications with great offline behavior with very little effort.

- Allows you to load individual slices of data from the Inbox API, such as a list of threads in the user's inbox with attachments, or create robust email applications that maintain a local cache and sync the user's entire mailbox.

- Comes with kickass sample apps. <links>


There are two ways to use Inbox:

**1. Run the Inbox Sync Engine**

Download the Inbox Sync Engine and run the server locally on your development machine. The sync engine does not perform any authentication on API requests. To get started, follow the instructions at [https://github.com/inboxapp/inbox/](https://github.com/inboxapp/inbox/).

**2. Connect to the Inbox API *(Coming soon!)***

You need to obtain an Inbox App ID from https://developers.inboxapp.com/ and download the latest version of the Inbox SDK from https://developers.inboxapp.com/ios. Follow the instructions in Setting up Authentication to add Inbox login to your app.


Getting Started
---------------

1. Drag and drop `Inbox.framework` into your Xcode project and add an import to your application's .pch header file:

	`#import <Inbox/Inbox.h>`


2. If you're connecting to the hosted Inbox API at http://api.inboxapp.com/, follow the [Authentication](./authentication.md) instructions to add sign-in and API token support to your app.
 
3. Click one of the links below to choose your own adventure:

	- [Display Threads](./threads.md)
	- [Compose Drafts and Send Mail](./compsing.md)
