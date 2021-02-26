//
//  NewVideoCutCtrl.m
//  videoClip
//
//  Created by db J on 2021/2/25.
//



#import "NewVideoCutCtrl.h"
#import "FrameModel.h"
#import "ThumbCell.h"
#import "CellFlowLayout.h"

@interface NewVideoCutCtrl () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *thumbCollectBgView;
@property (strong, nonatomic) UICollectionView *thumbCollection;

@property (nonatomic, strong) NSMutableArray *thumbModels;
@end

@implementation NewVideoCutCtrl{
    AVPlayer *_videoPlayer;
    AVPlayerItem *_playerItem;
    NSTimer *_videoTimer;
    CGFloat _collectionOffsetTime, _startPointOffsetTime, _endPointOffsetTime;
    CGFloat _lastStartPointX, _lastEndPointX;
    NSInteger _max_video_time;
    BOOL _onShow;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_videoPlayer play];
    _onShow = YES;
    
    [self initTimer];
    [self addNotification];
    [self addObserverToPlayerItem];
    [self initEndTimeLabel];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_videoPlayer pause];
    _onShow = NO;
    
    [self removeNotification];
    [self removeObserverFromPlayerItem];
    [_videoTimer invalidate];
    _videoTimer = nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _endPointOffsetTime = PIXEL_VIDEOGIF_SEGEMENT_NUMBER / [SettingManager shareManager].videoExractFPS;
    [self initVideoPlayer];
    [self initCollectionData];
    [self initCollection];
    
}

- (void)initCollectionData {
    _thumbModels = [NSMutableArray array];
    for (NSString *imgPath in _thumbImgs) {
        FrameModel *model = [[FrameModel alloc]init];
        model.imagePath = imgPath;
        [_thumbModels addObject:model];
    }
}

- (void)initCollection {
    [self.thumbCollectBgView addSubview:self.thumbCollection];
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

        _thumbCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60) collectionViewLayout:configLayout];
        _thumbCollection.delegate = self;
        _thumbCollection.dataSource = self;
        _thumbCollection.showsVerticalScrollIndicator = NO;//隐藏滚动条
        _thumbCollection.backgroundColor = [UIColor yellowColor];
        [_thumbCollection registerNib:[UINib nibWithNibName:@"ThumbCell" bundle:nil] forCellWithReuseIdentifier:@"ThumbCell"];

    }
    return _thumbCollection;
}

- (void)initVideoPlayer {
    if (!_videoPlayer) {
        
        _playerItem = [AVPlayerItem playerItemWithAsset:_originalAsset];
        _videoPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_videoPlayer];
        playerLayer.frame = CGRectMake(0, 0, K_W-20, K_W-20);
        [_videoView.layer addSublayer:playerLayer];
    }
}

- (void)initTimer {
    if (_videoTimer || _videoPlayer==nil) {
        return;
    }
    _videoTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(refreshTimeLabel) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_videoTimer forMode:NSDefaultRunLoopMode];
}

- (void)initEndTimeLabel {
    NSInteger endTime = PIXEL_VIDEOGIF_SEGEMENT_NUMBER / [SettingManager shareManager].videoExractFPS;
    NSString *endStr = [NSString stringWithFormat:@"00:%02ld", endTime];
    //self.endLabel.text = endStr;
}

- (void)refreshTimeLabel {
    if (!_onShow) {
        return;
    }
    
    CMTime ctime = _playerItem.currentTime;
    float currentTimeSec = ctime.value / ctime.timescale;
    
    float endTime = (_collectionOffsetTime + _endPointOffsetTime);   //重新返回起始点播放
    if (currentTimeSec >= endTime ) {
        [self playVideoInSpecificTime];
    }
    
    NSString *cur = [SystemUtils timeFormatted:(int)currentTimeSec];
    NSString *whole = [SystemUtils timeFormatted:(int)CMTimeGetSeconds(_playerItem.duration)];
    NSString *timeText = [NSString stringWithFormat:@"%@/%@", cur, whole];
    _timeLabel.text = timeText;
}

- (void)dealloc {
    NSLog(@"视频播放页销毁");
}

#pragma mark - collectiondelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thumbModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbCell" forIndexPath:indexPath];
    FrameModel *model = self.thumbModels[indexPath.item];
    cell.model = model;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"选中%ld", indexPath.item);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float videoLength = (float)_originalAsset.duration.value / _originalAsset.duration.timescale;
    _collectionOffsetTime = videoLength * (scrollView.contentOffset.x / scrollView.contentSize.width);
    //[self refreshPointTime];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self playVideoInSpecificTime];
}

#pragma mark - 视频定点播放
- (void)playVideoInSpecificTime {
    float startTime = (_collectionOffsetTime + _startPointOffsetTime);
    [_videoPlayer seekToTime:CMTimeMakeWithSeconds(startTime, 600)];
}

#pragma mark - kvo视频播放相关

- (void)addObserverToPlayerItem{
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserverFromPlayerItem{
    
    @try {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    } @catch (NSException *exception) {
        NSLog(@"多次删除报错");
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerStatusReadyToPlay){

            float wholeTime = CMTimeGetSeconds(_playerItem.duration);
            NSLog(@"AVPlayerStatusReadyToPlay，视频总长度:%.2f", wholeTime);
        }
    }
    else if([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        NSArray *array = _playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f 进度",totalBuffer);
    }
}

- (void)playFinished:(NSNotification *)notification{
    
    [_videoPlayer seekToTime:CMTimeMake(0, 1)];
    [_videoPlayer play];
}



#pragma mark - notification
- (void)addNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_videoPlayer.currentItem];
}

- (void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// 下一步 跳转到视频转gif页面
- (IBAction)pushNextBtn:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    
    float startTime = (_collectionOffsetTime + _startPointOffsetTime);
    float endTime = (_collectionOffsetTime + _endPointOffsetTime);
    
    CMTime start = CMTimeMakeWithSeconds(startTime, 600);
    CMTime duration = CMTimeMakeWithSeconds((endTime-startTime), 600);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    int startSeconds = 0;
    
    if (range.duration.value != 0) {
        startSeconds = (int)(range.start.value / range.start.timescale);
    }
    
    [HudManager showLoading];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [GifUtils imgsWithVideoAsset:self.originalAsset withTimeInterval:[SettingManager shareManager].floatFps withTimeRange:range completion:^(NSMutableArray *images) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HudManager hideLoading];
                if (images.count > 0) {
                    [weakSelf pushEditCtrlWith:images type:GifFromVideo];
                }else {
                    [HudManager showWord:NSLocalizedString(@"get_imgs_fail", nil)];
                }
            });
        }]; //提取图片
    });
    
}

- (void)pushEditCtrlWith:(NSMutableArray *)imgs type:(GifType)gifType{
    
    dispatch_async(dispatch_get_main_queue(), ^{        
        GifEditCtrl *next = [[GifEditCtrl alloc] init];
        next.originImages = imgs;
        next.gifType = gifType;
        [self.navigationController pushViewController:next animated:YES];
    });
}

@end
