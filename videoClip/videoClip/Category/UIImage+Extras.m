//
//  UIImage+Extras.m
//  videoClip
//
//  Created by db J on 2021/2/26.
//

#import "UIImage+Extras.h"

@implementation UIImage (Extras)
+ (UIImage *)imageByCroppingCGImage:(CGImageRef)cgImage toSize:(CGSize)size {
    double refWidth = CGImageGetWidth(cgImage);
    double refHeight = CGImageGetHeight(cgImage);
    
    double x = (refWidth - size.width) / 2.0;
    double y = (refHeight - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect(cgImage, cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

+ (UIImage *)imageByCroppingVideoFrameCGImage:(CGImageRef)cgImage toSize:(CGSize)size {
    double width = CGImageGetWidth(cgImage);
    double height = CGImageGetHeight(cgImage);
    double newCropWidth, newCropHeight;
    
    if (width < height) {
        if (width < size.width) {
            newCropWidth = size.width;
        } else {
            newCropWidth = width;
        }
        newCropHeight = (newCropWidth * size.height)/size.width;
    } else {
        if (height < size.height) {
            newCropHeight = size.height;
        } else {
            newCropHeight = height;
        }
        newCropWidth = (newCropHeight * size.width)/size.height;
    }
    
    double x = width / 2.0 - newCropWidth / 2.0;
    double y = height / 2.0 - newCropHeight / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, newCropWidth, newCropHeight);
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(cgImage, cropRect);
    
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef];
    CGImageRelease(croppedImageRef);
    
    UIGraphicsBeginImageContext(size);
    [croppedImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

- (UIImage *)applyFilter:(Filter *)filter {
    // Check filter title / if empty return original image back
    if ([filter.ciFilterTitle isEqualToString:@""]) {
        return self;
    }
    
    // Prepare OpenGL ES context (to process filtering on GPU)
    CIImage *ciImage = [CIImage imageWithCGImage:self.CGImage];
    
    // Prepare filter based on ciImage and filter title
    CIFilter *ciFilter = [CIFilter filterWithName:filter.ciFilterTitle withInputParameters:@{kCIInputImageKey: ciImage}];
    
    // Check intensivity / apply only if value is more than 0
    if (filter.ciFilterIntensivity >= 0) {
        [ciFilter setValue:@(filter.ciFilterIntensivity) forKey:kCIInputIntensityKey];
    }
    
    // Get output image
    CIImage *outputCIImage = [ciFilter outputImage];
    struct CGImage *resultCGImage = [((AppDelegate *)[[UIApplication sharedApplication] delegate]).context createCGImage:outputCIImage fromRect:outputCIImage.extent];
    UIImage *resultImage = [UIImage imageWithCGImage:resultCGImage];
    CGImageRelease(resultCGImage);
    
    return resultImage;
}
@end
