//
//  ZHNearXuanController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/7/3.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHNearXuanController.h"
#import "WPCAreaSelectCell.h"
#import "CityListViewController.h"//大学选择
#define kGender @"xuangender"
#define kage @"xuanage"
#define ksport @"xuansport"
#define kdistance @"xuandistance"
#define kschool @"xuanschool"

static NSString *colletIde = @"colletIde";

@interface ZHNearXuanController ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate>{
    NSString *distance;
    NSString *schoolName;
    NSString *sportType;
    NSString *genderType;
    NSString *maxAge;
    NSString *minAge;
    NSString *universityName;
}
@property (nonatomic, strong)NSArray *itemResource;//运动类型
@property (nonatomic, strong)NSArray *genderArr;
@property (nonatomic, strong)NSArray *distanceArr;
@property (nonatomic, strong)NSArray *ageArr;
@property (nonatomic, strong)NSMutableArray *schoolArr;
@property (nonatomic,strong) UITableView *mTableView;
@property (nonatomic,strong) UICollectionView *genderCollect;
@property (nonatomic,strong) UICollectionView *ageCollect;
@property (nonatomic,strong) UICollectionView *sportCollect;

@property (nonatomic,strong) UICollectionView *distanceCollect;
@property (nonatomic,strong) UICollectionView *schoolCollect;
@property (nonatomic,strong) UITextField *searSchool;
@property (nonatomic,strong) UIButton *searBtn;
//modify
@end

@implementation ZHNearXuanController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"筛选";
    distance = @"";
    schoolName = @"";
    sportType = @"";
    genderType = @"";
    maxAge = @"";
    minAge = @"";
    universityName = @"不限";
    [kUserDefault setObject:@"" forKey:kdistance];
    [kUserDefault setObject:@"" forKey:kschool];
    [kUserDefault setObject:@"" forKey:ksport];
    [kUserDefault setObject:@"" forKey:kage];
    [kUserDefault setObject:@"" forKey:kGender];

    [self navgationBarLeftReturn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(okONclick)];
    [self readPlist];
    [self.view addSubview:self.mTableView];
    [self loadUniversity];
}
- (void)loadUniversity{
    [self showHudInView:self.view hint:LoadingWord];
    NSMutableDictionary * dic = [LVTools getTokenApp];
    request = [DataService requestWeixinAPI:getUniversity parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        if ([result[@"statusCodeInfo"] isEqualToString:@"成功"]) {
             NSLog(@"%@",result);
            [self.schoolArr addObjectsFromArray:result[@"result"]];
            [_schoolCollect reloadData];
        }
        else{
            [self showHint:ErrorWord];
        }
        
    }];
    
}

