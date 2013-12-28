//
//  KEZSampleTableViewController.m
//  KEZCollectionViewTableLayout
//
//  Created by James Richard on 12/27/13.
//  Copyright (c) 2013 James Richard. All rights reserved.
//

#import "KEZSampleTableViewController.h"
#import "KEZTableLabelDataSource.h"
#import "KEZLabeledHeaderView.h"
#import "KEZCornerCell.h"

@interface KEZSampleTableViewController ()
@property (nonatomic, strong) KEZTableLabelDataSource *dataSource;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic) BOOL useCornerDecoration;
@property (nonatomic) BOOL useRowHeaders;
@property (nonatomic) BOOL useColumnHeaders;
@end

@implementation KEZSampleTableViewController
- (void) viewDidLoad {
  [super viewDidLoad];
  [self.collectionView registerClass:[KEZLabeledHeaderView class] forSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewRowHeader withReuseIdentifier:@"LabelHeader"];
  [self.collectionView registerClass:[KEZLabeledHeaderView class] forSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader withReuseIdentifier:@"LabelHeader"];

  if (self.useCornerDecoration) {
    [self.collectionView.collectionViewLayout registerClass:[KEZCornerCell class] forDecorationViewOfKind:KEZCollectionViewTableLayoutDecorationViewCornerCell];
  }
  
  self.dataSource = [KEZTableLabelDataSource sampleDataSourceWithRows:100 columns:20 rowHeaders:self.useRowHeaders columnHeaders:self.useColumnHeaders];
  self.collectionView.dataSource = self.dataSource;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(KEZCollectionViewTableLayout *)layout sizeForCellAtIndexPath:(NSIndexPath *)indexPath {
  NSString *label = [self.dataSource labelAtIndexPath:indexPath];
  NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13.f]};
  CGSize size = [label sizeWithAttributes:attributes];
  CGSize adjustedSize = CGSizeMake(ceil(size.width), ceil(size.height));
  return adjustedSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(KEZCollectionViewTableLayout *)layout supplementaryViewOfKind:(NSString *)kind sizeAtIndexPath:(NSIndexPath *)indexPath {
  if ([kind isEqualToString:KEZCollectionViewTableLayoutSupplementaryViewRowHeader]) {
    NSString *label = [self.dataSource rowHeaderTitleAtIndexPath:indexPath];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13.f]};
    CGSize size = [label sizeWithAttributes:attributes];
    CGSize adjustedSize = CGSizeMake(ceil(size.width), ceil(size.height));
    return adjustedSize;
  } else if ([kind isEqualToString:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader]) {
    NSString *label = [self.dataSource columnHeaderTitleAtIndexPath:indexPath];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13.f]};
    CGSize size = [label sizeWithAttributes:attributes];
    CGSize adjustedSize = CGSizeMake(ceil(size.width), ceil(size.height));
    return adjustedSize;
  }
  
  return CGSizeZero;
}

@end
