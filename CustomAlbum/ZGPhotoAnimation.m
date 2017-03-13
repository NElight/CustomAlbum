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

@interface ZGPhotoAnimation ()<CAAnimationDelegate>

@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@end

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
    self.transitionContext = context;
    PhotoScanViewController *fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    PhotoDetailViewController *toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [context containerView];
    [containerView addSubview:toVC.view];
    UIView *startView = fromVC.selectedCell;
    
    CGRect realFrame = [startView convertRect:startView.bounds toView:containerView];
    CGPoint realCenter = [startView convertPoint:startView.center toView:containerView];
//    CGRect realFrame = CGRectMake(startView.frame.origin.x, startView.frame.origin.y + 64, startView.frame.size.width, startView.frame.size.height);
//    CGPoint realCenter = CGPointMake(startView.center.x, startView.center.y + 64);
    UIBezierPath *startBP = [UIBezierPath bezierPathWithOvalInRect:realFrame];
    
    
    CGPoint finalPoint;
    //判断触发点在那个象限
    if(realFrame.origin.x > (toVC.view.bounds.size.width / 2)){
        if (realFrame.origin.y < (toVC.view.bounds.size.height / 2)) {
            //第一象限
            finalPoint = CGPointMake(realCenter.x - 0, realCenter.y - CGRectGetMaxY(toVC.view.bounds)+30);
        }else{
            //第四象限
            finalPoint = CGPointMake(realCenter.x - 0, realCenter.y - 0);
        }
    }else{
        if (realFrame.origin.y < (toVC.view.bounds.size.height / 2)) {
            //第二象限
            finalPoint = CGPointMake(realCenter.x - CGRectGetMaxX(toVC.view.bounds), realCenter.y - CGRectGetMaxY(toVC.view.bounds)+30);
        }else{
            //第三象限
            finalPoint = CGPointMake(realCenter.x - CGRectGetMaxX(toVC.view.bounds), realCenter.y - 0);
        }
    }
    
    
    CGFloat radius = sqrt((finalPoint.x * finalPoint.x) + (finalPoint.y * finalPoint.y));
    UIBezierPath *finalBP = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(realFrame, -radius, -radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = finalBP.CGPath;
    toVC.view.layer.mask = maskLayer;
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"path"];
    ani.fromValue = (__bridge id _Nullable)(startBP.CGPath);
    ani.toValue = (__bridge id _Nullable)(finalBP.CGPath);
    ani.duration = [self transitionDuration:context];
    ani.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    ani.removedOnCompletion = YES;
    ani.delegate = self;
    [maskLayer addAnimation:ani forKey:@"path"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
    [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
    [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.mask = nil;
}

- (void)popAnimation:(id<UIViewControllerContextTransitioning>)context {
    
    self.transitionContext = context;
    
    PhotoDetailViewController *fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    PhotoScanViewController *toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [context containerView];
    [containerView addSubview:toVC.view];
    [containerView addSubview:fromVC.view];
    fromVC.view.frame = CGRectMake(0, 0, fromVC.view.bounds.size.width, fromVC.view.bounds.size.height);
    
    
//    UIView *disView = toVC.selectedCell;
//    CGRect realFrame = CGRectMake(disView.frame.origin.x, disView.frame.origin.y + 64, disView.frame.size.width, disView.frame.size.height);
//    CGPoint realCenter = CGPointMake(disView.center.x, disView.center.y + 64);
//    
//    
//    UIBezierPath *finalPath = [UIBezierPath bezierPathWithOvalInRect:realFrame];
//    
//    CGPoint finalPoint;
//    
//    //判断触发点在哪个象限
//    if(realFrame.origin.x > (toVC.view.bounds.size.width / 2)){
//        if (realFrame.origin.y < (toVC.view.bounds.size.height / 2)) {
//            //第一象限
//            finalPoint = CGPointMake(realCenter.x - 0, realCenter.y - CGRectGetMaxY(toVC.view.bounds)+30);
//        }else{
//            //第四象限
//            finalPoint = CGPointMake(realCenter.x - 0, realCenter.y - 0);
//        }
//    }else{
//        if (realFrame.origin.y < (toVC.view.bounds.size.height / 2)) {
//            //第二象限
//            finalPoint = CGPointMake(realCenter.x - CGRectGetMaxX(toVC.view.bounds), realCenter.y - CGRectGetMaxY(toVC.view.bounds)+30);
//        }else{
//            //第三象限
//            finalPoint = CGPointMake(realCenter.x - CGRectGetMaxX(toVC.view.bounds), realCenter.y - 0);
//        }
//    }
//    
//    CGFloat radius = sqrt(finalPoint.x * finalPoint.x + finalPoint.y * finalPoint.y);
//    UIBezierPath *startPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(realFrame, -radius, -radius)];
//    
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.path = finalPath.CGPath;
//    fromVC.view.layer.mask = maskLayer;
//    
//    CABasicAnimation *pingAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
//    pingAnimation.fromValue = (__bridge id)(startPath.CGPath);
//    pingAnimation.toValue   = (__bridge id)(finalPath.CGPath);
//    pingAnimation.duration = [self transitionDuration:context];
//    pingAnimation.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    
//    pingAnimation.delegate = self;
//    [maskLayer addAnimation:pingAnimation forKey:@"pingInvert"];
    [UIView animateWithDuration:[self transitionDuration:context] animations:^{
        fromVC.view.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        BOOL isCancel = [context transitionWasCancelled];
        [context completeTransition:!isCancel];
        fromVC.view.alpha = 1;
        toVC.view.alpha = 1;
    }];
    
    
    
}



@end
