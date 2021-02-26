//
//  EditImageView.h
//  WaterMarkDemo
//
//  Created by mac on 16/4/28.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditImageView;
@protocol EditImageViewDelegate <NSObject>

//- (void)didRemoveWaterMark:(EditImageView *)watermarkIV;
- (void)editImageViewDidBeginEditing:(EditImageView *)sticker;
- (void)editImageViewDidChangeEditing:(EditImageView *)sticker;
- (void)editImageViewDidEndEditing:(EditImageView *)sticker;

- (void)editImageViewDidClose:(EditImageView *)sticker;

- (void)editImageViewDidShowEditingHandles:(EditImageView *)sticker;
- (void)editImageViewDidHideEditingHandles:(EditImageView *)sticker;

- (void)stickerViewTap;
@end

@interface EditImageView : UIView <UIGestureRecognizerDelegate>
{
    BOOL _isShowingEditingHandles;
    UIImageView *_resizeView; ///< 尺寸
    UIImageView *_rotateView; ///< 角度
    UIImageView *_closeView; ///< 关闭
}
@property (nonatomic, assign) BOOL showContentShadow;   ///< 默认YES.
@property (nonatomic, assign) BOOL enableClose;         ///< 默认YES.
@property (nonatomic, assign) BOOL enableResize;        ///< 默认YES.
@property (nonatomic, assign) BOOL enableRotate;        ///< 默认YES.

@property (nonatomic, assign) float rotationAngle;      ///< 当前旋转角度

//Give call's to refresh. If SuperView is UIScrollView. And it changes it's zoom scale.
- (void)refresh;

- (void)hideEditingHandles;
- (void)showEditingHandles;

@property (strong, nonatomic) UIImageView *contentIV;
@property (weak, nonatomic) id<EditImageViewDelegate> delegate;

@end
