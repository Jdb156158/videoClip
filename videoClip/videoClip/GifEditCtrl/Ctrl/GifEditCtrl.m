//
//  GifEditCtrl.m
//  videoClip
//
//  Created by db J on 2021/2/25.
//

#import "GifEditCtrl.h"
#import "ThumbCell.h"
#import "FilterEmojiView.h"

@interface GifEditCtrl () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *nowFrameNum;
@property (weak, nonatomic) IBOutlet UIImageView *displayImg;
@property (weak, nonatomic) IBOutlet UISlider *delaySlider;
@property (weak, nonatomic) IBOutlet UILabel *delayLabel;
@property (weak, nonatomic) IBOutlet UIImageView *markIV;
@property (strong, nonatomic) EditImageView *markIVForEdit;
@property (weak, nonatomic) IBOutlet UIView *yuanlanBgView;

@property (weak, nonatomic) IBOutlet UIButton *zantingBtn;
@property (weak, nonatomic) IBOutlet UIButton *daoxuBtn;
@property (weak, nonatomic) IBOutlet UIButton *cutBtn;
@property (weak, nonatomic) IBOutlet UIButton *filterBtn;
@property (weak, nonatomic) IBOutlet UIButton *changeTextBnt;

@property (strong, nonatomic) UICollectionView *thumbCollection;

@property (nonatomic, strong) NSMutableArray *allModels, *selectedModels;
@property (nonatomic, assign) NSInteger currentIndex, lastIndex;
@property (nonatomic, assign) BOOL isReverse, isPlayPause,openFilter;//正序/倒序、播放/暂停、是否打开滤镜view

//当前滤镜
@property (strong, nonatomic) FilterEmojiView *filterDisplayView;
@property (strong, nonatomic) Filter *activeFilter;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;

@end

@implementation GifEditCtrl{
    NSTimer *_playTimer;
    ThumbCell *_lastCell;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

// 视图实际可见时调用
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self refreshDataAndView];
    self.currentIndex = 0;
    [self initPlayTimer:self.imgDelay isReverseOrder:self.isReverse];
    _nowFrameNum.text = [NSString stringWithFormat:@"%ld%@", (long)self.selectedModels.count, @"帧"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initOriginData];
    [self initSliderAndImgDelay];
    [self initCollection];
    
    //当前滤镜
    self.activeFilter = self.filterDisplayView.filters.firstObject;
}

- (void)initCollection {
    [self.yuanlanBgView addSubview:self.thumbCollection];
}

- (UICollectionView *)thumbCollection{
    if (!_thumbCollection) {
        
        NSInteger allTime = PIXEL_VIDEOGIF_SEGEMENT_NUMBER / [SettingManager shareManager].videoExractFPS;
        NSLog(@"======videoExractFPS %ld",[SettingManager shareManager].videoExractFPS);
        NSInteger width = (K_W-24- 1*allTime) / allTime;   //保证是一排10个，一屏的时间刚好20s
        
        CellFlowLayout *configLayout = [[CellFlowLayout alloc]init];
        configLayout.kCollectionViewWidth = width;
        configLayout.kCollectionViewHeight = 60;
        configLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        configLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);

        _thumbCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-24, 60) collectionViewLayout:configLayout];
        _thumbCollection.delegate = self;
        _thumbCollection.dataSource = self;
        _thumbCollection.showsVerticalScrollIndicator = NO;//隐藏滚动条
        _thumbCollection.userInteractionEnabled = NO;//禁止交互
        _thumbCollection.backgroundColor = [UIColor yellowColor];
        [_thumbCollection registerNib:[UINib nibWithNibName:@"ThumbCell" bundle:nil] forCellWithReuseIdentifier:@"ThumbCell"];

    }
    return _thumbCollection;
}

- (void)initBaseView {
    //[_delaySlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
    _delaySlider.maximumValue = [SettingManager shareManager].maxGifImgDelay;
}

