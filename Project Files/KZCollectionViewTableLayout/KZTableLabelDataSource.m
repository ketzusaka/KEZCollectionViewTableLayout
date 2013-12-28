//
//  KZTableDataSource.m
//  KZCollectionViewTableLayout
//
//  Created by James Richard on 12/13/13.
//  Copyright (c) 2013 James Richard. All rights reserved.
//

#import "KZTableLabelDataSource.h"
#import "KZLabelCell.h"
#import "KZLabeledHeaderView.h"
#import "KZCollectionViewTableLayout.h"

@interface KZTableLabelDataSource ()
@property (nonatomic, strong) NSArray *rowTitles;
@property (nonatomic, strong) NSArray *columnTitles;
@property (nonatomic, strong) NSArray *labelStrings;
@end

@implementation KZTableLabelDataSource
- (instancetype) init {
  return [self initWithRowTitles:nil columnTitles:nil labelStrings:@[]];
}

- (instancetype) initWithRowTitles:(NSArray *)rowTitles columnTitles:(NSArray *)columnTitles labelStrings:(NSArray *)labelStrings {
  if (self = [super init]) {
    _rowTitles = rowTitles;
    _columnTitles = columnTitles;
    _labelStrings = labelStrings;
  }
  
  return self;
}

+ (instancetype) sampleDataSourceWithRows:(NSUInteger)rows columns:(NSUInteger)columns rowHeaders:(BOOL)rowHeaders columnHeaders:(BOOL)columnHeaders {
  static NSNumberFormatter *formatter;
  if (!formatter) {
    formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterSpellOutStyle;
  }
  
  NSMutableArray *rowTitles = [NSMutableArray array];
  NSMutableArray *rowHeaderTitles = rowHeaders ? [NSMutableArray array] : nil;
  NSMutableArray *columnHeaderTitles = columnHeaders ? [NSMutableArray array] : nil;
  
  for (int i = 0; i != rows; i++) {
    NSMutableArray *row = [NSMutableArray array];
    if (rowHeaders)
      [rowHeaderTitles addObject:[NSString stringWithFormat:@"Row %i", i]];
    
    for (int j = 0; j != columns; j++) {
      if (columnHeaders)
        [columnHeaderTitles addObject:[NSString stringWithFormat:@"Column %i", j]];
      
      [row addObject:[formatter stringFromNumber:@(i * j)]];
    }
    [rowTitles addObject:row];
  }
  
  return [[self alloc] initWithRowTitles:[rowHeaderTitles copy] columnTitles:[columnHeaderTitles copy] labelStrings:[rowTitles copy]];
}

- (NSString *) labelAtIndexPath:(NSIndexPath *)indexPath {
  return self.labelStrings[indexPath.section][indexPath.row];
}

- (NSString *) columnHeaderTitleAtIndexPath:(NSIndexPath *)indexPath {
  return self.columnTitles[indexPath.row];
}

- (NSString *) rowHeaderTitleAtIndexPath:(NSIndexPath *)indexPath {
  return self.rowTitles[indexPath.section];
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"LabelCell";
  KZLabelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
  cell.label.text = self.labelStrings[indexPath.section][indexPath.row];
  return cell;
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"LabelHeader";
  KZLabeledHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:CellIdentifier forIndexPath:indexPath];
  if ([kind isEqualToString:KZCollectionViewTableLayoutSupplementaryViewColumnHeader])
    view.label.text = self.columnTitles[indexPath.row];
  else if ([kind isEqualToString:KZCollectionViewTableLayoutSupplementaryViewRowHeader])
    view.label.text = self.rowTitles[indexPath.section];
  
  return view;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return self.labelStrings.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return ((NSArray*)self.labelStrings[section]).count;
}
@end
