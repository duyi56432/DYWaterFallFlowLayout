//
//  ViewController.m
//  DYWaterFlowLayout
//
//  Created by duyi on 2021/8/31.
//

#import "ViewController.h"
#import "MJRefresh.h"
#import "DYWaterFallFlowLayout.h"
#import "DYWaterFlowCell.h"
#import "DYWaterFlowHeader.h"

#define iPhoneX \
    ({BOOL isPhoneX = NO;\
    if (@available(iOS 11.0, *)) {\
        isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
    }\
    (isPhoneX);})

#define ISIPAD [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

#define  kStatusBarHeight     ({CGFloat statusBarHeight = 0;\
    if (@available(iOS 13.0, *)) {\
        statusBarHeight = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarFrame.size.height;\
    }\
    ( statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height);})

#define  kNavBarHeight  (ISIPAD ? 60.f : 44.f)

#define  kNavigation_height  (kNavBarHeight+kStatusBarHeight)

@interface ViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *section0Array;
@property (nonatomic, strong) NSMutableArray *heightArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"瀑布流";
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
        layout.sectionInset = UIEdgeInsetsMake(5, 0, 5, 0);
        CGRect rect = self.view.bounds;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kNavigation_height, rect.size.width, rect.size.height - kNavigation_height) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
        _collectionView.contentMode = UIViewContentModeLeft;
        [_collectionView registerNib:[UINib nibWithNibName:@"DYWaterFlowCell" bundle:nil] forCellWithReuseIdentifier:@"DYWaterFlowCell"];
        [_collectionView registerNib:[UINib nibWithNibName:@"DYWaterFlowHeader" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DYWaterFlowHeader"];
        
        __weak typeof(self) weakSelf = self;
        _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf.collectionView.mj_header endRefreshing];
            [weakSelf.heightArray removeAllObjects];
            for (int i = 0; i < 10; i++) {
                [weakSelf.heightArray addObject:@(arc4random() % 9 * 10 + 10)];
            }
            [weakSelf.collectionView reloadData];
        }];
        _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [weakSelf.collectionView.mj_footer endRefreshing];
            for (int i = 0; i < 10; i++) {
                [weakSelf.heightArray addObject:@(arc4random() % 9 * 10 + 10)];
            }
            [weakSelf.collectionView reloadData];
        }];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 2) {
        return self.heightArray.count;
    }
    return self.section0Array.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DYWaterFlowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DYWaterFlowCell" forIndexPath:indexPath];
    cell.contentLabel.text = [NSString stringWithFormat:@"%@",@(indexPath.row)];
    cell.contentLabel.backgroundColor = indexPath.section == 1 ? [UIColor greenColor] : [UIColor redColor];
    cell.contentLabel.layer.cornerRadius = 3;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    DYWaterFlowHeader *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DYWaterFlowHeader" forIndexPath:indexPath];
    view.titleLabel.text = @[@"分组1",@"分组2",@"分组3"][indexPath.section];
    view.markLabel.text = @[@"纵向瀑布流",@"横向瀑布流",@"纵向瀑布流上拉加载更多"][indexPath.section];
    view.layer.cornerRadius = 5;
    return view;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(50,[self.section0Array[indexPath.row] doubleValue]);
    } else if (indexPath.section == 1) {
        return CGSizeMake([self.section0Array[indexPath.row] doubleValue], 50);
    } else {
        return CGSizeMake(50,[self.heightArray[indexPath.row] doubleValue]);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(0, 50);
}

@end
