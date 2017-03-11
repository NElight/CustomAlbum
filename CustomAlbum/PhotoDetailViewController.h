//
//  PhotoDetailViewController.h
//  CustomAlbum
//
//  Created by Yioks-Mac on 17/3/10.
//  Copyright © 2017年 Yioks-Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

@interface PhotoDetailViewController : UIViewController<UINavigationControllerDelegate>

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) PHFetchResult *fetchResult;

@property (nonatomic, strong) NSMutableArray *assetArr;

@property (nonatomic, strong) UICollectionViewCell *selectedCell;

@property (nonatomic, strong) UIView *snapView;

@property (nonatomic, strong) UICollectionView *collectionView;

@end
