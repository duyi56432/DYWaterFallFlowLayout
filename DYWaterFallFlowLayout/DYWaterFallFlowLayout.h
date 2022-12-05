//
//  DYWaterFlowLayout.h
//  DYWaterFlowLayout
//
//  Created by duyi on 2021/8/31.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FlowLayoutMode) {
    FlowLayoutModeDefalt, //默认模式
    FlowLayoutModeFall //瀑布流
};

NS_ASSUME_NONNULL_BEGIN

@interface DYFlowLayoutModel : NSObject

/// 模式
@property (nonatomic, assign) FlowLayoutMode layoutMode;

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

@property (nonatomic, assign) CGFloat pageX;

@property (nonatomic, assign) UIEdgeInsets insets;

@end

@interface DYWaterFallFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, copy) void (^sizeUpdatedBlock)(CGSize size);

///分页模式返回当前页码（从0开始）
@property (nonatomic, copy) void (^pageDidChangeBlock)(NSInteger page);

///开启横向分页模式
@property (nonatomic, assign) BOOL isPage;

@end

NS_ASSUME_NONNULL_END
