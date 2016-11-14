# Chabok Push SDK Documentation (ObjectiveC)

Chabok Push provides you with an iOS framework which is compatible with iOS 7 and later.


### Required Frameworks

First make sure you have imported MobileCoreServices.framework, SystemConfiguration.framework and CoreData from Linked Library



### Required Capabilities

Please check *Remote Notifications* checkmark in Project Setting > Capabilities > Background Modes
Please enable *Push Notifications* in Project Setting > Capabilities.


### Enabling Chabok Push

Then add the Chabok framework which you have downloaded into your workspace. 
Import it and define a property in your `AppDelegate.h` to hold the Chabok client singleton instance.

```objc
#import <AdpPushClient/AdpPushClient.h>

@interface AppDelegate () <PushClientManagerDelegate>
  @property (nonatomic, strong) PushClientManager *manager;
@end
```


Then inside your `didFinishLaunchingWithOptions` method in `AppDelegate.m` do the below:

For development accounts to select sandbox chabok servers use +setDevelopment:develop

```objc
[PushClientManager setDevelopment:YES];
```

Now create a singleton instance of PushClientManager using `defaultManager`:
```objc
self.manager = [PushClientManager defaultManager];
```

add your AppDelegate as delegation for callback purposes:
```objc
[self.manager addDelegate:self];
```


call didFinishLaunchingWithOptions of manager
```objc
[self.manager application:application didFinishLaunchingWithOptions:launchOptions])
```


Now define your account APP_ID, SDK_USERNAME and SDK_PASSWORD. You can find your SDK_KEY from the chabok web panel:
```objc
[self.manager registerApplication:@"YOUR_APP_ID"
                                   apiKey:@"YOUR_SDK_KEY"
                                 userName:@"SDK_USERNAME"
                                 password:@"SDK_PASSWORD"]
```
        
        
It's time to register the user with a userId
```objc
[self.manager registerUser:@"USER_ID"
                              channels:@[@"YOUR_CHANNEL" ]
                   registrationHandler:^(BOOL isRegistered, NSString *userId, NSError *error) {
  // handle registration result from server
}
```
After the first time registration, `self.manager.userId` property will be set 
and you may want to check manager's object to see if it has a registered userId or not.



### Enable Notification Delegation

Include the code below inside your AppDelegate.m. 
These helps Chabok client to handle remote and local notification delegates:

```objc
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
                                                       fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    // Hook and Handle New Remote Notification, must be use for remote payloads
    [self.manager application:application
           didReceiveRemoteNotification:userInfo
                 fetchCompletionHandler:completionHandler];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    // Hook and handle failure of get Device token from Apple APNS Server
    [self.manager application:application
                  didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    // Manager hook and handle receive Device Token From APNS Server
    [self.manager application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    // Manager hook and Handle iOS 8 remote Notificaiton Settings
    [self.manager application:application didRegisterUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    // Manager Hook and handle receive iOS (4.0 and later) local notification
    [self.manager application:application didReceiveLocalNotification:notification];
}
```



### PushClientManager Delegation Callback

After calling `manager.addDelegate(self)` as shown above, you can use the following delegates
to receive internal events of Chabok framework. These include:

```objc
- (void)pushClientManagerDidRegisterUser:(BOOL)registration{
    // called when PushClientManager Registered user Successfully
}


- (void)pushClientManagerDidFailRegisterUser:(NSError *)error{
    // Called When PushClientMangager fail in registerApplication:appVersion:userName:password:
    // Or - registerUser:userId and registerAgainWithUserId:userId
    NSLog(@"%@ %@",@(__PRETTY_FUNCTION__),error);
    // OR
    NSLog(@"%@ %@",@(__PRETTY_FUNCTION__),self.manager.failureError);
}


- (void)pushClientManagerDidReceivedDelivery:(DeliveryMessage *)delivery{
    // Called When PushClientManager has received new delivery from server
}


- (void)pushClientManagerDidReceivedMessage:(PushClientMessage *)message{
    // Called When PushClientManager has been received new message from server
}


- (void)pushClientManagerDidChangedServerConnectionState{
    // Called When PushClientManager Connecting State has been Changed
}


- (void)pushClientManagerDidChangeServerReachiability:(BOOL)reachable
                                          networkType:(PushClientServerReachabilityNetworkType)networkType{
    // Called When PushClientManager Server Reachiability has been Changed
}

```


### Using Observing which require NSNotificationCenter

As an alternative, you can use NSNotificationCenter's observer methods to receive events.
To receive events this way, you can add any of these osbervers:

```objc
[[NSNotificationCenter defaultCenter] addObserver:self
	selector:@selector(pushClientFailureHandler:)
		name:kPushClientDidFailRegisterUserNotification object:nil];
    
[[NSNotificationCenter defaultCenter] addObserver:self
	selector:@selector(pushClientNewMessageHandler:)
    	name:kPushClientDidReceivedMessageNotification object:nil];
    
[[NSNotificationCenter defaultCenter] addObserver:self
	selector:@selector(pushClientRegistrationHandler:)
		name:kPushClientDidRegisterUserNotification object:nil];
    
[[NSNotificationCenter defaultCenter] addObserver:self
	selector:@selector(pushClientServerConnectionStateHandler:)
    	name:kPushClientDidChangeServerConnectionStateNotification object:nil];
    
[[NSNotificationCenter defaultCenter] addObserver:self
	selector:@selector(pushClientServerReachabilityHandler:)
    	name:kPushClientDidChangeServerReachabilityNotification object:nil];
```

and then implement following observer methods to receive Chabok events:

```objc
- (void)pushClientNewMessageHandler:(NSNotification*)notification{
    PushClientMessage* message = notification.userInfo[@"message"];
    // handle message
}

- (void)pushClientServerConnectionStateHandler:(NSNotification*)notification{
	// self.manager.connectionState will be one of
    // PushClientServerConnectingStartState
    // PushClientServerConnectingState
    // PushClientServerConnectedState
    // PushClientServerDisconnectedState
    // PushClientServerDisconnectedErrorState

}

- (void)pushClientFailureHandler:(NSNotification*)notification{
}

- (void)pushClientServerReachabilityHandler:(NSNotification *)notification{
}

- (void)pushClientRegistrationHandler:(NSNotification *)notification{
}
```


### Channel Subscription

To subscribe to a channel you can use the following:

```objc
[self.manager subscribe:@"myAlerts"]; // private (personal) channel
[self.manager subscribe:@"public/sport"]; // public channel

[self.manager unsubscribe:@"public/+"]; // all public channels
```


### Publishing Messages

To publish a message from client to Chabok server, use this:

```objc
PushClientMessage *message = [[PushClientMessage alloc]
                                  initWithMessage:@"message body"
                                  withData:@{
                                             @"test": @"value"
                                             }
                                  topic:@"USER_ID/CHANNEL_NAME"];
message.alertText = @"New Message Alert Text";

[self.manager publish:message];
```



### Receive Deliveries

To enable receive of delivery acknowledgements of a published message, you should enable the deliveries before: 

```objc
self.manager.deliveryChannelEnabeled = YES;
```


### Badge Handling

If you want to reset your application badge number, you can simply:

```objc
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [PushClientManager resetBadge];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [PushClientManager resetBadge];
}
```