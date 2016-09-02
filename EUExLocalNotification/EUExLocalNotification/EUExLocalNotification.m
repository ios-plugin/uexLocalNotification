//
//  EUExScanner.m
//  AppCan
//
//  Created by AppCan on 11-9-7.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "EUExLocalNotification.h"


@interface EUExLocalNotification()

@end


@implementation EUExLocalNotification

static UILocalNotification * launchLocalNotification = nil;

static NSString *const kUexLocalNotificationIDKey = @"notificationId";
static NSString *const kUexLocalNotificationMessageKey = @"msg";
static NSString *const kUexLocalNotificationExtrasKey = @"extras";


- (instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    if (self = [super initWithWebViewEngine:engine]) {
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }
    }
    return self;
}

- (void)dealloc {
    [self clean];
}

- (void)clean {
}


+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    launchLocalNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    return YES;
}
+ (void)rootPageDidFinishLoading{

    if(launchLocalNotification){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = launchLocalNotification.userInfo;
            
            NSString *notID = userInfo[kUexLocalNotificationIDKey];
            NSString *message = userInfo[kUexLocalNotificationMessageKey];
            NSDictionary * extras = userInfo[kUexLocalNotificationExtrasKey];
            
            [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:@"uexLocalNotification.onActive" arguments:ACArgsPack(notID,message,extras.ac_JSONFragment)];

        });
    }
}

+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    UIApplicationState state = [application applicationState];
    NSDictionary *userInfo = notification.userInfo;
    
    NSString *message = userInfo[kUexLocalNotificationMessageKey];
    NSString * notID = userInfo[kUexLocalNotificationIDKey];
    NSDictionary *extras = userInfo[kUexLocalNotificationExtrasKey];

    NSString *cbName = (state == UIApplicationStateActive) ? @"uexLocalNotification.onMessage" : @"uexLocalNotification.onActive";
    [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:cbName arguments:ACArgsPack(notID,message,extras.ac_JSONFragment)];
    application.applicationIconBadgeNumber = 0;
}

- (void)add:(NSMutableArray *)inArguments {

    
    ACArgsUnpack(NSString *notificationId,NSNumber *timestamp,NSNumber *mode,NSString *message,NSString *buttonTitle,__unused NSString *sound,NSString *cycleFlag,NSNumber *badge,NSDictionary * extras) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(notificationId);
    UEX_PARAM_GUARD_NOT_NIL(timestamp);
    UEX_PARAM_GUARD_NOT_NIL(message);


    
    NSArray<UILocalNotification *> *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in notifications) {
        if ([notificationId isEqual:notification.userInfo[kUexLocalNotificationIDKey]]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            break;
        }
    }
    
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    
    NSDictionary<NSString *,NSNumber*> *cycleFlagDict = @{
                                                          @"daily": @(NSCalendarUnitDay),
                                                          @"weekly": @(NSCalendarUnitWeekOfYear),
                                                          @"monthly": @(NSCalendarUnitMonth),
                                                          @"yearly": @(NSCalendarUnitYear)
                                                          };
    NSNumber *repeatUnit = cycleFlagDict[cycleFlag];
    if (repeatUnit) {
        notif.repeatInterval = [repeatUnit unsignedIntegerValue];
    }
    notif.fireDate = [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue / 1000];
    notif.hasAction = (mode.integerValue == 1);
    notif.timeZone = [NSTimeZone defaultTimeZone];
    notif.alertBody = message;
    notif.alertAction = buttonTitle;
    notif.soundName = UILocalNotificationDefaultSoundName;
    notif.applicationIconBadgeNumber = badge.integerValue;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[kUexLocalNotificationIDKey] = notificationId;
    userInfo[kUexLocalNotificationMessageKey] = message;
    userInfo[kUexLocalNotificationExtrasKey] = extras;
    notif.userInfo = userInfo;
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];

	
}

- (void)remove:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *notificationId) = inArguments;

	NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
	for (UILocalNotification *notification in notifications) {
		if ([notificationId isEqual:notification.userInfo[kUexLocalNotificationIDKey]]) {
			[[UIApplication sharedApplication] cancelLocalNotification:notification];
            break;
		}
	}
}

- (void)removeAll:(NSMutableArray *)inArguments {
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
