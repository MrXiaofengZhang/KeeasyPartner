//
//  WPCAreaView.m
//  yuezhan123
//
//  Created by admin on 15/6/9.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCAreaView.h"
#import "WPCAreaSelectCell.h"

static NSInteger defaultIndex = 0;
static NSString * cellIdentifer = @"cell";
@implementation WPCAreaView
- (id)initWithFrame:(CGRect)frame dataSource:(NSArray *)arr city:(NSString *)aCity viewController:(UIViewController *)vc;
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _open = NO;
        
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        _dataSource = [NSArray arrayWithArray:arr];
        
        //创建底部半透明视图
        _backView = [[UIView alloc] initWithFrame:frame];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0;
        [self addSubview:_backView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(desappear)];
        [_backView addGestureRecognizer:tap];
        
        //创建collectionview的载体视图
        _whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, -self.height*3/5, UISCREENWIDTH, self.height*3/5)];
        _whiteView.autoresizesSubviews = YES;
        _whiteView.backgroundColor = RGBACOLOR(234, 234, 234, 1);
        [self addSubview:_whiteView];
        
        //创建 collectionview
        CGFloat cellWidth = UISCREENWIDTH/3.6;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth/3);
        flowLayout.sectionInset = UIEdgeInsetsMake(15, (UISCREENWIDTH-3*cellWidth)/4, 15, (UISCREENWIDTH-3*cellWidth)/4);
        
        _areaCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, _whiteView.height*3/4) collectionViewLayout:flowLayout];
        _areaCollection.dataSource = self;
        _areaCollection.showsVerticalScrollIndicator = NO;
        _areaCollection.backgroundColor = [UIColor clearColor];
        _areaCollection.delegate = self;
        [_areaCollection registerClass:[WPCAreaSelectCell class] forCellWithReuseIdentifier:cellIdentifer];
        [_whiteView addSubview:_areaCollection];
        
        //创建collection下方视图
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, _areaCollection.bottom, UISCREENWIDTH-20, 0.5)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [_whiteView addSubview:lineView];
        
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(10, lineView.bottom+_whiteView.height/16, UISCREENWIDTH-20, _whiteView.height/8)];
        tempView.backgroundColor = [UIColor whiteColor];
        tempView.layer.borderWidth = 0.5;
        tempView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [_whiteView addSubview:tempView];
        
        _currentCityLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, tempView.height)];
        _currentCityLab.text = @"当前城市：北京市";
        _currentCityLab.textColor = RGBACOLOR(127, 133, 136, 1);
        _currentCityLab.backgroundColor = [UIColor clearColor];
        [tempView addSubview:_currentCityLab];
        
        UIView *changeView = [[UIView alloc] initWithFrame:CGRectMake(tempView.right-80, 0, 80, tempView.height)];
        tempView.userInteractionEnabled = YES;
        changeView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tapChangeView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeEvent)];
        [changeView addGestureRecognizer:tapChangeView];
        
        UILabel *changeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.height-20)/2, 35, 20)];
        changeLabel.text = @"更换";
        changeLabel.textColor = RGBACOLOR(77, 161, 218, 1);
        [changeView addSubview:changeLabel];
        
        UIImageView *arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
        arrowImg.frame = CGRectMake(changeLabel.right, (tempView.height-20)/2, 20, 20);
        [changeView addSubview:arrowImg];
        
        [tempView addSubview:changeView];
        
        self.viewVC = vc;
        self.delegate = (id)vc;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame dataSource:(NSArray *)arr city:(NSString *)aCity ;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        _dataSource = [NSArray arrayWithArray:arr];
        
        //创建底部半透明视图
        _backView = [[UIView alloc] initWithFrame:frame];
        _backView.backgroundColor = [UIColor blackColor];
        [self addSubview:_backView];
        
        //创建collectionview的载体视图
        _whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, self.height)];
        _whiteView.autoresizesSubviews = YES;
        _whiteView.backgroundColor = RGBACOLOR(234, 234, 234, 1);
        [self addSubview:_whiteView];
        
        //创建 collectionview
        CGFloat cellWidth = UISCREENWIDTH/3.6;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth/3);
        flowLayout.sectionInset = UIEdgeInsetsMake(15, (UISCREENWIDTH-3*cellWidth)/4, 15, (UISCREENWIDTH-3*cellWidth)/4);
        
        _areaCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, _whiteView.height*3/4) collectionViewLayout:flowLayout];
        _areaCollection.dataSource = self;
        _areaCollection.showsVerticalScrollIndicator = NO;
        _areaCollection.backgroundColor = [UIColor clearColor];
        _areaCollection.delegate = self;
        [_areaCollection registerClass:[WPCAreaSelectCell class] forCellWithReuseIdentifier:cellIdentifer];
        [_whiteView addSubview:_areaCollection];
        
        //创建collection下方视图
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, _areaCollection.bottom, UISCREENWIDTH-20, 0.5)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [_whiteView addSubview:lineView];
        
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(10, lineView.bottom+_whiteView.height/16, UISCREENWIDTH-20, _whiteView.height/8)];
        tempView.backgroundColor = [UIColor whiteColor];
        tempView.layer.borderWidth = 0.5;
        tempView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [_whiteView addSubview:tempView];
        
        _currentCityLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, tempView.height)];
        _currentCityLab.text = @"当前城市：北京市";
        _currentCityLab.textColor = RGBACOLOR(127, 133, 136, 1);
        _currentCityLab.backgroundColor = [UIColor clearColor];
        [tempView addSubview:_currentCityLab];
        
        UIView *changeView = [[UIView alloc] initWithFrame:CGRectMake(tempView.right-80, 0, 80, tempView.height)];
        tempView.userInteractionEnabled = YES;
        changeView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tapChangeView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeEvent)];
        [changeView addGestureRecognizer:tapChangeView];
        
        UILabel *changeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.height-20)/2, 35, 20)];
        changeLabel.text = @"更换";
        changeLabel.textColor = RGBACOLOR(77, 161, 218, 1);
        [changeView addSubview:changeLabel];
        
        UIImageView *arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
        arrowImg.frame = CGRectMake(changeLabel.right, (tempView.height-20)/2, 20, 20);
        [changeView addSubview:arrowImg];
        
        [tempView addSubview:changeView];
    }
    return self;
}
- (void)disappearImmediately
{
    _open = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:ARROW_CHANGE_DIRECTION_NOTIFICATION object:nil];
    _whiteView.frame = CGRectMake(0, -self.height*3/5, UISCREENWIDTH, self.height*3/5);
    _backView.alpha = 0;
    [self removeFromSuperview];
}

