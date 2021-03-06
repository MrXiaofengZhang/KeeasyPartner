//
//  PhoneListController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 16/3/3.
//  Copyright © 2016年 LV. All rights reserved.
//
#define kADDRESSLIST_TAB_CELL_HEIGHT 85/2
#define kADDRESSLIST_TAB_HEADER_HEIGHT 62/2
#define kADDRESSLIST_TAB_CELL_DETAIL_BTN_TAG 101

//屏幕宽
#define SCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width

#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height


#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#import "PhoneListController.h"
#import <AddressBook/AddressBook.h>
//#import <AddressBookUI/AddressBookUI.h>
#import "pinyin.h"
#import "ChineseString.h"
#import "CoShuXing.h"
#import "SearchCoreManager.h"
#import "PhoneManaddCell.h"
#import "FriendListModel.h"
#import "WPCFriednMsgVC.h"
#import "LVSportViewController.h"
@interface PhoneListController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    NSMutableArray *_resultArray;
    
    UISearchDisplayController *_disPlayVC;
    
    UITableView *_tableView;
    
    NSMutableArray *_addressBookTemp;
    
    UISearchBar *_searchBar;

    NSMutableArray *_phoneArray;
    
    NSMutableArray *_infoArray;
}
@property (nonatomic, strong)NSMutableArray *dataArr;

@property (nonatomic, strong)NSMutableArray *sortedArrForArrays;//sort:分类

@property (nonatomic, strong)NSMutableArray *sectionHeadsKeys;

@property (nonatomic, strong)NSMutableArray *friendsArr;

@property (nonatomic, strong)UITableView *resultTableView;

@property (nonatomic, strong) NSMutableDictionary *contactDic;

@property (nonatomic, strong) NSMutableArray *searchByName;

@property (nonatomic, strong) NSMutableArray *searchByPhone;


@end

