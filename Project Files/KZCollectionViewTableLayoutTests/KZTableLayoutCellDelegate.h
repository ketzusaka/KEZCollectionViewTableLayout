//
//  KZTableLayoutCellDelegate.h
//  KZCollectionViewTableLayout
//
//  Created by James Richard on 12/20/13.
//  Copyright (c) 2013 James Richard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KEZCollectionViewTableLayout.h"

@interface KZTableLayoutCellDelegate : NSObject <KEZCollectionViewDelegateTableLayout>
- (void) setCellSize:(NSValue *)size forIndexPath:(NSIndexPath *)indexPath;
@end