//点击灰色视图出把视图消失
- (void)desappear
{
    _open = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:ARROW_CHANGE_DIRECTION_NOTIFICATION object:nil];
    [UIView animateWithDuration:0.3 animations:^{
        _whiteView.frame = CGRectMake(0, -self.height*3/5, UISCREENWIDTH, self.height*3/5);
        _backView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)desappearTheCustomView
{
    _open = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:ARROW_CHANGE_DIRECTION_NOTIFICATION object:nil];
    [UIView animateWithDuration:0.3 animations:^{
        _whiteView.frame = CGRectMake(0, -self.height*3/5, UISCREENWIDTH, self.height*3/5);
        _backView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

//点击城市视图出现
- (void)appearTheCustomView
{
    _open = YES;
    [self.areaCollection reloadData];
    [self.viewVC.view addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        _whiteView.frame = CGRectMake(0, 0, UISCREENWIDTH, self.height*3/5);
        _backView.alpha = 0.6;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark -- uicollectionview datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WPCAreaSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifer forIndexPath:indexPath];
    cell.titleLab.text = _dataSource[indexPath.row];
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = [RGBACOLOR(215, 215, 215, 1) CGColor];
    cell.titleLab.textColor = RGBACOLOR(135, 136, 136, 1);
    cell.backgroundColor = [UIColor whiteColor];
//    if (indexPath.row == [[kUserDefault valueForKey:kAreaIndex] integerValue]) {
//        cell.backgroundColor = RGBACOLOR(222, 222, 222, 1);
//    }
    if (indexPath.row == defaultIndex) {
        cell.backgroundColor = RGBACOLOR(222, 222, 222, 1);
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate collectionCellClickAtIndex:indexPath.row];
    [kUserDefault setValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:kAreaIndex];
    if (self.areaType == TypeAppoint) {
        [self desappear];
    } else if (self.areaType == TypeVenue) {
        defaultIndex = indexPath.row;
    }
}

- (void)changeDatasource:(NSArray *)arr {
    self.dataSource = arr;
    defaultIndex = 0;
    [_areaCollection reloadData];
}

#pragma mark --更换按钮事件
- (void)changeEvent
{
    [self.delegate changeBtnClick];
}

@end
