//
//  SettingManager.h
//  gifmaker
//
//  Created by 张帆 on 2017/10/30.
//  Copyright © 2017年 adesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingManager : NSObject

@property (nonatomic, assign)BOOL isCameraLightOn, isCameraFront;
@property (nonatomic, assign)float maxImgPix, maxGifImgDelay, floatFps;
@property (nonatomic, assign)NSInteger videoExractFPS;
@property (nonatomic, assign)NSInteger clarity;

+ (instancetype)shareManager;

@end
