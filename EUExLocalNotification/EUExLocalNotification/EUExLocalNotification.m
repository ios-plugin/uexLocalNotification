//
//  EUExScanner.m
//  AppCan
//
//  Created by AppCan on 11-9-7.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "EUExLocalNotification.h"
#import "EUtility.h"
#import "JSON/JSON.h"
#import <AudioToolbox/AudioToolbox.h>

#define MUTE_NOTI @"mute"//静音
#define SOUND_NOTI @"sound"//铃声
#define VIBRATE_NOTI @"vibrate"//震动
#define BOTH_NOTI @"both"//铃声&震动
#define UNKNOWN_NOTI @"unknown"//未知

#define SOUND_ID_NOTI 1007

@interface EUExLocalNotification()

@end


@implementation EUExLocalNotification

-(id)initWithBrwView:(EBrowserView *) eInBrwView {
	if (self = [super initWithBrwView:eInBrwView]) {
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
            NSString * notID = [userInfo objectForKey:@"notificationId"];
            NSString * jsStr = [NSString stringWithFormat:@"uexLocalNotification.onActive(\'%@\',\'%@\')",notID, [@{@"extras":extras} JSONFragment]];
            [EUtility evaluatingJavaScriptInRootWnd:jsStr];
            [user removeObjectForKey:@"EUExLocalNotification_userInfo"];
        });
    }
}
+(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"AppCan==>>uexLocalNotification==>>didReceiveLocalNotification==>>notification.userInfo==>>%@",notification.userInfo);
    NSDictionary *getInfoDic = notification.userInfo;
    
    UIApplicationState state = [application applicationState];
    NSDictionary *extras=[self parseRemoteNotification:[notification.userInfo objectForKey:@"extras"]];
    NSString *message=[notification.userInfo objectForKey:@"msg"];
    NSString * notID = [notification.userInfo objectForKey:@"notificationId"];
    if (state == UIApplicationStateActive) {
        //		NSString *notID = [notification.userInfo objectForKey:@"notificationId"];
        //NSString * msg = [notification.userInfo objectForKey:@"msg"];
        //		NSString * jsStr = [NSString stringWithFormat:@"uexLocalNotification.onActive(\'%@\', \'%@\')", notID, msg];
        //		EBrowserView *brwView = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer].meRootBrwWnd.meBrwView;
        //		if (brwView) {
        //			[brwView  stringByEvaluatingJavaScriptFromString:jsStr];
        //		}
        
        //app处于活跃状态
        
        if ([getInfoDic objectForKey:@"sound"] != nil) {
            
            if ([getInfoDic[@"sound"] isEqualToString:SOUND_NOTI]) {
                SystemSoundID myAlertSound = SOUND_ID_NOTI;
                AudioServicesPlaySystemSound(myAlertSound);
            }
            
            if ([getInfoDic[@"sound"] isEqualToString:BOTH_NOTI]) {
                SystemSoundID myAlertSound = SOUND_ID_NOTI;
                AudioServicesPlaySystemSound(myAlertSound);
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            
            if ([getInfoDic[@"sound"] isEqualToString:VIBRATE_NOTI]) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            
            if ([getInfoDic[@"sound"] isEqualToString:UNKNOWN_NOTI]) {
                SystemSoundID myAlertSound = SOUND_ID_NOTI;
                AudioServicesPlaySystemSound(myAlertSound);
            }
        }
        
         NSString * jsStr = [NSString stringWithFormat:@"uexLocalNotification.onMessage(\'%@\',\'%@\',\'%@\')",notID,message, [@{@"extras":extras} JSONFragment]];
         [EUtility evaluatingJavaScriptInRootWnd:jsStr];
        application.applicationIconBadgeNumber = 0;
//        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:UEX_LOCALIZEDSTRING(@"提示") message:msg delegate:self cancelButtonTitle:UEX_LOCALIZEDSTRING(@"确认") otherButtonTitles:nil];
//        alertView.tag = 200;
//        [alertView show];
//        [alertView release];
        
    } else {
        //NSDictionary *extras=[self parseRemoteNotification:[notification.userInfo objectForKey:@"extras"]];
//        NSString *extras=[notification.userInfo objectForKey:@"extras"];
//        NSString * notID = [notification.userInfo objectForKey:@"notificationId"];
        
        if ([getInfoDic[@"sound"] isEqualToString:VIBRATE_NOTI] || [getInfoDic[@"sound"] isEqualToString:BOTH_NOTI]) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
        NSString * jsStr = [NSString stringWithFormat:@"uexLocalNotification.onActive(\'%@\',\'%@\',\'%@\')",notID,message, [@{@"extras":extras} JSONFragment]];
        /*
        EBrowserView *brwView = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer].meRootBrwWnd.meBrwView;
        if (brwView) {
            
            [brwView  stringByEvaluatingJavaScriptFromString:jsStr];
            
        }
         */
        [EUtility evaluatingJavaScriptInRootWnd:jsStr];
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
    
//    NSLog(@"add inArguments = %@",inArguments);
//    
//    for (id q1 in inArguments) {
//        
//        NSLog(@"add inArguments class ==== %@",[q1 class]);
//        
//    }
    
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
        extras = [[inArguments objectAtIndex:8] JSONValue];
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
		if ([[NSString stringWithFormat:@"%@",notificationId] isEqualToString:[NSString stringWithFormat:@"%@",notId]]) {
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
    
    if ([[NSString stringWithFormat:@"%@",sound] isEqualToString:MUTE_NOTI]) {
        notif.soundName = nil;
    } else if ([[NSString stringWithFormat:@"%@",sound] isEqualToString:SOUND_NOTI] || [[NSString stringWithFormat:@"%@",sound] isEqualToString:BOTH_NOTI]) {
        notif.soundName = UILocalNotificationDefaultSoundName;
    } else if ([[NSString stringWithFormat:@"%@",sound] isEqualToString:VIBRATE_NOTI]) {
        notif.soundName = nil;
    } else {
        notif.soundName = UILocalNotificationDefaultSoundName;
        sound = UNKNOWN_NOTI;
    }
    
    notif.applicationIconBadgeNumber = badge;
	NSDictionary *userDict = nil;
	if (msg && msg.length > 0) {
		userDict = [NSDictionary dictionaryWithObjectsAndKeys:notificationId,@"notificationId",msg,@"msg",extras,@"extras",sound,@"sound",nil];
	} else {
		userDict = [NSDictionary dictionaryWithObjectsAndKeys:notificationId,@"notificationId",sound,@"sound",nil];
	}
    notif.userInfo = userDict;
    
    NSLog(@"");
    
	[[UIApplication sharedApplication] scheduleLocalNotification:notif];
}

-(void)remove:(NSMutableArray *)inArguments {
	NSString *notificationId = [inArguments objectAtIndex:0];
	NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
	for (UILocalNotification *notification in notifications) {
		NSString *notId = [notification.userInfo objectForKey:@"notificationId"];
		if ([[NSString stringWithFormat:@"%@",notificationId] isEqualToString:[NSString stringWithFormat:@"%@",notId]]) {
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
