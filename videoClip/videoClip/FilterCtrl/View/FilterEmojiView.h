//
//  FilterEmojiView.h
//  videoClip
//
//  Created by db J on 2021/2/26.
//

#import <UIKit/UIKit.h>
#import "Filter.h"

NS_ASSUME_NONNULL_BEGIN

@interface FilterEmojiView : UIView

@property (nonatomic,copy) void (^didSelectFilterAtIndex)(NSIndexPath *indexPath,UICollectionView *collectionView,Filter *filter);
@property (nonatomic,copy) void (^didCloseFilterDisplayView)(void);

@property (strong, nonatomic) UICollectionView *filterCollection;
@property (strong, nonatomic) UIImage *sourceImage;
@property (strong, nonatomic) NSArray<Filter *> *filters;
@property (strong, nonatomic) NSIndexPath *lastIndexPath;
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
