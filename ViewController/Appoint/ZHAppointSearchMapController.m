//
//  ZHAppointSearchMapController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/4/10.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHAppointSearchMapController.h"
#import "ZHNavgationSearchBar.h"
#import "ZHMKPOIView.h"
#import "ZHReverseCode.h"
@interface ZHAppointSearchMapController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *dataArray;
    NSString *searchKey;
    ZHReverseCode *Revercode;
    NSString *latitude;
    NSString *longitude;
    UIView *backGround;
    UIImageView *firstImg;
}
@property (nonatomic,strong) ZHNavgationSearchBar *searchBar;
@property (nonatomic,strong) ZHMKPOIView *mapView;
@property (nonatomic,strong) UITableView *mTableView;
@end

@implementation ZHAppointSearchMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = @"详细地址";
    searchKey = @"场馆";
    Revercode = [[ZHReverseCode alloc] init];
    [self navgationBarLeftReturn];
    dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self navgationbarRrightImg:@"searchbar" WithAction:@selector(searchBar) WithTarget:self];
    [self createView];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([kUserDefault boolForKey:@"notSecondTime"] == NO) {
        backGround = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        backGround.backgroundColor = [UIColor blackColor];
        backGround.alpha = 0.7;
        backGround.userInteractionEnabled = YES;
        [[[UIApplication sharedApplication] keyWindow] addSubview:backGround];
        
        CGFloat rate = 750.0/1134.0;
        firstImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,BOUNDS.size.width, BOUNDS.size.width/rate)];
        firstImg.image = [UIImage imageNamed:@"guide1"];
        firstImg.userInteractionEnabled = YES;
        firstImg.contentMode = UIViewContentModeScaleAspectFit;
        [[[UIApplication sharedApplication] keyWindow] addSubview:firstImg];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disappearFirstImg:)];
        [backGround addGestureRecognizer:tap];
        [firstImg addGestureRecognizer:tap];
    }

}
- (void)disappearFirstImg:(UIGestureRecognizer *)gesture {
    [firstImg removeFromSuperview];
    firstImg = nil;
    [backGround removeFromSuperview];
    backGround = nil;
    [kUserDefault setBool:YES forKey:@"notSecondTime"];
}
- (void)loadDefaultdata{
    
    _mapView.SearchKey=searchKey;
    __weak NSMutableArray *weakDataarray =dataArray;
    __weak UITableView *weakTableView = _mTableView;
    __weak ZHReverseCode *weakRevercode = Revercode;
    __weak typeof(self) weakSelf = self;
    __weak NSString *weakCity = _cityMeaning;
    __weak NSString *weakAdress = _address;
    //__weak typeof(_mapView) weakMap = _mapView;
    
    _mapView.chuanBlock=^(NSArray * arr ,NSString *errorInfo)
    {
        if (_mapView.nearby.pageIndex==0) {
            [weakDataarray removeAllObjects];
        }
        if (errorInfo) {
            [weakSelf showHint:errorInfo];
            [weakTableView reloadData];
            return ;
        }
        NSLog(@"arr ===== %@",arr);
        for (NSDictionary *dic in arr) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:dic];
            [weakRevercode shareReverseCodeWithLongitude:[dic objectForKey:@"longitude"] WithLatitude:[dic objectForKey:@"latitude"] With:^(NSString *string) {
                [dict setObject:string forKey:@"adress"];
                
            }];
            [weakDataarray addObject:dict];
        }
        //[weakSelf hideHud];
        [weakTableView reloadData];
        //重置中心点
        [weakRevercode shareForwardCodeWithCityName:weakCity AndAddress:weakAdress With:^(NSDictionary *dic) {
            //
            NSLog(@"%@",dic);
//           [weakMap.mapView setCenterCoordinate:CLLocationCoordinate2DMake([[dic objectForKey:@"latitude"] doubleValue], [[dic objectForKey:@"longitude"] doubleValue]) animated:YES];
        }];
    };
    [Revercode shareForwardCodeWithCityName:self.cityMeaning AndAddress:self.address With:^(NSDictionary *dic) {
        latitude = [dic objectForKey:@"latitude"];
        longitude = [dic objectForKey:@"longitude"];
        [_mapView poiSearchNearbyWithLatitude:latitude WithLongitude:longitude WithRadius:@"10"];//获得某个点范围的
    }];

    
}
- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark UItextfieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length !=0) {
    searchKey = textField.text;
    _mapView.nearby.pageIndex = 0;
    [self loadDefaultdata];
    }
    [textField resignFirstResponder];
    [_searchBar.searchView removeFromSuperview];
    [_searchBar removeFromSuperview];
    return YES;
}
- (void)createView{
    [self showHudInView:self.view hint:@"搜索中..."];
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.mTableView];
    [self loadDefaultdata];
}
#pragma mark getter
- (ZHNavgationSearchBar*)searchBar{
    if (_searchBar == nil) {
        _searchBar =[[ZHNavgationSearchBar alloc]init];
        _searchBar.searchTextField.delegate=self;
    }
    _searchBar.searchTextField.placeholder = @"输入场馆名称或详细地址";
    [_searchBar.searchTextField becomeFirstResponder];
    [self.view addSubview:_searchBar.searchView];
    [self.navigationController.navigationBar addSubview:_searchBar];
        return _searchBar;
}
- (ZHMKPOIView*)mapView{
    if (_mapView == nil) {
        _mapView = [[ZHMKPOIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height*0.4)];
          }
    return _mapView;
}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _mapView.bottom, BOUNDS.size.width, BOUNDS.size.height-_mapView.bottom-64) style:UITableViewStylePlain];
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
    }
    return _mTableView;
}
#pragma mark UItableViewdatasourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [dataArray count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *strIde = @"strIde";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:strIde];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:strIde];
    }
    NSDictionary *dic = [dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text =[NSString stringWithFormat:@"%ld,%@",(unsigned long)indexPath.row+1,[dic objectForKey:@"title"]];
    cell.detailTextLabel.text =[dic objectForKey:@"address"];
    NSLog(@"%@",[NSString stringWithFormat:@"longitude%@,latitude%@",[dic objectForKey:@"longitude"],[dic objectForKey:@"latitude"]]);
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *selectDic= [dataArray objectAtIndex:indexPath.row];
    self.chuanBlock([NSArray arrayWithObjects:[selectDic objectForKey:@"address"],[selectDic objectForKey:@"longitude"],[selectDic objectForKey:@"latitude"],[selectDic objectForKey:@"title"], nil]);
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
