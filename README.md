# KZCollectionViewTableLayout

A UICollectionViewLayout subclass that places your cells into grid-like positions, similar to a spreadsheet. It supports cells as regular cells, row and column headers as supplementary views, and a corner view as a decoration view to fill up the top-left space when using both row and column headers.

Before using this layout, I strongly encourage you to really consider if this is the best tool for the job. More often then not, it's better not to present tabulated data in an iOS application. Lets keep things beautiful, and only use this layout when absolutely necessary.

## Using KZCollectionViewTableLayout

KZCollectionViewTableLayout is a direct subclass of UICollectionViewLayout. To use it, instantiate your collection view with a KZCollectionViewTableLayout instance in the layout parameter.

```objective-c
KZCollectionViewTableLayout *layout = [[KZCollectionViewTableLayout alloc] init];
UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
```

If You are using storyboards or nib files you can change the class of layout used on under attributes with your UICollectionView selected.

## Sizing Cells

You can set the size of all cells by setting the cellSize property on your KZCollectionViewTableLayout instance.

```objective-c
KZCollectionViewTableLayout *layout = [[KZCollectionViewTableLayout alloc] init];
layout.cellSize = CGSizeMake(200.0f, 44.0f);
```

Similar to UICollectionViewFlowLayout, KZCollectionViewTableLayout has a protocol that inherits from UICollectionViewDelegate. It adds one method to help determine the size of a cell.

```objective-c
- (CGSize) collectionView:(UICollectionView *)collectionView layout:(KZCollectionViewTableLayout *)layout sizeForCellAtIndexPath:(NSIndexPath *)indexPath;
```

If you implement this method on your delegate it will be used instead of the cellSize property.

Note that the indexPath terminology doesn't map quite as well as it does with a UITableView. Within an NSIndexPath, the section is the row represented in the layout, and the row is the column within that section.

### Restricting Cell Size

KZCollectionViewTableLayout has a couple properties to help reduce the complexity of your sizing code if you want minimum and maximum cell sizes. 

```objective-c
KZCollectionViewTableLayout *layout = [[KZCollectionViewTableLayout alloc] init];
// This will not allow any cell to have a width or height less than 44 points
layout.minimumCellSize = CGSizeMake(44.0f, 44.0f);
// This will not allow any cell to have a width or height larger than 200 points
layout.maximumCellSize = CGSizeMake(200.0f, 200.0f);
```

These limits are only consulted when doing delegated sizing. They are not consulted when you set the cellSize directly.

## Header Sizing

KZCollectionViewTableLayout has a couple of properties to set the width and height of header cells.

```objective-c
KZCollectionViewTableLayout *layout = [[KZCollectionViewTableLayout alloc] init];
// This will set the column headers to have a height of 100 points. The width will be determined by the widest cell.
layout.columnHeaderHeight = 100.0f;
// This will set the row headers to have a width of 100 points. The height of the row will be determined by the tallest cell
layout.rowHeaderWidth = 100.0f;
```

There is also a delegate method that allows you to size header cells.

```objective-c
- (CGSize) collectionView:(UICollectionView *)collectionView layout:(KZCollectionViewTableLayout *)layout supplementaryViewOfKind:(NSString *)kind sizeAtIndexPath:(NSIndexPath *)indexPath;
```

The value of kind could be either KZCollectionViewTableLayoutSupplementaryViewColumnHeader or KZCollectionViewTableLayoutSupplementaryViewRowHeader. 
KZCollectionViewTableLayoutSupplementaryViewColumnHeader will be passed in when calculating the height of column header cells (the headers width will be determined by the 
widest cell in the columns data), and KZCollectionViewTableLayoutSupplementaryViewRowHeader will be passed in when calculating the width of row header cells (The headers height will be determined
by the tallest cell in the rows data). 

The indexPath will represent where the header will go. Column headers will always have a section of 0, and row headers will always have a row of 0. This can be a little confusing, but the goal was to
map the headers similarly to the data. Each section of an index path represents one row of a data, and each row index is a column. See the sample project if this isn't making sense.

### Restricting Header Size

Header cells will use the same minimumCellSize and maximumCellSize properties to have their size limited. 

### Sticky Headers

If you need your headers to always be visible you can set the stickyHeaders property to YES. This will cause the header cells to move as the bounds of your collection view change.

### Corner Cell

If you have both row headers and column headers the first column will get shifted to the right of the row header, and the first row will get shifted below the column header leaving
a blank space on the top-left corner. You can give it a decoration view by registering a decoration view on the layout with the decorationViewKind set to KZCollectionViewTableLayoutDecorationViewCornerCell.

```objective-c
KZCollectionViewTableLayout *layout = [[KZCollectionViewTableLayout alloc] init];
[layout registerClass:[MyCornerCell class] forDecorationViewOfKind:KZCollectionViewTableLayoutDecorationViewCornerCell];
```

Note that decoration cells must have all their visual data setup in the initializer or nib that it is being loaded from. See the UICollectionViewLayout documentation for more information about decoration cells.

## Sample Application

The sample application includes a number of demonstrations using the KZCollectionViewTableLayout. Fire it up and give it a look around. Be sure to look at the User Defined
Runtime Attributes for the view controllers and layouts within the storyboard to get the whole story on the configuration done.

