//
//  DYWaterFlowLayout.h
//  DYWaterFlowLayout
//
//  Created by duyi on 2021/8/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DYFlowLayoutModel : NSObject

/// 是否是纵向瀑布流
@property (nonatomic, assign) BOOL isFallHeight;

@property (nonatomic, strong) NSMutableArray *rowFallArray;

/// 计算后的layout数组
@property (nonatomic, strong) NSMutableArray *cellFrameArray;

/// 原始layout数组
@property (nonatomic, strong) NSMutableArray *attArray;

@property (nonatomic, strong) UICollectionViewLayoutAttributes *headLayoutAttributes;

@property (nonatomic, strong) UICollectionViewLayoutAttributes *footerLayoutAttributes;

@property (nonatomic, assign) NSInteger section;

@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) CGFloat itemSpace;

@property (nonatomic, assign) CGFloat lineSpace;

@property (nonatomic, assign) CGFloat maxY;

@property (nonatomic, assign) CGFloat maxX;

@end

@interface DYWaterFallFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, copy) void (^sizeUpdatedBlock)(CGSize size);

@end

NS_ASSUME_NONNULL_END
