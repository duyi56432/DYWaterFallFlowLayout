//
//  DYWaterFlowLayout.m
//  DYWaterFlowLayout
//
//  Created by duyi on 2021/8/31.
//

#import "DYWaterFallFlowLayout.h"

@implementation DYFlowLayoutModel

- (NSMutableArray *)rowFallArray {
    if (!_rowFallArray) {
        _rowFallArray = [NSMutableArray array];
    }
    return _rowFallArray;
}

- (NSMutableArray *)cellFrameArray {
    if (!_cellFrameArray) {
        _cellFrameArray = [NSMutableArray array];
    }
    return _cellFrameArray;
}

@end

@interface DYWaterFallFlowLayout()

@property (nonatomic, strong) NSMutableArray *sectionArray;

@property (nonatomic, strong) NSMutableArray *allAttArray;

@property (nonatomic, assign) CGFloat maxY;

@property (nonatomic, assign) CGFloat maxX;

@property (nonatomic, assign) CGSize lastSize;

@end

@implementation DYWaterFallFlowLayout

#pragma mark - 初始化

- (NSMutableArray *)allAttArray {
    if (!_allAttArray) {
        _allAttArray = [NSMutableArray array];
    }
    return _allAttArray;
}

- (NSMutableArray *)sectionArray {
    if (!_sectionArray) {
        _sectionArray = [NSMutableArray array];
        
        for (int i = 0; i < [self numberOfSections]; i++) {
            DYFlowLayoutModel *model = [[DYFlowLayoutModel alloc] init];
            [_sectionArray addObject:model];
            model.section = i;
            model.itemSpace = [self minItemSpace:i];
            model.lineSpace = [self minLineSpace:i];
            model.maxX = self.collectionView.contentInset.left;
            model.maxY = self.collectionView.contentInset.top;
        }
    }
    return _sectionArray;
}

- (void)prepareLayout {
    [super prepareLayout];
    self.maxY = 0.0;
    if (_sectionArray) {
        [_sectionArray removeAllObjects];
        _sectionArray = nil;
    }
    [self sectionArray];
}

#pragma mark - 布局刷新

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attArr = [NSMutableArray array];
    for (DYFlowLayoutModel *model in self.sectionArray) {
        if (model.cellFrameArray.count < [self rowOfSection:model.section] ) {
            if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                [self updateAttributes:model.section];
            } else {
                [self updateHorizontal:model.section];
            }
        }
        if (model.headLayoutAttributes) {
            [attArr addObject:model.headLayoutAttributes];
        }
        [attArr addObjectsFromArray:model.cellFrameArray];
        if (model.footerLayoutAttributes) {
            [attArr addObject:model.footerLayoutAttributes];
        }
    }
    self.allAttArray = attArr;
    return self.allAttArray;
}

- (NSArray *)layoutAttributesForSection:(NSArray *)layoutAttributes section:(NSInteger)section{
    if (layoutAttributes.count == 0) {
        return layoutAttributes;
    }
    DYFlowLayoutModel *model = self.sectionArray[section];
    if (model.isFallHeight) {
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            [self setCellFrameIsFallVertical:layoutAttributes section:section];
        } else {
            [self setCellFrameIsFallHorizontal:layoutAttributes section:section];
        }
    } else {
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            [self setCellFrameNoFallVertical:layoutAttributes section:section];
        } else {
            [self setCellFrameNoFallHorizontal:layoutAttributes section:section];
        }
    }
    return layoutAttributes;
}

- (CGSize)collectionViewContentSize {
    CGSize size = [super collectionViewContentSize];
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        size.height = self.maxY;
    } else {
        size.width = self.maxX;
    }
    if (!CGSizeEqualToSize(size, self.lastSize)  && self.sizeUpdatedBlock) {
        self.sizeUpdatedBlock(size);
    }
    self.lastSize = size;
    return size;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}

#pragma mark - model赋值

