//
//  AssetViewController.m
//  TestDemo
//
//  Created by Jack on 2018/1/24.
//  Copyright © 2018年 Jack. All rights reserved.
//

#import "AssetViewController.h"
#import "AssetCell.h"
#import "AssetImageManager.h"
#import "AssetModel.h"
#import <Photos/Photos.h>
#import "PreviewView.h"

@interface AssetViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,AssetCellDelegate>

/** collectionview */
@property (weak, nonatomic) UICollectionView *collectionView;
/** 相册数组 */
@property (strong, nonatomic) NSMutableArray<AssetModel *> *assetArray;
/** 图片选择数label */
@property (weak, nonatomic) UILabel *countLabel;
/** 选中的图片数组 */
@property (strong, nonatomic) NSMutableArray<AssetModel *> *selectArray;
/** 初始化大小 */
@property (assign, nonatomic) CGRect cellRect;
/** 全选按钮 */
@property (nonatomic, weak) UIButton *allSelectButton;
@end

@implementation AssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载相册图片数据
    [self loadPhotoLibrary];
    //创建子控件
    [self createCollectionView];
    //设置导航栏
    [self setupNavigationView];
    //设置底部工具栏
    [self createBottomToolView];
}

- (void)setupNavigationView {
    UIColor *mainColor = [UIColor colorWithRed:68/255.0 green:150/255.0 blue:241/255.0 alpha:1.0];
    CGFloat width = CGRectGetWidth(self.view.frame);
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 64)];
    navView.backgroundColor = mainColor;
    [self.view addSubview:navView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 20, width - 64 * 2, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    if (self.title) {
        titleLabel.text = self.title;
    }else{
        titleLabel.text = @"相册";
    }
    titleLabel.font = [UIFont systemFontOfSize:18];
    [navView addSubview:titleLabel];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(self.view.frame.size.width - 54, 20, 44, 44);
    [doneButton setTitle:@"取消" forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [doneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:doneButton];
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createBottomToolView{
    UIView *tool = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 49, self.view.frame.size.width, 49)];
    [self.view addSubview:tool];
    tool.backgroundColor = [UIColor whiteColor];
    
    UIColor *mainColor = [UIColor colorWithRed:68/255.0 green:150/255.0 blue:241/255.0 alpha:1.0];
    UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
    [done setTitleColor:mainColor forState:UIControlStateNormal];
    CGRect frame = CGRectMake(self.view.frame.size.width - 55, 15, 45, 20);
    done.frame = frame;
    [done setTitle:@"完成" forState:UIControlStateNormal];
    [done addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    [tool addSubview:done];
    
    UILabel *count = [[UILabel alloc] init];
    count.font = [UIFont systemFontOfSize:10];
    [tool addSubview:count];
    count.textColor = [UIColor whiteColor];
    count.frame = CGRectMake(self.view.frame.size.width - 80, 15, 20, 20);
    count.text = @"0";
    count.textAlignment = NSTextAlignmentCenter;
    count.layer.cornerRadius = 10;
    count.layer.masksToBounds = YES;
    self.countLabel = count;
    count.backgroundColor = mainColor;
    
    UIButton *allSelect = [UIButton buttonWithType:UIButtonTypeCustom];
    [allSelect setTitle:@"全选" forState:UIControlStateNormal];
    [allSelect setTitle:@"取消" forState:UIControlStateSelected];
    [allSelect setTitleColor:mainColor forState:UIControlStateNormal];
    allSelect.adjustsImageWhenDisabled = NO;
    allSelect.adjustsImageWhenHighlighted = NO;
    [tool addSubview:allSelect];
    allSelect.frame = CGRectMake(10, 0, 40, 49);
    [allSelect addTarget:self action:@selector(allClick:) forControlEvents:UIControlEventTouchUpInside];
    self.allSelectButton = allSelect;
}

- (void)allClick:(UIButton *)button{
    button.selected = !button.selected;
    [self.selectArray removeAllObjects];
    [_assetArray enumerateObjectsUsingBlock:^(AssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (button.selected) {
            obj.selected = YES;
            [self.selectArray addObject:obj];
        }else{
            obj.selected = NO;
            [self.selectArray removeAllObjects];
        }
    }];
    [_collectionView reloadData];
    if (button.selected) {
        _countLabel.text = [NSString stringWithFormat:@"%zd",_assetArray.count];
    }else{
        _countLabel.text = @"0";
    }
}

- (void)doneClick:(UIButton *)button{
    if (self.selectImage) {
        self.selectImage(self.selectArray);
    }
    [self dismiss];
}

- (void)createCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 5;
    CGFloat width_height = (self.view.frame.size.width - 20) / 4;
    layout.itemSize = CGSizeMake( width_height, width_height);
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame) - 64 - 49;
    CGRect frame = CGRectMake(0, 64, width, height);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor lightGrayColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.view addSubview:collectionView];
    [collectionView registerClass:[AssetCell class] forCellWithReuseIdentifier:@"AssetCell"];
    self.collectionView = collectionView;
}

