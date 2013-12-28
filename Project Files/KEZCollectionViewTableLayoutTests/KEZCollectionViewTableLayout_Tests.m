//
//  KEZCollectionViewTableLayoutTests.m
//  KEZCollectionViewTableLayoutTests
//
//  Created by James Richard on 12/9/13.
//  Copyright (c) 2013 James Richard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>
#import "KEZCollectionViewTableLayout.h"
#import "KEZTableLayoutCellAndHeaderDelegate.h"

#define KEZValuedSizeMake(width, height) [NSValue valueWithCGSize:CGSizeMake(width, height)]
#define KEZSizeIgnored CGSizeMake(CGFLOAT_MAX, CGFLOAT_MIN)

static NSString * const kKEZHeaderColumnSizes = @"kKEZHeaderColumnSizes";
static NSString * const kKEZHeaderRowSizes = @"kKEZHeaderRowSizes";

@interface KEZCollectionViewTableLayout_Tests : XCTestCase
@property (nonatomic, strong) KEZCollectionViewTableLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) id delegate;
@end

@implementation KEZCollectionViewTableLayout_Tests
#pragma mark - Initialization
#pragma mark Default Cell Size
- (void) testInit_setsDefaultCellSizeTo100x100 {
  [self setupWithoutDelegate];
  assertThat([NSValue valueWithCGSize:self.layout.cellSize], equalTo(KEZValuedSizeMake(100, 100)));
}

- (void) testInit_setsMinimumCellSizeToZero {
  [self setupWithoutDelegate];
  assertThat([NSValue valueWithCGSize:self.layout.minimumCellSize], equalTo([NSValue valueWithCGSize:CGSizeZero]));
}

- (void) testInit_setsMaximumCellSizeToMax {
  [self setupWithoutDelegate];
  CGSize maxSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
  assertThat([NSValue valueWithCGSize:self.layout.maximumCellSize], equalTo([NSValue valueWithCGSize:maxSize]));
}

- (void) testInitWithCoder_setsDefaultCellSizeTo100x100 {
  [self setupWithoutDelegateWithCoder:nil];
  assertThat([NSValue valueWithCGSize:self.layout.cellSize], equalTo(KEZValuedSizeMake(100, 100)));
}

- (void) testInitWithCoder_setsMinimumCellSizeToZero {
  [self setupWithoutDelegateWithCoder:nil];
  assertThat([NSValue valueWithCGSize:self.layout.minimumCellSize], equalTo([NSValue valueWithCGSize:CGSizeZero]));
}

- (void) testInitWithCoder_setsMinimumCellSizeToMax {
  [self setupWithoutDelegateWithCoder:nil];
  CGSize maxSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
  assertThat([NSValue valueWithCGSize:self.layout.maximumCellSize], equalTo([NSValue valueWithCGSize:maxSize]));
}

#pragma mark - Collection View Content Size
#pragma mark Using properties
- (void) testCollectionViewContentSize_withOneRow_adheresToSizing {
  [self configureLayoutWithCellSize:CGSizeMake(100.0f, 100.0f) withRows:@[@20]];
  CGSize contentSize = self.layout.collectionViewContentSize;
  assertThat([NSValue valueWithCGSize:contentSize], equalTo(KEZValuedSizeMake(2000, 100)));
}

- (void) testCollectionViewContentSize_withManyRows_adheresToSizing {
  [self configureLayoutWithCellSize:CGSizeMake(100.0f, 100.0f) withRows:@[@20, @50, @30]];
  CGSize contentSize = self.layout.collectionViewContentSize;
  assertThat([NSValue valueWithCGSize:contentSize], equalTo(KEZValuedSizeMake(5000, 300)));
}

- (void) testCollectionViewContentSize_withHeaders_withSingleRow_adheresToSizing {
  [self configureLayoutWithCellSize:CGSizeMake(100.0f, 100.0f) withRows:@[@20] columnHeaderHeight:150.0f rowHeaderWidth:50.0f];
  CGSize contentSize = self.layout.collectionViewContentSize;
  assertThat([NSValue valueWithCGSize:contentSize], equalTo(KEZValuedSizeMake(2050, 250)));
}

- (void) testCollectionViewContentSize_withHeaders_withMultipleRows_adheresToSizing {
  [self configureLayoutWithCellSize:CGSizeMake(100.0f, 100.0f) withRows:@[@20, @50, @30] columnHeaderHeight:150.0f rowHeaderWidth:50.0f];
  CGSize contentSize = self.layout.collectionViewContentSize;
  assertThat([NSValue valueWithCGSize:contentSize], equalTo(KEZValuedSizeMake(5050, 450)));
}

- (void) testCollectionViewContentSize_isNotLimitedByMinimumSize {
  [self configureLayoutWithCellSize:CGSizeMake(100.0f, 100.0f)
                           withRows:@[@10, @20]
                    minimumCellSize:CGSizeMake(200.0f, 150.0f)
                    maximumCellSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
  CGSize contentSize = self.layout.collectionViewContentSize;
  assertThat([NSValue valueWithCGSize:contentSize], equalTo(KEZValuedSizeMake(2000, 200)));
}

- (void) testCollectionViewContentSize_isNotLimitedByMaximumSize {
  [self configureLayoutWithCellSize:CGSizeMake(300.0f, 300.0f)
                           withRows:@[@10, @20]
                    minimumCellSize:CGSizeZero
                    maximumCellSize:CGSizeMake(200.0f, 150.0f)];
  CGSize contentSize = self.layout.collectionViewContentSize;
  assertThat([NSValue valueWithCGSize:contentSize], equalTo(KEZValuedSizeMake(6000, 600)));
}

- (void) testCollectionViewContentSize_whenLayoutInvalidatedManually_andSizeChanged_isRecalculated {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 100.0f) withRows:@[@4, @5, @2]];
  CGSize initialContentSize = self.layout.collectionViewContentSize;
  [self doLayoutInvalidationWithRelayoutUsingCellSize:CGSizeMake(100.0f, 100.0f)];
  assertThat([NSValue valueWithCGSize:self.layout.collectionViewContentSize], isNot(equalTo([NSValue valueWithCGSize:initialContentSize])));
}