/// 更新纵向model
/// @param section 所在分组
- (void)updateAttributes:(NSInteger)section {

    DYFlowLayoutModel *model = self.sectionArray[section];
    model.maxY = self.maxY;
    //head修改frame
    UICollectionViewLayoutAttributes *head = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    if (head.frame.size.height * head.frame.size.width > 0) {
        model.headLayoutAttributes = head;
        CGRect headFrame = model.headLayoutAttributes.frame;
        headFrame.origin.y = model.maxY;
        model.headLayoutAttributes.frame = headFrame;
        model.maxY += headFrame.size.height;
    }
    model.maxY += self.sectionInset.top;
    model.maxX = self.sectionInset.left;
    //计算每个cell的frame
    NSMutableArray *attArray = [NSMutableArray array];
    for (int j = 0; j < [self rowOfSection:section]; j++) {
        UICollectionViewLayoutAttributes *att = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:j inSection:section]];
        [attArray addObject:att];
        if (model.size.height == 0.0) {
            model.size = att.frame.size;
        } else {
            if ((NSInteger)model.size.height != (NSInteger)att.frame.size.height) {
                model.isFallHeight = YES;
            }
        }
    }

    model.cellFrameArray = [[self layoutAttributesForSection:attArray section:section] mutableCopy];
    model.maxY = 0.0;
    for (UICollectionViewLayoutAttributes *att in model.cellFrameArray) {
        model.maxY = MAX(att.frame.origin.y + att.frame.size.height, model.maxY);
    }
    
    //footer修改frame
    UICollectionViewLayoutAttributes *footer = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    if (footer.frame.size.height * footer.frame.size.width > 0) {
        model.footerLayoutAttributes = footer;
        CGRect footerFrame = model.footerLayoutAttributes.frame;
        footerFrame.origin.y = model.maxY;
        model.footerLayoutAttributes.frame = footerFrame;
        model.maxY += footerFrame.size.height;
    }
    model.maxY += self.sectionInset.bottom;
    self.maxY = MAX(model.maxY , self.maxY);
}

/// 更新横向model
/// @param section 所在分组
- (void)updateHorizontal:(NSInteger)section {
    DYFlowLayoutModel *model = self.sectionArray[section];
    UICollectionViewLayoutAttributes *head = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    
    model.maxX = self.maxX;
    if (head.frame.size.height * head.frame.size.width > 0) {
        model.headLayoutAttributes = head;
        CGRect headFrame = model.headLayoutAttributes.frame;
        headFrame.origin.x = model.maxX;
        model.headLayoutAttributes.frame = headFrame;
        model.maxX += headFrame.size.width;
    }
    model.maxX += self.sectionInset.left;
    model.maxY = self.sectionInset.top ;
    //计算每个cell的frame
    NSMutableArray *attArray = [NSMutableArray array];
    for (int j = 0; j < [self rowOfSection:section]; j++) {
        UICollectionViewLayoutAttributes *att = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:j inSection:section]];
        [attArray addObject:att];
        if (model.size.height == 0.0) {
            model.size = att.frame.size;
        } else {
            if ((NSInteger)model.size.width != (NSInteger)att.frame.size.width) {
                model.isFallHeight = YES;
            }
        }
    }
    
    model.cellFrameArray = [[self layoutAttributesForSection:attArray section:section] mutableCopy];
    model.maxX = 0.0;
    for (UICollectionViewLayoutAttributes *att in model.cellFrameArray) {
        model.maxX = MAX(att.frame.origin.x + att.frame.size.width, model.maxX);
    }
    
    //footer修改frame
    UICollectionViewLayoutAttributes *footer = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    if (footer.frame.size.height * footer.frame.size.width > 0) {
        model.footerLayoutAttributes = footer;
        CGRect footerFrame = model.footerLayoutAttributes.frame;
        footerFrame.origin.x = model.maxX;
        model.footerLayoutAttributes.frame = footerFrame;
        model.maxX += footerFrame.size.width;
    }
    model.maxX += self.sectionInset.right;
    self.maxX = MAX(model.maxX , self.maxX);
}

#pragma mark - 坐标计算

