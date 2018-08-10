//
//  CommonUtils.h
//  FreeRDP
//
//  Created by conan on 2018/8/4.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommonUtils : NSObject
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;
+ (NSString *)cNowTimestamp;
+ (int)isInnerIP:(NSString *)hostName;
+ (UIImage*)text:(NSString*)text addToView:(UIImage*)image textColor:(UIColor*) color;
+ (UIImage*)image:(UIImage*)image addToImage:(UIImage*)bigImage;
+ (UIImage*)convertImageFromeView:(UIView*)view;
@end
