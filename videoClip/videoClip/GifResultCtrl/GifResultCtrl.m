//
//  GifResultCtrl.m
//  videoClip
//
//  Created by db J on 2021/2/25.
//

#import "GifResultCtrl.h"

@interface GifResultCtrl ()
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *gifView;
@end

@implementation GifResultCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"PATH_GIF的路径地址:%@",PATH_GIF);
    _gifView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:PATH_GIF]];
    _gifView.backgroundColor = [UIColor yellowColor];
}

- (IBAction)ClickSaveGifBtn:(id)sender {
}
@end