/// 纵向布局，瀑布流（等宽）
/// @param layoutAttributes layout数组
/// @param section 分组
- (void)setCellFrameIsFallVertical:(NSArray *)layoutAttributes section:(NSInteger)section {

    DYFlowLayoutModel *model = self.sectionArray[section];
    CGFloat yMinPoint = 0.0;
    CGFloat width = self.collectionView.frame.size.width - self.sectionInset.right - self.collectionView.contentInset.left - self.collectionView.contentInset.right;
    for (int index = 0; index < layoutAttributes.count; index ++) {
        
        UICollectionViewLayoutAttributes *currentAttr = layoutAttributes[index];
        if (model.maxX + currentAttr.frame.size.width <= width) {
            CGRect nowFrame = currentAttr.frame;
            nowFrame.origin.y = model.maxY;
            nowFrame.origin.x = model.maxX;
            currentAttr.frame = nowFrame;
            model.maxX += currentAttr.frame.size.width + model.itemSpace;
            [model.rowFallArray addObject:[NSValue valueWithCGSize:CGSizeMake(currentAttr.frame.origin.x, currentAttr.frame.size.height + currentAttr.frame.origin.y)]];
        } else {
            CGRect nowFrame = currentAttr.frame;
            NSInteger minIndex = 0;
            for (int i = 0; i < model.rowFallArray.count; i++) {
                CGSize size = [model.rowFallArray[i] CGSizeValue];
                if (i == 0) {
                    yMinPoint = size.height;
                    minIndex = i;
                } else {
                    if (size.height < yMinPoint) {
                        yMinPoint = size.height;
                        minIndex = i;
                    }
                }
            }
            CGSize size = [model.rowFallArray[minIndex] CGSizeValue];
            nowFrame.origin.x = size.width;
            nowFrame.origin.y = yMinPoint + model.lineSpace;
            currentAttr.frame = nowFrame;
            model.rowFallArray[minIndex] = [NSValue valueWithCGSize:CGSizeMake(currentAttr.frame.origin.x, currentAttr.frame.size.height + currentAttr.frame.origin.y)];
        }
        [model.cellFrameArray addObject:currentAttr];
    }
}

/// 纵向布局，非瀑布流（等高）
/// @param layoutAttributes layout数组
/// @param section 分组
- (void)setCellFrameNoFallVertical:(NSArray *)layoutAttributes section:(NSInteger)section {

    DYFlowLayoutModel *model = self.sectionArray[section];
    for (NSUInteger index = 0; index < layoutAttributes.count ; index++) {
        
        UICollectionViewLayoutAttributes *currentAttr = layoutAttributes[index]; // 当前cell的位置信息
        UICollectionViewLayoutAttributes *nextAttr = index + 1 == layoutAttributes.count ?
        nil : layoutAttributes[index+1];//下一个cell 位置信息

        CGRect nowFrame = currentAttr.frame;
        nowFrame.origin.x = model.maxX;
        nowFrame.origin.y = model.maxY;
        
        currentAttr.frame = nowFrame;
        model.maxX += nowFrame.size.width + model.itemSpace;
        [model.cellFrameArray addObject:currentAttr];
        CGFloat width = self.collectionView.frame.size.width - self.sectionInset.right - self.collectionView.contentInset.left - self.collectionView.contentInset.right;
        //换行
        if (model.maxX + nextAttr.frame.size.width > width){
            model.maxX = self.sectionInset.left;
            model.maxY = currentAttr.frame.origin.y + currentAttr.frame.size.height + model.lineSpace;
        }
    }
}

/// 横向布局，非瀑布流（等宽）
/// @param layoutAttributes layout数组
/// @param section 分组
- (void)setCellFrameNoFallHorizontal:(NSArray *)layoutAttributes section:(NSInteger)section {
    DYFlowLayoutModel *model = self.sectionArray[section];
    for (NSUInteger index = 0; index < layoutAttributes.count ; index++) {
        
        UICollectionViewLayoutAttributes *currentAttr = layoutAttributes[index]; // 当前cell的位置信息
        UICollectionViewLayoutAttributes *nextAttr = index + 1 == layoutAttributes.count ?
        nil : layoutAttributes[index+1];//下一个cell 位置信息

        CGRect nowFrame = currentAttr.frame;
        nowFrame.origin.x = model.maxX;
        nowFrame.origin.y = model.maxY;
        
        currentAttr.frame = nowFrame;
        model.maxY += nowFrame.size.height + model.lineSpace;
        [model.cellFrameArray addObject:currentAttr];
        CGFloat height = self.collectionView.frame.size.height - self.sectionInset.bottom - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom;
        //换行
        if (model.maxY + nextAttr.frame.size.height > height){
            model.maxY = self.sectionInset.top;
            model.maxX = currentAttr.frame.origin.x + currentAttr.frame.size.width + model.itemSpace;
        }
    }
}

