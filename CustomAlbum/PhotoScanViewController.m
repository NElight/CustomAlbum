//
//  PhotoScanViewController.m
//  CustomAlbum
//
//  Created by Yioks-Mac on 17/3/10.
//  Copyright © 2017年 Yioks-Mac. All rights reserved.
//

#import "PhotoScanViewController.h"
#import <PhotosUI/PhotosUI.h>
#import "ImageCell.h"
#import "UICollectionView+IndexPathInRect.h"
#import "PhotoDetailViewController.h"

@interface PhotoScanViewController ()<PHPhotoLibraryChangeObserver, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic) CGSize thumbnailSize;
@property (nonatomic) CGRect previousPreheatRect;

@property (nonatomic, strong) NSMutableDictionary *imageCache;

@end

@implementation PhotoScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self createCollectionView];
    
    self.imageManager = [PHCachingImageManager defaultManager];
    [self resetCachedAssets];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)createCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(self.view.bounds.size.width / 4, self.view.bounds.size.width / 4);
    self.thumbnailSize = layout.itemSize;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:self.collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        
        cell.livePhotoBadgeImageView.image = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
    }
    
    [self.imageCache setObject:asset.localIdentifier forKey:@(indexPath.item)];
    
    [self.imageManager requestImageForAsset:asset targetSize:self.thumbnailSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if ([[self.imageCache objectForKey:@(indexPath.item)] isEqualToString:asset.localIdentifier]) {
            cell.imageView.image = result;
        }
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    PhotoDetailViewController *vc = [[PhotoDetailViewController alloc]init];
    vc.selectedIndexPath = indexPath;
    vc.fetchResult = self.fetchResult;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat scale = [UIScreen mainScreen].scale;
    self.thumbnailSize = CGSizeMake(self.view.bounds.size.width * scale, self.view.bounds.size.height  * scale);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAsset)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateCachedAssets];
}

- (void)updateCachedAssets {
    if (!self.isViewLoaded || self.view.window == nil) {
        return ;
    }
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    CGRect preheatRect = CGRectInset(visibleRect, 0, - 0.5 * visibleRect.size.height);
    CGFloat delta = fabs(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta <= self.view.bounds.size.height / 3) {
        return ;
    }
    
    NSDictionary *addAndRemoves = [self differencesBetweenRects:preheatRect withOldRect:self.previousPreheatRect];
    NSMutableArray *addedAssets = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *removedAssets = [NSMutableArray arrayWithCapacity:0];
    for (NSValue *rectValue in addAndRemoves[@"added"]) {
        NSArray *indexPaths = [self.collectionView indexPathsForElementsInRect:[rectValue CGRectValue]];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:0];
        for (NSIndexPath * indexPath in indexPaths) {
            PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
            [temp addObject:asset];
        }
        [addedAssets addObjectsFromArray:temp];
    }
    
    for (NSValue *rectValue in addAndRemoves[@"removed"]) {
        NSArray *indexPaths = [self.collectionView indexPathsForElementsInRect:[rectValue CGRectValue]];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:0];
        for (NSIndexPath * indexPath in indexPaths) {
            PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
            [temp addObject:asset];
        }
        [removedAssets addObjectsFromArray:temp];
    }
    
    [self.imageManager startCachingImagesForAssets:addedAssets targetSize:self.thumbnailSize contentMode:PHImageContentModeAspectFill options:nil];
    [self.imageManager stopCachingImagesForAssets:removedAssets targetSize:self.thumbnailSize contentMode:PHImageContentModeAspectFill options:nil];
    self.previousPreheatRect = preheatRect;
    
}

- (NSDictionary *)differencesBetweenRects:(CGRect)new withOldRect:(CGRect)old {
    if (CGRectIntersectsRect(old, new)) {
        NSMutableArray *added = [NSMutableArray arrayWithCapacity:0];
        if (CGRectGetMaxY(new) > CGRectGetMaxY(old)) {
            CGRect temp = CGRectMake(new.origin.x, CGRectGetMaxY(old), new.size.width, CGRectGetMaxY(new) - CGRectGetMaxY(old));
            NSValue *tempValue = [NSValue valueWithCGRect:temp];
            [added addObject:tempValue];
        }
        if (CGRectGetMinY(old) > CGRectGetMinY(new)) {
            CGRect temp = CGRectMake(new.origin.x, CGRectGetMinY(new), new.size.width, CGRectGetMinY(old) - CGRectGetMinY(new));
            NSValue *tempValue = [NSValue valueWithCGRect:temp];
            [added addObject:tempValue];
        }
        
        NSMutableArray *removed = [NSMutableArray arrayWithCapacity:0];
        if (CGRectGetMaxY(new) < CGRectGetMaxY(old)) {
            CGRect temp = CGRectMake(new.origin.x, CGRectGetMaxY(new), new.size.width, CGRectGetMaxY(old) - CGRectGetMaxY(new));
            NSValue *tempValue = [NSValue valueWithCGRect:temp];
            [removed addObject:tempValue];
        }
        if (CGRectGetMinY(old) < CGRectGetMinY(new)) {
            CGRect temp = CGRectMake(new.origin.x, CGRectGetMinY(old), new.size.width, CGRectGetMinY(new) - CGRectGetMinY(old));
            NSValue *tempValue = [NSValue valueWithCGRect:temp];
            [removed addObject:tempValue];
        }
        return @{@"added" : added, @"removed" : removed};
    }else {
        NSValue *newV = [NSValue valueWithCGRect:new];
        NSValue *oldV = [NSValue valueWithCGRect:old];
        return @{@"added" : @[newV], @"removed" : @[oldV]};
    }
}

- (void)addAsset {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc]initWithSize:CGSizeMake(self.view.bounds.size.width / 4, self.view.bounds.size.width / 4)];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [[UIColor colorWithHue:(CGFloat)(arc4random_uniform(100) / 100) saturation:1 brightness:1 alpha:1] setFill];
        [rendererContext fillRect:rendererContext.format.bounds];
    }];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *creationRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        if (self.assetCollection) {
            PHAssetCollectionChangeRequest *addAssetRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.assetCollection];
            [addAssetRequest addAssets:@[creationRequest.placeholderForCreatedAsset]];
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (!success) {
            NSLog(@"-----------%@", error);
        }
    }];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResultChangeDetails *detail = [changeInstance changeDetailsForFetchResult:self.fetchResult];
    if (!detail) {
        return;
    }
    
    if (detail.hasIncrementalChanges) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.fetchResult = [detail fetchResultAfterChanges];
            [self.collectionView performBatchUpdates:^{
                if (detail.removedIndexes.count > 0) {
                    
                    [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[detail.removedIndexes firstIndex] inSection:0]]];
                }
                
                if (detail.insertedIndexes.count > 0) {
                    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[detail.insertedIndexes firstIndex] inSection:0]]];
                }
                
                if (detail.changedIndexes.count > 0) {
                    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[detail.changedIndexes firstIndex] inSection:0]]];
                }
                
                [detail enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                    [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0] toIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]];
                }];
                
            } completion:^(BOOL finished) {
                
            }];
        });
    }else {
        [self.collectionView reloadData];
    }
    
    [self resetCachedAssets];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCachedAssets];
}

- (NSMutableDictionary *)imageCache {
    if (!_imageCache) {
        _imageCache = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _imageCache;
}

- (void)resetCachedAssets {
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
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
