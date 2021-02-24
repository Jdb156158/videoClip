//
//  HomeViewController.m
//  videoClip
//
//  Created by db J on 2021/2/24.
//

#import "HomeViewController.h"
#import "VideoPickerController.h"
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
            //允许
            [self pushPickCtrl];
            
        }else if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
            //不允许
        }
    }];
}

-(void)pushPickCtrl{
    VideoPickerController *videoCtrl = [[VideoPickerController alloc] init];
    [self.navigationController pushViewController:videoCtrl animated:YES];
}


@end
