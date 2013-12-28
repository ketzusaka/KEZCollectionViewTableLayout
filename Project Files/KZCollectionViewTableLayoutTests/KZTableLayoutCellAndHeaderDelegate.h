//
//  KZTableLayoutCellAndHeaderDelegate.h
//  KZCollectionViewTableLayout
//
//  Created by James Richard on 12/20/13.
//  Copyright (c) 2013 James Richard. All rights reserved.
//

#import "KZTableLayoutCellDelegate.h"

@interface KZTableLayoutCellAndHeaderDelegate : KZTableLayoutCellDelegate
- (void) setRowHeaderSize:(NSValue *)size forIndexPath:(NSIndexPath *)indexPath;
- (void) setColumnHeaderSize:(NSValue *)size forIndexPath:(NSIndexPath *)indexPath;
@end
