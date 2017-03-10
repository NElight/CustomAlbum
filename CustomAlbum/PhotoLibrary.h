//
//  PhotoLibrary.h
//  CustomAlbum
//
//  Created by Yioks-Mac on 17/3/9.
//  Copyright © 2017年 Yioks-Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@interface PhotoLibrary : NSObject


- (PHFetchResult<PHAsset*>*)createAssets;
- (PHAssetCollection *)createCollection;



@end
