//
//  KEZCollectionViewTableLayout.m
//  SampleTableLayout
//
//  Created by James Richard on 12/9/13.
//  Copyright (c) 2013 James Richard. All rights reserved.
//

#import "KEZCollectionViewTableLayout.h"

NSString * const KEZCollectionViewTableLayoutSupplementaryViewColumnHeader = @"KEZCollectionViewTableLayoutSupplementaryViewColumnHeader";
NSString * const KEZCollectionViewTableLayoutSupplementaryViewRowHeader = @"KEZCollectionViewTableLayoutSupplementaryViewRowHeader";
NSString * const KEZCollectionViewTableLayoutDecorationViewCornerCell = @"KEZCollectionViewTableLayoutDecorationViewCornerCell";

#pragma mark - KEZTableSizing
@interface KEZTableSizing : NSObject
- (CGFloat) widthForColumn:(NSUInteger)column;
- (CGFloat) heightForRow:(NSUInteger)row;
- (void) setWidth:(CGFloat)width forColumn:(NSUInteger)column;
- (void) setHeight:(CGFloat)height forRow:(NSUInteger)row;
@end

@interface KEZTableSizing ()
@property (nonatomic, strong) NSMutableDictionary *rows;
@property (nonatomic, strong) NSMutableDictionary *columns;
@property (nonatomic) CGFloat columnHeaderHeight;
@property (nonatomic) CGFloat rowHeaderWidth;
@end

@implementation KEZTableSizing
- (instancetype) init {
  if (self = [super init]) {
    _rows = [[NSMutableDictionary alloc] init];
    _columns = [[NSMutableDictionary alloc] init];
    _columnHeaderHeight = 0;
    _rowHeaderWidth = 0;
  }
  
  return self;
}

- (CGFloat) widthForColumn:(NSUInteger)column {
  return [[self.columns objectForKey:@(column)] floatValue];
}

- (CGFloat) heightForRow:(NSUInteger)row {
  return [[self.rows objectForKey:@(row)] floatValue];
}

- (void) setWidth:(CGFloat)width forColumn:(NSUInteger)column {
  self.columns[@(column)] = @(width);
}

- (void) setHeight:(CGFloat)height forRow:(NSUInteger)row {
  self.rows[@(row)] = @(height);
}
@end

#pragma mark - BLCollectionViewTableLayoutInvalidationContext
@interface KEZCollectionViewTableLayoutInvalidationContext : UICollectionViewFlowLayoutInvalidationContext
@property (nonatomic) BOOL useCachedSizing;
@end

@implementation KEZCollectionViewTableLayoutInvalidationContext
@end

#pragma mark - KEZCollectionViewTableLayout
@interface KEZCollectionViewTableLayout ()
@property (nonatomic) CGSize collectionViewContentSize;
@property (nonatomic, strong) NSArray *cellAttributes;
@property (nonatomic, strong) NSDictionary *supplementaryAttributes;
@property (nonatomic, strong) NSDictionary *decorationAttributes;
@property (nonatomic, strong) KEZTableSizing *tableSizing;
@property (nonatomic) BOOL skipBuildingCellAttributes;
@property (nonatomic) BOOL hasRegisteredCellCornerDecorationView;
@end

@implementation KEZCollectionViewTableLayout
#pragma mark - Instantiation
- (instancetype) init {
  if (self = [super init]) {
    [self setup];
  }
  
  return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self setup];
  }
  
  return self;
}

- (void) setup {
  _cellSize = CGSizeMake(100, 100);
  _minimumCellSize = CGSizeZero;
  _maximumCellSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
  _rowHeaderWidth = 0.0f;
  _columnHeaderHeight = 0.0f;
  _collectionViewContentSize = CGSizeZero;
}

#pragma mark - UICollectionViewLayout Overrides
// Note that we don't override collectionViewContentSize because our
// private property declaration provides the right implementation.

// Overriding decoration registers so we don't always require a cell corner.
- (void) registerClass:(Class)viewClass forDecorationViewOfKind:(NSString *)decorationViewKind {
  [super registerClass:viewClass forDecorationViewOfKind:decorationViewKind];
  if ([decorationViewKind isEqualToString:KEZCollectionViewTableLayoutDecorationViewCornerCell])
    self.hasRegisteredCellCornerDecorationView = viewClass != nil;
}

- (void) registerNib:(UINib *)nib forDecorationViewOfKind:(NSString *)decorationViewKind {
  [super registerNib:nib forDecorationViewOfKind:decorationViewKind];
  if ([decorationViewKind isEqualToString:KEZCollectionViewTableLayoutDecorationViewCornerCell])
    self.hasRegisteredCellCornerDecorationView = nib != nil;
}

