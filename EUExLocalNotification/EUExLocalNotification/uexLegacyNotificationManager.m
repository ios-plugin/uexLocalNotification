/**
 *
 *	@file   	: uexLegacyNotificationManager.m  in EUExLocalNotification
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


#import "uexLegacyNotificationManager.h"



@interface uexLegacyNotificationManager()
@property (nonatomic,strong,nullable)UILocalNotification *launchNotification;
@end

@implementation uexLegacyNotificationManager


+ (instancetype)sharedManager{
    static uexLegacyNotificationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

static uexLocalNotificationData* _Nullable dataForNotification(UILocalNotification *notification){
    
    uexLocalNotificationData *data = [uexLocalNotificationData new];
    NSDictionary *userInfo = notification.userInfo;
    if (!!userInfo[kUexLocalNotificationSpecifierKey]) {
        return nil;
    }
    data.message = userInfo[kUexLocalNotificationMessageKey];
    data.uid = userInfo[kUexLocalNotificationIDKey];
    data.extras = userInfo[kUexLocalNotificationExtrasKey];
    return data;
}


- (void)addaddNotificationWithData:(uexLocalNotificationData *)data{
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    
    


        
    notif.repeatInterval = data.repeatInterval;
    notif.fireDate = data.fireDate;
    notif.hasAction = data.hasAction;
    notif.timeZone = [NSTimeZone defaultTimeZone];
    notif.alertBody = data.message;
    notif.alertAction = data.buttonTitle;
    notif.soundName = UILocalNotificationDefaultSoundName;
    if (data.badgeNumber) {
        notif.applicationIconBadgeNumber = data.badgeNumber.integerValue;
    }

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[kUexLocalNotificationIDKey] = data.uid;
    userInfo[kUexLocalNotificationMessageKey] = data.message;
    userInfo[kUexLocalNotificationExtrasKey] = data.extras;
    userInfo[kUexLocalNotificationSpecifierKey] = UEX_TRUE;
    notif.userInfo = userInfo;
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
}

- (void)cancelNotificationWithUID:(NSString *)uid{
    NSArray<UILocalNotification *> *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notif in notifications){
        if ([notif.userInfo[kUexLocalNotificationIDKey] isEqual:uid]) {
            [[UIApplication sharedApplication]cancelLocalNotification:notif];
            break;
        }
    }
}

- (void)cancelAllNotifications{
    [[UIApplication sharedApplication]cancelAllLocalNotifications];
}

- (void)notifyRootPageFinishingLoading{
    uexLocalNotificationData *data = dataForNotification(self.launchNotification);
    if (data) {
        self.onActionHandler(data);
    }
    self.launchNotification = nil;
}
- (void)notifyApplicationLaunchWithOptions:(NSDictionary *)launchOptions{
    self.launchNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    uexLocalNotificationData *data = dataForNotification(notification);
    if (data) {
        if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
            self.onMessageHandler(data);
        }else{
            self.onActionHandler(data);
        }
    }
}


- (void)requestAuthorization{
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
}



@end
