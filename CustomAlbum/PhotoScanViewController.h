//
//  PhotoScanViewController.h
//  CustomAlbum
//
//  Created by Yioks-Mac on 17/3/10.
//  Copyright © 2017年 Yioks-Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface PhotoScanViewController : UIViewController

@property (nonatomic, strong) PHFetchResult<PHAsset *> * fetchResult;
@property (nonatomic, strong) PHAssetCollection * assetCollection;

@property (nonatomic, strong) UICollectionViewCell *selectedCell;

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTran;

@end