- (void)okONclick{
    //筛选确定
    if ([[kUserDefault objectForKey:kdistance] isEqualToString:@"1"]) {
        distance = @"1";
    }
    else{
        distance = @"0";
    }
    schoolName = universityName;
    if ([universityName isEqualToString:@"不限"]) {
        schoolName = @"";
    }
    
    sportType = [[self.itemResource objectAtIndex:[[kUserDefault objectForKey:ksport] integerValue]] objectForKey:@"sport2"];
    if (self.shaixuanType == ShaixuanTypeTeam) {
        self.chuanBlock(@[[LVTools mToString:self.searSchool.text],schoolName,distance,sportType]);
    } else {
        self.chuanBlock(@[minAge,maxAge,sportType,genderType]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)readPlist{
    //运动
    NSString * path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
    self.itemResource = [NSArray arrayWithContentsOfFile:path];
    //性别
    self.genderArr = @[@"不限",@"男",@"女"];
    self.ageArr = @[@"不限",@"18岁以下",@" 18-22岁",@"23-26岁",@"27－35岁",@"35岁以上"];
    self.distanceArr = @[@"不限",@"离我最近"];
    self.schoolArr = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark getter
- (UITableView*)mTableView{
    if (_mTableView==nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64) style:UITableViewStylePlain];
        _mTableView.separatorStyle =UITableViewCellSeparatorStyleNone;
        _mTableView.backgroundColor = BackGray_dan;
        _mTableView.delegate =self;
        _mTableView.dataSource = self;
        
    }
    return _mTableView;
}
- (void)hideKeyBoard{
    [self.view endEditing:YES];
}
- (UICollectionView*)genderCollect{
    if (_genderCollect == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellWidth = UISCREENWIDTH/3.6;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        layout.itemSize = CGSizeMake(cellWidth, cellWidth/3);
        layout.sectionInset = UIEdgeInsetsMake(15, (UISCREENWIDTH-3*cellWidth)/4, 15, (UISCREENWIDTH-3*cellWidth)/4);
        _genderCollect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 70) collectionViewLayout:layout];
        _genderCollect.dataSource = self;
        _genderCollect.delegate = self;
        _genderCollect.backgroundColor = BackGray_dan;
        [_genderCollect registerClass:[WPCAreaSelectCell class] forCellWithReuseIdentifier:colletIde];
    }
    return _genderCollect;
}
- (UICollectionView*)ageCollect{
    if (_ageCollect == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellWidth = UISCREENWIDTH/3.6;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        layout.itemSize = CGSizeMake(cellWidth, cellWidth/3);
        layout.sectionInset = UIEdgeInsetsMake(15, (UISCREENWIDTH-3*cellWidth)/4, 15, (UISCREENWIDTH-3*cellWidth)/4);

        _ageCollect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 140) collectionViewLayout:layout];
        _ageCollect.dataSource = self;
        _ageCollect.delegate = self;
        _ageCollect.backgroundColor = BackGray_dan;
        [_ageCollect registerClass:[WPCAreaSelectCell class] forCellWithReuseIdentifier:colletIde];
    }
    return _ageCollect;
}
- (UICollectionView*)sportCollect{
    if (_sportCollect == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellWidth = UISCREENWIDTH/3.6;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        layout.itemSize = CGSizeMake(cellWidth, cellWidth/3);
        layout.sectionInset = UIEdgeInsetsMake(15, (UISCREENWIDTH-3*cellWidth)/4, 15, (UISCREENWIDTH-3*cellWidth)/4);
        _sportCollect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 350) collectionViewLayout:layout];
        _sportCollect.dataSource = self;
        _sportCollect.delegate = self;
        _sportCollect.backgroundColor = BackGray_dan;
        [_sportCollect registerClass:[WPCAreaSelectCell class] forCellWithReuseIdentifier:colletIde];
    }
    return _sportCollect;
}
- (UICollectionView*)schoolCollect{
    if (_schoolCollect == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellWidth = UISCREENWIDTH/3.6;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        layout.itemSize = CGSizeMake(cellWidth, cellWidth/3);
        layout.sectionInset = UIEdgeInsetsMake(15, (UISCREENWIDTH-3*cellWidth)/4, 15, (UISCREENWIDTH-3*cellWidth)/4);
        _schoolCollect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 150) collectionViewLayout:layout];
        _schoolCollect.dataSource = self;
        _schoolCollect.delegate = self;
        _schoolCollect.backgroundColor = BackGray_dan;
        [_schoolCollect registerClass:[WPCAreaSelectCell class] forCellWithReuseIdentifier:colletIde];
    }
    return _schoolCollect;
}
- (UICollectionView*)distanceCollect{
    if (_distanceCollect == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellWidth = UISCREENWIDTH/3.6;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        layout.itemSize = CGSizeMake(cellWidth, cellWidth/3);
        layout.sectionInset = UIEdgeInsetsMake(15, (UISCREENWIDTH-3*cellWidth)/4, 15, (UISCREENWIDTH-3*cellWidth)/4);
        _distanceCollect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 70) collectionViewLayout:layout];
        _distanceCollect.dataSource = self;
        _distanceCollect.delegate = self;
        _distanceCollect.backgroundColor = BackGray_dan;
        [_distanceCollect registerClass:[WPCAreaSelectCell class] forCellWithReuseIdentifier:colletIde];
    }
    return _distanceCollect;
}
- (UITextField*)searSchool{
    if (_searSchool == nil) {
        _searSchool = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, BOUNDS.size.width-20, 30)];
        _searSchool.returnKeyType = UIReturnKeySearch;
        _searSchool.placeholder = @"输入关键字筛选";
        [_searSchool setValue:[UIFont systemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"];
        _searSchool.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mygap, 0)];
        UIImageView *temp = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 26.5, 20)];
        temp.image = [UIImage imageNamed:@"blue_search"];
        _searSchool.leftView = temp;
        _searSchool.leftViewMode = UITextFieldViewModeAlways;
        _searSchool.backgroundColor = [UIColor whiteColor];
        _searSchool.delegate = self;
    }
    return _searSchool;
}
- (UIButton*)searBtn{
    if (_searBtn == nil) {
        _searBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_searBtn setFrame:CGRectMake(self.searSchool.right + mygap, _searSchool.top, 60, 30)];
        [_searBtn setTitleColor:NavgationColor forState:UIControlStateNormal];
        [_searBtn setTitle:@"搜索" forState:UIControlStateNormal];
        [_searBtn setBackgroundColor:[UIColor whiteColor]];
        _searBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _searBtn.layer.borderWidth = 0.5;
        [_searBtn addTarget:self action:@selector(searClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searBtn;
}
-(void)searClick{
    NSLog(@"搜索");
    [_searSchool resignFirstResponder];
}
#pragma mark UITableViewDataSourse
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    if (self.shaixuanType == ShaixuanTypePerson) {
    if (indexPath.section==0) {
        [cell.contentView addSubview:self.genderCollect];
    }
    else if(indexPath.section == 1){
        [cell.contentView addSubview:self.ageCollect];
    }
    else if(indexPath.section == 2){
        [cell.contentView addSubview:self.sportCollect];
    }
    }
    else{
        if (indexPath.section==0) {
            
            UILabel *titlelab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
            titlelab.textAlignment = NSTextAlignmentLeft;
            titlelab.text = @"    学校:";
            titlelab.font = Btn_font;
            [cell.contentView addSubview:titlelab];
            
            cell.detailTextLabel.text = universityName;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.section == 1){
            [cell.contentView addSubview:self.distanceCollect];
        }
        else if(indexPath.section == 2){
            [cell.contentView addSubview:self.sportCollect];
        }

    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 50.0;
    }
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.shaixuanType == ShaixuanTypePerson) {
    if (indexPath.section==0) {
        return self.genderCollect.height;
    }
    else if(indexPath.section==1){
        return self.ageCollect.height;
    }
    else{
        return self.sportCollect.height;
    }
    }
    else{
        if (indexPath.section==0) {
            return 44.0f;
        }
        else if(indexPath.section==1){
            return self.distanceCollect.height;
        }
        else{
            return self.sportCollect.height;
        }

    }
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *lb= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 30)];
    lb.backgroundColor =  [UIColor clearColor];//label必须为透明，label上的子控件才会显示
    lb.userInteractionEnabled = YES;
    lb.font = Btn_font;
    lb.textColor = [UIColor blackColor];
    if (self.shaixuanType == ShaixuanTypePerson) {
    if (section == 0) {
        lb.text = @"    性别:";
    }
    else if (section == 1){
        lb.text = @"    年龄:";
    }
    else{
        lb.text = @"    运动类型:";
    }
    }
    else{
        if (section == 1) {
            lb.text = @"    距离:";
        }
        else if (section == 0){
            lb.text = @"";
            [lb addSubview:self.searSchool];
            //[lb addSubview:self.searBtn];
        }
        else{
            lb.text = @"    运动类型:";
        }

    }
    return lb;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.shaixuanType == ShaixuanTypeTeam) {
        if (indexPath.section == 0&&indexPath.row==0) {
            
            CityListViewController *univerList = [[CityListViewController alloc] init];
            univerList.isUniversityList = YES;
            univerList.title = @"大学选择";
            univerList.chuanBlock = ^(NSArray *arr){
                universityName = arr[0];
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            };
            UINavigationController *navi  =[[UINavigationController alloc] initWithRootViewController:univerList];
            [self presentViewController:navi animated:YES completion:nil];
        }
    }
    else{
        
    }
}
//去掉heaview粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 30;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