- (void) testCollectionViewContentSize_whenLayoutInvalidatedDueToBoundsChange_andSizeChanged_doesNotChange {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 100.0f) withRows:@[@4, @5, @2]];
  CGSize initialContentSize = self.layout.collectionViewContentSize;
  [self doLayoutInvalidationForBoundsChangeWithRelayoutUsingCellSize:CGSizeMake(100.0f, 100.0f)];
  assertThat([NSValue valueWithCGSize:self.layout.collectionViewContentSize], equalTo([NSValue valueWithCGSize:initialContentSize]));
}

#pragma mark Using the delegate
- (void) testCollectionViewContentSize_withDelegate_adheresToSizing {
  [self configureDelegatedLayoutWithCellSizes:@[
                                                @[KEZValuedSizeMake(200.0f, 100.0f), KEZValuedSizeMake(100.0f, 100.0f)],
                                                @[KEZValuedSizeMake(300.0f, 100.0f), KEZValuedSizeMake(500.0f, 200.0f), KEZValuedSizeMake(100.0f, 150.0f)],
                                                @[KEZValuedSizeMake(170.0f, 50.0f)]
                                                ]];
  CGSize contentSize = self.layout.collectionViewContentSize;
  assertThat([NSValue valueWithCGSize:contentSize], equalTo(KEZValuedSizeMake(900.0f, 350.0f)));
}

- (void) testCollectionViewContentSize_withDelegate_isLimitedByMinimumSize {
  [self configureDelegatedLayoutWithCellSizes:@[
                                                @[KEZValuedSizeMake(200.0f, 100.0f), KEZValuedSizeMake(100.0f, 100.0f)],
                                                @[KEZValuedSizeMake(300.0f, 100.0f), KEZValuedSizeMake(500.0f, 200.0f), KEZValuedSizeMake(100.0f, 150.0f)],
                                                @[KEZValuedSizeMake(170.0f, 50.0f)]
                                                ]
                                  minCellSize:CGSizeMake(200.0f, 200.0f)
                                  maxCellSize:KEZSizeIgnored];
  CGSize contentSize = self.layout.collectionViewContentSize;
  assertThat([NSValue valueWithCGSize:contentSize], equalTo(KEZValuedSizeMake(1000.0f, 600.0f)));
}

- (void) testCollectionViewContentSize_withDelegate_isLimitedByMaximumSize {
  [self configureDelegatedLayoutWithCellSizes:@[
                                                @[KEZValuedSizeMake(200.0f, 100.0f), KEZValuedSizeMake(100.0f, 100.0f)],
                                                @[KEZValuedSizeMake(300.0f, 100.0f), KEZValuedSizeMake(500.0f, 200.0f), KEZValuedSizeMake(100.0f, 150.0f)],
                                                @[KEZValuedSizeMake(170.0f, 50.0f)]
                                                ]
                                  minCellSize:KEZSizeIgnored
                                  maxCellSize:CGSizeMake(200.0f, 100.0f)];
  CGSize contentSize = self.layout.collectionViewContentSize;
  assertThat([NSValue valueWithCGSize:contentSize], equalTo(KEZValuedSizeMake(500.0f, 250.0f)));
}

#pragma mark - Layout Attributes for Item At Index Path
- (void) testLayoutAttributesForItemAtIndexPath_withoutDelegate_withoutHeaders_adheresToSizing {
  [self configureLayoutWithCellSize:CGSizeMake(300.0f, 300.0f) withRows:@[@2, @3]];

  UICollectionViewLayoutAttributes *expected;
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withFrame:CGRectMake(0, 0, 300, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] withFrame:CGRectMake(300, 0, 300, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] withFrame:CGRectMake(0, 300, 300, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] withFrame:CGRectMake(300, 300, 300, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:2 inSection:1] withFrame:CGRectMake(600, 300, 300, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]], equalTo(expected));
}

- (void) testLayoutAttributesForItemAtIndexPath_withoutDelegate_withHeaders_adheresToSizing {
  [self configureLayoutWithCellSize:CGSizeMake(300.0f, 300.0f) withRows:@[@2, @3] columnHeaderHeight:150.0f rowHeaderWidth:125.0f];
  
  UICollectionViewLayoutAttributes *expected;
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withFrame:CGRectMake(125, 150, 300, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] withFrame:CGRectMake(425, 150, 300, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] withFrame:CGRectMake(125, 450, 300, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] withFrame:CGRectMake(425, 450, 300, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:2 inSection:1] withFrame:CGRectMake(725, 450, 300, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]], equalTo(expected));
}

- (void) testLayoutAttributesForItemAtIndexPath_withDelegate_adheresToSizing {
  [self configureDelegatedLayoutWithCellSizes:@[
                                                @[KEZValuedSizeMake(50, 100),KEZValuedSizeMake(150, 80)],
                                                @[KEZValuedSizeMake(500, 100),KEZValuedSizeMake(20, 200),KEZValuedSizeMake(50, 50)]
                                                ]];
  
  UICollectionViewLayoutAttributes *expected;
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withFrame:CGRectMake(0, 0, 500, 100)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] withFrame:CGRectMake(500, 0, 150, 100)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] withFrame:CGRectMake(0, 100, 500, 200)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] withFrame:CGRectMake(500, 100, 150, 200)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:2 inSection:1] withFrame:CGRectMake(650, 100, 50, 200)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]], equalTo(expected));
}

- (void) testLayoutAttributesForItemAtIndexPath_withDelegate_withHeaders_adheresToSizing {
  [self configureDelegatedLayoutWithCellSizes:@[
                                                @[KEZValuedSizeMake(50, 100), KEZValuedSizeMake(150, 80)],
                                                @[KEZValuedSizeMake(500, 100), KEZValuedSizeMake(20, 200), KEZValuedSizeMake(50, 50)]
                                                ]
                                  headerSizes:@{
                                                kKEZHeaderColumnSizes: @[KEZValuedSizeMake(100, 200), KEZValuedSizeMake(100, 250), KEZValuedSizeMake(100, 100)],
                                                kKEZHeaderRowSizes: @[KEZValuedSizeMake(150, 100), KEZValuedSizeMake(50, 300)]
                                                }];
  
  UICollectionViewLayoutAttributes *expected;
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withFrame:CGRectMake(150, 250, 500, 100)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] withFrame:CGRectMake(650, 250, 150, 100)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] withFrame:CGRectMake(150, 350, 500, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] withFrame:CGRectMake(650, 350, 150, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:2 inSection:1] withFrame:CGRectMake(800, 350, 100, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]], equalTo(expected));
}

