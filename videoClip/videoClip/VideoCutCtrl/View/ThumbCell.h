//
//  ThumbCell.h
//  videoClip
//
//  Created by db J on 2021/2/25.
//

#import <UIKit/UIKit.h>
#import "FrameModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ThumbCell : UICollectionViewCell
@property (nonatomic, strong) FrameModel *model;
@property (nonatomic, assign) BOOL showBiao;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImg;
@end

NS_ASSUME_NONNULL_END
