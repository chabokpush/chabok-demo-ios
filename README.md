# Chabok iOS Documentation

Chabok framework is compatible with iOS 7 and later.


Import MobileCoreServices.framework and SystemConfiguration.framework, CoreData from Linked Library


Please Check Remote Notification Checkmark in:
Project Setting in file List Menu > Capabilities > Background Mode > turn it on > Check Remote Notification


Import framework and define a property to hold the Chabok Client Singleton.
```obj
#import <AdpPushClient/AdpPushClient.h>

@interface AppDelegate () <PushClientManagerDelegate>
@property (nonatomic, strong) PushClientManager *manager;
@end
```

Then inside your `didFinishLaunchingWithOptions` do the below:


for development and access to local server use +setDevelopment:develop
```objc
[PushClientManager setDevelopment:YES];
```

Step1 : create singletone default manager of PushClientManager
```objc
self.manager = [PushClientManager defaultManager];
```


Step2 Solution 1: add appDelegate as delegation for callback purpose
```objc
[self.manager addDelegate:self];
```

Or Solution 2: use observer methods detailed down below.



Step 3: Check Application Launch With Local Or remote Notification
```objc
if ([self.manager application:application
  didFinishLaunchingWithOptions:launchOptions]){
    // handle backend and UI here
}
```


Step 4: register APP_ID with version here and set username, password which server assign to APP_ID
```objc
[self.manager registerApplication:@"YOUR_APP_ID"
                                   apiKey:@"YOUR_SDK_KEY"
                                 userName:@"SDK_USERNAME"
                                 password:@"SDK_PASSWORD"]
```
        
Step 5: register user after registerApplication:appVersion:username:password return true otherwise handle failureError property of PushClientManager
Register new user Id and pushClientManager store new userId using blocks
```objc
[self.manager registerUser:@"989125336383"
                              channels:@[@"alert" ]
                   registrationHandler:^(BOOL isRegistered, NSString *userId, NSError *error) {
  // handle registration result from server
}
```
After first time registration, self.manager.userId property will be set, and you can check pushClientManager object has old userId or not.





### Enable Notification Delegation
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

and implement following observer methods:

```obj
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
```objc
[self.manager subscribe:@"public/sport"];

[self.manager unsubscribe:@"public/+"];
```


### Publishing Messages

```objc
PushClientMessage *message = [[PushClientMessage alloc]
                                  initWithMessage:@"message body"
                                  withData:@{
                                             @"test": @"value"
                                             }
                                  topic:@"989395336383/default"];
message.alertText = @"New Message Alert";
[self.manager publish:message];
```



### Receive Deliveries

```objc
self.manager.deliveryChannelEnabeled = YES;
```


### Badge Handling

```objc
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [PushClientManager resetBadge];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [PushClientManager resetBadge];
}


```