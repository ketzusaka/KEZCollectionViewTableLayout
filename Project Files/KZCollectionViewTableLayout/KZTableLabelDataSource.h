//
//  KZTableDataSource.h
//  KZCollectionViewTableLayout
//
//  Created by James Richard on 12/13/13.
//  Copyright (c) 2013 James Richard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KZTableLabelDataSource : NSObject <UICollectionViewDataSource>
+ (instancetype) sampleDataSourceWithRows:(NSUInteger)rows columns:(NSUInteger)columns rowHeaders:(BOOL)rowHeaders columnHeaders:(BOOL)columnHeaders;
- (NSString *) labelAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *) columnHeaderTitleAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *) rowHeaderTitleAtIndexPath:(NSIndexPath *)indexPath;
@end
