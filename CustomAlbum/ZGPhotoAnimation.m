//
//  ZGPhotoAnimation.m
//  CustomAlbum
//
//  Created by Yioks-Mac on 17/3/10.
//  Copyright © 2017年 Yioks-Mac. All rights reserved.
//

#import "ZGPhotoAnimation.h"
#import "PhotoScanViewController.h"
#import "PhotoDetailViewController.h"

@implementation ZGPhotoAnimation

- (instancetype)initWithType:(UINavigationControllerOperation )type {
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    if (self.type == UINavigationControllerOperationPush) {
        [self pushAnimation:transitionContext];
    }else if (self.type == UINavigationControllerOperationPop) {
        [self popAnimation:transitionContext];
    }
    
    
    
}

- (void)pushAnimation:(id<UIViewControllerContextTransitioning>)context {
    
    PhotoScanViewController *fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    PhotoDetailViewController *toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    
    
}

- (void)popAnimation:(id<UIViewControllerContextTransitioning>)context {
    
}

@end
