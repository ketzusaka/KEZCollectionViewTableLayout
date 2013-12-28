//
//  KEZCollectionViewTableLayout.h
//  SampleTableLayout
//
//  Created by James Richard on 12/9/13.
//  Copyright (c) 2013 James Richard. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const KEZCollectionViewTableLayoutSupplementaryViewColumnHeader;
extern NSString * const KEZCollectionViewTableLayoutSupplementaryViewRowHeader;
extern NSString * const KEZCollectionViewTableLayoutDecorationViewCornerCell;

@interface KEZCollectionViewTableLayout : UICollectionViewLayout
@property (nonatomic) CGSize cellSize;
@property (nonatomic) CGFloat columnHeaderHeight;
@property (nonatomic) CGFloat rowHeaderWidth;
@property (nonatomic) CGSize minimumCellSize;
@property (nonatomic) CGSize maximumCellSize;
@property (nonatomic) BOOL stickyHeaders;
@end

@protocol KEZCollectionViewDelegateTableLayout <UICollectionViewDelegate>
@optional
/** Asks the delegate for the size of a cell.

 If you do not implement this method, the table layout uses the values in its cellSize property to set the cell's size instead.

 The value returned by this method will be checked against the layout's minimumCellSize property and maximumCellSize property. If the cell does not fit within those
 sizes it will be changed to adhere to them.
 
 @param collectionView The collection view object displaying the table layout.
 @param layout The layout object requesting the information
 @param indexPath The index path for the cell that needs to be sized.
 @return The size for the cell. This value may not be the actual size of the cell as a cells width is the maximum width of all cells within its column, 
 and the maximum height of all cells within its row.
 */
- (CGSize) collectionView:(UICollectionView *)collectionView layout:(KEZCollectionViewTableLayout *)layout sizeForCellAtIndexPath:(NSIndexPath *)indexPath;

/** Asks the delegate for the size of a supplementary view. This is used to get the sizing of row and column header cells.

 If you do not implement this method, the table layout uses the value in its columnHeaderHeight property for the column header cells height, and the
 rowHeaderWidth property for the row header cells width. 

 The value returned by this method will be checked against the layout's minimumCellSize property and maximumCellSize property. If the cell does not fit within those
 sizes it will be changed to adhere to them.

 When asking for the size of a rows header width the index path's section value represents the row index; the index path's row value can be ignored. 
 When asking for the size of a columns header height the index path's row value represents the column index; the index path's section value can be ignored.
 
 @param collectionView The collection view object displaying the table layout.
 @param layout The layout object requesting the information
 @param kind The type of header cell we are inquiring about. Either KEZCollectionViewTableLayoutSupplementaryViewColumnHeader or KEZCollectionViewTableLayoutSupplementaryViewRowHeader.
 @param indexPath The index path for the header cell that needs to be sized.
 @return The size for the header cell. This value may not be the actual size of the cell as a cells width is the maximum width of all cells within its column, 
 and the maximum height of all cells within its row.
 */
- (CGSize) collectionView:(UICollectionView *)collectionView layout:(KEZCollectionViewTableLayout *)layout supplementaryViewOfKind:(NSString *)kind sizeAtIndexPath:(NSIndexPath *)indexPath;
@end
