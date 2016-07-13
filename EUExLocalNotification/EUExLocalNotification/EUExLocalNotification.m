//
//  EUExScanner.m
//  AppCan
//
//  Created by AppCan on 11-9-7.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "EUExLocalNotification.h"
#import "EUtility.h"


@interface EUExLocalNotification()

@end


@implementation EUExLocalNotification


//-(id)initWithBrwView:(EBrowserView *) eInBrwView {	
//	if (self = [super initWithBrwView:eInBrwView]) {
//        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
//        {
//            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
//        }
//	}
//	return self;
//}
-(id)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    if (self = [super initWithWebViewEngine:engine]) {
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }
    }
    return self;
}
+(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    UILocalNotification *notification = [launchOptions objectForKey:@"UIApplicationLaunchOptionsLocalNotificationKey"];
    if(notification && notification.userInfo){
        /*
         UIAlertView *alert=[[UIAlertView alloc]init];
         [alert addButtonWithTitle:@"didFinishLaunchingWithOptions"];
         alert.message=[notification.userInfo JSONFragment];
         [alert show];
         */
        NSUserDefaults *user= [NSUserDefaults standardUserDefaults];
        [user setObject:notification.userInfo forKey:@"EUExLocalNotification_userInfo"];
    }
    return YES;
}
+(void)rootPageDidFinishLoading{
    NSUserDefaults *user= [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo=[user objectForKey:@"EUExLocalNotification_userInfo"];
    if(userInfo){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            NSString *extras=[userInfo objectForKey:@"extras"];
            NSString *notID = [userInfo objectForKey:@"notificationId"];
            NSString *message = [userInfo objectForKey:@"msg"];
            //NSString * jsStr = [NSString stringWithFormat:@"uexLocalNotification.onActive(\'%@\',\'%@\')",notID, [@{@"extras":extras} ac_JSONFragment]];
            //[EUtility evaluatingJavaScriptInRootWnd:jsStr];
             [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:@"uexLocalNotification.onActive" arguments:ACArgsPack(notID,message,[@{@"extras":extras} ac_JSONFragment])];
            [user removeObjectForKey:@"EUExLocalNotification_userInfo"];
        });
    }
}
+(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    UIApplicationState state = [application applicationState];
    NSDictionary *extras=[self parseRemoteNotification:[notification.userInfo objectForKey:@"extras"]];
    NSString *message=[notification.userInfo objectForKey:@"msg"];
    NSString * notID = [notification.userInfo objectForKey:@"notificationId"];
    if (state == UIApplicationStateActive) {
        
        //		NSString *notID = [notification.userInfo objectForKey:@"notificationId"];
//        NSString * msg = [notification.userInfo objectForKey:@"msg"];
//        NSString * notID = [notification.userInfo objectForKey:@"notificationId"];
        //		NSString * jsStr = [NSString stringWithFormat:@"uexLocalNotification.onActive(\'%@\', \'%@\')", notID, msg];
        //		EBrowserView *brwView = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer].meRootBrwWnd.meBrwView;
        //		if (brwView) {
        //			[brwView  stringByEvaluatingJavaScriptFromString:jsStr];
        //		}
        //NSString * notID = [notification.userInfo objectForKey:@"notificationId"];
        //NSString * jsStr = [NSString stringWithFormat:@"uexLocalNotification.onMessage(\'%@\',\'%@\')",notID,message,[@{@"extras":extras} ac_JSONFragment]];
        [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:@"uexLocalNotification.onMessage" arguments:ACArgsPack(notID,message,[@{@"extras":extras} ac_JSONFragment])];
        /*
         EBrowserView *brwView = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer].meRootBrwWnd.meBrwView;
         if (brwView) {
         
         [brwView  stringByEvaluatingJavaScriptFromString:jsStr];
         
         }
         */
        //[EUtility evaluatingJavaScriptInRootWnd:jsStr];
        application.applicationIconBadgeNumber = 0;
//        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:UEX_LOCALIZEDSTRING(@"提示") message:msg delegate:self cancelButtonTitle:UEX_LOCALIZEDSTRING(@"确认") otherButtonTitles:nil];
//        alertView.tag = 200;
//        [alertView show];
//        [alertView release];
        
    } else {
        
        //NSString * jsStr = [NSString stringWithFormat:@"uexLocalNotification.onActive(\'%@\',\'%@\')",notID,message];
        /*
        EBrowserView *brwView = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer].meRootBrwWnd.meBrwView;
        if (brwView) {
            
            [brwView  stringByEvaluatingJavaScriptFromString:jsStr];
            
        }
         */
        //[EUtility evaluatingJavaScriptInRootWnd:jsStr];
        [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:@"uexLocalNotification.onActive" arguments:ACArgsPack(notID,message,[@{@"extras":extras} ac_JSONFragment])];
        application.applicationIconBadgeNumber = 0;
        
    }

}
+(NSDictionary *)parseRemoteNotification:(NSDictionary*)userinfo{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    NSMutableDictionary *extras=[NSMutableDictionary dictionary];
    NSArray *keys=[userinfo allKeys];
    
    for(int i=0;i<[keys count];i++){
        NSString *keyStr=keys[i];
        [extras setValue:[userinfo objectForKey:keyStr] forKey:keyStr];
    }
    [dict setValue:extras forKey:@"extras"];
    return dict;
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
    NSMutableDictionary *extras=[NSMutableDictionary dictionary];
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
    if (count > 8) {
        extras = [[inArguments objectAtIndex:8] ac_JSONValue];
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
		userDict = [NSDictionary dictionaryWithObjectsAndKeys:notificationId,@"notificationId",msg,@"msg",extras,@"extras",nil];
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
	//NSString *jsStr = [NSString stringWithFormat:@"uexLocalNotification.cbGetData(\'%@\',\'%@\')", notificationId, msg];
	[self.webViewEngine callbackWithFunctionKeyPath:@"uexLocalNotification.cbGetData" arguments:ACArgsPack(notificationId,msg)];
}

@end
