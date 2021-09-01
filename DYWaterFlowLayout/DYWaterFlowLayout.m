//
//  DYWaterFlowLayout.m
//  DYWaterFlowLayout
//
//  Created by duyi on 2021/8/31.
//

#import "DYWaterFlowLayout.h"

@implementation DYFlowLayoutModel

- (NSMutableArray *)rowHeightArray {
    if (!_rowHeightArray) {
        _rowHeightArray = [NSMutableArray array];
    }
    return _rowHeightArray;
}

- (NSMutableArray *)cellFrameArray {
    if (!_cellFrameArray) {
        _cellFrameArray = [NSMutableArray array];
    }
    return _cellFrameArray;
}

@end

@interface DYWaterFlowLayout()

@property (nonatomic, strong) NSMutableArray *sectionArray;

@property (nonatomic, strong) NSMutableArray *allAttArray;

@property (nonatomic, assign) CGFloat maxY;

@end

@implementation DYWaterFlowLayout

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
            model.maxX = self.sectionInset.left;
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

- (void)updateAttributes:(NSInteger)section {

    DYFlowLayoutModel *model = self.sectionArray[section];
    
    //head修改frame
    model.headLayoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    model.maxY = self.maxY;
    CGRect headFrame = model.headLayoutAttributes.frame;
    headFrame.origin.y = model.maxY;
    model.headLayoutAttributes.frame = headFrame;
    model.maxY += headFrame.size.height + self.sectionInset.top;
    
    //计算每个cell的frame
    NSMutableArray *attArray = [NSMutableArray array];
    for (int j = 0; j < [self rowOfSection:section]; j++) {
        UICollectionViewLayoutAttributes *att = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:j inSection:section]];
        [attArray addObject:att];
        if (model.size.height == 0.0) {
            model.size = att.frame.size;
            model.numOfRow = (self.collectionView.frame.size.width - self.sectionInset.left - self.sectionInset.right - self.collectionView.contentInset.left - self.collectionView.contentInset.right) / (att.frame.size.width + model.itemSpace);
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
    model.footerLayoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    CGRect footerFrame = model.footerLayoutAttributes.frame;
    footerFrame.origin.y = model.maxY + self.sectionInset.bottom;
    model.footerLayoutAttributes.frame = footerFrame;
    model.maxY += self.sectionInset.bottom + footerFrame.size.height;
    self.maxY = MAX(model.maxY , self.maxY);
}

#pragma mark - 属性计算

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attArr = [NSMutableArray array];
    for (DYFlowLayoutModel *model in self.sectionArray) {
        if (model.cellFrameArray.count < [self rowOfSection:model.section] ) {
            [self updateAttributes:model.section];
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
        [self setCellFrameVertical:layoutAttributes section:section];
    } else {
        [self setCellFrameHorizontal:layoutAttributes section:section];
    }
    return layoutAttributes;
}

- (void)setCellFrameVertical:(NSArray *)layoutAttributes section:(NSInteger)section {

    DYFlowLayoutModel *model = self.sectionArray[section];
    CGFloat yMinPoint = 0.0;
    for (int index = 0; index < layoutAttributes.count; index ++) {
        
        UICollectionViewLayoutAttributes *currentAttr = layoutAttributes[index];
        if (index < model.numOfRow && model.rowHeightArray.count < model.numOfRow) {
            CGRect nowFrame = currentAttr.frame;
            nowFrame.origin.y = model.maxY;
            nowFrame.origin.x = model.maxX;
            currentAttr.frame = nowFrame;
            model.maxX += currentAttr.frame.size.width + model.itemSpace;
            [model.rowHeightArray addObject:[NSValue valueWithCGSize:CGSizeMake(currentAttr.frame.origin.x, currentAttr.frame.size.height + currentAttr.frame.origin.y)]];
        } else {
            CGRect nowFrame = currentAttr.frame;
            NSInteger minIndex = 0;
            for (int i = 0; i < model.rowHeightArray.count; i++) {
                CGSize size = [model.rowHeightArray[i] CGSizeValue];
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
            CGSize size = [model.rowHeightArray[minIndex] CGSizeValue];
            nowFrame.origin.x = size.width;
            nowFrame.origin.y = yMinPoint + model.lineSpace;
            currentAttr.frame = nowFrame;
            model.rowHeightArray[minIndex] = [NSValue valueWithCGSize:CGSizeMake(currentAttr.frame.origin.x, currentAttr.frame.size.height + currentAttr.frame.origin.y)];
        }
        [model.cellFrameArray addObject:currentAttr];
    }
}

- (void)setCellFrameHorizontal:(NSArray *)layoutAttributes section:(NSInteger)section {

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
        CGFloat width = self.collectionView.frame.size.width - self.sectionInset.left - self.sectionInset.right - self.collectionView.contentInset.left - self.collectionView.contentInset.right;
        //换行
        if (model.maxX + nextAttr.frame.size.width > width){
            model.maxX = self.sectionInset.left;
            model.maxY = currentAttr.frame.origin.y + currentAttr.frame.size.height + model.lineSpace;
        }
    }
}

- (CGSize)collectionViewContentSize {
    CGSize size = [super collectionViewContentSize];
    size.height = self.maxY;
    return size;
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
    SEL sel = @selector(numberOfSectionsInCollectionView:);
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
