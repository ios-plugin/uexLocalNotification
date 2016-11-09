/**
 *
 *	@file   	: EUExLocalNotification.m  in EUExLocalNotification
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2016/11/8
 *
 *	@copyright 	: 2016 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */


#import "EUExLocalNotification.h"
#import <UserNotifications/UserNotifications.h>
#import "uexLegacyNotificationManager.h"
#import "uexUserNotificationManager.h"


NSString *const kUexLocalNotificationSpecifierKey = @"kUexLocalNotificationSpecifierKey";
NSString *const kUexLocalNotificationIDKey = @"kUexLocalNotificationIDKey";
NSString *const kUexLocalNotificationMessageKey = @"kUexLocalNotificationMessageKey";
NSString *const kUexLocalNotificationExtrasKey = @"kUexLocalNotificationExtrasKey";



@implementation uexLocalNotificationData
@end


@interface EUExLocalNotification()<AppCanApplicationEventObserver>

@end



#define NotificationManager ([EUExLocalNotification localNotificationManager])

@implementation EUExLocalNotification


+ (id<uexLocalNotificationManager>)localNotificationManager{
    if (ACSystemVersion() < 10) {
        return [uexLegacyNotificationManager sharedManager];
    }else{
        return [uexUserNotificationManager sharedManager];
    }
}




+ (void)initialize{
    [NotificationManager requestAuthorization];
    
    
    [NotificationManager setOnMessageHandler:^(uexLocalNotificationData *data){
        [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:@"uexLocalNotification.onMessage" arguments:ACArgsPack(data.uid,data.message,data.extras.ac_JSONFragment)];
    }];
    
    
    
    [NotificationManager setOnActionHandler:^(uexLocalNotificationData *data){
        [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:@"uexLocalNotification.onActive" arguments:ACArgsPack(data.uid,data.message,data.extras.ac_JSONFragment)];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }];
}


- (instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    if (self = [super initWithWebViewEngine:engine]) {
        
    }
    return self;
}
- (void)dealloc {
    [self clean];
}
    
- (void)clean {
    
}

    
    
+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [NotificationManager notifyApplicationLaunchWithOptions:launchOptions];
    return YES;
}
+ (void)rootPageDidFinishLoading{

    [NotificationManager notifyRootPageFinishingLoading];
}
    
+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    [[uexLegacyNotificationManager sharedManager] application:application didReceiveLocalNotification:(UILocalNotification *)notification];
}

+ (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSUInteger))completionHandler{
    [[uexUserNotificationManager sharedManager] userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
}

+ (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    [[uexUserNotificationManager sharedManager] userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
}

    
- (void)add:(NSMutableArray *)inArguments {
    
    
    ACArgsUnpack(NSString *notificationId,NSNumber *timestamp,NSNumber *mode,NSString *message,NSString *buttonTitle,__unused NSString *sound,NSString *cycleFlag,NSNumber *badge,NSDictionary * extras) = inArguments;
    ACArgsUnpack(NSDictionary *info) = inArguments;
    
    NSString *imagePath = nil;
    if (info) {
        notificationId = stringArg(info[@"id"]);
        timestamp = numberArg(info[@"timestamp"]);
        mode = numberArg(info[@"mode"]);
        message = stringArg(info[@"message"]);
        buttonTitle = stringArg(info[@"buttonTitle"]);
        cycleFlag = stringArg(info[@"repeat"]);
        badge = numberArg(info[@"badge"]);
        extras = dictionaryArg(info[@"extras"]);
        imagePath = [self absPath:stringArg(info[@"image"])];

    }
    UEX_PARAM_GUARD_NOT_NIL(notificationId);
    UEX_PARAM_GUARD_NOT_NIL(timestamp);
    UEX_PARAM_GUARD_NOT_NIL(message);
    
    [NotificationManager cancelNotificationWithUID:notificationId];
    uexLocalNotificationData *data = [uexLocalNotificationData new];
    NSDictionary<NSString *,NSNumber*> *cycleFlagDict = @{
                                                          @"once": @0,
                                                          @"daily": @(NSCalendarUnitDay),
                                                          @"weekly": @(NSCalendarUnitWeekOfYear),
                                                          @"monthly": @(NSCalendarUnitMonth),
                                                          @"yearly": @(NSCalendarUnitYear)
                                                          };

    data.repeatInterval = (NSCalendarUnit)[cycleFlagDict[cycleFlag] unsignedIntegerValue];
    data.uid = notificationId;
    data.fireDate = [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue / 1000];
    data.hasAction = (mode.integerValue == 1);
    data.message = message;
    data.buttonTitle = buttonTitle;
    data.badgeNumber = badge;
    data.extras = extras;
    //only for iOS 10+
    if (imagePath) {
        data.imageURL = [NSURL fileURLWithPath:imagePath];
    }
    
    data.title = stringArg(info[@"title"]);
    data.subtitle = stringArg(info[@"subtitle"]);
    
    
    [NotificationManager addaddNotificationWithData:data];
}
    
- (void)remove:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *notificationId) = inArguments;
    [NotificationManager cancelNotificationWithUID:notificationId];

}
    
- (void)removeAll:(NSMutableArray *)inArguments {
    [NotificationManager cancelAllNotifications];

}



@end
