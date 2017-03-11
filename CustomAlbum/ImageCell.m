//
//  ImageCell.m
//  CustomAlbum
//
//  Created by Yioks-Mac on 17/3/10.
//  Copyright © 2017年 Yioks-Mac. All rights reserved.
//

#import "ImageCell.h"

@interface ImageCell ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *chooseBtn;

@end

@implementation ImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        _imageView = [[UIImageView alloc]initWithFrame:self.contentView.bounds];
        _livePhotoBadgeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_livePhotoBadgeImageView];
        _chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_chooseBtn setImage:[UIImage imageNamed:@"zl_icon_image_no"] forState:UIControlStateNormal];
        [_chooseBtn setImage:[UIImage imageNamed:@"zl_icon_image_yes"] forState:UIControlStateSelected];
        [_chooseBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        _chooseBtn.frame = CGRectMake(self.bounds.size.width - 20, 0, 20, 20);
        [self.contentView addSubview:_chooseBtn];
        
        [self addPanGesture];
        
    }
    return self;
    
}

- (void)setHideChooseBtn:(BOOL)hideChooseBtn {
    self.chooseBtn.hidden = hideChooseBtn;
}

- (void)btnClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageChoose:inCell:)]) {
        [self.delegate imageChoose:btn.selected inCell:self];
    }
}

- (void)addPanGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    if (self.delegate && [self.delegate respondsToSelector:@selector(panGestureBegin:)]) {
        [self.delegate panGestureBegin:pan];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint tran = [pan translationInView:self];
        if (fabs(tran.y) > 3) {
            return YES;
        }else {
            return NO;
        }
    }else {
        return YES;
    }
}



@end
