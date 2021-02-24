//
//  PickerCell.h
//  videoClip
//
//  Created by db J on 2021/2/24.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface PickerCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImg;
@property (weak, nonatomic) IBOutlet UILabel *videoTimeLabel;

- (void)setPickerPHAsset:(PHAsset *)asset  index:(int)index;
@end

NS_ASSUME_NONNULL_END