- (void)initOriginData {
    _allModels = [NSMutableArray array];
    for (NSString *imgPath in _originImages) {
        FrameModel *model = [[FrameModel alloc]init];
        model.imagePath = imgPath;
        model.isSelected = YES;
        [self.allModels addObject:model];
    }
}

- (void)initSliderAndImgDelay {
    if (_gifType != GifFromGif) {
        float timeDelay = IMG_DELAY_DEFAULT;
        if (_gifType == GifFromVideo || _gifType == GifFromLivephoto) {
            timeDelay = 0.15f;
        }
        self.imgDelay = timeDelay;
    }
    _delaySlider.value = self.imgDelay;
    _isReverse = IMG_REVERSE_DEFAULT;
    _delayLabel.text = [NSString stringWithFormat:@"%.2fs", self.imgDelay];
}

- (FilterEmojiView *)filterDisplayView {
    
    __weak typeof(self) weakSelf = self;
    
    if (!_filterDisplayView) {
        CGFloat height = IS_IPhoneX_All ? 213 : 179;
        _filterDisplayView = [[FilterEmojiView alloc] initWithFrame:CGRectMake(0, K_H, K_W, height)];
        _filterDisplayView.backgroundColor = [UIColor blackColor];
        FrameModel *model = self.selectedModels.firstObject;
        _filterDisplayView.sourceImage = [UIImage imageWithContentsOfFile:model.imagePath];
        
        _filterDisplayView.didCloseFilterDisplayView = ^{
            weakSelf.openFilter = NO;
        };
        
        _filterDisplayView.didSelectFilterAtIndex = ^(NSIndexPath * _Nonnull indexPath, UICollectionView * _Nonnull collectionView, Filter * _Nonnull filter) {
            weakSelf.currentIndexPath = indexPath;
            weakSelf.filterDisplayView.lastIndexPath = indexPath;
            weakSelf.activeFilter = filter;
            [weakSelf refreshDataAndView];
            [weakSelf.filterDisplayView reloadData];
        };
        [self.view addSubview:_filterDisplayView];
    }
    return _filterDisplayView;
}

