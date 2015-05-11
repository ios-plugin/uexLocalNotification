//
//  EUExScanner.m
//  AppCan
//
//  Created by AppCan on 11-9-7.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "EUExLocalNotification.h"
#import "EUtility.h"

@implementation EUExLocalNotification

-(id)initWithBrwView:(EBrowserView *) eInBrwView {	
	if (self = [super initWithBrwView:eInBrwView]) {
	}
	return self;
}

-(void)dealloc {
	[super dealloc];
}

-(void)clean {
}

-(void)add:(NSMutableArray *)inArguments {
	NSString *notificationId = nil;
	double timestamp = -1.0;
	BOOL hasAction = NO;
	NSString *msg = nil;
	NSString *action = nil;
	NSString *sound = nil;
	NSString *repeat = nil;
	NSInteger badge = -1;
	NSInteger count = [inArguments count];
	if (count > 0) {
		notificationId = [inArguments objectAtIndex:0];
	}
	if (count > 1) {
		timestamp = [[inArguments objectAtIndex:1] doubleValue]/1000;
	}
	if (count > 2) {
		hasAction = ([[inArguments objectAtIndex:2] intValue] == 1) ? YES : NO;
	}
	if (count > 3) {
		msg = [inArguments objectAtIndex:3];
	}
	if (count > 4) {
		action = [inArguments objectAtIndex:4];
	}
	if (count > 5) {
		sound = [inArguments objectAtIndex:5];
	}
	if (count > 6) {
		repeat = [inArguments objectAtIndex:6];
	}
	if (count > 7) {
		badge = [[inArguments objectAtIndex:7] intValue];
	}
	NSMutableDictionary *repeatDict = [[NSMutableDictionary alloc] init];
    [repeatDict setObject:[NSNumber numberWithInt:NSDayCalendarUnit] forKey:@"daily"];
    [repeatDict setObject:[NSNumber numberWithInt:NSWeekCalendarUnit] forKey:@"weekly"];
    [repeatDict setObject:[NSNumber numberWithInt:NSMonthCalendarUnit] forKey:@"monthly"];
    [repeatDict setObject:[NSNumber numberWithInt:NSYearCalendarUnit] forKey:@"yearly"];
    [repeatDict setObject:[NSNumber numberWithInt:0] forKey:@"once"];
	
	NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
	for (UILocalNotification *notification in notifications) {
		NSString *notId = [notification.userInfo objectForKey:@"notificationId"];
		if ([notificationId isEqualToString:notId]) {
			[[UIApplication sharedApplication] cancelLocalNotification:notification];
			break;
		}
	}

	NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
	UILocalNotification *notif = [[UILocalNotification alloc] init];
	notif.fireDate = date;
	notif.hasAction = hasAction;
	notif.timeZone = [NSTimeZone defaultTimeZone];
    notif.repeatInterval = [[repeatDict objectForKey:repeat] intValue];
	notif.alertBody = ([msg isEqualToString:@""]) ? nil : msg;
	notif.alertAction = action;
    notif.soundName = UILocalNotificationDefaultSoundName;
    notif.applicationIconBadgeNumber = badge;
	NSDictionary *userDict = nil;
	if (msg && msg.length > 0) {
		userDict = [NSDictionary dictionaryWithObjectsAndKeys:notificationId,@"notificationId",msg,@"msg",nil];
	} else {
		userDict = [NSDictionary dictionaryWithObjectsAndKeys:notificationId,@"notificationId",nil];
	}
    notif.userInfo = userDict;
	[[UIApplication sharedApplication] scheduleLocalNotification:notif];
}

-(void)remove:(NSMutableArray *)inArguments {
	NSString *notificationId = [inArguments objectAtIndex:0];
	NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
	for (UILocalNotification *notification in notifications) {
		NSString *notId = [notification.userInfo objectForKey:@"notificationId"];
		if ([notificationId isEqualToString:notId]) {
			[[UIApplication sharedApplication] cancelLocalNotification:notification];
		}
	}
}

-(void)removeAll:(NSMutableArray *)inArguments {
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)getData:(NSMutableArray *)inArguments {
	NSString *notificationId = [inArguments objectAtIndex:0];
	NSMutableDictionary *localNotifDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"localData"];
	if (!localNotifDict) {
		return;
	}
	NSString *msg = [localNotifDict objectForKey:notificationId];
	NSString *jsStr = [NSString stringWithFormat:@"uexLocalNotification.cbGetData(\'%@\',\'%@\')", notificationId, msg];
	[meBrwView stringByEvaluatingJavaScriptFromString:jsStr];
}

@end
