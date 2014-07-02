Authentication with api.inboxapp.com
------------------------------------

Note: The open-source Inbox Sync Engine does not support authentication.
You can skip these steps unless you plan to use the hosted Inbox API.



1. Add your Inbox App ID to your application's `Info.plist` file as `INAppID`.

2. Add code to your App Delegate to handle authorization callbacks:

    
		- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
		{
			return [[INAPIManager shared] handleURL: url];
		}
    

3. Find an appropriate place in your application to ask the user to sign into their email account. If you're building a full-fledged mail client, you should ask users to sign in to their email immediately. If your application needs email access for a particular feature, you should prompt users to log in to their email when they access that feature.

4. Call `INAPIManager`'s `authenticateWithEmail:andCompletionBlock:` to begin the login process. This method directs the user to their email provider (Gmail, Exchange, etc.) in Safari to enter their account credentials. When authorization is completed and Inbox has received an auth token, the completion block runs and your application can dismiss login UI and begin displaying mail.

	    NSString * email = @"ben@inboxapp.com";
	    [[INAPIManager shared] authenticateWithEmail:email andCompletionBlock:^(BOOL success, NSError *error) {
	        if (success)
	            // the user approved us to access their account - let's go!
	        else if (error)
	            [UIAlertView alloc] init....
	    }];

