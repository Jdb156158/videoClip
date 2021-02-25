//
//  VideoPickerController.h
//  videoClip
//
//  Created by db J on 2021/2/24.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface VideoPickerController : UIViewController
@property (nonatomic,copy) void (^needCut)(AVAsset *asset,NSMutableArray *images);
@property (nonatomic,copy) void (^jumpEdit)(NSMutableArray *images);
@end

NS_ASSUME_NONNULL_END
