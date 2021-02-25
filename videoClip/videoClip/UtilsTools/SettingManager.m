//
//  SettingManager.m
//  gifmaker
//
//  Created by 张帆 on 2017/10/30.
//  Copyright © 2017年 adesk. All rights reserved.
//

#define USERDEFAULTS [NSUserDefaults standardUserDefaults]
#define USERKEY_CAMERA_LIGHT @"CAMERA_LIGHT"
#define USERKEY_CAMERA_FRONT @"CAMERA_ISFRONT"
#define USERKEY_FPS @"VIDEO_IMG_FPS"
#define USERKEY_MAX_PIXEL @"VIDEO_MAX_PIXEL"
#define USERKEY_MAX_GIFIMG_DELAY @"VIDEO_MAX_GIFIMG_DELAY"

#import "SettingManager.h"

@implementation SettingManager

static SettingManager *manager;
static dispatch_once_t onceToken;

+ (instancetype)shareManager {
    dispatch_once(&onceToken, ^{
        manager = [[SettingManager alloc] init];
    });
    return manager;
}

#pragma mark - get & set

- (float)floatFps {
    float result = 1.00 / [SettingManager shareManager].videoExractFPS;
    return result;
}

//- (NSInteger)clarity {
//    NSInteger result = [SettingManager shareManager].clarity;
//    return result;
//}

//闪光灯
- (void)setIsCameraLightOn:(BOOL)isCameraLightOn {
    [USERDEFAULTS setBool:isCameraLightOn forKey:USERKEY_CAMERA_LIGHT];
}

- (BOOL)isCameraLightOn {
    BOOL isOn = [USERDEFAULTS boolForKey:USERKEY_CAMERA_LIGHT];
    return isOn;
}

//摄像头方向
- (void)setIsCameraFront:(BOOL)isCameraFront {
    [USERDEFAULTS setBool:isCameraFront forKey:USERKEY_CAMERA_FRONT];
}

- (BOOL)isCameraFront {
    BOOL isFront = [USERDEFAULTS boolForKey:USERKEY_CAMERA_FRONT];
    return isFront;
}

//每秒视频张数
- (void)setVideoExractFPS:(NSInteger)videoExractFPS {
    [USERDEFAULTS setFloat:videoExractFPS forKey:USERKEY_FPS];
}

- (NSInteger)videoExractFPS {
    NSInteger fps = [USERDEFAULTS floatForKey:USERKEY_FPS];
    if (fps <= 0.00001f) {
        fps = 5;
    }
    return fps;
}

//提取图片的最大尺寸

- (void)setMaxImgPix:(float)maxImgPix {
    [USERDEFAULTS setFloat:maxImgPix forKey:USERKEY_MAX_PIXEL];
}

- (float)maxImgPix {
    
    float maxPixel = [USERDEFAULTS floatForKey:USERKEY_MAX_PIXEL];
    if (maxPixel <= 1.0f) {
        maxPixel = 100.0f;
    }
    return maxPixel;
}

//slider的最大停留时间
- (void)setMaxGifImgDelay:(float)maxGifImgDelay {
    [USERDEFAULTS setFloat:maxGifImgDelay forKey:USERKEY_MAX_GIFIMG_DELAY];
}

- (float)maxGifImgDelay {
    float maxDelay = [USERDEFAULTS floatForKey:USERKEY_MAX_GIFIMG_DELAY];
    if (maxDelay <= 0.0001f) {
        maxDelay = 1.0f;
    }
    return maxDelay;
}

@end
