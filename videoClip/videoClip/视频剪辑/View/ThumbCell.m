//
//  ThumbCell.m
//  videoClip
//
//  Created by db J on 2021/2/25.
//

#import "ThumbCell.h"

@implementation ThumbCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(FrameModel *)model {
    
    _model = model;
    UIImage *image = [UIImage imageWithContentsOfFile:model.imagePath];
    [_thumbImg setImage:image];
}

- (void)setShowBiao:(BOOL)showBiao {
    _showBiao = showBiao;
    //_biao.hidden = !showBiao;
}

@end
