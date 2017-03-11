//
//  ImageCell.h
//  CustomAlbum
//
//  Created by Yioks-Mac on 17/3/10.
//  Copyright © 2017年 Yioks-Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ImageCell;
@protocol ImageCellDelegate <NSObject>

- (void)panGestureBegin:(UIPanGestureRecognizer *)pan;

- (void)imageChoose:(BOOL)isChoose inCell:(ImageCell *)cell;

@end

@interface ImageCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *livePhotoBadgeImageView;

@property (nonatomic, assign) BOOL isGestureUseful;

@property (nonatomic, weak) id<ImageCellDelegate> delegate;

@property (nonatomic, assign) BOOL hideChooseBtn;

@end
