//
//  UIImage+Extras.h
//  videoClip
//
//  Created by db J on 2021/2/26.
//

#import <UIKit/UIKit.h>
#import "Filter.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Extras)

+ (UIImage *)imageByCroppingCGImage:(CGImageRef)cgImage toSize:(CGSize)size;
+ (UIImage *)imageByCroppingVideoFrameCGImage:(CGImageRef)cgImage toSize:(CGSize)size;
- (UIImage *)applyFilter:(Filter *)filter;

@end

NS_ASSUME_NONNULL_END
