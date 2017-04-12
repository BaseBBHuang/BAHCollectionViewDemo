//
//  ViewController.m
//  BAHCollectionView
//
//  Created by 乔贝斯 on 2017/4/11.
//  Copyright © 2017年 BAH. All rights reserved.
//

#import "ViewController.h"
#import "BAHCollectionViewCell.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
static NSString *collectionCellID = @"BAHCollectionViewCellID";

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) NSMutableArray *cellLayoutAttributeArray;

@end

@implementation ViewController

#pragma mark - getters and setters
- (NSMutableArray *)imagesArray
{
    if (!_imagesArray) {
        _imagesArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < 32; i++) {
            [_imagesArray addObject:[NSString stringWithFormat:@"%d", i+1]];
        }
    }
    return _imagesArray;
}

- (NSMutableArray *)cellLayoutAttributeArray
{
    if (!_cellLayoutAttributeArray) {
        _cellLayoutAttributeArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _cellLayoutAttributeArray;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.minimumLineSpacing = 1.0;
        flowLayout.minimumInteritemSpacing = 1.0;
        flowLayout.sectionInset = UIEdgeInsetsMake(5, 0, 0, 0);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor lightGrayColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.delaysContentTouches = NO;//可以解决单元格被点击时，高亮显示慢的问题。
    }
    return _collectionView;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self.collectionView registerClass:[BAHCollectionViewCell class] forCellWithReuseIdentifier:@"BAHCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BAHCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:collectionCellID];
    [self.view addSubview:self.collectionView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegate, DataSource and UICollectionViewDelegateFlowLayout
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagesArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((kScreenWidth-3)/4, (kScreenWidth-3)/4);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BAHCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.imageView.image = [UIImage imageNamed:self.imagesArray[indexPath.row]];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureClick:)];
    [cell addGestureRecognizer:longPress];
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 手指按下高亮
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor lightGrayColor]];
}
// 手指松开取消高亮
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor whiteColor]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BAHCollectionViewCell *cell = (BAHCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSLog(@"indexpath %ld, collectionItem: %@", indexPath.row, cell.titleLabel.text);
}

#pragma mark - custom event
- (void)longPressGestureClick:(UILongPressGestureRecognizer *)longPressGesture
{
    BAHCollectionViewCell *cell = (BAHCollectionViewCell *)longPressGesture.view;
    [_collectionView bringSubviewToFront:cell];
    NSIndexPath *cellIndexPath = [_collectionView indexPathForCell:cell];

    BOOL isChanged = NO;
    if (longPressGesture.state == UIGestureRecognizerStateChanged) {
        [self.cellLayoutAttributeArray removeAllObjects];
        for (int i = 0; i < self.imagesArray.count; i++) {
            [self.cellLayoutAttributeArray addObject:[_collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
        }
        cell.center = [longPressGesture locationInView:_collectionView];
        
        for (UICollectionViewLayoutAttributes *attributes in self.cellLayoutAttributeArray)
        {
            if (CGRectContainsPoint(attributes.frame, cell.center) && cellIndexPath != attributes.indexPath)
            {
                isChanged = YES;
                NSString *imgStr = self.imagesArray[cellIndexPath.row];
                [self.imagesArray removeObjectAtIndex:cellIndexPath.row];
                [self.imagesArray insertObject:imgStr atIndex:attributes.indexPath.row];
                [self.collectionView moveItemAtIndexPath:cellIndexPath toIndexPath:attributes.indexPath];
            }
        }
        
    } else if(longPressGesture.state == UIGestureRecognizerStateEnded) {
        if (!isChanged) {
            cell.center = [_collectionView layoutAttributesForItemAtIndexPath:cellIndexPath].center;
        }
    }
}




@end