- (void) testLayoutAttributesForItemAtIndexPath_withDelegate_withHeaders_withCellSizeRestrictions_isLimitedByMinimumCellSize {
  [self configureDelegatedLayoutWithCellSizes:@[
                                                @[KEZValuedSizeMake(50, 100), KEZValuedSizeMake(150, 80)],
                                                @[KEZValuedSizeMake(500, 100), KEZValuedSizeMake(20, 200), KEZValuedSizeMake(50, 50)]
                                                ]
                                  headerSizes:@{
                                                kKEZHeaderColumnSizes: @[KEZValuedSizeMake(100, 200), KEZValuedSizeMake(100, 250), KEZValuedSizeMake(100, 100)],
                                                kKEZHeaderRowSizes: @[KEZValuedSizeMake(150, 100), KEZValuedSizeMake(50, 300)]
                                                }
                                  minCellSize:CGSizeMake(200, 150)
                                  maxCellSize:KEZSizeIgnored];
  
  UICollectionViewLayoutAttributes *expected;
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withFrame:CGRectMake(200, 250, 500, 150)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] withFrame:CGRectMake(700, 250, 200, 150)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] withFrame:CGRectMake(200, 400, 500, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] withFrame:CGRectMake(700, 400, 200, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:2 inSection:1] withFrame:CGRectMake(900, 400, 200, 300)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]], equalTo(expected));
}

- (void) testLayoutAttributesForItemAtIndexPath_withDelegate_withHeaders_withCellSizeRestrictions_isLimitedByMaximumCellSize {
  [self configureDelegatedLayoutWithCellSizes:@[
                                                @[KEZValuedSizeMake(50, 100), KEZValuedSizeMake(150, 80)],
                                                @[KEZValuedSizeMake(500, 100), KEZValuedSizeMake(20, 200), KEZValuedSizeMake(50, 50)]
                                                ]
                                  headerSizes:@{
                                                kKEZHeaderColumnSizes: @[KEZValuedSizeMake(100, 200), KEZValuedSizeMake(100, 250), KEZValuedSizeMake(100, 100)],
                                                kKEZHeaderRowSizes: @[KEZValuedSizeMake(150, 100), KEZValuedSizeMake(50, 300)]
                                                }
                                  minCellSize:KEZSizeIgnored
                                  maxCellSize:CGSizeMake(200, 150)];
  
  UICollectionViewLayoutAttributes *expected;
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withFrame:CGRectMake(150, 150, 200, 100)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] withFrame:CGRectMake(350, 150, 150, 100)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] withFrame:CGRectMake(150, 250, 200, 150)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] withFrame:CGRectMake(350, 250, 150, 150)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:2 inSection:1] withFrame:CGRectMake(500, 250, 100, 150)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]], equalTo(expected));
}

- (void) testLayoutAttributesForItemAtIndexPath_withDelegate_isLimitedByMinimumSize {
  [self configureDelegatedLayoutWithCellSizes:@[
                                                @[KEZValuedSizeMake(50, 100), KEZValuedSizeMake(150, 80)],
                                                @[KEZValuedSizeMake(500, 100), KEZValuedSizeMake(20, 200), KEZValuedSizeMake(50, 50)]
                                                ]
                                  minCellSize:CGSizeMake(200, 150)
                                  maxCellSize:KEZSizeIgnored];
  
  UICollectionViewLayoutAttributes *expected;
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withFrame:CGRectMake(0, 0, 500, 150)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] withFrame:CGRectMake(500, 0, 200, 150)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] withFrame:CGRectMake(0, 150, 500, 200)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] withFrame:CGRectMake(500, 150, 200, 200)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:2 inSection:1] withFrame:CGRectMake(700, 150, 200, 200)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]], equalTo(expected));
}

- (void) testLayoutAttributesForItemAtIndexPath_withDelegate_isLimitedByMaximumSize {
  [self configureDelegatedLayoutWithCellSizes:@[
                                                @[KEZValuedSizeMake(50, 100), KEZValuedSizeMake(150, 80)],
                                                @[KEZValuedSizeMake(500, 100), KEZValuedSizeMake(20, 200), KEZValuedSizeMake(50, 50)]
                                                ]
                                  minCellSize:KEZSizeIgnored
                                  maxCellSize:CGSizeMake(150, 100)];
  
  UICollectionViewLayoutAttributes *expected;
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withFrame:CGRectMake(0, 0, 150, 100)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] withFrame:CGRectMake(150, 0, 150, 100)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] withFrame:CGRectMake(0, 100, 150, 100)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] withFrame:CGRectMake(150, 100, 150, 100)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]], equalTo(expected));
  expected = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:2 inSection:1] withFrame:CGRectMake(300, 100, 50, 100)];
  assertThat([self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]], equalTo(expected));
}

#pragma mark - Layout Attributes for Supplementary Views
#pragma mark Without Sticky Headers
- (void) testLayoutAttributesForSupplementaryViewOfKindColumnHeader_withoutDelegate_adheresToSizing {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@3] columnHeaderHeight:100.0f rowHeaderWidth:0];
  
  UICollectionViewLayoutAttributes *expected;
  expected = [self columnHeaderLayoutAttributesWithColumn:0 withFrame:CGRectMake(0, 0, 200, 100)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self columnHeaderLayoutAttributesWithColumn:1 withFrame:CGRectMake(200, 0, 200, 100)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]], equalTo(expected));
  expected = [self columnHeaderLayoutAttributesWithColumn:2 withFrame:CGRectMake(400, 0, 200, 100)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]], equalTo(expected));
}

- (void) testLayoutAttributesForSupplementaryViewOfKindRowHeader_withoutDelegate_adheresToSizing {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@1, @1, @1] columnHeaderHeight:0 rowHeaderWidth:100.0f];
  
  UICollectionViewLayoutAttributes *expected;
  expected = [self rowHeaderLayoutAttributesWithRow:0 withFrame:CGRectMake(0, 0, 100, 200)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewRowHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self rowHeaderLayoutAttributesWithRow:1 withFrame:CGRectMake(0, 200, 100, 200)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewRowHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], equalTo(expected));
  expected = [self rowHeaderLayoutAttributesWithRow:2 withFrame:CGRectMake(0, 400, 100, 200)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewRowHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]], equalTo(expected));
}

