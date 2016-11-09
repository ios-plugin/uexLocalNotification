/**
 *
 *	@file   	: EUExLocalNotification.h  in EUExLocalNotification
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


#import <Foundation/Foundation.h>
#import <AppCanKit/AppCanKit.h>

NS_ASSUME_NONNULL_BEGIN








@interface uexLocalNotificationData: NSObject

@property (nonatomic,strong) NSString *message;
@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong) NSDate *fireDate;
@property (nonatomic,strong,nullable) NSNumber *badgeNumber;
@property (nonatomic,strong,nullable) NSDictionary *extras;
@property (nonatomic,strong,nullable) NSURL *imageURL;
@property (nonatomic,strong,nullable) NSString *title;
@property (nonatomic,strong,nullable) NSString *subtitle;
@property (nonatomic,assign) NSCalendarUnit repeatInterval;
@property (nonatomic,assign) BOOL hasAction;
@property (nonatomic,strong,nullable) NSString *buttonTitle;

@end




@interface EUExLocalNotification: EUExBase

@end



typedef void(^NotificationDataHandleBlock)(uexLocalNotificationData *);


extern NSString *const kUexLocalNotificationSpecifierKey;
extern NSString *const kUexLocalNotificationIDKey;
extern NSString *const kUexLocalNotificationMessageKey;
extern NSString *const kUexLocalNotificationExtrasKey;


@protocol uexLocalNotificationManager <NSObject>

@property (nonatomic,strong,nullable)NotificationDataHandleBlock onActionHandler;
@property (nonatomic,strong,nullable)NotificationDataHandleBlock onMessageHandler;



+ (instancetype)sharedManager;
- (void)notifyApplicationLaunchWithOptions:(nullable NSDictionary *)launchOptions;
- (void)notifyRootPageFinishingLoading;

- (void)requestAuthorization;
- (void)addaddNotificationWithData:(uexLocalNotificationData *)data;
- (void)cancelNotificationWithUID:(NSString *)uid;
- (void)cancelAllNotifications;

@end

NS_ASSUME_NONNULL_END
