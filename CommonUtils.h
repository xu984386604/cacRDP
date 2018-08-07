//
//  CommonUtils.h
//  FreeRDP
//
//  Created by conan on 2018/8/4.
//
//

#import <Foundation/Foundation.h>

@interface CommonUtils : NSObject
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;
+ (NSString *)cNowTimestamp;
@end
