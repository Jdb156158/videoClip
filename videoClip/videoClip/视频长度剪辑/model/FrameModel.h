//
//  FrameModel.h
//  videoClip
//
//  Created by db J on 2021/2/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrameModel : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSString *imagePath;

@end

NS_ASSUME_NONNULL_END
