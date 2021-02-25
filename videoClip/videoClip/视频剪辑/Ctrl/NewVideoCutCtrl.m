//
//  NewVideoCutCtrl.m
//  videoClip
//
//  Created by db J on 2021/2/25.
//



#import "NewVideoCutCtrl.h"

#define K_W [UIScreen mainScreen].bounds.size.width
#define K_H [UIScreen mainScreen].bounds.size.height
#define VIDEOFRAME CGRectMake(0, 0, K_W-20, K_W-20)
#define ONESCREENTIME 20.0f

@interface NewVideoCutCtrl ()

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)initVideoPlayer {
    if (!_videoPlayer) {
        
        _playerItem = [AVPlayerItem playerItemWithAsset:_originalAsset];
        _videoPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_videoPlayer];
        playerLayer.frame = VIDEOFRAME;
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

#pragma mark - 视频定点播放
- (void)playVideoInSpecificTime {
    
    float startTime = (_collectionOffsetTime + _startPointOffsetTime);
    [_videoPlayer seekToTime:CMTimeMakeWithSeconds(startTime, 600)];
}

@end
