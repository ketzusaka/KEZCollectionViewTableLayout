//
//  KEZTableLayoutCellDelegate.m
//  KEZCollectionViewTableLayout
//
//  Created by James Richard on 12/20/13.
//  Copyright (c) 2013 James Richard. All rights reserved.
//

#import "KEZTableLayoutCellDelegate.h"

@interface KEZTableLayoutCellDelegate ()
@property (nonatomic, strong) NSMutableDictionary *cellSizing;
@end

@implementation KEZTableLayoutCellDelegate
- (instancetype) init {
  if (self = [super init]) {
    _cellSizing = [NSMutableDictionary dictionary];
  }
  
  return self;
}

- (void) setCellSize:(NSValue *)size forIndexPath:(NSIndexPath *)indexPath {
  self.cellSizing[indexPath] = size;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(KEZCollectionViewTableLayout *)layout sizeForCellAtIndexPath:(NSIndexPath *)indexPath {
  return [self.cellSizing[indexPath] CGSizeValue];
}
@end