- (void) prepareLayout {
  [super prepareLayout];
  [self buildLayoutAttributes];
  if (CGSizeEqualToSize(self.collectionViewContentSize, CGSizeZero))
    [self buildCollectionViewContentSize];
}

- (UICollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
  return self.cellAttributes[indexPath.section][indexPath.row];
}

- (UICollectionViewLayoutAttributes *) layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
  return self.supplementaryAttributes[kind][indexPath];
}

- (UICollectionViewLayoutAttributes *) layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
  return self.decorationAttributes[decorationViewKind][indexPath];
}

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
  NSMutableArray *elements = [NSMutableArray array];
  
  for (NSArray *rows in self.cellAttributes) {
    for (UICollectionViewLayoutAttributes *attributes in rows) {
      if (CGRectIntersectsRect(rect, attributes.frame)) {
        [elements addObject:attributes];
      }
    }
  }

  void (^handler)(id key, UICollectionViewLayoutAttributes *attributes, BOOL *stop) = ^(id key, UICollectionViewLayoutAttributes *attributes, BOOL *stop){
    if (CGRectIntersectsRect(rect, attributes.frame)) {
      [elements addObject:attributes];
    }
  };
  
  
  [self.supplementaryAttributes[KEZCollectionViewTableLayoutSupplementaryViewColumnHeader] enumerateKeysAndObjectsUsingBlock:handler];
  [self.supplementaryAttributes[KEZCollectionViewTableLayoutSupplementaryViewRowHeader] enumerateKeysAndObjectsUsingBlock:handler];
  [self.decorationAttributes[KEZCollectionViewTableLayoutDecorationViewCornerCell] enumerateKeysAndObjectsUsingBlock:handler];
  return [elements copy];
}

