//
//  HomeViewController.m
//  videoClip
//
//  Created by db J on 2021/2/24.
//

#import "HomeViewController.h"
#import "VideoPickerController.h"
#import "NewVideoCutCtrl.h"
#import <Photos/Photos.h>
@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (IBAction)selectVideo:(id)sender {
    
    PHAuthorizationStatus state = [PHPhotoLibrary authorizationStatus];
    if (state == PHAuthorizationStatusAuthorized) {
        NSLog(@"用户授权访问相册");
        [self pushPickCtrl];
    }else if (state == PHAuthorizationStatusNotDetermined) {
        NSLog(@"用户未对权限作出选择");
        [self requestAlbumAuth];
    }else {
        NSLog(@"其它情况");
        [self requestAlbumAuth];
    }
    
}

-(void)requestAlbumAuth{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //允许
                [self pushPickCtrl];
            });
            
            
        }else if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
            //不允许
        }
    }];
}

-(void)pushPickCtrl{
    __weak typeof(self) weakSelf = self;
    
    VideoPickerController *videoCtrl = [[VideoPickerController alloc] init];
    videoCtrl.needCut = ^(AVAsset * _Nonnull asset, NSMutableArray * _Nonnull images) {
        [weakSelf asyncPushVideoCutCtrl:asset withImages:images];
    };
    videoCtrl.jumpEdit = ^(NSMutableArray * _Nonnull images) {
        [weakSelf asyncPushGifEditCtrl:images type:GifFromVideo];
    };
    [self.navigationController pushViewController:videoCtrl animated:YES];
}

#pragma mark - 弹出视频长度裁剪界面
- (void)asyncPushVideoCutCtrl:(AVAsset *)avasset withImages:(NSArray *)thumbImgs {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NewVideoCutCtrl *videCutView = [[NewVideoCutCtrl alloc] init];
        videCutView.originalAsset = avasset;
        videCutView.thumbImgs = thumbImgs;
        [self.navigationController pushViewController:videCutView animated:YES];
    });
    
}

#pragma mark - 弹出Gif编辑页面
- (void)asyncPushGifEditCtrl:(NSMutableArray *)imgs type:(GifType)gifType {
    dispatch_async(dispatch_get_main_queue(), ^{
        GifEditCtrl *next = [[GifEditCtrl alloc] init];
        next.originImages = imgs;
        next.gifType = gifType;
        [self.navigationController pushViewController:next animated:YES];
    });
}

@end
