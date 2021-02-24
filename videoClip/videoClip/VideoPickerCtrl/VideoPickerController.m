//
//  VideoPickerController.m
//  videoClip
//
//  Created by db J on 2021/2/24.
//

#import "VideoPickerController.h"
#import <Photos/Photos.h>
#import "PickerCell.h"
#import "CellFlowLayout.h"
@interface VideoPickerController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *pickerModels, *selectedIndexs;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation VideoPickerController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self initPickerData];
        dispatch_async(dispatch_get_main_queue(), ^{
            //相册数据获取完成
            [self.collectionView reloadData];
        });
    });
}

#pragma mark - get
- (NSMutableArray *)pickerModels {
    
    if (!_pickerModels) {
        _pickerModels = [NSMutableArray array];
    }
    return _pickerModels;
}

- (NSMutableArray *)selectedIndexs {
    if (!_selectedIndexs) {
        _selectedIndexs = [NSMutableArray array];
    }
    return _selectedIndexs;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        CellFlowLayout *configLayout = [[CellFlowLayout alloc]init];
        configLayout.kCollectionViewWidth = ([UIScreen mainScreen].bounds.size.width-60)/3;
        configLayout.kCollectionViewHeight = 100;
        configLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        configLayout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);

        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:configLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;//隐藏滚动条
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"PickerCell" bundle:nil] forCellWithReuseIdentifier:@"PickerCell"];

    }
    return _collectionView;
}

#pragma mark - data
- (void)initPickerData {
    //刷新前清空一下
    [self.pickerModels removeAllObjects];
    
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *assetCollection in assetCollections) {
        [self enumerateAssetsInAssetCollection:assetCollection original:NO];
    }
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    [self enumerateAssetsInAssetCollection:cameraRoll original:NO];

}

//细分照片类型
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original{

    PHFetchOptions *fetchOption = [[PHFetchOptions alloc] init];
    fetchOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOption];
    for (PHAsset *asset in assets) {
        BOOL isLivePhoto, isVideo, isBurst, isPhoto;
        BOOL isNotLivePhoto;
        BOOL isGIF = NO;
        if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"] ||
            [[asset valueForKey:@"filename"] hasSuffix:@"gif"]) {
            isGIF = YES;
        }else {
            isGIF = NO;
        }
        if (@available(iOS 9.1, *)){
            isLivePhoto = (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive || asset.mediaSubtypes == 520);    //livephot 属于 照片细分type
            if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive || asset.mediaSubtypes == 520) {
                isNotLivePhoto = NO;
            }else{
                isNotLivePhoto = YES;
            }
        }else {
            isLivePhoto = NO;
            isNotLivePhoto = YES;
        }
        isBurst = asset.representsBurst;
        isVideo = (asset.mediaType == PHAssetMediaTypeVideo);
        isPhoto = (asset.mediaType == PHAssetMediaTypeImage) && isNotLivePhoto && !isGIF;
        
        //按条件添加
        if (isLivePhoto) {
        }
        if (isVideo) {
            [self.pickerModels addObject:asset];
            continue;
        }
        if (isBurst) {
        }
        if (isPhoto) {
        }
        if (isGIF) {
        }
    }
}

#pragma mark - collectiondelegate


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.pickerModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //PickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PickerCell class]) forIndexPath:indexPath];
    
    PickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PickerCell" forIndexPath:indexPath];
    
    if (indexPath.item <= self.pickerModels.count - 1) {
        PHAsset *asset = self.pickerModels[indexPath.item];
        [cell setPickerPHAsset:asset index:indexPath.item];
    }
    return cell;
}

@end
