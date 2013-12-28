//
//  KZSampleTableViewController.m
//  KZCollectionViewTableLayout
//
//  Created by James Richard on 12/27/13.
//  Copyright (c) 2013 James Richard. All rights reserved.
//

#import "KZSampleTableViewController.h"
#import "KZTableLabelDataSource.h"
#import "KZLabeledHeaderView.h"
#import "KZCornerCell.h"

@interface KZSampleTableViewController ()
@property (nonatomic, strong) KZTableLabelDataSource *dataSource;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic) BOOL useCornerDecoration;
@property (nonatomic) BOOL useRowHeaders;
@property (nonatomic) BOOL useColumnHeaders;
@end

@implementation KZSampleTableViewController
- (void) viewDidLoad {
  [super viewDidLoad];
  [self.collectionView registerClass:[KZLabeledHeaderView class] forSupplementaryViewOfKind:KZCollectionViewTableLayoutSupplementaryViewRowHeader withReuseIdentifier:@"LabelHeader"];
  [self.collectionView registerClass:[KZLabeledHeaderView class] forSupplementaryViewOfKind:KZCollectionViewTableLayoutSupplementaryViewColumnHeader withReuseIdentifier:@"LabelHeader"];
  
  if (self.useCornerDecoration) {
    [self.collectionView.collectionViewLayout registerClass:[KZCornerCell class] forDecorationViewOfKind:KZCollectionViewTableLayoutDecorationViewCornerCell];
  }
  
  self.dataSource = [KZTableLabelDataSource sampleDataSourceWithRows:100 columns:20 rowHeaders:self.useRowHeaders columnHeaders:self.useColumnHeaders];
  self.collectionView.dataSource = self.dataSource;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(KZCollectionViewTableLayout *)layout sizeForCellAtIndexPath:(NSIndexPath *)indexPath {
  NSString *label = [self.dataSource labelAtIndexPath:indexPath];
  NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13.f]};
  CGSize size = [label sizeWithAttributes:attributes];
  CGSize adjustedSize = CGSizeMake(ceil(size.width), ceil(size.height));
  return adjustedSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(KZCollectionViewTableLayout *)layout supplementaryViewOfKind:(NSString *)kind sizeAtIndexPath:(NSIndexPath *)indexPath {
  if ([kind isEqualToString:KZCollectionViewTableLayoutSupplementaryViewRowHeader]) {
    NSString *label = [self.dataSource rowHeaderTitleAtIndexPath:indexPath];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13.f]};
    CGSize size = [label sizeWithAttributes:attributes];
    CGSize adjustedSize = CGSizeMake(ceil(size.width), ceil(size.height));
    return adjustedSize;
  } else if ([kind isEqualToString:KZCollectionViewTableLayoutSupplementaryViewColumnHeader]) {
    NSString *label = [self.dataSource columnHeaderTitleAtIndexPath:indexPath];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13.f]};
    CGSize size = [label sizeWithAttributes:attributes];
    CGSize adjustedSize = CGSizeMake(ceil(size.width), ceil(size.height));
    return adjustedSize;
  }
  
  return CGSizeZero;
}

@end
