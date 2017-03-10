//
//  UICollectionView+IndexPathInRect.m
//  CustomAlbum
//
//  Created by Yioks-Mac on 17/3/10.
//  Copyright © 2017年 Yioks-Mac. All rights reserved.
//

#import "UICollectionView+IndexPathInRect.h"

@implementation UICollectionView (IndexPathInRect)

- (NSIndexPath *)indexPathsForElementsInRect:(CGRect)rect {
    NSArray * allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:0];
    for (UICollectionViewLayoutAttributes * attr in allLayoutAttributes) {
        [temp addObject:attr.indexPath];
    }
    return temp;
}

@end
