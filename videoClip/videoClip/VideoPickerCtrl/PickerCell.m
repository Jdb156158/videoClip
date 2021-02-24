//
//  PickerCell.m
//  videoClip
//
//  Created by db J on 2021/2/24.
//

#import "PickerCell.h"
@interface PickerCell ()

@property (assign, nonatomic) PHImageRequestID requestID, videoRequestID;

@end

@implementation PickerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setPickerPHAsset:(PHAsset *)asset  index:(int)index {
    [self initCoverImg:asset index:index];
    [self initTimeLabel:asset index:index];
}

#pragma mark - 非公开
- (void)initCoverImg:(PHAsset *)asset index:(int)index {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode   = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.synchronous = NO;
    options.networkAccessAllowed = YES;
    [self.coverImg setImage:nil];
    
    int magicIndex = index + 100;
    if (self.coverImg.tag != magicIndex) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
    }
    
    self.coverImg.tag = magicIndex;
    CGSize size = [self sizeMaxWidth:300.f withAsset:asset];
    self.requestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.coverImg.tag != magicIndex) {
                return;
            }
            [self.coverImg setImage:result];
        });
    }];
}

- (void)initTimeLabel:(PHAsset *)asset index:(int)index {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    int newIndex = index + 200;
    if (self.videoTimeLabel.tag != newIndex) {
        [[PHImageManager defaultManager] cancelImageRequest:self.videoRequestID];
    }
    self.videoTimeLabel.tag = newIndex;
    self.videoRequestID = [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        float videoLength = (float)asset.duration.value / asset.duration.timescale;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.videoTimeLabel.tag != newIndex) {
                return;
            }
            self.videoTimeLabel.text = [NSString stringWithFormat:@"%lds", (long)videoLength];
        });
    }];
}

- (CGSize)sizeMaxWidth:(float)maxWidth withAsset:(PHAsset *)asset {
    
    float scale = 1.0f;
    CGSize resultSize;
    if (asset.pixelWidth > asset.pixelHeight) {
        //原图 宽>高
        if (maxWidth > asset.pixelWidth) {
            scale = 1.0f;
        }else {
            scale = asset.pixelWidth / maxWidth;
        }
    }else {
        //原图 宽<=高
        if (maxWidth > asset.pixelHeight) {
            scale = 1.0f;
        }else {
            scale = asset.pixelHeight / maxWidth;
        }
    }
    resultSize = CGSizeMake(asset.pixelWidth/scale, asset.pixelHeight/scale);
    
//    NSLog(@"--------------------------");
//    NSLog(@"资源size%@， 缩小倍数%02f", NSStringFromCGSize(resultSize), (float)scale);
//    NSLog(@"--------------------------");
    return resultSize;
}

@end