/// 横向布局，瀑布流（等高）
/// @param layoutAttributes layout数组
/// @param section 分组
- (void)setCellFrameIsFallHorizontal:(NSArray *)layoutAttributes section:(NSInteger)section {
    DYFlowLayoutModel *model = self.sectionArray[section];
    CGFloat xMinPoint = 0.0;
    CGFloat height = self.collectionView.frame.size.height - self.sectionInset.bottom - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom;
    for (int index = 0; index < layoutAttributes.count; index ++) {
        
        UICollectionViewLayoutAttributes *currentAttr = layoutAttributes[index];
        if (model.maxY + currentAttr.frame.size.height <= height) {
            CGRect nowFrame = currentAttr.frame;
            nowFrame.origin.y = model.maxY;
            nowFrame.origin.x = model.maxX;
            currentAttr.frame = nowFrame;
            model.maxY += currentAttr.frame.size.height + model.lineSpace;
            [model.rowFallArray addObject:[NSValue valueWithCGSize:CGSizeMake(currentAttr.frame.origin.x + currentAttr.frame.size.width, currentAttr.frame.origin.y)]];
        } else {
            CGRect nowFrame = currentAttr.frame;
            NSInteger minIndex = 0;
            for (int i = 0; i < model.rowFallArray.count; i++) {
                CGSize size = [model.rowFallArray[i] CGSizeValue];
                if (i == 0) {
                    xMinPoint = size.width;
                    minIndex = i;
                } else {
                    if (size.width < xMinPoint) {
                        xMinPoint = size.width;
                        minIndex = i;
                    }
                }
            }
            CGSize size = [model.rowFallArray[minIndex] CGSizeValue];
            nowFrame.origin.y = size.height;
            nowFrame.origin.x = xMinPoint + model.itemSpace;
            currentAttr.frame = nowFrame;
            model.rowFallArray[minIndex] = [NSValue valueWithCGSize:CGSizeMake(currentAttr.frame.origin.x + currentAttr.frame.size.width, currentAttr.frame.origin.y)];
        }
        [model.cellFrameArray addObject:currentAttr];
    }
}

#pragma mark - 获取layout信息

- (NSInteger)numberOfSections {
    SEL selNumOfSection = @selector(numberOfSectionsInCollectionView:);
    NSInteger numOfSection = 1;
    if ([self.collectionView.delegate respondsToSelector:selNumOfSection]) {
        id target = (id<UICollectionViewDataSource>)self.collectionView.delegate;
        numOfSection = [target numberOfSectionsInCollectionView:self.collectionView];
    }
    return numOfSection;
}

- (NSInteger)rowOfSection:(NSInteger)section {
    SEL sel = @selector(collectionView:numberOfItemsInSection:);
    NSInteger rowOfSection = 0;
    if ([self.collectionView.delegate respondsToSelector:sel]) {
        id target = (id<UICollectionViewDataSource>)self.collectionView.delegate;
        rowOfSection = [target collectionView:self.collectionView numberOfItemsInSection:section];
    }
    return rowOfSection;
}

- (CGFloat)minLineSpace:(NSInteger)section {
    SEL selLine = @selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:);
    CGFloat lineSpace = self.minimumLineSpacing;
    if ([self.collectionView.delegate respondsToSelector:selLine]) {
        id target = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
        lineSpace = [target collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
    }
    return lineSpace;
}

- (CGFloat)minItemSpace:(NSInteger)section {
    SEL sel = @selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:);
    CGFloat itemSpace = self.minimumInteritemSpacing;
    if ([self.collectionView.delegate respondsToSelector:sel]) {
        id target = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
        itemSpace = [target collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
    }
    return itemSpace;
}

@end
