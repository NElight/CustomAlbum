//
//  ImageCell.m
//  CustomAlbum
//
//  Created by Yioks-Mac on 17/3/10.
//  Copyright © 2017年 Yioks-Mac. All rights reserved.
//

#import "ImageCell.h"

@implementation ImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        _imageView = [[UIImageView alloc]initWithFrame:self.contentView.bounds];
        _livePhotoBadgeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_livePhotoBadgeImageView];
        
        [self addPanGesture];
        
    }
    return self;
    
}

- (void)addPanGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    if (self.delegate && [self.delegate respondsToSelector:@selector(panGestureBegin:)]) {
        [self.delegate panGestureBegin:pan];
    }
}



@end
