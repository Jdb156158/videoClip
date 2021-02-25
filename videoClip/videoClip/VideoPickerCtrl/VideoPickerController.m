//
//  VideoPickerController.m
//  videoClip
//
//  Created by db J on 2021/2/24.
//

#import "VideoPickerController.h"
#import "PickerCell.h"
#import "CellFlowLayout.h"
#import "HudManager.h"
#import "SettingManager.h"

@interface VideoPickerController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *pickerModels, *selectedIndexs;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation VideoPickerController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self initPickerData];
        dispatch_async(dispatch_get_main_queue(), ^{
            //相册数据获取完成
            [self.collectionView reloadData];
        });
    });
}

#pragma mark - get
- (NSMutableArray *)pickerModels {
    
    if (!_pickerModels) {
        _pickerModels = [NSMutableArray array];
    }
    return _pickerModels;
}

- (NSMutableArray *)selectedIndexs {
    if (!_selectedIndexs) {
        _selectedIndexs = [NSMutableArray array];
    }
    return _selectedIndexs;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        CellFlowLayout *configLayout = [[CellFlowLayout alloc]init];
        configLayout.kCollectionViewWidth = ([UIScreen mainScreen].bounds.size.width-60)/3;
        configLayout.kCollectionViewHeight = 100;
        configLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        configLayout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);

        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:configLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;//隐藏滚动条
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"PickerCell" bundle:nil] forCellWithReuseIdentifier:@"PickerCell"];

    }
    return _collectionView;
}

#pragma mark - data
- (void)initPickerData {
    //刷新前清空一下
    [self.pickerModels removeAllObjects];
    
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *assetCollection in assetCollections) {
        [self enumerateAssetsInAssetCollection:assetCollection original:NO];
    }
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    [self enumerateAssetsInAssetCollection:cameraRoll original:NO];

}

//细分照片类型
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original{

    PHFetchOptions *fetchOption = [[PHFetchOptions alloc] init];
    fetchOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOption];
    for (PHAsset *asset in assets) {
        BOOL isLivePhoto, isVideo, isBurst, isPhoto;
        BOOL isNotLivePhoto;
        BOOL isGIF = NO;
        if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"] ||
            [[asset valueForKey:@"filename"] hasSuffix:@"gif"]) {
            isGIF = YES;
        }else {
            isGIF = NO;
        }
        if (@available(iOS 9.1, *)){
            isLivePhoto = (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive || asset.mediaSubtypes == 520);    //livephot 属于 照片细分type
            if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive || asset.mediaSubtypes == 520) {
                isNotLivePhoto = NO;
            }else{
                isNotLivePhoto = YES;
            }
        }else {
            isLivePhoto = NO;
            isNotLivePhoto = YES;
        }
        isBurst = asset.representsBurst;
        isVideo = (asset.mediaType == PHAssetMediaTypeVideo);
        isPhoto = (asset.mediaType == PHAssetMediaTypeImage) && isNotLivePhoto && !isGIF;
        
        //按条件添加
        if (isLivePhoto) {
        }
        if (isVideo) {
            [self.pickerModels addObject:asset];
            continue;
        }
        if (isBurst) {
        }
        if (isPhoto) {
        }
        if (isGIF) {
        }
    }
}

#pragma mark - collectiondelegate


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.pickerModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //PickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PickerCell class]) forIndexPath:indexPath];
    
    PickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PickerCell" forIndexPath:indexPath];
    
    if (indexPath.item <= self.pickerModels.count - 1) {
        PHAsset *asset = self.pickerModels[indexPath.item];
        [cell setPickerPHAsset:asset index:indexPath.item];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item >= self.pickerModels.count) {
        NSLog(@"数组越界");
        return;
    }
    
    PHAsset *asset = self.pickerModels[indexPath.row];
    
    [self videoTouched:asset];
    
}

- (void)videoTouched:(PHAsset *)asset {
    [HudManager showLoading];
    
    __weak typeof(self) weakSelf = self;
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable avasset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        __block BOOL needCut = asset.duration*[SettingManager shareManager].videoExractFPS > PIXEL_VIDEOGIF_SEGEMENT_NUMBER;//asset.duration > MAX_RECORD_TIME
        float interval = needCut ? 1.0f : [SettingManager shareManager].floatFps;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self imgsWithVideoAsset:avasset withTimeInterval:interval withTimeRange:kCMTimeRangeZero completion:^(NSMutableArray *images) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [HudManager hideLoading];
                    if (images.count > 0) {
                        if (needCut) {
                            //需要裁剪大小
                            //[weakSelf asyncPushCutCtrl:avasset withImages:images];
                            if (weakSelf.needCut) {
                                weakSelf.needCut(avasset, images);
                            }
                        } else {
                            //不需要裁剪直接编辑
                            //[weakSelf pushEditCtrlWith:images type:GifFromVideo];
                            if (weakSelf.jumpEdit) {
                                weakSelf.jumpEdit(images);
                            }
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }else {
                        [HudManager showWord:NSLocalizedString(@"get_imgs_fail", nil)];
                    }
                });
            }];
        });
    }];
}