- (void) testLayoutAttributesForSupplementaryViewOfKindColumnHeader_withDelegate_adheresToSizing {
  [self configureDelegatedLayoutWithCellSizes:@[
                                                @[KEZValuedSizeMake(50, 100), KEZValuedSizeMake(150, 80)],
                                                @[KEZValuedSizeMake(500, 100), KEZValuedSizeMake(20, 200), KEZValuedSizeMake(50, 50)]
                                                ]
                                  headerSizes:@{
                                                kKEZHeaderColumnSizes: @[KEZValuedSizeMake(100, 200), KEZValuedSizeMake(100, 250), KEZValuedSizeMake(100, 100)],
                                                kKEZHeaderRowSizes: @[KEZValuedSizeMake(150, 100), KEZValuedSizeMake(50, 300)]
                                                }];
  
  UICollectionViewLayoutAttributes *expected;
  expected = [self columnHeaderLayoutAttributesWithColumn:0 withFrame:CGRectMake(150, 0, 500, 250)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self columnHeaderLayoutAttributesWithColumn:1 withFrame:CGRectMake(650, 0, 150, 250)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]], equalTo(expected));
  expected = [self columnHeaderLayoutAttributesWithColumn:2 withFrame:CGRectMake(800, 0, 100, 250)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]], equalTo(expected));
}

- (void) testLayoutAttributesForSupplementaryViewOfKindRowHeader_withDelegate_adheresToSizing {
  [self configureDelegatedLayoutWithCellSizes:@[
                                                @[KEZValuedSizeMake(50, 100), KEZValuedSizeMake(150, 80)],
                                                @[KEZValuedSizeMake(500, 100), KEZValuedSizeMake(20, 200), KEZValuedSizeMake(50, 50)]
                                                ]
                                  headerSizes:@{
                                                kKEZHeaderColumnSizes: @[KEZValuedSizeMake(100, 200), KEZValuedSizeMake(100, 250), KEZValuedSizeMake(100, 100)],
                                                kKEZHeaderRowSizes: @[KEZValuedSizeMake(150, 100), KEZValuedSizeMake(50, 300)]
                                                }];
  
  UICollectionViewLayoutAttributes *expected;
  expected = [self rowHeaderLayoutAttributesWithRow:0 withFrame:CGRectMake(0, 250, 150, 100)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewRowHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self rowHeaderLayoutAttributesWithRow:1 withFrame:CGRectMake(0, 350, 150, 300)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewRowHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], equalTo(expected));
}

#pragma mark With Sticky Headers

- (void) testLayoutAttributesForSupplementaryViewOfKindColumnHeader_withStickyHeaders_withoutDelegate_whenMovedSticksToBounds {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@3] columnHeaderHeight:100.0f rowHeaderWidth:0 stickyHeaders:YES];
  [self moveCollectionViewToOffset:CGPointMake(0, 100)];
  UICollectionViewLayoutAttributes *expected;
  expected = [self columnHeaderLayoutAttributesWithColumn:0 withFrame:CGRectMake(0, 100, 200, 100)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self columnHeaderLayoutAttributesWithColumn:1 withFrame:CGRectMake(200, 100, 200, 100)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]], equalTo(expected));
  expected = [self columnHeaderLayoutAttributesWithColumn:2 withFrame:CGRectMake(400, 100, 200, 100)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]], equalTo(expected));
}

- (void) testLayoutAttributesForSupplementaryViewOfKindColumnHeader_withStickyHeaders_withInsets_withoutDelegate_isBoundsPlusInsets {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@3] columnHeaderHeight:100.0f rowHeaderWidth:0 stickyHeaders:YES contentInsets:UIEdgeInsetsMake(64, 0, 0, 0)];

  UICollectionViewLayoutAttributes *expected;
  expected = [self columnHeaderLayoutAttributesWithColumn:0 withFrame:CGRectMake(0, 0, 200, 100)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self columnHeaderLayoutAttributesWithColumn:1 withFrame:CGRectMake(200, 0, 200, 100)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]], equalTo(expected));
  expected = [self columnHeaderLayoutAttributesWithColumn:2 withFrame:CGRectMake(400, 0, 200, 100)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]], equalTo(expected));
}

- (void) testLayoutAttributesForSupplementaryViewOfKindRowHeader_withStickyHeaders_withoutDelegate_whenMovedSticksToBounds {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@3, @1, @2] columnHeaderHeight:0.0f rowHeaderWidth:100.0f stickyHeaders:YES];
  [self moveCollectionViewToOffset:CGPointMake(100, 0)];
  UICollectionViewLayoutAttributes *expected;
  expected = [self rowHeaderLayoutAttributesWithRow:0 withFrame:CGRectMake(100, 0, 100, 200)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewRowHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self rowHeaderLayoutAttributesWithRow:1 withFrame:CGRectMake(100, 200, 100, 200)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewRowHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], equalTo(expected));
  expected = [self rowHeaderLayoutAttributesWithRow:2 withFrame:CGRectMake(100, 400, 100, 200)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewRowHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]], equalTo(expected));
}

- (void) testLayoutAttributesForSupplementaryViewOfKindRowHeader_withStickyHeaders_withInsets_withoutDelegate_isBoundsPlusInsets {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@3, @1, @2] columnHeaderHeight:0.0f rowHeaderWidth:100.0f stickyHeaders:YES contentInsets:UIEdgeInsetsMake(0, 44, 0, 0)];
  UICollectionViewLayoutAttributes *expected;
  expected = [self rowHeaderLayoutAttributesWithRow:0 withFrame:CGRectMake(0, 0, 100, 200)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewRowHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
  expected = [self rowHeaderLayoutAttributesWithRow:1 withFrame:CGRectMake(0, 200, 100, 200)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewRowHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], equalTo(expected));
  expected = [self rowHeaderLayoutAttributesWithRow:2 withFrame:CGRectMake(0, 400, 100, 200)];
  assertThat([self.layout layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewRowHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]], equalTo(expected));
}