@implementation PhoneListController
@synthesize dataArr =_dataArr;
@synthesize sortedArrForArrays =_sortedArrForArrays;
@synthesize sectionHeadsKeys =_sectionHeadsKeys;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"手机联系人";
    [self navgationBarLeftReturn];
    if (self.hasRightBtn) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(okOnClick)];
    }
    _addressBookTemp = [NSMutableArray array];
    
    _phoneArray = [NSMutableArray array];
    
    
    self.searchByName = [[NSMutableArray alloc]init];
    self.searchByPhone = [[NSMutableArray alloc]init];
    self.contactDic = [[NSMutableDictionary alloc]init];
    
    //获得通讯录信息
    [self getAddressList];
    
    //获得数据询问用户是否允许访问通讯录
    
    [self getSectionAndCellData];
    
    //创建tableView
    [self createTableView];

}
- (void)okOnClick{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark   create method
- (void)getAddressList{
    //iOS6之前
//    addBook =ABAddressBookCreate();
    //iOS6之后
    //app是否获得通讯录授权
    int __block tip = 0;
    ABAddressBookRef addressBooks = nil;
    
    addressBooks =  ABAddressBookCreateWithOptions(NULL, NULL);
    //获取通讯录权限
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error) {
        if (!granted) {
            tip = 1;
        }
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    if(tip){
        //用户拒绝访问通讯录
        UILabel *tipLb = [[UILabel alloc] initWithFrame:CGRectMake(mygap*2, 0, BOUNDS.size.width-4*mygap, 50)];
        tipLb.center = self.view.center;
        tipLb.numberOfLines = 0;
        tipLb.textColor = [UIColor lightGrayColor];
        tipLb.text = @"请您设置允许APP访问您的通讯录\n设置>隐私>通讯录";
        tipLb.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:tipLb];
    }
    else{
    //获取通讯录中的所有人
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    
    //通讯录中人数
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBooks);
        [kUserDefault setObject:[NSNumber numberWithInteger:nPeople] forKey:PhoneListCount];
        [kUserDefault synchronize];
        ((LVSportViewController*)[((UINavigationController*)[self.navigationController.tabBarController.viewControllers objectAtIndex:0]).viewControllers objectAtIndex:0]).newPeopleCount=0;
    for(NSInteger i = 0; i < nPeople; i++)
    {
        //创建一个addressBook shuxing类
        CoShuXing *addressBook = [[CoShuXing alloc] init];
        addressBook.localID = [NSNumber numberWithInteger:i];
        
        //获取个人
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        //获取个人名字
        CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        CFStringRef abFullName = ABRecordCopyCompositeName(person);
        NSString *nameString = (__bridge NSString *)abName;
        NSString *lastNameString = (__bridge NSString *)abLastName;
        if ((__bridge id)abFullName != nil) {
            nameString = (__bridge NSString *)abFullName;
        } else {
            if ((__bridge id)abLastName != nil)
            {
                nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastNameString];
            }
        }
        if(!nameString)
        {
            if (abName) CFRelease(abName);
            if (abLastName) CFRelease(abLastName);
            if (abFullName) CFRelease(abFullName);
            continue;
        }
        
        addressBook.name = nameString;
        
        addressBook.recordID = (int)ABRecordGetRecordID(person);
        
        ABPropertyID multiProperties[] = {
            
            kABPersonPhoneProperty,
            
            kABPersonEmailProperty
            
        };
        
        NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
        
        for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
            
            ABPropertyID property = multiProperties[j];
            
            ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
            
            NSInteger valuesCount = 0;
            
            if (valuesRef != nil) valuesCount = ABMultiValueGetCount(valuesRef);
            
            if (valuesCount == 0) {
                
                CFRelease(valuesRef);
                continue;
            }
            
            
            for (NSInteger k = 0; k < valuesCount; k++) {
                
                CFTypeRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                
                switch (j) {
                        
                    case 0: {// Phone number
                        
                        addressBook.tel = [[NSMutableArray alloc]initWithObjects:[[self mToString: (__bridge NSString*)value] stringByReplacingOccurrencesOfString:@"-" withString:@""],nil];
                        
                        break;
                    }
                    case 1: {// Email
                        
                        addressBook.email =[self mToString: (__bridge NSString*)value];
                        
                        break;
                    }
                    case 2:{
                        addressBook.birthday = [self mToString:(__bridge NSString*)value];
                    }
                }
                
                CFRelease(value);
                
            }
            
            CFRelease(valuesRef);
            
        }
        /****************将个人信息添加到数组中********************/
        
        //循环完成后addressBookTemp中包含所有联系人的信息
        if ([LVTools mToString: [addressBook.tel lastObject]].length==11) {
        [self.contactDic setObject:addressBook forKey:addressBook.localID];
        [_addressBookTemp addObject:addressBook];
        [[SearchCoreManager share] AddContact:addressBook.localID name:addressBook.name phone:addressBook.tel];
        [_phoneArray addObject:[addressBook.tel lastObject]];
        }
        }
        
    [self requestData];
    }
}
- (void)requestData{
    NSMutableDictionary *paramDic = [LVTools getTokenApp];
    [paramDic setObject:_phoneArray forKey:@"mobiles"];
    NSLog(@"paramDic+++%@",paramDic);
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:getUsersByMobiles parsms:@{@"param":[LVTools configDicToDES:paramDic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"------%@",result);
        NSArray *array = result[@"data"][@"users"];
        if ([result[@"status"] boolValue]&&array) {
            
            if (array.count>0&&_infoArray==nil) {
                _infoArray = [NSMutableArray array];
            
            for (NSInteger i=0; i<array.count; i++) {
                FriendListModel *model = [[FriendListModel alloc] init];
                [model setValuesForKeysWithDictionary:array[i]];
                //这里用selected属性表示是否好友
                model.selected = [self didBuddyExist:[LVTools mToString: model.userId]];
                [_infoArray addObject:model];
            }
                //将手机号存在本地用来判断是否有新的联系人
                
            }
            [_tableView reloadData];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
//判断是否已经发送了申请加好友请求
- (BOOL)hasSendBuddyRequest:(NSString *)buddyName
{
    NSArray *buddyList = [[[EaseMob sharedInstance] chatManager] buddyList];
    for (EMBuddy *buddy in buddyList) {
        if ([buddy.username isEqualToString:buddyName] &&
            buddy.followState == eEMBuddyFollowState_NotFollowed &&
            buddy.isPendingApproval) {
            return YES;
        }
    }
    return NO;
}
//判断是否在好友列表中
- (BOOL)didBuddyExist:(NSString *)buddyName
{
    NSArray *buddyList = [[[EaseMob sharedInstance] chatManager] buddyList];
    
    for (EMBuddy *buddy in buddyList) {
//        NSLog(@"%@",buddy.username);
        if ([buddy.username isEqualToString:buddyName] &&
            buddy.followState != eEMBuddyFollowState_NotFollowed) {
            return YES;
        }
    }
    return NO;
}

// 获得区头和单元格的数据
- (void)getSectionAndCellData {
    
    
    _dataArr = [[NSMutableArray alloc] init];
    
    
    _sortedArrForArrays = [[NSMutableArray alloc] init];
    
    
    _sectionHeadsKeys = [[NSMutableArray alloc] init];//initialize a array to hold keys like A,B,C ...
    
    for (int i = 0; i < [_addressBookTemp count]; i++) {
        
        CoShuXing *user = [_addressBookTemp objectAtIndex:i];
        
        [_dataArr addObject:user.name];
        
    }
    
    self.sortedArrForArrays = [self getChineseStringArr:_dataArr];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent=NO;
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [_searchBar resignFirstResponder];
    self.navigationController.navigationBar.translucent=YES;
    
}
- (void)createTableView
{
    // 添加 搜索栏
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    _searchBar.delegate=self;
    [self.view addSubview:_searchBar];
    _disPlayVC=[[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
    _disPlayVC.delegate=self;
    _disPlayVC.searchResultsTableView.dataSource=self;        // 通讯录表
    _disPlayVC.searchResultsTableView.delegate = self;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT-104) style:UITableViewStylePlain];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
    
    _tableView.dataSource =self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if ([self.sortedArrForArrays count]!=0) {
        [self.view addSubview:_tableView];
    }
    else{
        UILabel *emptyLb=[[UILabel alloc]initWithFrame:CGRectMake(20, 20, SCREEN_WIDTH-40, 44)];
        emptyLb.textAlignment=NSTextAlignmentCenter;
        emptyLb.numberOfLines=2;
        emptyLb.textColor = [UIColor colorWithWhite:0.45 alpha:0.8];
        emptyLb.font=[UIFont systemFontOfSize:12];
        emptyLb.center=self.view.center;
        emptyLb.text=@"您的通讯录为空,或检查“设置－隐私－通讯录”是否开启通讯录权限";
        [self.view addSubview:emptyLb];
    }
    
    
    if ([_tableView respondsToSelector:@selector(setSectionIndexColor:)]) {
        _tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        _tableView.sectionIndexColor = [UIColor clearColor];
    }
    
}

//查询
-(void)relustByText:(NSString*)str
{
    if (_resultArray==nil) {
        _resultArray=[[NSMutableArray alloc]init];
    }
    [_resultArray removeAllObjects];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",str];
    NSArray *array =[_dataArr filteredArrayUsingPredicate:pred];
    [_resultArray addObjectsFromArray:array];
    [_disPlayVC.searchResultsTableView reloadData];
}

#pragma mark  UISearchBarDelegate
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    
    [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
    for(UIView *subView in self.searchDisplayController.searchBar.subviews){
        
        if([subView isKindOfClass:UIButton.class]){
            [(UIButton*)subView setTitle:@"取消" forState:UIControlStateNormal];
        }
    }
}

// 开始编辑时调用
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [UIView animateWithDuration:0.5 animations:^{
        _searchBar.frame = CGRectMake(0, 20, SCREEN_WIDTH, searchBar.frame.size.height);
        _tableView.frame=CGRectMake(0, 64, SCREEN_WIDTH, _tableView.frame.size.height);
    }];
}// called when text starts editing
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    //[self relustByText:searchText];
    
    [[SearchCoreManager share] Search:searchText searchArray:nil nameMatch:_searchByName phoneMatch:self.searchByPhone];
    
    [_resultTableView reloadData];
    
    
    
}// called when text changes (including clear)

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [UIView animateWithDuration:0.5 animations:^{
        _searchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, searchBar.frame.size.height);
        _tableView.frame=CGRectMake(0, 44, SCREEN_WIDTH, _tableView.frame.size.height);
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [_tableView reloadData];
    _tableView.userInteractionEnabled = YES;
    
}// called when keyboard search button pressed

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    
    _tableView.userInteractionEnabled = YES;
}// called when cancel button pressed
#pragma mark  searchBarClick
- (void)searchBarClick{
    
    _tableView.userInteractionEnabled = YES;
    
}
#pragma mark  UITableViewDelegate
//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
//设置区头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([tableView isEqual:_tableView]) {
        
        
        return kADDRESSLIST_TAB_HEADER_HEIGHT;
    }
    else{
        return 0.0f;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([tableView isEqual:_tableView]) {
        ChineseString *userInfo = [[self.sortedArrForArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSLog(@"%@-%@",userInfo.string,userInfo.tel);
        if (userInfo.tel.length==11&&[LVTools isValidateMobile:userInfo.tel]) {
            //是手机号
            FriendListModel *model = [self configByMobile:userInfo.tel];
            if (model) {
                WPCFriednMsgVC *msgVc =[[WPCFriednMsgVC alloc] init];
                msgVc.uid = [LVTools mToString:model.userId];
                [self.navigationController pushViewController:msgVc animated:YES];
            }
            else{
                [self show:@"TA还未开通校动\n消息将会以免费短信的形式到达对方" icon:@"sadface" view:self.view];
            }
        }
        else{
            
        }
    }
    else{
        
    }
}
#pragma mark
#pragma mark UITableViewDataSource
#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:_tableView]) {
        
        return [[self.sortedArrForArrays objectAtIndex:section] count];
    }
    else{
        if ([_searchBar.text length] <= 0) {
            return [self.contactDic count];
        } else {
            return [self.searchByName count] + [self.searchByPhone count];
        }
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:_tableView]) {
        
        return [self.sortedArrForArrays count];
    }
    else{
        return 1;
    }
    
}
//为section添加标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if ([tableView isEqual:_tableView]) {
        
        return [_sectionHeadsKeys objectAtIndex:section];
    }
    else{
        return nil;
    }
}
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
//    if ([tableView isEqual:_tableView]) {
//        
//        return self.sectionHeadsKeys;
//    }
//    else{
//        return nil;
//    }
//    
//}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([_tableView isEqual:tableView]) {
        
        
        UILabel *lb=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        lb.text=[NSString stringWithFormat:@"  %@", [self.sectionHeadsKeys objectAtIndex:section]];
        lb.backgroundColor = RGBACOLOR(245, 245, 245, 1);
        return lb;
    }
    else{
        return nil;
    }
}
//创建tableView的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId =@"CellId";
    
    PhoneManaddCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell ==nil) {
        cell = [[PhoneManaddCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    }
   
    if ([_tableView isEqual:tableView]) {
        
        
        if ([self.sortedArrForArrays count] > indexPath.section){
            
            NSArray *arr = [self.sortedArrForArrays objectAtIndex:indexPath.section];
            
            if ([arr count] > indexPath.row){
                
                
                ChineseString *userNameStr = (ChineseString *) [arr objectAtIndex:indexPath.row];
                
                
                cell.textLabel.text = userNameStr.string;
                [cell.imageView setImage:[UIImage imageNamed:@"plhor_2"]];
                cell.detailTextLabel.text = userNameStr.tel;
                cell.addBtn.tag = 1000*indexPath.section+indexPath.row;
                [cell.addBtn addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
                if (_infoArray) {
                    FriendListModel *model =[self configByMobile:userNameStr.tel];
                    if (model) {
                        
                        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,model.path]] placeholderImage:[UIImage imageNamed:@"plhor_2"]];
                        cell.detailTextLabel.text = model.nickName;
                        if (model.selected) {
                            cell.addBtn.enabled = NO;
                        }
                        else{
                            cell.addBtn.enabled = YES;
                        }
                    }
                    else{
                        cell.addBtn.enabled = YES;
                    }
                }
            } else {
                cell.addBtn.enabled = YES;
                NSLog(@"arr out of range");
            }
            
        } else {
            
            NSLog(@"sortedArrForArrays out of range");
            
        }
    }
    else{
        if ([_searchBar.text length] <= 0) {
            CoShuXing *contact = [[self.contactDic allValues] objectAtIndex:indexPath.row];
            cell.textLabel.text = contact.name;
            cell.detailTextLabel.text = @"";
            return cell;
        }
        
        NSNumber *localID = nil;
        NSMutableString *matchString = [NSMutableString string];
        NSMutableArray *matchPos = [NSMutableArray array];
        if (indexPath.row < [_searchByName count]) {
            localID = [self.searchByName objectAtIndex:indexPath.row];
            
            //姓名匹配 获取对应匹配的拼音串 及高亮位置
            if ([_searchBar.text length]) {
                [[SearchCoreManager share] GetPinYin:localID pinYin:matchString matchPos:matchPos];
            }
        } else {
            localID = [self.searchByPhone objectAtIndex:indexPath.row-[_searchByName count]];
            NSMutableArray *matchPhones = [NSMutableArray array];
            
            //号码匹配 获取对应匹配的号码串 及高亮位置
            if ([_searchBar.text length]) {
                [[SearchCoreManager share] GetPhoneNum:localID phone:matchPhones matchPos:matchPos];
                [matchString appendString:[matchPhones objectAtIndex:0]];
            }
        }
        CoShuXing *contact = [self.contactDic objectForKey:localID];
//        NSLog(@"%@",contact);
        cell.textLabel.text = contact.name;
        cell.detailTextLabel.text = matchString;
        //cell.textLabel.text=[_resultArray objectAtIndex:indexPath.row];
    }
    return cell;
}
- (void)addFriend:(UIButton*)btn{
    if (btn.selected==NO) {
        
        btn.selected = YES;
    ChineseString *userInfo = [[self.sortedArrForArrays objectAtIndex:btn.tag/1000] objectAtIndex:btn.tag%1000];
    NSLog(@"%@-%@",userInfo.string,userInfo.tel);
    if (userInfo.tel.length==11&&[LVTools isValidateMobile:userInfo.tel]) {
        //是手机号
    FriendListModel *model = [self configByMobile:userInfo.tel];
    if (model) {
        [self applyAddFriendByMobile:[LVTools mToString:model.userId] withIndex:[NSIndexPath indexPathForRow:btn.tag/1000 inSection:btn.tag%1000]];
    }
    else{
        [self sendMessageByServerWithMobile:userInfo.tel withIndex:[NSIndexPath indexPathForRow:btn.tag/1000 inSection:btn.tag%1000]];
    }
    }
    else{
        [self show:@"仅支持手机" icon:@"sadface" view:self.view];
    }
    }
}
/** 注册过的直接添加发送环信好友申请*/
- (void)applyAddFriendByMobile:(NSString*)mobile withIndex:(NSIndexPath*)index{
    //环信申请添加好友
    [self showHudInView:self.view hint:NSLocalizedString(@"friend.sendApply", @"sending application...")];
    EMError *error;
    [[EaseMob sharedInstance].chatManager addBuddy:[LVTools mToString: mobile] message:@"申请添加你为好友" error:&error];
    [self hideHud];
    if (error) {
        [self showHint:NSLocalizedString(@"friend.sendApplyFail", @"send application fails, please operate again")];
    }
    else{
//        [self showHint:NSLocalizedString(@"friend.sendApplySuccess", @"send successfully")];
        [_tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
    }

}
/**未注册的直接后台发短信*/
- (void)sendMessageByServerWithMobile:(NSString*)mobile withIndex:(NSIndexPath*)index{
    NSMutableDictionary *paramDic = [LVTools getTokenApp];
    [paramDic setObject:mobile forKey:@"mobile"];
    NSLog(@"paramDic+++%@",paramDic);
    [self showHudInView:self.view hint:LoadingWord];
    [DataService requestWeixinAPI:sendInvitationMessage parsms:@{@"param":[LVTools configDicToDES:paramDic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"------%@",result);
        if ([result[@"status"] boolValue]) {
//         [_tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
        }
        else{
//            [self showHint:ErrorWord];
        }
    }];
}
- (FriendListModel*)configByMobile:(NSString*)mobile{
    for (FriendListModel *model in _infoArray) {
        if ([mobile isEqualToString:model.mobile]) {
            return model;
        }
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    // 获得所点button的cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSLog(@"cell.textLabel.text_____%@",cell.textLabel.text);
    
    for (int i = 0; i < [_addressBookTemp count]; i++) {
        
        CoShuXing *user = [_addressBookTemp objectAtIndex:i];
        
        if ([user.name isEqualToString:cell.textLabel.text]) {
            
            //***********************获得点击通讯录中的信息********************//
            NSLog(@"user.name____%@;\n user.tel____%@;\n user.Email____%@",user.name,[user.tel firstObject],user.email);
            
            //[WCAlertView showAlertWithTitle:user.name message:[NSString stringWithFormat:@"电话%@\n邮箱%@",[XUtil mToString: user.tel],[XUtil mToString:user.email]] customizationBlock:nil completionBlock:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        }
    }
    
}
#pragma mark   - 获取首字母,将填充给cell的值按照首字母排序  -

- (NSMutableArray *)getChineseStringArr:(NSMutableArray *)arrToSort{
    
    
    NSMutableArray *chineseStringsArray = [NSMutableArray array];
    
    for(int i =0; i < [arrToSort count]; i++){
        
        ChineseString *chineseString=[[ChineseString alloc] init];
        
        chineseString.string = [NSString stringWithString:[arrToSort objectAtIndex:i]];
        
        if(chineseString.string == nil)
        {
            chineseString.string = @"";
        }
        
        if(![chineseString.string isEqualToString:@""])
        {
            
            NSString *pinYinResult = [NSString string];
            
            
            for(int j = 0;j < chineseString.string.length; j++)
            {
                NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c", pinyinFirstLetter([chineseString.string characterAtIndex:j])] uppercaseString];
                
                pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
                
            }
            chineseString.pinYin = pinYinResult;
        } else {
            chineseString.pinYin = @"";
        }
        CoShuXing *infoBean = [self getInfoByName:chineseString.string];
        if ([infoBean.tel lastObject]) {
            chineseString.tel = [infoBean.tel lastObject];
        }
        
        [chineseStringsArray addObject:chineseString];
        
    }
    
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinYin"ascending:YES]];
    
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    NSMutableArray *arrayForArrays = [NSMutableArray array];
    
    BOOL checkValueAtIndex = NO; //flag to check
    
    NSMutableArray *TempArrForGrouping = nil;
    
    for(int index = 0; index < [chineseStringsArray count]; index++) {
        
        ChineseString *chineseStr = (ChineseString *)[chineseStringsArray objectAtIndex:index];
        
        NSMutableString *strchar = [NSMutableString stringWithString:chineseStr.pinYin];
        
        NSString *sr= [strchar substringToIndex:1];
        
        if(![_sectionHeadsKeys containsObject:[sr uppercaseString]]) {
            
            [_sectionHeadsKeys addObject:[sr uppercaseString]];
            
            TempArrForGrouping = [[NSMutableArray alloc]initWithCapacity:0];
            
            checkValueAtIndex = NO;
            
        }
        
        if([_sectionHeadsKeys containsObject:[sr uppercaseString]]) {
            
            [TempArrForGrouping addObject:[chineseStringsArray objectAtIndex:index]];
            
            if(checkValueAtIndex == NO){
                
                [arrayForArrays addObject:TempArrForGrouping];
                
                checkValueAtIndex = YES;
            }
        }
    }
    return arrayForArrays;
    
}
- (CoShuXing*)getInfoByName:(NSString*)name{
    for (NSInteger i=0; i<_addressBookTemp.count; i++) {
        CoShuXing *infoBean = [_addressBookTemp objectAtIndex:i];
        if ([infoBean.name isEqualToString:name]) {
            return infoBean;
        }
    }
    return nil;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    _tableView.userInteractionEnabled = YES;
    [self.view endEditing:YES];
    
}

- (NSString *)mToString:(id)obj
{
    if (obj == [NSNull null]) {
        return @"";
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    return [obj stringValue];
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
