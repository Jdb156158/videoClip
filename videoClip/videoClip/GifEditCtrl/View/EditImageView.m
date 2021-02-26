//
//  EditImageView.m
//  WaterMarkDemo
//
//  Created by mac on 16/4/28.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "EditImageView.h"
#import <QuartzCore/QuartzCore.h>
#define RGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define BorderColor RGBColor(229, 34, 34)

CG_INLINE CGPoint CGRectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CG_INLINE CGPoint CGPointRorate(CGPoint point, CGPoint basePoint, CGFloat angle)
{
    CGFloat x = cos(angle) * (point.x-basePoint.x) - sin(angle) * (point.y-basePoint.y) + basePoint.x;
    CGFloat y = sin(angle) * (point.x-basePoint.x) + cos(angle) * (point.y-basePoint.y) + basePoint.y;
    
    return CGPointMake(x,y);
}

CG_INLINE CGRect CGRectSetCenter(CGRect rect, CGPoint center)
{
    return CGRectMake(center.x-CGRectGetWidth(rect)/2, center.y-CGRectGetHeight(rect)/2, CGRectGetWidth(rect), CGRectGetHeight(rect));
}

CG_INLINE CGRect CGRectScale(CGRect rect, CGFloat wScale, CGFloat hScale)
{
    return CGRectMake(rect.origin.x * wScale, rect.origin.y * hScale, rect.size.width * wScale, rect.size.height * hScale);
}

CG_INLINE CGFloat CGPointGetDistance(CGPoint point1, CGPoint point2)
{
    //Saving Variables.
    CGFloat fx = (point2.x - point1.x);
    CGFloat fy = (point2.y - point1.y);
    
    return sqrt((fx*fx + fy*fy));
}

CG_INLINE CGFloat CGAffineTransformGetAngle(CGAffineTransform t)
{
    return atan2(t.b, t.a);
}


CG_INLINE CGSize CGAffineTransformGetScale(CGAffineTransform t)
{
    return CGSizeMake(sqrt(t.a * t.a + t.c * t.c), sqrt(t.b * t.b + t.d * t.d)) ;
}


static EditImageView *lastTouchedView;

@implementation EditImageView
{
    CGFloat _globalInset;
    
    CGRect initialBounds;
    CGFloat initialDistance;
    
    CGPoint beginningPoint;
    CGPoint beginningCenter;
    
    CGPoint prevPoint;
    CGPoint touchLocation;
    
    CGFloat deltaAngle;
    
    CGAffineTransform startTransform;
    CGRect beginBounds;
}

@synthesize contentIV = _contentIV;
@synthesize enableClose = _enableClose;
@synthesize enableResize = _enableResize;
@synthesize enableRotate = _enableRotate;
@synthesize delegate = _delegate;
@synthesize showContentShadow = _showContentShadow;

-(void)refresh
{
    if (self.superview)
    {
        CGSize scale = CGAffineTransformGetScale(self.superview.transform);
        CGAffineTransform t = CGAffineTransformMakeScale(scale.width, scale.height);
        [_closeView setTransform:CGAffineTransformInvert(t)];
        [_resizeView setTransform:CGAffineTransformInvert(t)];
        [_rotateView setTransform:CGAffineTransformInvert(t)];
        
        if (_isShowingEditingHandles)   [_contentIV.layer setBorderWidth:1/scale.width];
        else                            [_contentIV.layer setBorderWidth:0.0];
    }
    
    [_closeView setFrame:CGRectMake(0, 0, _globalInset*2, _globalInset*2)];
    [_resizeView setFrame:CGRectMake(self.bounds.size.width-_globalInset*2, self.bounds.size.height-_globalInset*2, _globalInset*2, _globalInset*2)];
    [_resizeView setFrame:CGRectMake(0, self.bounds.size.height-_globalInset*2, _globalInset*2, _globalInset*2)];
}

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self refresh];
}

- (void)setFrame:(CGRect)newFrame
{
    [super setFrame:newFrame];
    [self refresh];
}