- (void)loadPhotoLibrary{
    if (self.assetArray.count) {
        [self.assetArray removeAllObjects];
    }
    __weak typeof(self) weakSelf = self;
    __block NSUInteger count = 0;
    [[AssetImageManager shardInstance] getPhotoLibraryOriginal:YES completion:^(AlbumModel *albumModel) {
        self.assetArray = [NSMutableArray arrayWithArray:albumModel.models];
        [weakSelf.selectImages enumerateObjectsUsingBlock:^(AssetModel * _Nonnull preObj, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakSelf.assetArray enumerateObjectsUsingBlock:^(AssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([preObj.asset isKindOfClass:[PHAsset class]]) {
                    PHAsset *asset = (PHAsset *)preObj.asset;
                    PHAsset *current = (PHAsset *)obj.asset;
                    if ([asset.localIdentifier isEqualToString:current.localIdentifier]) {
                        obj.selected = YES;
                        count ++;
                    }
                }
            }];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            self.countLabel.text = [NSString stringWithFormat:@"%zd",count];
        });
    }];
}

- (void)dealloc{
    NSLog(@"控制器销毁");
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetArray.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
    cell.assetModel = self.assetArray[indexPath.item];
    cell.delegate = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PreviewView *previewView = [[PreviewView alloc] init];
    AssetCell *cell = (AssetCell *)[collectionView cellForItemAtIndexPath:indexPath];
    CGRect rect = [cell convertRect:cell.bounds toView:self.view];
    previewView.frame = rect;
    self.cellRect = rect;
    UIWindow *keywindow = [UIApplication sharedApplication].keyWindow;
    [keywindow addSubview:previewView];
    previewView.alpha = 0.f;
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        previewView.alpha = 1.0;
        previewView.frame = UIScreen.mainScreen.bounds;
    } completion:^(BOOL finished) {
        previewView.dataArray = self.assetArray;
        previewView.index = indexPath.row;
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [previewView addGestureRecognizer:tap];
}

- (void)dismiss:(UITapGestureRecognizer *)tap{
    UIView *view = tap.view;
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        view.alpha = 0;
        view.frame = self.cellRect;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - AssetCellDelegate
- (void)assetCell:(AssetCell *)cell didClickButton:(UIButton *)button{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    button.selected = !button.selected;
    AssetModel *model = self.assetArray[indexPath.item];
    model.selected = !model.selected;
    if (model.selected) {
        [self.selectArray addObject:model];
    }else{
        [self.selectArray removeObject:model];
    }
    self.countLabel.text = [NSString stringWithFormat:@"%zd",self.selectArray.count];
    if (_assetArray.count == _selectArray.count) {
        _allSelectButton.selected = YES;
        [_allSelectButton setTitle:@"取消" forState:UIControlStateSelected];
    }else{
        _allSelectButton.selected = NO;
        [_allSelectButton setTitle:@"全选" forState:UIControlStateNormal];
    }
}

#pragma mark - setter and getter
- (NSMutableArray *)assetArray{
    if (!_assetArray) {
        _assetArray = [NSMutableArray array];
    }
    return _assetArray;
}

- (NSMutableArray *)selectArray{
    if (!_selectArray) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}

@end
