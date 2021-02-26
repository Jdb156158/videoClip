//
//  GifResultCtrl.h
//  videoClip
//
//  Created by db J on 2021/2/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GifResultCtrl : UIViewController
@property (assign, nonatomic) float imgDelay;
@property (strong, nonatomic) UIImage *firsrImg;
@property (nonatomic, strong) EditorModel *editorConfigModel;
@end

NS_ASSUME_NONNULL_END
