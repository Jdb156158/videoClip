//
//  VideoCutPhotoListCtrl.m
//  videoClip
//
//  Created by db J on 2021/2/26.
//

#import "VideoCutPhotoListCtrl.h"

@interface VideoCutPhotoListCtrl ()

@property (nonatomic, strong) NSMutableArray *historyValue;//历史操作

@end

@implementation VideoCutPhotoListCtrl


#pragma mark - get
- (NSMutableArray *)historyValue {
    if (!_historyValue) {
        _historyValue = [NSMutableArray array];
    }
    return _historyValue;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


@end
