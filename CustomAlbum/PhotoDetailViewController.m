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

@interface PhotoDetailViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, ImageCellDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIView *snapView;

@property (nonatomic) CGPoint startPoint;

@end

@implementation PhotoDetailViewController

- (instancetype)init {
    if (self = [super init]) {
        self.navigationController.delegate = self;
    }
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    return [[ZGPhotoAnimation alloc]initWithType:operation];
}

/*
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    
}
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    self.flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.minimumLineSpacing = 0;
    self.collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.pagingEnabled = YES;
    [self.view addSubview:self.collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:self.flowLayout.itemSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.imageView.image = result;
    }];
    
    return cell;
}

// MARK: -----------ImageCellDelegate
- (void)panGestureBegin:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        UIView *view = pan.view;
        self.snapView = [view snapshotViewAfterScreenUpdates:NO];
        view.hidden = YES;
        self.snapView.center = view.center;
        [self.view addSubview:self.snapView];
        self.startPoint = [pan locationInView:self.view];
        self.selectedCell = (ImageCell*)view;
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        CGFloat tranX = [pan locationOfTouch:0 inView:self.view].x - _startPoint.x;
        CGFloat tranY = [pan locationOfTouch:0 inView:self.view].y - _startPoint.y;
        self.startPoint = [pan locationOfTouch:0 inView:self.view];
        self.snapView.center = CGPointApplyAffineTransform(self.snapView.center, CGAffineTransformMakeTranslation(tranX, tranY));
    }else if (pan.state == UIGestureRecognizerStateEnded) {
        [self.snapView removeFromSuperview];
        self.selectedCell.hidden = NO;
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
