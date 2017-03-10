//
//  ZGPhotoAnimation.h
//  CustomAlbum
//
//  Created by Yioks-Mac on 17/3/10.
//  Copyright © 2017年 Yioks-Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZGPhotoAnimation : NSObject<UIViewControllerAnimatedTransitioning>

- (instancetype)initWithType:(UINavigationControllerOperation ) type;

@property (nonatomic) UINavigationControllerOperation type;

@end
