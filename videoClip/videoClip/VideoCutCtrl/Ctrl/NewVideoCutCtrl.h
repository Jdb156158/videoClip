//
//  NewVideoCutCtrl.h
//  videoClip
//
//  Created by db J on 2021/2/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewVideoCutCtrl : UIViewController

@property (nonatomic, strong) AVAsset *originalAsset;
@property (nonatomic, strong) NSArray *thumbImgs;

@end

NS_ASSUME_NONNULL_END
