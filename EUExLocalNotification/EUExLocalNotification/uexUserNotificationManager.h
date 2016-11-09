/**
 *
 *	@file   	: uexUserNotificationManager.h  in EUExLocalNotification
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
#import "EUExLocalNotification.h"


@class UNUserNotificationCenter;
@class UNNotification;
@class UNNotificationResponse;
NS_ASSUME_NONNULL_BEGIN
@interface uexUserNotificationManager: NSObject<uexLocalNotificationManager>
@property (nonatomic,strong,nullable)NotificationDataHandleBlock onActionHandler;
@property (nonatomic,strong,nullable)NotificationDataHandleBlock onMessageHandler;



- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSUInteger))completionHandler;

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler;

@end
NS_ASSUME_NONNULL_END
