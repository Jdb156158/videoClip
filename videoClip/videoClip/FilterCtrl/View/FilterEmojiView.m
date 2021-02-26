//
//  FilterEmojiView.m
//  videoClip
//
//  Created by db J on 2021/2/26.
//

#import "FilterEmojiView.h"
#import "FilterCollectionCell.h"

@interface FilterEmojiView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation FilterEmojiView


-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.filterCollection];
        
        //分割线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.filterCollection.frame), K_W, 1)];
        lineView.backgroundColor = [UIColor grayColor];
        [self addSubview:lineView];
        
        //关闭按钮
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setFrame:CGRectMake((K_W-60)/2.0, CGRectGetMaxY(self.filterCollection.frame), 60, 49)];
        [closeBtn setImage:[UIImage imageNamed:@"icon_unfold"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];
        
        _lastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    return self;
}

#pragma mark - method

- (void)close {
    CGFloat height = self.frame.size.height;
    [UIView animateWithDuration:.3 animations:^{
        self.frame = CGRectMake(0, K_H, K_W, height);
    }];
    
    if (self.didCloseFilterDisplayView) {
        self.didCloseFilterDisplayView();
    }
}

- (void)reloadData {
    [self.filterCollection reloadData];
}

- (UICollectionView *)filterCollection {
    if (!_filterCollection) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(74, 115);
        layout.minimumLineSpacing = 5.0f;
        layout.minimumInteritemSpacing = 5.0f;
        layout.sectionInset = UIEdgeInsetsZero;
        _filterCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 15, K_W, 115) collectionViewLayout:layout];
        _filterCollection.backgroundColor = [UIColor clearColor];
        _filterCollection.dataSource = self;
        _filterCollection.delegate = self;
        _filterCollection.showsHorizontalScrollIndicator = NO;
        [_filterCollection registerNib:[UINib nibWithNibName:@"FilterCollectionCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([FilterCollectionCell class])];
    }
    return _filterCollection;
}

- (NSArray<Filter *> *)filters {
    if (!_filters) {
        _filters = @[
                     [[Filter alloc] initWithTitle:@"原图" ciFilterTitle:@""],
                     [[Filter alloc] initWithTitle:@"怀旧" ciFilterTitle:@"CISepiaTone"],
                     [[Filter alloc] initWithTitle:@"黑白" ciFilterTitle:@"CIPhotoEffectMono"],
                     [[Filter alloc] initWithTitle:@"经典" ciFilterTitle:@"CIPhotoEffectInstant"],
                     [[Filter alloc] initWithTitle:@"自然" ciFilterTitle:@"CIPhotoEffectFade"],
                     [[Filter alloc] initWithTitle:@"鲜艳" ciFilterTitle:@"CIPhotoEffectChrome"],
                     [[Filter alloc] initWithTitle:@"森林" ciFilterTitle:@"CIPhotoEffectTransfer"]
                     ];
    }
    return _filters;
}

#pragma mark - data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FilterCollectionCell class]) forIndexPath:indexPath];
    [cell loadUIWithFilter:self.filters[indexPath.item] image:self.sourceImage index:indexPath.item];
    cell.isSelect = _lastIndexPath == indexPath;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectFilterAtIndex) {
        Filter *selectFilter = self.filters[indexPath.item];
        self.didSelectFilterAtIndex(indexPath, self.filterCollection, selectFilter);
    }
}


@end
