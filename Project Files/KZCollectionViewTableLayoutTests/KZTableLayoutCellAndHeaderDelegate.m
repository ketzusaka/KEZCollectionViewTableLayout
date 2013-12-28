//
//  KZTableLayoutCellAndHeaderDelegate.m
//  KZCollectionViewTableLayout
//
//  Created by James Richard on 12/20/13.
//  Copyright (c) 2013 James Richard. All rights reserved.
//

#import "KZTableLayoutCellAndHeaderDelegate.h"

@interface KZTableLayoutCellAndHeaderDelegate ()
@property (nonatomic, strong) NSMutableDictionary *rowHeaderSizing;
@property (nonatomic, strong) NSMutableDictionary *columnHeaderSizing;
@end

@implementation KZTableLayoutCellAndHeaderDelegate
- (instancetype) init {
  if (self = [super init]) {
    _rowHeaderSizing = [NSMutableDictionary dictionary];
    _columnHeaderSizing = [NSMutableDictionary dictionary];
  }
  
  return self;
}

- (void) setRowHeaderSize:(NSValue *)size forIndexPath:(NSIndexPath *)indexPath {
  self.rowHeaderSizing[indexPath] = size;
}

- (void) setColumnHeaderSize:(NSValue *)size forIndexPath:(NSIndexPath *)indexPath {
  self.columnHeaderSizing[indexPath] = size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(KEZCollectionViewTableLayout *)layout supplementaryViewOfKind:(NSString *)kind sizeAtIndexPath:(NSIndexPath *)indexPath {
  CGSize size;
  
  if ([kind isEqualToString:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader])
    size = [[self.columnHeaderSizing objectForKey:indexPath] CGSizeValue];
  else if ([kind isEqualToString:KEZCollectionViewTableLayoutSupplementaryViewRowHeader])
    size = [[self.rowHeaderSizing objectForKey:indexPath] CGSizeValue];
  
  return size;
}
@end
