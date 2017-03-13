//
//  PhotoDetailViewController.m
//  CustomAlbum
//
//  Created by Yioks-Mac on 17/3/10.
//  Copyright © 2017年 Yioks-Mac. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "ImageCell.h"
#import "ZGPhotoAnimation.h"
#import "PhotoScanViewController.h"

@interface PhotoDetailViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, ImageCellDelegate>
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UIPageControl *pageControl;



@property (nonatomic) CGPoint startPoint;

@property (nonatomic, strong) ZGPhotoAnimation *phAni;

@property (nonatomic, weak) PhotoScanViewController * navigationDelegate;
@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTran;

@end

@implementation PhotoDetailViewController

//- (instancetype)init {
//    if (self = [super init]) {
//        self.navigationController.delegate = self;
//    }
//    return self;
//}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    self.phAni = [[ZGPhotoAnimation alloc]initWithType:operation];
    return self.phAni;
}


- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    
    self.interactiveTran = [[UIPercentDrivenInteractiveTransition alloc]init];
    return self.interactive ? self.interactiveTran : nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.interactive = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self createCollectionView];
    
    [self createPageControl];
}


- (void)createPageControl {
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    self.pageControl.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height - 100);
    self.pageControl.numberOfPages = self.fetchResult.count;
    self.pageControl.currentPage = self.selectedIndexPath.item;
    [self.view addSubview:self.pageControl];
}

- (void)createCollectionView {
    self.flowLayout = [[UICollectionViewFlowLayout alloc]init];
    self.flowLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height -64);
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.minimumLineSpacing = 0;
    self.collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.pagingEnabled = YES;
    [self.view addSubview:self.collectionView];
    if (self.selectedIndexPath) {
        
        [self.collectionView scrollToItemAtIndexPath:self.selectedIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.assetArr) {
        return self.assetArr.count;
    }else {
        return self.fetchResult.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    PHAsset *asset = nil;
    if (self.assetArr) {
        asset = [self.assetArr objectAtIndex:indexPath.item];
    }else {
        asset = [self.fetchResult objectAtIndex:indexPath.item];
    }
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:self.flowLayout.itemSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.imageView.image = result;
    }];
    
    return cell;
}

// MARK: -----------ImageCellDelegate
- (void)panGestureBegin:(UIPanGestureRecognizer *)pan {
    CGFloat distance = 0.f;
    CGFloat per = 0.f;
    
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        UIView *view = pan.view;
        self.snapView = [view snapshotViewAfterScreenUpdates:NO];
        view.hidden = YES;
        CGPoint p = [self.collectionView convertPoint:view.center toView:self.view];
        self.snapView.center = p;
        [self.view addSubview:self.snapView];
        self.startPoint = [pan locationInView:self.view];
        self.selectedCell = (ImageCell*)view;
        
        self.navigationDelegate = (PhotoScanViewController *)self.navigationController.delegate;
        self.interactive = YES;
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        CGFloat tranX = [pan locationOfTouch:0 inView:self.view].x - _startPoint.x;
        CGFloat tranY = [pan locationOfTouch:0 inView:self.view].y - _startPoint.y;
        self.startPoint = [pan locationOfTouch:0 inView:self.view];
        self.snapView.center = CGPointApplyAffineTransform(self.snapView.center, CGAffineTransformMakeTranslation(tranX, tranY));
        if (self.snapView) {
            CGPoint p = [self.collectionView convertPoint:self.selectedCell.center toView:self.view];
            distance = sqrt(pow(self.snapView.center.x - p.x, 2) + pow(self.snapView.center.y - p.y, 2));
#define maxDistance 300
            per = distance / maxDistance >= 1 ? 0.99 : distance / maxDistance;
        }
        [self.navigationDelegate.interactiveTran updateInteractiveTransition:per];
    }else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        self.selectedCell.hidden = NO;
        if (per > 0.5) {
            [self.navigationDelegate.interactiveTran finishInteractiveTransition];
        }else {
            [self.navigationDelegate.interactiveTran cancelInteractiveTransition];
        }
        self.interactive = NO;
        [self.snapView removeFromSuperview];
        self.snapView = nil;
    }else {
        self.interactive = NO;
        self.snapView = nil;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page = scrollView.contentOffset.x / self.view.bounds.size.width;
    self.pageControl.currentPage = page;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
