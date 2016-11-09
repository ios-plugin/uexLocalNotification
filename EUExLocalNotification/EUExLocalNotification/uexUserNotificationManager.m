/**
 *
 *	@file   	: uexUserNotificationManager.m  in EUExLocalNotification
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


#import "uexUserNotificationManager.h"
#import <UserNotifications/UserNotifications.h>

@interface uexUserNotificationManager()
@property (nonatomic,assign)BOOL isLaunchNotification;
@property (nonatomic,strong)uexLocalNotificationData *launchNotificationData;
@end




@implementation uexUserNotificationManager





static uexLocalNotificationData* _Nullable dataForNotification(UNNotification *notification){

    NSDictionary *userinfo = notification.request.content.userInfo;
    if (!userinfo[kUexLocalNotificationSpecifierKey]) {
        return nil;
    }
    
    uexLocalNotificationData *data = [uexLocalNotificationData new];
    data.message = notification.request.content.body;
    data.uid = notification.request.identifier;
    data.extras = userinfo[kUexLocalNotificationExtrasKey];

    return data;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSUInteger))completionHandler{
    uexLocalNotificationData *data = dataForNotification(notification);
    if (data) {
        self.onMessageHandler(data);
        //completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
        
        //应用在前台时不显示通知,和iOS9保持一致
        completionHandler(UNNotificationActionOptionNone);
    }
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    uexLocalNotificationData *data = dataForNotification(response.notification);
    if (data) {
        completionHandler();
        if (self.isLaunchNotification) {
            self.isLaunchNotification = NO;
            self.launchNotificationData = data;
        }else{
            self.onActionHandler(data);
        }
        
        
        
    }
}

+ (instancetype)sharedManager{
    static uexUserNotificationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}





- (void)notifyApplicationLaunchWithOptions:(nullable NSDictionary *)launchOptions{
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        self.isLaunchNotification = YES;
    }
    

}
- (void)notifyRootPageFinishingLoading{
    self.isLaunchNotification = NO;
    if (self.launchNotificationData) {
        self.onActionHandler(self.launchNotificationData);
        self.launchNotificationData = nil;
    }
}

- (void)requestAuthorization{
    [[UNUserNotificationCenter currentNotificationCenter]requestAuthorizationWithOptions:UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
        ACLogDebug(@"request authorization granted: %@ ,error: %@",@(granted),error.localizedDescription);
    }];
}



- (void)addaddNotificationWithData:(uexLocalNotificationData *)data{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = data.title;
    content.subtitle = data.subtitle;
    content.body = data.message;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[kUexLocalNotificationSpecifierKey] = UEX_TRUE;
    userInfo[kUexLocalNotificationExtrasKey] = data.extras;
    content.userInfo = userInfo;
    content.badge = data.badgeNumber;
    
    UNNotificationTrigger *trigger;
    if (data.repeatInterval == 0) {
        trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:[data.fireDate timeIntervalSinceNow] repeats:NO];
    }else{
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [calendar setTimeZone:[NSTimeZone localTimeZone]];
        NSDateComponents *components = [calendar components:data.repeatInterval fromDate:data.fireDate];
        trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    }
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:data.uid content:content trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter]addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if(error){
            ACLogWarning(@"uexLocalNotification add notification ERROR: %@",error.localizedDescription);
        }
    }];

    
    
    
}
- (void)cancelNotificationWithUID:(NSString *)uid{
    if (!uid) {
        return;
    }
    [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[uid]];
    
}
- (void)cancelAllNotifications{
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
}



@end