#pragma mark - Handling Bounds Changes
- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  if (self.stickyHeaders && [self hasHeaderSizing]) {
    CGPoint origin = self.collectionView.bounds.origin;
    CGPoint newOrigin = newBounds.origin;
    CGFloat xDiff = newOrigin.x - origin.x;
    CGFloat yDiff = newOrigin.y - origin.y;
    if (fabsf(xDiff) > FLT_EPSILON && [self hasRowHeaderSizing]) {
      return YES;
    }
    
    if (fabsf(yDiff) > FLT_EPSILON && [self hasColumnHeaderSizing]) {
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - Invalidation Contexts
- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds {
  KEZCollectionViewTableLayoutInvalidationContext *context = (KEZCollectionViewTableLayoutInvalidationContext *)[super invalidationContextForBoundsChange:newBounds];
  context.useCachedSizing = YES;
  return context;
}

- (void) invalidateLayoutWithContext:(KEZCollectionViewTableLayoutInvalidationContext *)context {
  [super invalidateLayoutWithContext:context];
  if (!context.useCachedSizing) {
    self.tableSizing = nil;
    self.collectionViewContentSize = CGSizeZero;
  } else {
    self.skipBuildingCellAttributes = YES;
  }
}

+ (Class) invalidationContextClass {
  return [KEZCollectionViewTableLayoutInvalidationContext class];
}

#pragma mark - Accessor Overrides
- (KEZTableSizing *) tableSizing {
  if (!_tableSizing) {
    _tableSizing = [self createTableSizing];
  }
  
  return _tableSizing;
}

#pragma mark - Private methods
- (void) buildCollectionViewContentSize {
  CGFloat width = 0.f;
  CGFloat height = 0.f;
  
  NSUInteger sections = [self.collectionView numberOfSections];
  if (sections > 0) {
    NSUInteger lastRowCells = [self.collectionView numberOfItemsInSection:sections - 1];
    if (lastRowCells > 0) {
      UICollectionViewLayoutAttributes *lastAttributes = self.cellAttributes[sections - 1][lastRowCells - 1];
      height = CGRectGetMaxY(lastAttributes.frame);
    }
    
    for (NSUInteger i = 0; i != sections; i++) {
      NSUInteger cells = [self.collectionView numberOfItemsInSection:i];
      if (cells > 0) {
        UICollectionViewLayoutAttributes *attributes = self.cellAttributes[i][cells - 1];
        width = MAX(width, CGRectGetMaxX(attributes.frame));
      }
    }
  }

  self.collectionViewContentSize = CGSizeMake(width, height);
}

#pragma mark Building layout attributes
- (void) buildLayoutAttributes {
  if (!self.skipBuildingCellAttributes) {
    // Clear our existing attributes to prevent reusing of objects.
    [self clearLayoutAttributes];
    
    // Only build cell attributes if we aren't skipping so we don't have to ask
    // the delegate for sizing information again.
    [self buildCellAttributes];
  } else {
    self.skipBuildingCellAttributes = NO;
  }
  
  // Always recalculate these because they don't require a refresh of data, and may
  // need a new frame based on the bounds of the collection view.
  [self buildSupplementaryAttributes];
  [self buildDecorationAttributes];
}

- (void) buildCellAttributes {
  KEZTableSizing *sizing = self.tableSizing;
  NSMutableArray *tmpAttributes = [[NSMutableArray alloc] init];
  CGFloat yOffset = sizing.columnHeaderHeight;
  NSUInteger sections = [self.collectionView numberOfSections];
  for (NSUInteger section = 0; section != sections; section++) {
    NSUInteger rows = [self.collectionView numberOfItemsInSection:section];
    CGFloat xOffset = sizing.rowHeaderWidth;
    CGFloat height = [sizing heightForRow:section];
    
    NSMutableArray *tmpRowAttributes = [[NSMutableArray alloc] init];
    for (NSUInteger row = 0; row != rows; row++) {
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
      CGFloat width = [sizing widthForColumn:row];
      
      UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
      attributes.frame = CGRectMake(xOffset, yOffset, width, height);
      [tmpRowAttributes addObject:attributes];
      xOffset += width;
    }
    
    [tmpAttributes addObject:tmpRowAttributes];
    
    yOffset += height;
  }
  
  self.cellAttributes = tmpAttributes;
}

- (void) buildSupplementaryAttributes {
  KEZTableSizing *sizing = self.tableSizing;
  NSMutableDictionary *rowHeaderAttributes = self.supplementaryAttributes[KEZCollectionViewTableLayoutSupplementaryViewRowHeader] ?: [NSMutableDictionary dictionary];
  NSMutableDictionary *columnHeaderAttributes = self.supplementaryAttributes[KEZCollectionViewTableLayoutSupplementaryViewColumnHeader] ?: [NSMutableDictionary dictionary];

  if (sizing.columnHeaderHeight > 0 || sizing.rowHeaderWidth > 0) {
    NSUInteger maximumRows = 0;
    CGFloat yOffset = sizing.columnHeaderHeight;
    NSUInteger sections = [self.collectionView numberOfSections];
    for (NSUInteger section = 0; section != sections; section++) {
      NSUInteger rows = [self.collectionView numberOfItemsInSection:section];
      maximumRows = MAX(maximumRows, rows);
      if (sizing.rowHeaderWidth > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        UICollectionViewLayoutAttributes *attributes = rowHeaderAttributes[indexPath] ?: [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewRowHeader withIndexPath:indexPath];
        CGFloat height = [sizing heightForRow:section];
        CGFloat xOffset = self.stickyHeaders ? CGRectGetMinX(self.collectionView.bounds) + self.collectionView.contentInset.left : 0;
        attributes.frame = CGRectMake(xOffset, yOffset, sizing.rowHeaderWidth, height);
        attributes.zIndex = 100;
        rowHeaderAttributes[indexPath] = attributes;
        yOffset += height;
      }
    }
    
    if (sizing.columnHeaderHeight > 0) {
      CGFloat xOffset = sizing.rowHeaderWidth;
      for (NSUInteger row = 0; row != maximumRows; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        UICollectionViewLayoutAttributes *attributes = columnHeaderAttributes[indexPath] ?: [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader withIndexPath:indexPath];
        CGFloat width = [sizing widthForColumn:row];
        CGFloat yOffset = self.stickyHeaders ? CGRectGetMinY(self.collectionView.bounds) + self.collectionView.contentInset.top : 0;
        attributes.frame = CGRectMake(xOffset, yOffset, width, sizing.columnHeaderHeight);
        attributes.zIndex = 200;
        columnHeaderAttributes[indexPath] = attributes;
        xOffset += width;
      }
    }
  }
  
  self.supplementaryAttributes = @{
                                   KEZCollectionViewTableLayoutSupplementaryViewColumnHeader: columnHeaderAttributes,
                                   KEZCollectionViewTableLayoutSupplementaryViewRowHeader: rowHeaderAttributes
                                   };
}

- (void) buildDecorationAttributes {
  KEZTableSizing *sizing = self.tableSizing;
  NSMutableDictionary *cellCornerAttributes = [NSMutableDictionary dictionary];
  
  if (self.hasRegisteredCellCornerDecorationView && sizing.columnHeaderHeight > 0 && sizing.rowHeaderWidth > 0) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:KEZCollectionViewTableLayoutDecorationViewCornerCell withIndexPath:indexPath];
    CGFloat x = self.stickyHeaders ? CGRectGetMinX(self.collectionView.bounds) + self.collectionView.contentInset.left : 0;
    CGFloat y = self.stickyHeaders ? CGRectGetMinY(self.collectionView.bounds) + self.collectionView.contentInset.top : 0;
    attributes.frame = CGRectMake(x, y, sizing.rowHeaderWidth, sizing.columnHeaderHeight);
    attributes.zIndex = 500;
    cellCornerAttributes[indexPath] = attributes;
  }
  
  self.decorationAttributes = @{KEZCollectionViewTableLayoutDecorationViewCornerCell: cellCornerAttributes};
}

