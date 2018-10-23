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
        
        if ([data.fireDate timeIntervalSinceNow] < 0) {
            return;
        }
        
        trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:[data.fireDate timeIntervalSinceNow] repeats:NO];
    }else{
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [calendar setTimeZone:[NSTimeZone localTimeZone]];
        
        NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;//这句我也不明白具体时用来做什么。。。
        NSDateComponents *comps = [calendar components:unitFlags fromDate:data.fireDate];
        
        //用户设置的首次触发时间
        NSUInteger weekNumber = [comps weekday]; //获取星期对应的长整形字符串
        NSUInteger day=[comps day];//获取日期对应的长整形字符串
        //NSUInteger year=[comps year];//获取年对应的长整形字符串
        NSUInteger month=[comps month];//获取月对应的长整形字符串
        NSUInteger hour=[comps hour];//获取小时对应的长整形字符串
        NSUInteger minute=[comps minute];//获取月对应的长整形字符串
        NSUInteger second=[comps second];//获取秒对应的长整形字符串
        
        NSDateComponents *components = [[NSDateComponents alloc] init];
        switch (data.repeatInterval) {
            case NSCalendarUnitDay:
            {
                components.hour = hour;
                components.minute = minute;
                components.second = second;
            }
                break;
            case NSCalendarUnitWeekOfYear:
            {
                components.weekday = weekNumber;
                components.hour = hour;
                components.minute = minute;
                components.second = second;
            }
                break;
            case NSCalendarUnitMonth:
            {
                components.day = day;
                components.hour = hour;
                components.minute = minute;
                components.second = second;
            }
                break;
            case NSCalendarUnitYear:
            {
                components.month = month;
                components.day = day;
                components.hour = hour;
                components.minute = minute;
                components.second = second;
            }
                break;
                
            default:
                return;
                break;
        }
        
        trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
        
        UNCalendarNotificationTrigger *testTrigger = (UNCalendarNotificationTrigger *)trigger;
        NSLog(@"AppCan --> uexLocalNotification --> add --> next time = %@",[testTrigger nextTriggerDate]);
    }
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:data.uid content:content trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter]addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if(error){
            ACLogWarning(@"AppCan --> uexLocalNotification --> uexLocalNotification add notification ERROR: %@",error.localizedDescription);
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
