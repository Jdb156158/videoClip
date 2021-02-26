//
//  GifUtils.h
//  videoClip
//
//  Created by db J on 2021/2/25.
//

#import <Foundation/Foundation.h>
#import "EditImageView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GifType) {
    GifFromVideo = 0,
    GifFromBurst,
    GifFromLivephoto,
    GifFromImgs,
    GifFromGif
};

@interface GifUtils : NSObject

/** 视频-->图片 将视频转为按指定间隔转成一组图片
 * avasset : 视频资源
 * interval : 每帧之间的间隔
 * block 返回所需的一组图片
 */
+ (void)imgsWithVideoAsset:(AVAsset *)avasset withTimeInterval:(float)interval withTimeRange:(CMTimeRange)range completion:(void(^)(NSMutableArray *images))completionBlock;

/** 图片-->gif
 * images : 原材料
 * delay : 每一张图片停留的时间
 * haveWaterMark : 是否带有水印
 * markImage : 水印图片
 * isRecord : 是否是录制的视频
 * markIV: 自定义水印的视图
 * markFrame: 自定义水印的frame
 * isPhotoToGif : YES:需要统一尺寸 NO：不需要统一尺寸
 */
+ (void)gifWithImages:(NSArray *)images withDelay:(float)delay targetPath:(NSString *)targetPath withMuArr:(NSMutableArray *)textfieldDictArr markImage:(UIImage *)markImage isRecord:(BOOL)isRecord markIV:(EditImageView *)markIV markFrame:(CGRect)markFrame isPhotoToGif:(BOOL)isPhotoToGif;



+ (void)gifWithImages:(NSArray *)images scale:(CGFloat)scale withDelay:(float)delay targetPath:(NSString *)targetPath withMuArr:(NSMutableArray *)textfieldDictArr markImage:(UIImage *)markImage isRecord:(BOOL)isRecord markIV:(EditImageView *)markIV markFrame :(CGRect)markFrame isPhotoToGif:(BOOL)isPhotoToGif ;
@end

NS_ASSUME_NONNULL_END