#pragma mark - Layout Attributes for Decoration Views
- (void) testLayoutAttributesForDecorationViewOfKindCornerCell_withoutHeaders_isNil {
  [self configureLayoutWithCellSize:CGSizeMake(50.0f, 50.0f) withRows:@[@2, @5]];
  assertThat([self.layout layoutAttributesForDecorationViewOfKind:KEZCollectionViewTableLayoutDecorationViewCornerCell atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], nilValue());
}

- (void) testLayoutAttributesForDecorationViewOfKindCornerCell_withRowHeaders_isNil {
  [self configureLayoutWithCellSize:CGSizeMake(50.0f, 50.0f) withRows:@[@2, @5] columnHeaderHeight:0 rowHeaderWidth:100.0f];
  assertThat([self.layout layoutAttributesForDecorationViewOfKind:KEZCollectionViewTableLayoutDecorationViewCornerCell atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], nilValue());
}

- (void) testLayoutAttributesForDecorationViewOfKindCornerCell_withColumnHeaders_isNil {
  [self configureLayoutWithCellSize:CGSizeMake(50.0f, 50.0f) withRows:@[@2, @5] columnHeaderHeight:100.0f rowHeaderWidth:0];
  assertThat([self.layout layoutAttributesForDecorationViewOfKind:KEZCollectionViewTableLayoutDecorationViewCornerCell atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], nilValue());
}

- (void) testLayoutAttributesForDecorationViewOfKindCornerCell_withBothHeaders_isExpectedSizing {
  [self configureLayoutWithCellSize:CGSizeMake(50.0f, 50.0f) withRows:@[@2, @5] columnHeaderHeight:100.0f rowHeaderWidth:100.0f stickyHeaders:NO contentInsets:UIEdgeInsetsZero cornerCell:YES];
  UICollectionViewLayoutAttributes *expected = [self cellCornerLayoutAttributesWithFrame:CGRectMake(0, 0, 100.0f, 100.0f)];
  assertThat([self.layout layoutAttributesForDecorationViewOfKind:KEZCollectionViewTableLayoutDecorationViewCornerCell atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
}

- (void) testLayoutAttributesForDecorationViewOfKindCornerCell_withBothHeaders_invalidIndexPath_isNil {
  [self configureLayoutWithCellSize:CGSizeMake(50.0f, 50.0f) withRows:@[@2, @5] columnHeaderHeight:100.0f rowHeaderWidth:100.0f];
  assertThat([self.layout layoutAttributesForDecorationViewOfKind:KEZCollectionViewTableLayoutDecorationViewCornerCell atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]], nilValue());
}

- (void) testLayoutAttributesForDecorationViewCellCorner_withStickyHeaders_whenMoved_sticksToBounds {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@3, @1, @2] columnHeaderHeight:100.0f rowHeaderWidth:100.0f stickyHeaders:YES contentInsets:UIEdgeInsetsZero cornerCell:YES];
  [self moveCollectionViewToOffset:CGPointMake(100, 50)];
  UICollectionViewLayoutAttributes *expected = [self cellCornerLayoutAttributesWithFrame:CGRectMake(100, 50, 100, 100)];
  assertThat([self.layout layoutAttributesForDecorationViewOfKind:KEZCollectionViewTableLayoutDecorationViewCornerCell atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
}

- (void) testLayoutAttributesForDecorationViewCellCorner_withoutStickyHeaders_whenMoved_remainsInPosition {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@3, @1, @2] columnHeaderHeight:100.0f rowHeaderWidth:100.0f stickyHeaders:NO contentInsets:UIEdgeInsetsZero cornerCell:YES];
  [self moveCollectionViewToOffset:CGPointMake(100, 50)];
  UICollectionViewLayoutAttributes *expected = [self cellCornerLayoutAttributesWithFrame:CGRectMake(0, 0, 100, 100)];
  assertThat([self.layout layoutAttributesForDecorationViewOfKind:KEZCollectionViewTableLayoutDecorationViewCornerCell atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
}

- (void) testLayoutAttributesForDecorationViewCellCorner_withStickyHeaders_withInsets_whenMoved_sticksToBoundsAndInset {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@3, @1, @2] columnHeaderHeight:100.0f rowHeaderWidth:100.0f stickyHeaders:YES contentInsets:UIEdgeInsetsMake(50, 150, 0, 0) cornerCell:YES];
  [self moveCollectionViewToOffset:CGPointMake(100, 50)];
  UICollectionViewLayoutAttributes *expected = [self cellCornerLayoutAttributesWithFrame:CGRectMake(250, 100, 100, 100)];
  assertThat([self.layout layoutAttributesForDecorationViewOfKind:KEZCollectionViewTableLayoutDecorationViewCornerCell atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], equalTo(expected));
}


#pragma mark - Layout Attributes for Elements In Rect
- (void) testLayoutAttributesForElementsInRect_withoutSupplementaryViews_includesProperAttributes {
  [self configureLayoutWithCellSize:CGSizeMake(200, 200) withRows:@[@2, @1, @5, @2]];
  
  UICollectionViewLayoutAttributes *expected0_0 = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withFrame:CGRectMake(0.0f, 0.0f, 200.0f, 200.0f)];
  UICollectionViewLayoutAttributes *expected0_1 = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] withFrame:CGRectMake(200.0f, 0.0f, 200.0f, 200.0f)];
  UICollectionViewLayoutAttributes *expected1_0 = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] withFrame:CGRectMake(0.0f, 200.0f, 200.0f, 200.0f)];
  UICollectionViewLayoutAttributes *expected2_0 = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] withFrame:CGRectMake(0.0f, 400.0f, 200.0f, 200.0f)];
  UICollectionViewLayoutAttributes *expected2_2 = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:2 inSection:2] withFrame:CGRectMake(400.0f, 400.0f, 200.0f, 200.0f)];
  UICollectionViewLayoutAttributes *expected2_3 = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:3 inSection:2] withFrame:CGRectMake(600.0f, 400.0f, 200.0f, 200.0f)];
  UICollectionViewLayoutAttributes *expected2_4 = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:4 inSection:2] withFrame:CGRectMake(800.0f, 400.0f, 200.0f, 200.0f)];
  
  assertThat([self.layout layoutAttributesForElementsInRect:CGRectMake(0, 0, 200, 500)], containsInAnyOrder(expected0_0, expected1_0, expected2_0, nil));
  assertThat([self.layout layoutAttributesForElementsInRect:CGRectMake(0, 0, 300, 100)], containsInAnyOrder(expected0_0, expected0_1, nil));
  assertThat([self.layout layoutAttributesForElementsInRect:CGRectMake(500, 0, 300, 400)], equalTo(@[]));
  assertThat([self.layout layoutAttributesForElementsInRect:CGRectMake(500, 200, 400, 400)], containsInAnyOrder(expected2_2, expected2_3, expected2_4, nil));
}

