//
//  WPCChangeAccountVC.m
//  yuezhan123
//
//  Created by admin on 15/5/20.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCChangePackageVC.h"
#import "WPCChangePhoneVC.h"

@interface WPCChangePackageVC () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableview;

@end

@implementation WPCChangePackageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fakeTheNavigationBar];
    self.view.backgroundColor = UIColorFromRGB(234, 234, 234);
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 84, UISCREENWIDTH, 60) style:UITableViewStylePlain];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.scrollEnabled = NO;
    [self.view addSubview:_tableview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 70, 20)];
    titleLab.textColor = UIColorFromRGB(130, 130, 130);
    [cell.contentView addSubview:titleLab];
    
    UILabel *detailLab = [[UILabel alloc] initWithFrame:CGRectMake(UISCREENWIDTH/2-10, 20, UISCREENWIDTH/2-30, 20)];
    detailLab.textColor = UIColorFromRGB(130, 130, 130);
    [cell.contentView addSubview:detailLab];
    
    if (indexPath.row == 0) {
        titleLab.text = @"手机号";
        if ([[LVTools mToString:[kUserDefault valueForKey:KUserMobile]] length]==11) {
            detailLab.text = [self makeSecretCharater:[LVTools mToString:[kUserDefault valueForKey:KUserMobile]]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else{
            detailLab.text = @"点击进行绑定";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    } else {
        titleLab.text = @"邮箱";
        detailLab.text = [self makeSecretCharater:@"834392246@qq.com"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[LVTools mToString:[kUserDefault valueForKey:KUserMobile]] length]==11) {
        
    }
    else{
    WPCChangePhoneVC *vc = [[WPCChangePhoneVC alloc] init];
        vc.chuanBlock = ^(NSArray *arr){
            [_tableview reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
            self.chuanBlock(nil);
        };
    vc.title = @"手机验证";
    if (indexPath.row == 0) {
        vc.isChangePhone = YES;
    } else {
        vc.isChangePhone = NO;
    }
    [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSMutableString *)makeSecretCharater:(NSString *)str
{
    NSMutableString *mutableStr = [[NSMutableString alloc] initWithFormat:@"%@",str];
    [mutableStr replaceCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    return mutableStr;
}

- (void)fakeTheNavigationBar
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = @"绑定手机";
    
    UIView *naviViwe = [LVTools selfNavigationWithColor:UIColorFromRGB(77, 161, 218) leftBtn:btn rightBtn:nil titleLabel:titleLab];
    [self.view addSubview:naviViwe];
}

- (void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
