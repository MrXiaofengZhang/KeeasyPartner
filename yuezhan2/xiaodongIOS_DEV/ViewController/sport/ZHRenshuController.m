//
//  ZHRenshuController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/4/9.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHRenshuController.h"

@interface ZHRenshuController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *mTableView;
@end

@implementation ZHRenshuController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"参赛人数";
    [self navgationBarLeftReturn];
    
    [self.view addSubview:self.mTableView];
}
- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
}
- (UITableView*)mTableView{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height-64) style:UITableViewStylePlain];
        _mTableView.dataSource = self;
        _mTableView.delegate = self;
    }
    return _mTableView;
}
#pragma mark [代理实现]
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 19;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *zhmyIde= @"zhmycell";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:zhmyIde];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:zhmyIde];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld人",(unsigned long)indexPath.row+2];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(sendMsg:)]) {
        [self.delegate sendMsg:[NSString stringWithFormat:@"%ld人",((unsigned long)indexPath.row+2)]];
    }
    
    [self PopView];
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
