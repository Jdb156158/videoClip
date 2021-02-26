//
//  GifEditCtrl.h
//  videoClip
//
//  Created by db J on 2021/2/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GifEditCtrl : UIViewController

@property (nonatomic, strong) NSMutableArray *originImages;
@property (nonatomic, assign) GifType gifType;
@property (assign, nonatomic) BOOL isRecord;
@property (nonatomic, assign) float imgDelay;

@end

NS_ASSUME_NONNULL_END
