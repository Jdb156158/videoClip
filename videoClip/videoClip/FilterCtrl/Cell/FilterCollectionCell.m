//
//  FilterCollectionCell.m
//  videoClip
//
//  Created by db J on 2021/2/26.
//

#import "FilterCollectionCell.h"

@implementation FilterCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)loadUIWithFilter:(Filter *)filter image:(UIImage *)image index:(NSInteger)index {
    UIImage *resultImg = [image applyFilter:filter];
    _picIV.image = resultImg;
    _filterNameLb.text = filter.title;
}

- (void)setIsSelect:(BOOL)isSelect {
    _isSelect = isSelect;
    _picIV.layer.borderColor = isSelect ? [UIColor redColor].CGColor : [UIColor clearColor].CGColor;
    _filterNameLb.textColor = isSelect ?[UIColor redColor] : [UIColor whiteColor];
    _filterNameLb.font = isSelect ? [UIFont boldSystemFontOfSize:12] : [UIFont systemFontOfSize:12];
}

@end
