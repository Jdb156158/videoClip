//
//  FilterCollectionCell.h
//  videoClip
//
//  Created by db J on 2021/2/26.
//

#import <UIKit/UIKit.h>
#import "Filter.h"
NS_ASSUME_NONNULL_BEGIN

@interface FilterCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *picIV;
@property (weak, nonatomic) IBOutlet UILabel *filterNameLb;
@property (assign, nonatomic) BOOL isSelect;
- (void)loadUIWithFilter:(Filter *)filter image:(UIImage *)image index:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