- (void) testLayoutAttributesForElementsInRect_withSupplementaryViews_includesProperAttributesPass1 {
  [self configureLayoutWithCellSize:CGSizeMake(200, 200) withRows:@[@2, @1, @4, @2] columnHeaderHeight:50.0f rowHeaderWidth:100.0f stickyHeaders:NO contentInsets:UIEdgeInsetsZero cornerCell:YES];
  
  UICollectionViewLayoutAttributes *expectedColumnHeader0 = [self columnHeaderLayoutAttributesWithColumn:0 withFrame:CGRectMake(100.0f, 0.0f, 200.0f, 50.0f)];
  UICollectionViewLayoutAttributes *expectedRowHeader0 = [self rowHeaderLayoutAttributesWithRow:0 withFrame:CGRectMake(0.0f, 50.0f, 100.0f, 200.0f)];
  UICollectionViewLayoutAttributes *expectedRowHeader1 = [self rowHeaderLayoutAttributesWithRow:1 withFrame:CGRectMake(0.0f, 250.0f, 100.0f, 200.0f)];
  UICollectionViewLayoutAttributes *expectedRowHeader2 = [self rowHeaderLayoutAttributesWithRow:2 withFrame:CGRectMake(0.0f, 450.0f, 100.0f, 200.0f)];
  UICollectionViewLayoutAttributes *expectedCellCorner = [self cellCornerLayoutAttributesWithFrame:CGRectMake(0, 0, 100.0f, 50.0f)];
  UICollectionViewLayoutAttributes *expectedCell0_0 = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withFrame:CGRectMake(100.0f, 50.0f, 200.0f, 200.0f)];
  UICollectionViewLayoutAttributes *expectedCell1_0 = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] withFrame:CGRectMake(100.0f, 250.0f, 200.0f, 200.0f)];
  UICollectionViewLayoutAttributes *expectedCell2_0 = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] withFrame:CGRectMake(100.0f, 450.0f, 200.0f, 200.0f)];
  assertThat([self.layout layoutAttributesForElementsInRect:CGRectMake(0, 0, 200, 500)], containsInAnyOrder(expectedRowHeader0,
                                                                                                            expectedRowHeader1,
                                                                                                            expectedRowHeader2,
                                                                                                            expectedCellCorner,
                                                                                                            expectedColumnHeader0,
                                                                                                            expectedCell0_0,
                                                                                                            expectedCell1_0,
                                                                                                            expectedCell2_0, nil));
}

- (void) testLayoutAttributesForElementsInRect_withSupplementaryViews_includesProperAttributesPass2 {
  [self configureLayoutWithCellSize:CGSizeMake(200, 200) withRows:@[@2, @1, @4, @2] columnHeaderHeight:50.0f rowHeaderWidth:100.0f];
  UICollectionViewLayoutAttributes *expectedCell2_1 = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:2] withFrame:CGRectMake(300.0f, 450.0f, 200.0f, 200.0f)];
  UICollectionViewLayoutAttributes *expectedCell3_1 = [self cellLayoutAttributesWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:3] withFrame:CGRectMake(300.0f, 650.0f, 200.0f, 200.0f)];
  assertThat([self.layout layoutAttributesForElementsInRect:CGRectMake(400, 400, 100, 400)], containsInAnyOrder(expectedCell2_1, expectedCell3_1, nil));
}

#pragma mark - Layout Invalidation
#pragma mark Without Sticky Headers
- (void) testShouldInvalidateForBoundsChange_withoutHeaders_doesntRequireInvalidation {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@2, @1, @50]];
  assertThatBool([self.layout shouldInvalidateLayoutForBoundsChange:CGRectMake(10, 10, 1000, 1000)], equalToBool(NO));
}

- (void) testShouldInvalidateForBoundsChange_withColumnHeaders_whenMovedVertically_doesntRequireInvalidation {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@2, @1, @50] columnHeaderHeight:100.0f rowHeaderWidth:0.0f];
  assertThatBool([self.layout shouldInvalidateLayoutForBoundsChange:CGRectMake(0, 100, 1000, 1000)], equalToBool(NO));
}
- (void) testShouldInvalidateForBoundsChange_withRowHeaders_whenMovedHorizontally_doesntRequireInvalidation {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@2, @1, @50] columnHeaderHeight:0.0f rowHeaderWidth:100.0f];
  assertThatBool([self.layout shouldInvalidateLayoutForBoundsChange:CGRectMake(1000, 0, 1000, 1000)], equalToBool(NO));
}

- (void) testShouldInvalidateForBoundsChange_withHeaders_whenMoved_doesntRequireInvalidation {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@2, @1, @50] columnHeaderHeight:100.0f rowHeaderWidth:1000.0f];
  assertThatBool([self.layout shouldInvalidateLayoutForBoundsChange:CGRectMake(100, 100, 1000, 1000)], equalToBool(NO));
}

#pragma mark With Sticky Headers
- (void) testShouldInvalidateForBoundsChange_withStickyHeaders_withRowHeaders_whenMovedHorizontally_requiresLayoutInvalidation {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@2, @1, @50] columnHeaderHeight:0 rowHeaderWidth:50.0f stickyHeaders:YES];
  assertThatBool([self.layout shouldInvalidateLayoutForBoundsChange:CGRectMake(100, 0, 1000, 1000)], equalToBool(YES));
}

- (void) testShouldInvalidateForBoundsChange_withStickyHeaders_withRowHeaders_whenMovedVertically_doesntRequireInvalidation {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@2, @1, @50] columnHeaderHeight:0 rowHeaderWidth:50.0f stickyHeaders:YES];
  assertThatBool([self.layout shouldInvalidateLayoutForBoundsChange:CGRectMake(0, 100, 1000, 1000)], equalToBool(NO));
}