- (id)initWithFrame:(CGRect)frame {
    /*(1+_globalInset*2)*/
    if (frame.size.width < (1+10*2))     frame.size.width = 21;
    if (frame.size.height < (1+10*2))   frame.size.height = 21;
    
    self = [super initWithFrame:frame];
    if (self)
    {
        _globalInset = 10;
        
        //        self = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
        self.backgroundColor = [UIColor clearColor];
        
        //Close button view which is in top left corner
        _closeView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _globalInset*2, _globalInset*2)];
        [_closeView setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin)];
        _closeView.backgroundColor = [UIColor clearColor];
        _closeView.image = [UIImage imageNamed:@"close"];
        _closeView.userInteractionEnabled = YES;
        [self addSubview:_closeView];
        
        //Rotating view which is in bottom left corner
        _rotateView = [[UIImageView alloc]initWithFrame:CGRectMake(self.bounds.size.width-_globalInset*2, self.bounds.size.height-_globalInset*2, _globalInset*2, _globalInset*2)];
        [_rotateView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin)];
        _rotateView.backgroundColor = [UIColor clearColor];
        _rotateView.image = [UIImage imageNamed:@"arrow1"];
        _rotateView.userInteractionEnabled = YES;
        [self addSubview:_rotateView];
        
        //Resizing view which is in bottom right corner
        _resizeView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-_globalInset*2, _globalInset*2, _globalInset*2)];
        [_resizeView setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin)];
        _resizeView.backgroundColor = [UIColor clearColor];
        _resizeView.userInteractionEnabled = YES;
        _resizeView.image = [UIImage imageNamed:@"arrow1"];
        [self addSubview:_resizeView];
        
        UIPanGestureRecognizer* moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGesture:)];
        [self addGestureRecognizer:moveGesture];
        
        UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [_closeView addGestureRecognizer:singleTap];
        
        UILongPressGestureRecognizer* panResizeGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(resizeTranslate:)];
        [panResizeGesture setMinimumPressDuration:0.1];
        [_resizeView addGestureRecognizer:panResizeGesture];
        
        UILongPressGestureRecognizer* panRotateGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(rotateViewPanGesture:)];
        [panRotateGesture setMinimumPressDuration:0.1];
        [_rotateView addGestureRecognizer:panRotateGesture];
        
        [moveGesture requireGestureRecognizerToFail:singleTap];
        
        [self setEnableClose:YES];
        [self setEnableResize:YES];
        [self setEnableRotate:YES];
        [self setShowContentShadow:YES];
        
        _contentIV = [[UIImageView alloc] initWithFrame:CGRectMake(_globalInset, _globalInset, self.bounds.size.width - _globalInset * 2, self.bounds.size.height - _globalInset*2)];
        _contentIV.contentMode = UIViewContentModeScaleAspectFill;
        [_contentIV setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
        _contentIV.backgroundColor = [UIColor clearColor];
        _contentIV.layer.borderColor = [BorderColor CGColor];
        _contentIV.layer.borderWidth = 1.0f;
        _contentIV.userInteractionEnabled = YES;
        _contentIV.clipsToBounds = YES;
        [self insertSubview:_contentIV atIndex:0];
    }
    return self;
}



-(void)contentTapped:(UITapGestureRecognizer*)tapGesture
{
    if (_isShowingEditingHandles)
    {
        [self hideEditingHandles];
        [self.superview bringSubviewToFront:self];
    }
    else {
        [self showEditingHandles];
    }
    
    if([_delegate respondsToSelector:@selector(stickerViewTap)]) {
        [_delegate stickerViewTap];
    }
}

-(void)setEnableClose:(BOOL)enableClose
{
    _enableClose = enableClose;
    [_closeView setHidden:!_enableClose];
    [_closeView setUserInteractionEnabled:_enableClose];
}

-(void)setEnableResize:(BOOL)enableResize
{
    _enableResize = enableResize;
    [_resizeView setHidden:!_enableResize];
    [_resizeView setUserInteractionEnabled:_enableResize];
    // old no
    [_resizeView setHidden:YES];
}

