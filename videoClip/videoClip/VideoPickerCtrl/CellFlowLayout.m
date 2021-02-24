//
//  CellFlowLayout.m
//  videoClip
//
//  Created by db J on 2021/2/24.
//

#import "CellFlowLayout.h"

@implementation CellFlowLayout
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    self.itemSize = CGSizeMake(_kCollectionViewWidth, _kCollectionViewHeight);
    self.minimumLineSpacing = 15;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray * array = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes * attrs in array) {
        attrs.zIndex = attrs.indexPath.item;
    }
    return array;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
