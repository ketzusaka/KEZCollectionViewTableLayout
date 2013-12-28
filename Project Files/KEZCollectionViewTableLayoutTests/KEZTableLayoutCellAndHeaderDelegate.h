//
//  KEZTableLayoutCellAndHeaderDelegate.h
//  KEZCollectionViewTableLayout
//
//  Created by James Richard on 12/20/13.
//  Copyright (c) 2013 James Richard. All rights reserved.
//

#import "KEZTableLayoutCellDelegate.h"

@interface KEZTableLayoutCellAndHeaderDelegate : KEZTableLayoutCellDelegate
- (void) setRowHeaderSize:(NSValue *)size forIndexPath:(NSIndexPath *)indexPath;
- (void) setColumnHeaderSize:(NSValue *)size forIndexPath:(NSIndexPath *)indexPath;
@end
