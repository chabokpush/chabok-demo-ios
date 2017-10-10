//
//  LocalCache.h
//  AdpPushClient
//
//  Created by Hussein Habibi on 10/9/17.
//  Copyright © 2017 AdpDigital. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalSetting : NSObject

@property (nonatomic, strong) NSMutableDictionary *geofence;

+(instancetype) shareInstance;

-(void) removeGeofenceId:(NSString *) identifier;

-(void) insertGeofenceId:(NSString *) identifier expireCount:(NSInteger) count expireTs:(NSTimeInterval) ts enter:(NSString *) enter exit:(NSString *) exit;

-(void) updateGeofenceCount:(NSString *) identifier;

-(NSDictionary *) getGeofenceFromId:(NSString *) identifier;

@end