- (void) testShouldInvalidateForBoundsChange_withStickyHeaders_withColumnHeaders_whenMovedVertically_requiresLayoutInvalidation {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@2, @1, @50] columnHeaderHeight:100.0f rowHeaderWidth:0.0f stickyHeaders:YES];
  assertThatBool([self.layout shouldInvalidateLayoutForBoundsChange:CGRectMake(0, 100, 1000, 1000)], equalToBool(YES));
}

- (void) testShouldInvalidateForBoundsChange_withStickyHeaders_withColumnHeaders_whenMovedHorizontally_doesntRequireInvalidation {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@2, @1, @50] columnHeaderHeight:100.0f rowHeaderWidth:0.0f stickyHeaders:YES];
  assertThatBool([self.layout shouldInvalidateLayoutForBoundsChange:CGRectMake(100, 0, 1000, 1000)], equalToBool(NO));
}

- (void) testShouldInvalidateForBoundsChange_withStickyHeaders_withHeaders_whenMoved_requiresLayoutInvalidation {
  [self configureLayoutWithCellSize:CGSizeMake(200.0f, 200.0f) withRows:@[@2, @1, @50] columnHeaderHeight:100.0f rowHeaderWidth:100.0f stickyHeaders:YES];
  assertThatBool([self.layout shouldInvalidateLayoutForBoundsChange:CGRectMake(100, 100, 1000, 1000)], equalToBool(YES));
}

#pragma mark - Test Configuration
- (void) configureLayoutWithCellSize:(CGSize)size withRows:(NSArray *)rows {
  [self configureLayoutWithCellSize:size withRows:rows columnHeaderHeight:0 rowHeaderWidth:0];
}

- (void) configureLayoutWithCellSize:(CGSize)size withRows:(NSArray *)rows columnHeaderHeight:(CGFloat)columnHeaderHeight rowHeaderWidth:(CGFloat)rowHeaderWidth {
  [self configureLayoutWithCellSize:size withRows:rows columnHeaderHeight:columnHeaderHeight rowHeaderWidth:rowHeaderWidth stickyHeaders:NO];
}

- (void) configureLayoutWithCellSize:(CGSize)size withRows:(NSArray *)rows columnHeaderHeight:(CGFloat)columnHeaderHeight rowHeaderWidth:(CGFloat)rowHeaderWidth stickyHeaders:(BOOL)stickyHeaders {
  [self configureLayoutWithCellSize:size withRows:rows columnHeaderHeight:columnHeaderHeight rowHeaderWidth:rowHeaderWidth stickyHeaders:stickyHeaders contentInsets:UIEdgeInsetsZero];
}

- (void) configureLayoutWithCellSize:(CGSize)size withRows:(NSArray *)rows columnHeaderHeight:(CGFloat)columnHeaderHeight rowHeaderWidth:(CGFloat)rowHeaderWidth stickyHeaders:(BOOL)stickyHeaders contentInsets:(UIEdgeInsets)contentInsets {
  [self configureLayoutWithCellSize:size withRows:rows columnHeaderHeight:columnHeaderHeight rowHeaderWidth:rowHeaderWidth stickyHeaders:stickyHeaders contentInsets:contentInsets cornerCell:NO];
}

- (void) configureLayoutWithCellSize:(CGSize)size withRows:(NSArray *)rows columnHeaderHeight:(CGFloat)columnHeaderHeight rowHeaderWidth:(CGFloat)rowHeaderWidth stickyHeaders:(BOOL)stickyHeaders contentInsets:(UIEdgeInsets)contentInsets cornerCell:(BOOL)cornerCell {
  [self setupWithoutDelegate];
  self.collectionView.contentInset = contentInsets;
  
  self.layout.stickyHeaders = stickyHeaders;
  self.layout.cellSize = size;
  
  if (columnHeaderHeight > 0)
    self.layout.columnHeaderHeight = columnHeaderHeight;
  
  if (rowHeaderWidth > 0)
    self.layout.rowHeaderWidth = rowHeaderWidth;
  
  if (cornerCell) {
    [self.layout registerClass:[OCMockObject niceMockForClass:[UICollectionReusableView class]] forDecorationViewOfKind:KEZCollectionViewTableLayoutDecorationViewCornerCell];
  }
  
  [self prepareLayoutWithDataSourceHavingRows:rows];
  
  [self.layout prepareLayout];
}

- (void) configureLayoutWithCellSize:(CGSize)size withRows:(NSArray *)rows minimumCellSize:(CGSize)minimumSize maximumCellSize:(CGSize)maximumCellSize {
  [self setupWithoutDelegate];
  self.layout.cellSize = size;
  
  self.layout.minimumCellSize = minimumSize;
  self.layout.maximumCellSize = maximumCellSize;
  
  [self prepareLayoutWithDataSourceHavingRows:rows];
  
  [self.layout prepareLayout];
}

- (void) configureDelegatedLayoutWithCellSizes:(NSArray *)sizes {
  [self configureDelegatedLayoutWithCellSizes:sizes minCellSize:KEZSizeIgnored maxCellSize:KEZSizeIgnored];
}

- (void) configureDelegatedLayoutWithCellSizes:(NSArray *)sizes headerSizes:(NSDictionary *)headerSizes {
  [self configureDelegatedLayoutWithCellSizes:sizes headerSizes:headerSizes minCellSize:KEZSizeIgnored maxCellSize:KEZSizeIgnored];
}

- (void) configureDelegatedLayoutWithCellSizes:(NSArray *)sizes minCellSize:(CGSize)minSize maxCellSize:(CGSize)maxSize {
  [self configureDelegatedLayoutWithCellSizes:sizes headerSizes:nil minCellSize:minSize maxCellSize:maxSize];
}

