//
//  WPCSportsTypeChooseVC.m
//  yuezhan123
//
//  Created by admin on 15/6/11.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCSportsTypeChooseVC.h"
#import "WPCAreaSelectCell.h"
static NSString *sportTyepId = @"celll";

@interface WPCSportsTypeChooseVC()

@property (nonatomic, copy)NSString *selectedSport;

@end

@implementation WPCSportsTypeChooseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"运动类型";
    [self navgationBarLeftReturn];
    [self createRightBtn];
    [self initialDatasource];
    [self initialInterface];
}

- (void)createRightBtn {
    if (self.multipleChoose == YES) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmChoose:)];
    }
}

- (void)confirmChoose:(UIBarButtonItem *)sender {
    
    if (self.multipleChoose == YES) {
        if (_chooseArray&&_chooseArray.count!=0) {
            NSString *str = _chooseArray[0];
            for (int i = 1; i < _chooseArray.count; i ++) {
                str = [str stringByAppendingFormat:@",%@",_chooseArray[i]];
            }
            [self updateUserInfoWithKey:@"loveSports" AndValue:str];
        }
        else{
            [self updateUserInfoWithKey:@"loveSports" AndValue:@""];
        }
    }
        else{
            self.chuanBlock(_chooseArray);
            [self.navigationController popViewControllerAnimated:YES];
        }
    
}
- (void)updateUserInfoWithKey:(NSString*)key AndValue:(NSString*)value{
    NSMutableDictionary * dic = [LVTools getTokenApp];
    [dic setValue:[kUserDefault objectForKey:KUserMobile] forKey:@"mobile"];
    [dic setValue:value forKey:key];
    [DataService requestWeixinAPI:resetPassword parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"重置密码返回的信息：%@",result);
        NSDictionary * dic = (NSDictionary *)result;
        if ([dic[@"status"] boolValue]) {
            //修改本地缓存并回调block
            [_infoDic[@"user"] setObject:value forKey:key];
            [LVTools mSetLocalData:[NSKeyedArchiver archivedDataWithRootObject:_infoDic] Key:[NSString stringWithFormat:@"xd%@", [LVTools mToString: [kUserDefault objectForKey:kUserId]]]];
            self.chuanBlock(_chooseArray);
            self.sportCode(_chooseCodeArr);
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            if ([LVTools mToString: dic[@"info"]].length>0) {
                [self showHint:dic[@"info"]];
            }
            else{
                [self showHint:ErrorWord];
            }
        }
    }];
}

- (void)initialDatasource
{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
    _dataSource = [NSArray arrayWithContentsOfFile:path];
    if (_chooseArray==nil) {
        _chooseArray = [NSMutableArray arrayWithCapacity:10];
    }
    if (_chooseCodeArr == nil) {
        _chooseCodeArr = [NSMutableArray arrayWithCapacity:10];
    }
    
}

- (void)initialInterface
{
    CGFloat cellWidth = UISCREENWIDTH/3.6;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth/3);
    flowLayout.sectionInset = UIEdgeInsetsMake(15, (UISCREENWIDTH-3*cellWidth)/4, 15, (UISCREENWIDTH-3*cellWidth)/4);
    
    _collect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64) collectionViewLayout:flowLayout];
    _collect.dataSource = self;
    _collect.backgroundColor = RGBACOLOR(238, 238, 238, 1);
    _collect.alwaysBounceVertical = YES;
    _collect.delegate = self;
    [_collect registerClass:[WPCAreaSelectCell class] forCellWithReuseIdentifier:sportTyepId];
    //_collect.contentSize = CGSizeMake(UISCREENWIDTH, UISCREENHEIGHT);
    [self.view addSubview:_collect];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.ishoppy) {
    return _dataSource.count-1;
    }
    else{
    return 2;
    }
    
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WPCAreaSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:sportTyepId forIndexPath:indexPath];
    cell.titleLab.text = _dataSource[indexPath.row+1][@"name"];
    cell.titleLab.textColor = RGBACOLOR(135, 135, 135, 1);
    for (NSString *sportName in self.chooseArray) {
        if ([sportName isEqualToString:_dataSource[indexPath.row+1][@"name"]]) {
            cell.backgroundColor = RGBACOLOR(222, 222, 222, 1);
            cell.isSelected = YES;
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //todo
    if (self.multipleChoose == NO) {
        self.selectedSport = _dataSource[indexPath.row+1][@"name"];
        NSArray *arr = @[self.selectedSport];
        [_chooseCodeArr addObject:_dataSource[indexPath.row+1][@"sport2"]];
        self.chuanBlock(arr);
        self.sportCode(_chooseCodeArr);
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        //最多六个
        if(self.chooseArray.count>=6){
            [self showHint:@"最多选择6个"];
            return;
        }
        WPCAreaSelectCell *cell = (WPCAreaSelectCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.isSelected = !cell.isSelected;
        if (cell.isSelected == YES) {
            cell.backgroundColor = RGBACOLOR(222, 222, 222, 1);
            [_chooseArray addObject:_dataSource[indexPath.row+1][@"name"]];
            [_chooseCodeArr addObject:_dataSource[indexPath.row+1][@"sport2"]];
        } else {
            cell.backgroundColor = [UIColor whiteColor];
            [_chooseArray removeObject:_dataSource[indexPath.row+1][@"name"]];
            [_chooseCodeArr addObject:_dataSource[indexPath.row+1][@"sport2"]];
        }
        
    }
}

@end