#pragma mark - get & set
- (void)updateWaterMark {
    // 只会从非VIP切换到VIP状态。 对于VIP的水印， 在选择水印图片后， 进行初始化。
    // 因此， 这里只做删除默认gif制作的水印的处理。
    //self.markIV.hidden = true;
    //self.clearMarkBtn.hidden = true;
}
- (NSMutableArray *)selectedModels {
    if (!_selectedModels) {
        _selectedModels = [NSMutableArray array];
        for (FrameModel *model in self.allModels) {
            if (model.isSelected) {
                [self.selectedModels addObject:model];
            }
        }
    }
    return _selectedModels;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    
    //滚动时间轴
    if (currentIndex>=0 && currentIndex<self.selectedModels.count) {
        bool isAnimated = abs((int)(_lastIndex - currentIndex)) < 2;
        NSIndexPath *pointIndex = [NSIndexPath indexPathForRow:currentIndex inSection:0];
        [_thumbCollection scrollToItemAtIndexPath:pointIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:isAnimated];

        if (self.imgDelay > MIN_SCROOL_TIME) {    //大于指定时间才显示指针
            _lastIndex = currentIndex;

            //找到当前单元格，点亮图标
            if (_lastCell) {
                _lastCell.showBiao = NO;
            }
            ThumbCell *curCell = (ThumbCell *)[_thumbCollection cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
            if (curCell) {
                curCell.showBiao = YES;
                _lastCell = curCell;
            }
        }
        else {
            _lastCell.showBiao = NO;
        }
    }
}

//设置GIF图播放速度
- (void)setImgDelay:(float)imgDelay {
    _imgDelay = imgDelay;
    [self initPlayTimer:imgDelay isReverseOrder:_isReverse];    //改变定时器
}

- (void)setIsReverse:(BOOL)isReverse {
    _isReverse = isReverse;
    [self initPlayTimer:_imgDelay isReverseOrder:isReverse];
}

- (NSMutableArray *)creatTargetImgs {
    NSMutableArray *result = [NSMutableArray array];
    if (_isReverse) {
        for (int i=(int)self.selectedModels.count-1; i>=0; i--) {
            NSInteger randomNum = arc4random() % 100000; // 随机数
            NSString *targetImgPath = [NSString stringWithFormat:@"%@%ldtemp_%d.png", EDIT_IMGPATH,  randomNum, i];
            [SystemUtils deleteFileAtPath:targetImgPath];
            FrameModel *model = _selectedModels[i];
            
            UIImage *image = [UIImage imageWithContentsOfFile: model.imagePath];
            NSData *compressImage = UIImageJPEGRepresentation(image, 1.0);
            [compressImage writeToFile:targetImgPath atomically:YES];
            [result addObject:targetImgPath];
        }
    }else {
        for (int i=0; i<self.selectedModels.count; i++) {
            NSInteger randomNum = arc4random() % 100000; // 随机数
            NSString *targetImgPath = [NSString stringWithFormat:@"%@%ldtemp_%d.png", EDIT_IMGPATH,  randomNum, i];
            [SystemUtils deleteFileAtPath:targetImgPath];
            FrameModel *model = _selectedModels[i];
            UIImage *image = [UIImage imageWithContentsOfFile: model.imagePath];
            NSData *compressImage = UIImageJPEGRepresentation(image, 1.0);
            [compressImage writeToFile:targetImgPath atomically:YES];
            [result addObject:targetImgPath];
        }
    }
    return result;
}

- (NSMutableArray *)createAddTextTargetImgs {
    NSMutableArray *result = [NSMutableArray array];
    if (_isReverse) {
        for (int i=(int)self.allModels.count-1; i>=0; i--) {
            NSInteger randomNum = arc4random() % 100000; // 随机数
            NSString *targetImgPath = [NSString stringWithFormat:@"%@%ldtemp_%d.png", EDIT_IMGPATH,  randomNum, i];
            [SystemUtils deleteFileAtPath:targetImgPath];
            FrameModel *model = self.allModels[i];
            if (model.isSelected) {
                UIImage *image = [UIImage imageWithContentsOfFile: model.imagePath];
                NSData *compressImage = UIImageJPEGRepresentation(image, 1.0);
                BOOL isWrited = [compressImage writeToFile:targetImgPath atomically:YES];
                [result addObject:targetImgPath];
                
                NSLog(@"路径写入 = %d",isWrited);
            }
        }
    }else {
        for (int i=0; i<self.allModels.count; i++) {
            NSInteger randomNum = arc4random() % 100000; // 随机数
            NSString *targetImgPath = [NSString stringWithFormat:@"%@%ldtemp_%d.png", EDIT_IMGPATH,  randomNum, i];
            [SystemUtils deleteFileAtPath:targetImgPath];
            FrameModel *model = self.allModels[i];
            if (model.isSelected) {
                
                UIImage *image = [UIImage imageWithContentsOfFile: model.imagePath];
                NSData *compressImage = UIImageJPEGRepresentation(image, 1.0);
                NSError *error = nil ;
                BOOL isWrited = [compressImage writeToFile:targetImgPath options:NSDataWritingAtomic  error:&error];
                
              if (!isWrited) {
                  NSLog(@"writeToFile failed with error %@", error);
              }
                
//                NSLog(@"路径写入 = %d,error = %@",isWrited,[error localizedDescription]);
                [result addObject:targetImgPath];
            }
        }
    }
    return result;
}

#pragma mark - data
- (void)refreshDataAndView {
    
    NSLog(@"self.activeFilter.ciFilterTitle = %@",self.activeFilter.ciFilterTitle);

    [self.selectedModels removeAllObjects];
    
    
    for (int i = 0;  i< self.allModels.count; i ++) {
        
        FrameModel *model = self.allModels[i];
         if (model.isSelected) {
                   

                   if ([self.activeFilter.ciFilterTitle isEqualToString:@""]) {
                       FrameModel *selectModel  = [[FrameModel alloc]init];
                       selectModel.isSelected = YES;
                       selectModel.imagePath = model.imagePath;
                       [self.selectedModels addObject:selectModel];
                       
                   } else {
                       
                       UIImage *image = [UIImage imageWithContentsOfFile:model.imagePath];
                       UIImage *filterImg = [image applyFilter:self.activeFilter];
                       
                       NSString *imgPath = [NSString stringWithFormat:@"%@%@%d.png",VIDEO_IMGPATH,self.activeFilter.ciFilterTitle,i];
                       
                       FrameModel *selectModel  = [[FrameModel alloc]init];
                    selectModel.isSelected = YES;
                       selectModel.imagePath = imgPath;
                       NSData *imgData = UIImageJPEGRepresentation(filterImg, 1.0);
    
                       BOOL isWrited =  [imgData writeToFile:imgPath atomically:YES];
                       
                       NSLog(@"路径写入 = %d",isWrited);
                       [self.selectedModels addObject:selectModel];
                       
                   }
                   
              
               }
    }
    

    
    NSLog(@"self.selectedModels.count = %lu",(unsigned long)self.selectedModels.count);
    [_thumbCollection reloadData];
}

#pragma mark - play images
- (void)initPlayTimer:(float)interval isReverseOrder:(BOOL)isReverse {
    if (_playTimer) {
        [_playTimer invalidate];
        _playTimer = nil;
    }
    if (isReverse)
        _playTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(playImagesInReverseOrder) userInfo:nil repeats:YES];
    else
        _playTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(playImagesInOrder) userInfo:nil repeats:YES];
}