/** 视频-->图片 将视频转为按指定间隔转成一组图片
 * avasset : 视频资源
 * interval : 每帧之间的间隔
 * block 返回所需的一组图片
 */
-(void)imgsWithVideoAsset:(AVAsset *)avasset withTimeInterval:(float)interval withTimeRange:(CMTimeRange)range completion:(void(^)(NSMutableArray *images))completionBlock {
    NSMutableArray *resultImages = [NSMutableArray array];
    
    if (interval <= 0) {
        interval = 0.5;
    }
    
    CMTime cmDuration = avasset.duration;
    int startSeconds = 0;
    
    if (range.duration.value != 0) {
        cmDuration = range.duration;
        startSeconds = (int)(range.start.value / range.start.timescale);
    }
    
    float videoLength = (float)cmDuration.value / cmDuration.timescale;
    NSUInteger frameCount = videoLength / interval;
//    frameCount = frameCount > 30 ? 30 : frameCount;
    //确定时间间隔 timePoints->图片张数
    NSMutableArray *timePoints = [NSMutableArray array];
    for (int i = 0; i<frameCount; i++) {
        float point = i * interval + startSeconds;
        CMTime curTime = CMTimeMakeWithSeconds(point, 600);
        [timePoints addObject:[NSValue valueWithCMTime:curTime]];
    }
    
    if (timePoints.count == 0) {
        completionBlock(nil);
    }
    
    CGFloat pixel;
    if (timePoints.count <= PIXEL_VIDEOGIF_SEGEMENT_NUMBER) {
        pixel = MAX_PIXEL_VIDEOGIF_LESSIMAGE;
    } else {
        pixel = 800;
    }
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:avasset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = [self sizeMaxWidth:800 withAvAsset:avasset];
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    
    NSLock *locker = [[NSLock alloc] init];
    __block NSUInteger blockCount = 0;
    [generator generateCGImagesAsynchronouslyForTimes:timePoints completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        
        [locker lock];
        blockCount ++;
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"无法生成图片, error:%@", error);
        }else {
            UIImage *frameImg =[UIImage imageWithCGImage:image];
            NSString *imgPath = [NSString stringWithFormat:@"%@%ld.png", VIDEO_IMGPATH, blockCount];
            NSData *imgData = UIImageJPEGRepresentation(frameImg, 1.0);
            [self deleteFileAtPath:imgPath];
            [imgData writeToFile:imgPath atomically:YES];
            [resultImages addObject:imgPath];
            frameImg = nil;
        }
        
        if (blockCount == timePoints.count) {
            completionBlock(resultImages);
        }
        [locker unlock];
    }];
}

-(CGSize)sizeMaxWidth:(float)maxWidth withAvAsset:(AVAsset *)avasset {
    float scale = 1.0f;
    CGSize resultSize;
//
    NSLog(@"naturalSize.width = %f ,naturalSize.height = %f",avasset.naturalSize.width,avasset.naturalSize.height);

    resultSize = avasset.naturalSize;
    if (avasset.naturalSize.width > avasset.naturalSize.height) {
        //原图 宽>高
        if (maxWidth > avasset.naturalSize.width) {
            scale = 1.0f;
        }else {
            scale = avasset.naturalSize.width / maxWidth;
        }
    }else {
        //原图 宽<=高
        if (maxWidth > avasset.naturalSize.height) {
            scale = 1.0f;
        }else {
            scale = avasset.naturalSize.height / maxWidth;
        }
    }
    resultSize = CGSizeMake(avasset.naturalSize.width/scale, avasset.naturalSize.height/scale);

    NSLog(@"--------------------------");
    NSLog(@"资源size%@， 缩小倍数%02f", NSStringFromCGSize(resultSize), (float)scale);
    NSLog(@"--------------------------");
    return resultSize;
}

-(void)deleteFileAtPath:(NSString *)path{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

@end
