//
//  Filter.h
//  videoClip
//
//  Created by db J on 2021/2/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Filter : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *ciFilterTitle;
@property (nonatomic) CGFloat ciFilterIntensivity;


- (instancetype)initWithTitle:(NSString *)title ciFilterTitle:(NSString *)ciFilterTitle;
- (instancetype)initWithTitle:(NSString *)title ciFilterTitle:(NSString *)ciFilterTitle ciFilterIntensivity:(CGFloat)filterIntensivity;
- (BOOL)isNormal;
@end

NS_ASSUME_NONNULL_END
