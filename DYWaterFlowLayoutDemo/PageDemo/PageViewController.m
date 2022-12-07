//
//  PageViewController.m
//  DYWaterFlowLayoutDemo
//
//  Created by VolcanoStudio on 2022/12/6.
//

#import "PageViewController.h"
#import "DYWaterFallFlowLayout.h"
#import "DYWaterFlowCell.h"
#import "Const.h"
@interface PageViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *section0Array;
@property (nonatomic, strong) NSMutableArray *heightArray;
@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"横向分页";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.collectionView];
    self.section0Array = [NSMutableArray array];
    self.heightArray = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        [self.heightArray addObject:@(arc4random() % 9 * 10 + 10)];
        [self.section0Array addObject:@(arc4random() % 9 * 10 + 10)];
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        DYWaterFallFlowLayout *layout = [[DYWaterFallFlowLayout alloc] init];
        layout.isPage = YES;
  
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kNavigation_height, self.view.bounds.size.width, 150) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
        _collectionView.contentMode = UIViewContentModeLeft;
        [_collectionView registerNib:[UINib nibWithNibName:@"DYWaterFlowCell" bundle:nil] forCellWithReuseIdentifier:@"DYWaterFlowCell"];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 50;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DYWaterFlowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DYWaterFlowCell" forIndexPath:indexPath];
    cell.contentLabel.text = [NSString stringWithFormat:@"%@",@(indexPath.row)];
    cell.contentLabel.backgroundColor = indexPath.section == 1 ? [UIColor greenColor] : [UIColor redColor];
    cell.contentLabel.layer.cornerRadius = 3;
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (Screen_Width - 70) / 4.0;
    return CGSizeMake(width,50);
}

@end

