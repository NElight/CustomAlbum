//
//  PhotoSave.m
//  CustomAlbum
//
//  Created by Yioks-Mac on 17/3/9.
//  Copyright © 2017年 Yioks-Mac. All rights reserved.
//

#import "PhotoSave.h"

@implementation PhotoSave

- (void)saveImage:(UIImage *) image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), @"123");
    
}

@end