-(void)setEnableRotate:(BOOL)enableRotate
{
    _enableRotate = enableRotate;
    [_rotateView setHidden:!_enableRotate];
    [_rotateView setUserInteractionEnabled:_enableRotate];
}

-(void)setShowContentShadow:(BOOL)showContentShadow
{
    _showContentShadow = showContentShadow;
    
    if (_showContentShadow)
    {
        [self.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.layer setShadowOffset:CGSizeMake(0, 5)];
        [self.layer setShadowOpacity:1.0];
        [self.layer setShadowRadius:4.0];
    }
    else
    {
        [self.layer setShadowColor:[UIColor clearColor].CGColor];
        [self.layer setShadowOffset:CGSizeZero];
        [self.layer setShadowOpacity:0.0];
        [self.layer setShadowRadius:0.0];
    }
}

- (void)hideEditingHandles
{
    lastTouchedView = nil;
    
    _isShowingEditingHandles = NO;
    
    if (_enableClose)       _closeView.hidden = YES;
    if (_enableResize)      _resizeView.hidden = YES;
    if (_enableRotate)      _rotateView.hidden = YES;
    
//    [self refresh];
    
    if([_delegate respondsToSelector:@selector(editImageViewDidHideEditingHandles:)])
        [_delegate editImageViewDidHideEditingHandles:self];
}

- (void)showEditingHandles
{
    [lastTouchedView hideEditingHandles];
    
    _isShowingEditingHandles = YES;
    
    lastTouchedView = self;
    
    if (_enableClose)       _closeView.hidden = NO;
    if (_enableResize)      _resizeView.hidden = YES;//NO
    if (_enableRotate)      _rotateView.hidden = NO;
    
    [self refresh];
    
    if([_delegate respondsToSelector:@selector(editImageViewDidShowEditingHandles:)])
        [_delegate editImageViewDidShowEditingHandles:self];
}


- (void)setContentIV:(UIImageView *)contentIV {
    [_contentIV removeFromSuperview];
    
    _contentIV = contentIV;
    
    _contentIV.frame = CGRectMake(_globalInset, _globalInset, self.bounds.size.width - _globalInset * 2, self.bounds.size.height - _globalInset*2);//CGRectInset(self.bounds, _globalInset, _globalInset);//;
    _contentIV.contentMode = UIViewContentModeScaleAspectFill;
//    [_contentIV setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    _contentIV.backgroundColor = [UIColor clearColor];
    _contentIV.layer.borderColor = [BorderColor CGColor];
    _contentIV.layer.borderWidth = 1.0f;
    [self insertSubview:_contentIV atIndex:0];
}

-(void)singleTap:(UITapGestureRecognizer *)recognizer
{
    [self removeFromSuperview];
    
    if([_delegate respondsToSelector:@selector(editImageViewDidClose:)]) {
        [_delegate editImageViewDidClose:self];
    }
}

-(void)moveGesture:(UIPanGestureRecognizer *)recognizer
{
    touchLocation = [recognizer locationInView:self.superview];
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        //        [lastTouchedView hideEditingHandles];
        beginningPoint = touchLocation;
        beginningCenter = self.center;
        
        [self setCenter:CGPointMake(beginningCenter.x+(touchLocation.x-beginningPoint.x), beginningCenter.y+(touchLocation.y-beginningPoint.y))];
        
        beginBounds = self.bounds;
        
        //        [UIView animateWithDuration:0.1 animations:^{
        //            [self setBounds:CGRectMake(0, 0, 100, 100)];
        //        }];
        
        if([_delegate respondsToSelector:@selector(editImageViewDidBeginEditing:)])
            [_delegate editImageViewDidBeginEditing:self];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        
        [self setCenter:CGPointMake(beginningCenter.x+(touchLocation.x-beginningPoint.x), beginningCenter.y+(touchLocation.y-beginningPoint.y))];
        
        if([_delegate respondsToSelector:@selector(editImageViewDidChangeEditing:)])
            [_delegate editImageViewDidChangeEditing:self];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        
        [self setCenter:CGPointMake(beginningCenter.x+(touchLocation.x-beginningPoint.x), beginningCenter.y+(touchLocation.y-beginningPoint.y))];
        
        //        [UIView animateWithDuration:0.1 animations:^{
        //            [self setBounds:beginBounds];
        //        }];
        
        if([_delegate respondsToSelector:@selector(editImageViewDidEndEditing:)])
            [_delegate editImageViewDidEndEditing:self];
    }
    
    prevPoint = touchLocation;
}