- (void) configureDelegatedLayoutWithCellSizes:(NSArray *)sizes headerSizes:(NSDictionary *)headerSizes minCellSize:(CGSize)minSize maxCellSize:(CGSize)maxSize {
  if ([headerSizes objectForKey:kKEZHeaderColumnSizes] == nil && [headerSizes objectForKey:kKEZHeaderRowSizes] == nil)
    [self setupWithCellDelegate];
  else
    [self setupEntirely];
  
  if (!CGSizeEqualToSize(minSize, KEZSizeIgnored))
    self.layout.minimumCellSize = minSize;
  
  if (!CGSizeEqualToSize(maxSize, KEZSizeIgnored))
    self.layout.maximumCellSize = maxSize;
  
  KEZTableLayoutCellAndHeaderDelegate *delegate = self.delegate;
  
  if (headerSizes) {
    NSArray *columnSizes = [headerSizes objectForKey:kKEZHeaderColumnSizes];
    [columnSizes enumerateObjectsUsingBlock:^(NSValue *size, NSUInteger idx, BOOL *stop) {
      [delegate setColumnHeaderSize:size forIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
    
    NSArray *rowSizes = [headerSizes objectForKey:kKEZHeaderRowSizes];
    [rowSizes enumerateObjectsUsingBlock:^(NSValue *size, NSUInteger idx, BOOL *stop) {
      [delegate setRowHeaderSize:size forIndexPath:[NSIndexPath indexPathForRow:0 inSection:idx]];
    }];
  }
  
  NSMutableArray *rows = [NSMutableArray array];
  [sizes enumerateObjectsUsingBlock:^(NSArray *section, NSUInteger i, BOOL *stop1) {
    [rows addObject:@(section.count)];
    [section enumerateObjectsUsingBlock:^(NSValue *size, NSUInteger j, BOOL *stop2) {
      [delegate setCellSize:size forIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
    }];
  }];
  
  [self prepareLayoutWithDataSourceHavingRows:[rows copy]];
  [self.layout prepareLayout];
}

#pragma mark Configuration helpers
- (void) prepareLayoutWithDataSourceHavingRows:(NSArray *)rows {
  id mockDataSource = [OCMockObject mockForProtocol:@protocol(UICollectionViewDataSource)];
  [[[mockDataSource stub] andReturnValue:@(rows.count)] numberOfSectionsInCollectionView:self.collectionView];
  [rows enumerateObjectsUsingBlock:^(NSNumber *rowCount, NSUInteger idx, BOOL *stop) {
    [[[mockDataSource stub] andReturnValue:rowCount] collectionView:self.collectionView numberOfItemsInSection:idx];
  }];
  self.collectionView.dataSource = mockDataSource;
}

#pragma mark - Setup helpers
- (void) setupWithoutDelegate {
  self.layout = [[KEZCollectionViewTableLayout alloc] init];
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 1000, 1000) collectionViewLayout:self.layout];
}

- (void) setupWithCellDelegate {
  self.layout = [[KEZCollectionViewTableLayout alloc] init];
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 1000, 1000) collectionViewLayout:self.layout];
  self.delegate = [[KEZTableLayoutCellDelegate alloc] init];
  self.collectionView.delegate = self.delegate;
}

- (void) setupEntirely {
  self.layout = [[KEZCollectionViewTableLayout alloc] init];
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 1000, 1000) collectionViewLayout:self.layout];
  self.delegate = [[KEZTableLayoutCellAndHeaderDelegate alloc] init];
  self.collectionView.delegate = self.delegate;
}

- (void) setupWithoutDelegateWithCoder:(NSCoder*)coder {
  self.layout = [[KEZCollectionViewTableLayout alloc] initWithCoder:coder];
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 1000, 1000) collectionViewLayout:self.layout];
}

- (void) setupEntirelyWithCoder:(NSCoder*)coder {
  self.layout = [[KEZCollectionViewTableLayout alloc] initWithCoder:coder];
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 1000, 1000) collectionViewLayout:self.layout];
  self.delegate = [OCMockObject niceMockForProtocol:@protocol(KEZCollectionViewDelegateTableLayout)];
  self.collectionView.delegate = self.delegate;
}

#pragma mark - Test Helpers
- (void) moveCollectionViewToOffset:(CGPoint)offset {
  [self moveCollectionViewToOffset:offset rejectsDelegation:NO];
}

- (void) moveCollectionViewToOffset:(CGPoint)offset rejectsDelegation:(BOOL)rejectsDelegation {
  if (rejectsDelegation) {
    [[self.delegate reject] collectionView:self.collectionView layout:self.layout sizeForCellAtIndexPath:[OCMArg any]];
    [[self.delegate reject] collectionView:self.collectionView layout:self.layout supplementaryViewOfKind:[OCMArg any] sizeAtIndexPath:[OCMArg any]];
  }
  
  [self.collectionView setContentOffset:offset];
  [self invalidateLayoutForBounds:CGRectMake(offset.x, offset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds))];
}

- (void) doLayoutInvalidationForBoundsChangeWithRelayoutUsingCellSize:(CGSize)size {
  self.layout.cellSize = size;
  [self invalidateLayoutForBounds:self.collectionView.bounds];
}

- (void) doLayoutInvalidationWithRelayoutUsingCellSize:(CGSize)size {
  self.layout.cellSize = size;
  [self.layout invalidateLayout];
  [self.layout prepareLayout];
}

- (void) invalidateLayoutForBounds:(CGRect)bounds {
  UICollectionViewLayoutInvalidationContext *context = [self.layout invalidationContextForBoundsChange:bounds];
  [self.layout invalidateLayoutWithContext:context];
  [self.layout prepareLayout];
}

#pragma mark - Creation Helpers
- (UICollectionViewLayoutAttributes *) cellLayoutAttributesWithIndexPath:(NSIndexPath *)indexPath withFrame:(CGRect)frame {
  UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
  attributes.frame = frame;
  return attributes;
}

- (UICollectionViewLayoutAttributes *) columnHeaderLayoutAttributesWithColumn:(NSUInteger)column withFrame:(CGRect)frame {
  UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewColumnHeader withIndexPath:[NSIndexPath indexPathForRow:column inSection:0]];
  attributes.frame = frame;
  attributes.zIndex = 200;
  return attributes;
}

- (UICollectionViewLayoutAttributes *) rowHeaderLayoutAttributesWithRow:(NSUInteger)row withFrame:(CGRect)frame {
  UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:KEZCollectionViewTableLayoutSupplementaryViewRowHeader withIndexPath:[NSIndexPath indexPathForRow:0 inSection:row]];
  attributes.frame = frame;
  attributes.zIndex = 100;
  return attributes;
}

- (UICollectionViewLayoutAttributes *) cellCornerLayoutAttributesWithFrame:(CGRect)frame {
  UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:KEZCollectionViewTableLayoutDecorationViewCornerCell withIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  attributes.frame = frame;
  attributes.zIndex = 500;
  return attributes;
}

@end