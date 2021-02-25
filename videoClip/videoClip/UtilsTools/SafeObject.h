//
//  SafeObject.h
//  videoClip
//
//  Created by db J on 2021/2/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SafeObject : NSObject
#pragma mark - 安全的从字典中取值
+ (BOOL)objIsNull:(id)obj;

+ (NSDictionary *)safeDictionary:(NSDictionary *)dict objectForKey:(NSString *)key;

+ (NSString *)safeString:(NSDictionary *)dict objectForKey:(NSString *)key;

+ (int)safeInt:(NSDictionary *)dict objectForKey:(NSString *)key;//默认-1

+ (BOOL)safeBool:(NSDictionary *)dict objectForKey:(NSString *)key;

+ (float)safeFloat:(NSDictionary *)dict objectForKey:(NSString *)key;

+ (NSURL *)safeUrl:(NSDictionary *)dict objectForKey:(NSString *)key;

+ (NSArray *)safeArray:(NSDictionary *)dict objectForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