- (void)playImagesInOrder {
    if (self.selectedModels.count <= 0 || self.isPlayPause) {
        return;
    }
    self.currentIndex ++;   //放前边安全一点
    
    if (_currentIndex >= self.selectedModels.count) {
        self.currentIndex = 0;
    }
    FrameModel *model = self.selectedModels[_currentIndex];
    UIImage *image = [UIImage imageWithContentsOfFile:model.imagePath];
    [_displayImg setImage:image];
}

- (void)playImagesInReverseOrder {
    if (self.selectedModels.count <= 0 || self.isPlayPause) {
        return;
    }
    self.currentIndex --;
    
    if (_currentIndex < 0) {
        self.currentIndex = self.selectedModels.count - 1;
    }
    FrameModel *model = self.selectedModels[_currentIndex];
    UIImage *image = [UIImage imageWithContentsOfFile:model.imagePath];
    [_displayImg setImage:image];
}

- (IBAction)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickZhenListBtn:(id)sender {
    
}

- (IBAction)clickFilterBtn:(id)sender {
    _openFilter = YES;
    CGRect filterFrame = self.filterDisplayView.frame;
    [UIView animateWithDuration:.3 animations:^{
        self.filterDisplayView.frame = CGRectMake(0, K_H - filterFrame.size.height, K_W, filterFrame.size.height);
    }];
}