-(void)resizeTranslate:(UIPanGestureRecognizer *)recognizer
{
    touchLocation = [recognizer locationInView:self.superview];
    //Reforming touch location to it's Identity transform.
    touchLocation = CGPointRorate(touchLocation, CGRectGetCenter(self.frame), -CGAffineTransformGetAngle(self.transform));
    
    if ([recognizer state]== UIGestureRecognizerStateBegan)
    {
        if([_delegate respondsToSelector:@selector(editImageViewDidBeginEditing:)])
            [_delegate editImageViewDidBeginEditing:self];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        CGFloat wChange = (prevPoint.x - touchLocation.x); //Slow down increment
        CGFloat hChange = (touchLocation.y - prevPoint.y); //Slow down increment
        
        CGAffineTransform t = self.transform;
        [self setTransform:CGAffineTransformIdentity];
        
        CGRect scaleRect = CGRectMake(self.frame.origin.x, self.frame.origin.y,MAX(self.frame.size.width + (wChange*2), 1+_globalInset*2), MAX(self.frame.size.height + (hChange*2), 1+_globalInset*2));
        
        scaleRect = CGRectSetCenter(scaleRect, self.center);
        [self setFrame:scaleRect];
        [self.contentIV setFrame:CGRectMake(_globalInset, _globalInset, self.frame.size.width - _globalInset * 2, self.frame.size.height - _globalInset * 2)];
        [self setTransform:t];
        
        if([_delegate respondsToSelector:@selector(editImageViewDidChangeEditing:)])
            [_delegate editImageViewDidChangeEditing:self];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        if([_delegate respondsToSelector:@selector(editImageViewDidEndEditing:)])
            [_delegate editImageViewDidEndEditing:self];
    }
    
    prevPoint = touchLocation;
}

-(void)rotateViewPanGesture:(UIPanGestureRecognizer *)recognizer
{
    touchLocation = [recognizer locationInView:self.superview];
    
    CGPoint center = CGRectGetCenter(self.frame);
    
    if ([recognizer state] == UIGestureRecognizerStateBegan)
    {
        deltaAngle = atan2(touchLocation.y-center.y, touchLocation.x-center.x)-CGAffineTransformGetAngle(self.transform);
        
        initialBounds = self.bounds;
        initialDistance = CGPointGetDistance(center, touchLocation);
        
        if([_delegate respondsToSelector:@selector(editImageViewDidBeginEditing:)])
            [_delegate editImageViewDidBeginEditing:self];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
//        float ang = atan2(touchLocation.y-center.y, touchLocation.x-center.x);
//
//        float angleDiff = deltaAngle - ang;
//        [self setTransform:CGAffineTransformMakeRotation(-angleDiff)];
        [self setNeedsDisplay];
        
        //Finding scale between current touchPoint and previous touchPoint
        double scale = sqrtf(CGPointGetDistance(center, touchLocation)/initialDistance);
        
        CGRect scaleRect = CGRectScale(initialBounds, scale, scale);
        
        if (scaleRect.size.width >= (1+_globalInset*2) && scaleRect.size.height >= (1+_globalInset*2))
        {
            [self setBounds:scaleRect];
        }
        
        if([_delegate respondsToSelector:@selector(editImageViewDidChangeEditing:)])
            [_delegate editImageViewDidChangeEditing:self];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
//        _rotationAngle = CGAffineTransformGetAngle(self.transform);
        if([_delegate respondsToSelector:@selector(editImageViewDidEndEditing:)])
            [_delegate editImageViewDidEndEditing:self];
    }
}

-(void)dealloc {
    NSLog(@"%@ 我真的释放了", NSStringFromClass([self class]));
}


@end