#pragma mark UICollectionViewDelegete
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if([collectionView isEqual:_sportCollect])
        return self.itemResource.count;
    else if([collectionView isEqual:_genderCollect]){
        return _genderArr.count;
    }
    else if ([collectionView isEqual:_ageCollect]){
        return _ageArr.count;
    }
    else if([collectionView isEqual:_distanceCollect])
        return _distanceArr.count;
    else
        return _schoolArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WPCAreaSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:colletIde forIndexPath:indexPath];
    if ([collectionView isEqual:_sportCollect]) {
        NSDictionary *dict = [self.itemResource objectAtIndex:indexPath.row];
        cell.backgroundColor = [UIColor whiteColor];
        cell.layer.borderWidth = 0.5;
        cell.layer.borderColor = [RGBACOLOR(215, 215, 215, 1) CGColor];
        cell.titleLab.textColor = RGBACOLOR(135, 136, 136, 1);
        cell.titleLab.text = dict[@"name"];
        if (indexPath.row == [[kUserDefault valueForKey:ksport] integerValue]) {
            cell.backgroundColor = RGBACOLOR(222, 222, 222, 1);
        }
    }
    else{
        NSArray *arr = nil;
        NSString *type= nil;
        if([collectionView isEqual:_genderCollect]){
            arr = _genderArr;
            type = kGender;

        }
        else if ([collectionView isEqual:_ageCollect]){
            arr = _ageArr;
            type = kage;
        }
        else if([collectionView isEqual:_distanceCollect]){
            arr = _distanceArr;
        type = kdistance;
        }
        else{
            arr = _schoolArr;
            type = kschool;
            cell.titleLab.text = arr[indexPath.row];
        }
        if (![collectionView isEqual:_schoolCollect]) {
            cell.titleLab.text = arr[indexPath.row];
        }
        cell.backgroundColor = [UIColor whiteColor];
        cell.layer.borderWidth = 0.5;
        cell.layer.borderColor = [RGBACOLOR(215, 215, 215, 1) CGColor];
        cell.titleLab.textColor = RGBACOLOR(135, 136, 136, 1);
        cell.backgroundColor = [UIColor whiteColor];
        if (indexPath.row == [[kUserDefault valueForKey:type] integerValue]) {
            cell.backgroundColor = RGBACOLOR(222, 222, 222, 1);
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //todo,改变第3个sor标签的内容
    //WPCAreaSelectCell *cell = (WPCAreaSelectCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //同时要记住用户选择这个
    NSString *type= nil;
    if ([collectionView isEqual:_genderCollect]) {
        type = kGender;
        if (indexPath.row == 0) {
            genderType = @"";
        } else if (indexPath.row == 1) {
            genderType = @"XB_0001";
        } else {
            genderType = @"XB_0002";
        }
    }
    else if([collectionView isEqual:_ageCollect]){
        type = kage;
        if (indexPath.row == 0) {
            maxAge = @"";
            minAge = @"";
        } else if (indexPath.row == 1) {
            maxAge = @"17";
            minAge = @"";
        } else if (indexPath.row == 2) {
            maxAge = @"22";
            minAge = @"18";
        } else if (indexPath.row == 3) {
            maxAge = @"26";
            minAge = @"23";
        } else if (indexPath.row == 4) {
            maxAge = @"35";
            minAge = @"27";
        } else if (indexPath.row == 5) {
            maxAge = @"";
            minAge = @"36";
        }
    }
    else if([collectionView isEqual:_sportCollect]){
        type = ksport;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"selectItem" ofType:@"plist"];
        NSArray *arr = [NSArray arrayWithContentsOfFile:path];
        sportType = arr[indexPath.row][@"sport2"];
    }
    else if([collectionView isEqual:_distanceCollect]){
        type = kdistance;

    }
    else if ([collectionView isEqual:_schoolCollect]){
        type = kschool;
    }
       [kUserDefault setValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:type];
    [collectionView reloadData];
}
#pragma mark UITextfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