- (IBAction)clickFinshBtn:(id)sender {
    
    [HudManager showLoading];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SystemUtils deleteFileAtPath:PATH_GIF];
        
        __block NSArray *targetImgs = (NSArray *)[self creatTargetImgs];
        
        NSLog(@"targetImags = %lu",(unsigned long)targetImgs.count);
        UIImage *firstImg = [UIImage imageWithContentsOfFile:targetImgs.firstObject];
        UIImage *markImg;
        __block CGRect markRect = CGRectZero;
        
        BOOL isEn, isJa, isKo;
        isEn = [SystemUtils isEn];
        isJa = [SystemUtils isJP];
        isKo = [SystemUtils isKo];
        markImg = [UIImage imageNamed:@"shuiyin"];
        if (isEn) {
            markImg = [UIImage imageNamed:@"shuiyin_english"];
        }else if (isJa) {
            markImg = [UIImage imageNamed:@"shuiyin_japanese"];
        }else if (isKo) {
            markImg = [UIImage imageNamed:@"shuiyin_Korean"];
        }
        markRect = self.markIV.frame;

        
        //判断是否都是需要统一尺寸
        BOOL needUnitySize = ![self isSameSize:targetImgs];///如果均为同一尺寸的图片，则不需要统一尺寸添加黑边；否则，需要加黑边补全图片;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            EditorModel *editorModel = [[EditorModel alloc]init];
            editorModel.imgPathArr = targetImgs;
            editorModel.isRecord = self.isRecord;
            editorModel.markImg = markImg;
            editorModel.markRect = markRect;
            editorModel.needUnitySize = needUnitySize;
            editorModel.imgDelay = self.imgDelay;
            
            
            CGFloat borderLineSize = 5*1024.0 *1024;
            CGFloat maxLimitSize = 25 * 1024 *1024;
            
            
            [GifUtils gifWithImages:targetImgs  withDelay:self.imgDelay targetPath:PATH_GIF withMuArr:nil markImage:markImg isRecord:self.isRecord markIV:self.markIVForEdit markFrame:markRect isPhotoToGif:needUnitySize];  //保存Gif到沙盒, 默认带水印
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [HudManager hideLoading];
                
                NSData *finalData = [NSData dataWithContentsOfFile:PATH_GIF];
                NSLog(@"orignal  gif %.2f M", (CGFloat)finalData.length / (1024.0 *1024));
                
                CGFloat scale = 1.0 ;
                
                if (finalData.length >= borderLineSize) {
                    
                    editorModel.shareScale = scale * borderLineSize / (CGFloat)finalData.length;
                    
                } else {
                    
                    editorModel.shareScale = scale;
                }
                
                
                if (finalData.length >= maxLimitSize) {
                    
                    editorModel.maxUseScale = scale * ( 25.0 * (1024.0 *1024) / (CGFloat)finalData.length);
                    
                } else {
                    
                    editorModel.maxUseScale = 1.0;
                }
                
                
                NSLog(@" editorModel.imgPathArr.count = %ld ,targetImgs.count = %ld",editorModel.imgPathArr.count,targetImgs.count);
                
                //去到结果页保存
                GifResultCtrl *resultCtrl = [[GifResultCtrl alloc] init];
                resultCtrl.imgDelay = self.imgDelay;
                resultCtrl.firsrImg = firstImg;
                resultCtrl.editorConfigModel = editorModel;
                [self.navigationController pushViewController:resultCtrl animated:YES];
                
            });
            targetImgs = nil;
        });
        
    });
    
}

- (IBAction)sendersliderValueOnChange:(UISlider *)sender {
    _delayLabel.text = [NSString stringWithFormat:@"%.2fs", sender.value];
}

- (IBAction)slderTouchUp:(UISlider *)sender {
    NSLog(@"拖动结束 %f", sender.value);
    self.imgDelay = sender.value;
}

#pragma mark -buttom tool click btn
//暂停/开始
- (IBAction)clickPauseBtn:(UIButton *)sender {
    self.isPlayPause = !sender.selected;
    sender.selected = !sender.selected;
}

//正序/倒序
- (IBAction)clickFlashbackBtn:(UIButton *)sender {
    self.isReverse = !sender.selected;
    sender.selected = !sender.selected;
}

//判断是否为同一尺寸的图片
- (BOOL)isSameSize:(NSArray *)imgs {
    CGSize lastSize = [UIImage imageWithContentsOfFile:imgs.firstObject].size;
    UIImage *image;
    for (NSString *imgPath in imgs) {
        image = [UIImage imageWithContentsOfFile:imgPath];
        CGSize imgSize = image.size;
        if (!CGSizeEqualToSize(imgSize, lastSize)) {
            return NO;
            break;
        }
    }
    return YES;
}

#pragma mark - collectiondelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.selectedModels.count) {
        NSLog(@"数组越界");
        return nil;
    }
    ThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ThumbCell class]) forIndexPath:indexPath];
    FrameModel *model = self.selectedModels[indexPath.item];
    cell.model = model;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"选中%ld", indexPath.item);
}
@end
