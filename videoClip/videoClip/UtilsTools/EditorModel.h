//
//  EditorModel.h
//  videoClip
//
//  Created by db J on 2021/2/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditorModel : NSObject

@property (nonatomic, strong) NSArray  *imgPathArr;//图片路径地址
@property (nonatomic, assign) CGFloat   imgDelay;//gif播放速度
@property (nonatomic, strong) UIImage   *markImg;//水印
@property (nonatomic, assign) BOOL     isRecord;//记录
@property (nonatomic, assign) CGRect    markRect;//水印位置
@property (nonatomic, assign) BOOL     needUnitySize;

@property (nonatomic, assign) CGFloat  shareScale;//分享时的size
@property (nonatomic, assign) CGFloat  maxUseScale;//最大szie

@end

NS_ASSUME_NONNULL_END