#pragma mark Sizing Helpers
- (KEZTableSizing *) createTableSizing {
  KEZTableSizing *sizing = [[KEZTableSizing alloc] init];
  
  NSUInteger sections = [self.collectionView numberOfSections];
  BOOL delegatesCellSizing = (self.collectionView.delegate && [self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:sizeForCellAtIndexPath:)]);
  BOOL delegatesHeaderSizing = (self.collectionView.delegate && [self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:supplementaryViewOfKind:sizeAtIndexPath:)]);
  
  if (!delegatesHeaderSizing) {
    sizing.rowHeaderWidth = self.rowHeaderWidth;
    sizing.columnHeaderHeight = self.columnHeaderHeight;
  }
  
  for (NSUInteger section = 0; section != sections; section++) {
    NSUInteger rows = [self.collectionView numberOfItemsInSection:section];
    
    if (delegatesHeaderSizing) {
      CGSize size = [((id<KEZCollectionViewDelegateTableLayout>)self.collectionView.delegate) collectionView:self.collectionView layout:self supplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewRowHeader sizeAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
      CGFloat width = MIN(MAX(size.width, self.minimumCellSize.width), self.maximumCellSize.width);
      CGFloat height = MIN(MAX(size.height, self.minimumCellSize.height), self.maximumCellSize.height);
      
      if (sizing.rowHeaderWidth < width)
        sizing.rowHeaderWidth = width;
      
      [sizing setHeight:height forRow:section];
    }
    
    for (NSUInteger row = 0; row != rows; row++) {
      
      if (delegatesHeaderSizing) {
        CGSize size = [((id<KEZCollectionViewDelegateTableLayout>)self.collectionView.delegate) collectionView:self.collectionView layout:self supplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader sizeAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        CGFloat width = MIN(MAX(size.width, self.minimumCellSize.width), self.maximumCellSize.width);
        CGFloat height = MIN(MAX(size.height, self.minimumCellSize.height), self.maximumCellSize.height);
        
        if (sizing.columnHeaderHeight < height)
          sizing.columnHeaderHeight = height;
        
        if ([sizing widthForColumn:row] < width)
          [sizing setWidth:width forColumn:row];
      }
      
      CGFloat width;
      CGFloat height;
      
      if (delegatesCellSizing) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        CGSize delegatedSize = [((id<KEZCollectionViewDelegateTableLayout>)self.collectionView.delegate) collectionView:self.collectionView layout:self sizeForCellAtIndexPath:indexPath];
        width = MIN(MAX(delegatedSize.width, self.minimumCellSize.width), self.maximumCellSize.width);
        height = MIN(MAX(delegatedSize.height, self.minimumCellSize.height), self.maximumCellSize.height);
      } else {
        width = self.cellSize.width;
        height = self.cellSize.height;
      }
      
      if ([sizing heightForRow:section] < height)
        [sizing setHeight:height forRow:section];
      
      if ([sizing widthForColumn:row] < width)
        [sizing setWidth:width forColumn:row];
    }
  }
  
  return sizing;
}

- (BOOL) hasHeaderSizing {
  return [self hasColumnHeaderSizing] || [self hasRowHeaderSizing];
}

- (BOOL) hasColumnHeaderSizing {
  return [self.supplementaryAttributes[KEZCollectionViewTableLayoutSupplementaryViewColumnHeader] count] > 0;
}

- (BOOL) hasRowHeaderSizing {
  return [self.supplementaryAttributes[KEZCollectionViewTableLayoutSupplementaryViewRowHeader] count] > 0;
}

- (void) clearLayoutAttributes {
  self.cellAttributes = nil;
  self.supplementaryAttributes = nil;
  self.decorationAttributes = nil;
}
@end
