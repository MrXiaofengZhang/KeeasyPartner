//
//  SelfInforAddrZhViewController.m
//  yuezhan123
//
//  Created by zhoujin on 15/3/30.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "SelfInforAddrZhViewController.h"

@interface SelfInforAddrZhViewController ()
{

    UITableView *_tableView;
    NSMutableArray *_dataArray;

}
@end

@implementation SelfInforAddrZhViewController
-(void)loadData
{
    [self showHudInView:self.view hint:@"地址加载中..."];
    _dataArray=[[NSMutableArray alloc]init];
    NSMutableDictionary *dic=[LVTools getTokenApp];
    [dic setObject:self.regionid forKey:@"regionId"];
    [DataService requestWeixinAPI:getarea parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSDictionary *dic=(NSDictionary *)result;
        NSLog(@"dic=%@",dic);
        if ([[dic objectForKey:@"statusCodeInfo"] isEqualToString:@"提示信息"])
        {
            [self hideHud];
            NSArray *array=[dic objectForKey:@"regionsList"];
          
            for (NSDictionary *dic in array) {
                  AreaModel *model=[[AreaModel alloc]init];
                [model setValuesForKeysWithDictionary:dic];
                [_dataArray addObject:model];
            }
        }
        else
        {
            [self hideHud];
            [self showHint:@"地址加载失败,请重试！"];
        }
        [_tableView reloadData];

    }];
  
    

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeUI];
    [self loadData];
    [self navgationBarLeftReturn];
    
   
    // Do any additional setup after loading the view.
}
- (void)PopView{
  
    [self.areaArray removeLastObject];
    [self.areaArray removeLastObject];
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)makeUI
{
    if (self.areaArray.count==4) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(areacommint) forControlEvents:UIControlEventTouchUpInside];
        button.frame=CGRectMake(0, 0,40, 40);
        UIBarButtonItem  *barbutton=[[UIBarButtonItem alloc]initWithCustomView:button];
        self.navigationItem.rightBarButtonItem=barbutton;
    
    }
    
    _tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT-20-44) style:UITableViewStylePlain];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    [self.view addSubview:_tableView];
}
#pragma mark-UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   static NSString *CELL=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CELL];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
    }
    AreaModel *model=[_dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text=[model valueForKey:@"regionname"];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    AreaModel  *model=[_dataArray objectAtIndex:indexPath.row];
        if (!self.areaArray)
    {
        self.areaArray=[[NSMutableArray alloc]init];
    }
    if([model.regionname isEqualToString:@"台湾省"]||[model.regionname isEqualToString:@"香港特别行政区"]||[model.regionname isEqualToString:@"澳门特别行政区"])
    {
        [self.areaArray addObject:[model valueForKey:@"regionid"]];
        [self.areaArray addObject:[model valueForKey:@"regionname"]];
        self.chuanBlock(self.areaArray);
        [self.navigationController popViewControllerAnimated:YES];
        return;
        
    }

    if ( self.areaArray.count==4)
    {

        [self.areaArray addObject:[model valueForKey:@"regioncode"]];
        [self.areaArray addObject:model.regionname];

        return;
        
    }
    else if ( self.areaArray.count==6)
    {
        [self.areaArray removeLastObject];
        [self.areaArray removeLastObject];
        [self.areaArray addObject:[model valueForKey:@"regioncode"]];
        [self.areaArray addObject:[model valueForKey:@"regionname"]];
        return;
        
    }
    SelfInforAddrZhViewController *addr=[[SelfInforAddrZhViewController alloc]init];
    addr.title=@"区域";
   
   
    [self.areaArray addObject:[model valueForKey:@"regionid"]];
    [self.areaArray addObject:[model valueForKey:@"regionname"]];
    addr.chuanBlock=^(NSArray *arr){
    
        self.chuanBlock(arr);
    
    };
    
    addr.areaArray=self.areaArray;
    addr.regionid=[model valueForKey:@"regionid"];
//    addr.popBlock=^(){
//        
//        if (self.areaArray.count==6) {
//            for (int i=0; i<4; i++) {
//                 [self.areaArray removeLastObject];
//            }
//        }
//        else
//        {
//             [self.areaArray removeLastObject];
//             [self.areaArray removeLastObject];
//        }
//       
//       
//        
//        [self.navigationController popViewControllerAnimated:YES];
//            };
    [self.navigationController pushViewController:addr animated:YES];

}
-(void)areacommint
{
    if (self.areaArray.count==6) {
        UIViewController *viewController=[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-4];
        self.chuanBlock(self.areaArray);
        [self.navigationController popToViewController:viewController animated:YES];
        
    }
    
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
