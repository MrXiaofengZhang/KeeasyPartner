/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "ChatGroupDetailViewController.h"

#import "ZHInviteFriendController.h"
#import "GroupSettingViewController.h"
#import "EMGroup.h"
#import "ContactView.h"
#import "GroupBansViewController.h"
#import "GroupSubjectChangingViewController.h"
#import "NearByModel.h"
#import "ZHupdateImage.h"
#import "WPCFriednMsgVC.h"
#import "ZHJubaoController.h"
#pragma mark - ChatGroupDetailViewController
#define kColOfRow 6
#define kContactSize 60.f

@interface ChatGroupDetailViewController ()<IChatManagerDelegate, UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    UIImageView *img;
}

- (void)unregisterNotifications;
- (void)registerNotifications;

@property (nonatomic) GroupOccupantType occupantType;
@property (strong, nonatomic) EMGroup *chatGroup;

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *addButton;

@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIButton *clearButton;
@property (strong, nonatomic) UIButton *exitButton;
@property (strong, nonatomic) UIButton *dissolveButton;
@property (strong, nonatomic) UIButton *configureButton;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;
@property (strong, nonatomic) ContactView *selectedContact;

- (void)dissolveAction;
- (void)clearAction;
- (void)exitAction;
- (void)configureAction;

@end

@implementation ChatGroupDetailViewController

- (void)registerNotifications {
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterNotifications {
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    
}

- (void)dealloc {
    [self unregisterNotifications];
}

- (instancetype)initWithGroup:(EMGroup *)chatGroup
{
    self = [super init];
    if (self) {
        // Custom initialization
        _chatGroup = chatGroup;
        _dataSource = [NSMutableArray array];
        _occupantType = GroupOccupantTypeMember;
        [self registerNotifications];
    }
    return self;
}

- (instancetype)initWithGroupId:(NSString *)chatGroupId
{
    EMGroup *chatGroup = nil;
    NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
    for (EMGroup *group in groupArray) {
        if ([group.groupId isEqualToString:chatGroupId]) {
            chatGroup = group;
            break;
        }
    }
    
    if (chatGroup == nil) {
        chatGroup = [EMGroup groupWithId:chatGroupId];
    }
    
    self = [self initWithGroup:chatGroup];
    if (self) {
        //
    }
    
    return self;
}
- (void)PopView{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(PopView)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(PopView)];
    
    self.tableView.tableFooterView = self.footerView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = BackGray_dan;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupBansChanged) name:@"GroupBansChanged" object:nil];
    
//    [[EaseMob sharedInstance].chatManager asyncChangeGroupSubject:@"xieyajie test345678" forGroup:@"1409903855656" completion:^(EMGroup *group, EMError *error) {
//        NSLog(@"%@", group.groupSubject);
//        if (!error) {
//            [self fetchGroupInfo];
//        }
//    } onQueue:nil];
    
    [self fetchGroupInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - getter

- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, kContactSize)];
        _scrollView.tag = 0;
        _scrollView.backgroundColor = [UIColor whiteColor];
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kContactSize - 10, kContactSize - 10)];
        [_addButton setImage:[UIImage imageNamed:@"addImg"] forState:UIControlStateNormal];
        [_addButton setImage:[UIImage imageNamed:@"addImg"] forState:UIControlStateHighlighted];
        [_addButton addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
        
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteContactBegin:)];
        _longPress.minimumPressDuration = 0.5;
    }
    
    return _scrollView;
}

- (UIButton *)clearButton
{
    if (_clearButton == nil) {
        _clearButton = [[UIButton alloc] init];
        [_clearButton setTitle:NSLocalizedString(@"group.removeAllMessages", @"remove all messages") forState:UIControlStateNormal];
        [_clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_clearButton addTarget:self action:@selector(clearAction) forControlEvents:UIControlEventTouchUpInside];
        [_clearButton setBackgroundColor:[UIColor colorWithRed:87 / 255.0 green:186 / 255.0 blue:205 / 255.0 alpha:1.0]];
    }
    
    return _clearButton;
}

- (UIButton *)dissolveButton
{
    if (_dissolveButton == nil) {
        _dissolveButton = [[UIButton alloc] init];
        [_dissolveButton setTitle:NSLocalizedString(@"group.destroy", @"dissolution of the group") forState:UIControlStateNormal];
        [_dissolveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_dissolveButton addTarget:self action:@selector(dissolveAction) forControlEvents:UIControlEventTouchUpInside];
        _dissolveButton.layer.cornerRadius = 5.0;
        [_dissolveButton setBackgroundColor: color_red_dan];
    }
    
    return _dissolveButton;
}

- (UIButton *)exitButton
{
    if (_exitButton == nil) {
        _exitButton = [[UIButton alloc] init];
        [_exitButton setTitle:NSLocalizedString(@"group.leave", @"quit the group") forState:UIControlStateNormal];
        [_exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_exitButton addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
        _exitButton.layer.cornerRadius = 5.0;
        [_exitButton setBackgroundColor:color_red_dan];
    }
    
    return _exitButton;
}

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 160)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        self.clearButton.frame = CGRectMake(20, 40, _footerView.frame.size.width - 40, 35);
        //[_footerView addSubview:self.clearButton];
        
        self.dissolveButton.frame = CGRectMake(20, CGRectGetMaxY(self.clearButton.frame) + 30, _footerView.frame.size.width - 40, 35);
        
        self.exitButton.frame = CGRectMake(20, CGRectGetMaxY(self.clearButton.frame) + 30, _footerView.frame.size.width - 40, 35);
    }
    
    return _footerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
  if ([_chatGroup.owner isEqualToString:[LVTools mToString: [kUserDefault objectForKey:kUserId]]]) {
      return 5;
  }
  else{
      return 6;
  }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:self.scrollView];
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"群聊名称";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = _chatGroup.groupSubject;
        if ([_chatGroup.owner isEqualToString:[LVTools mToString: [kUserDefault objectForKey:kUserId]]]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if (indexPath.row == 2)
    {
        cell.textLabel.text =@"群聊头像";
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"%i / %i", (int)[_chatGroup.occupants count], (int)_chatGroup.groupSetting.groupMaxUsersCount];
        img = [[UIImageView alloc] initWithFrame:CGRectMake(BOUNDS.size.width-80, 5, 40, 40)];
        img.layer.masksToBounds = YES;
        img.layer.cornerRadius = 5.0;
//        NSString *groupIcon = nil;
//        [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,groupIcon]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
        [cell.contentView addSubview:img];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSString *iconPath =[LVTools mToString: [kUserDefault objectForKey:_chatGroup.groupId]];
        if (iconPath.length==0) {
            //网络请求
            NSMutableDictionary *dic = [LVTools getTokenApp];
            [dic setValue:_chatGroup.groupId forKey:@"groupid"];
            NSLog(@"%@",_chatGroup.groupId);
            [DataService requestWeixinAPI:getGroupShow parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"POST" completion:^(id result) {
                //
                NSLog(@"result%@",result);
                if ([result[@"statusCodeInfo"] isEqualToString:@"成功"]) {
                    if (![result[@"groupShow"] isKindOfClass:[NSNull class]]) {
                        NSString *groupId=[LVTools mToString:result[@"groupShow"][@"groupid"]];
                        NSString *path =[LVTools mToString:result[@"groupShow"][@"path"]];
                        if (groupId.length!=0&&path.length!=0) {
                            [kUserDefault setValue:path forKey:groupId];
                            [kUserDefault synchronize];
                            [img sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@",preUrl,path]] placeholderImage:[UIImage imageNamed:@"groupPrivateHeader"]];
                        }
                        else{
                            [img sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@",preUrl,iconPath]] placeholderImage:[UIImage imageNamed:@"groupPrivateHeader"]];
                        }
                    }
                    else{
                        [img sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@",preUrl,iconPath]] placeholderImage:[UIImage imageNamed:@"groupPrivateHeader"]];
                    }
                    
                }
                else{
                    [img sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@",preUrl,iconPath]] placeholderImage:[UIImage imageNamed:@"groupPrivateHeader"]];
                }
            }];
            if ([_chatGroup.owner isEqualToString:[LVTools mToString: [kUserDefault objectForKey:kUserId]]]) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        else
        {
            [img sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@",preUrl,iconPath]] placeholderImage:[UIImage imageNamed:@"groupPrivateHeader"]];
        }

    }
    else if (indexPath.row == 3)
    {
        cell.textLabel.text =@"消息免打扰";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 4)
    {
        cell.textLabel.text = @"清空聊天记录";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //cell.detailTextLabel.text = _chatGroup.groupSubject;
    }
    else if (indexPath.row == 5)
    {
        cell.textLabel.text = @"举报";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
   
        UIView *grayView = [[UIView alloc] initWithFrame:CGRectZero];
    if (indexPath.row==0) {
        grayView.frame = CGRectMake(0, _scrollView.height+40, BOUNDS.size.width, 10.0);
    }
    else{
        grayView.frame = CGRectMake(0, 50.0, BOUNDS.size.width, 10.0);
    }
        grayView.backgroundColor = BackGray_dan;
        [cell.contentView addSubview:grayView];
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = (int)indexPath.row;
    if (row == 0) {
        return self.scrollView.frame.size.height + 40+10.0;
    }
    else {
        return 50+10.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 3) {
        GroupSettingViewController *settingController = [[GroupSettingViewController alloc] initWithGroup:_chatGroup];
        [self.navigationController pushViewController:settingController animated:YES];
    }
    else if (indexPath.row == 1)
    {
        if ([_chatGroup.owner isEqualToString:[LVTools mToString:[kUserDefault objectForKey:kUserId]]]) {
        GroupSubjectChangingViewController *changingController = [[GroupSubjectChangingViewController alloc] initWithGroup:_chatGroup];
            changingController.backBlock = ^void(NSString *string){
                [self showHint:LoadingWord];
                [[EaseMob sharedInstance].chatManager asyncFetchGroupInfo:_chatGroup.groupId completion:^(EMGroup *group, EMError *error) {
                    //
                    [self hideHud];
                    _chatGroup = group;
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                } onQueue:nil];
                
        };
        [self.navigationController pushViewController:changingController animated:YES];
        }
    }
    else if (indexPath.row == 4) {
//        GroupBansViewController *bansController = [[GroupBansViewController alloc] initWithGroup:_chatGroup];
//        [self.navigationController pushViewController:bansController animated:YES];
        [self clearAction];
    }
    else if (indexPath.row == 5){
        ZHJubaoController *jubaoVC = [[ZHJubaoController alloc] init];
        [self.navigationController pushViewController:jubaoVC animated:YES];
    }
    else if(indexPath.row == 2){
        //上传群头像
        if ([_chatGroup.owner isEqualToString:[LVTools mToString: [kUserDefault objectForKey:kUserId]]]) {
            //群主编辑群头像
        [self imgclick];
        }
    }
}
- (void)groupBansChanged
{
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:self.chatGroup.occupants];
    [self refreshScrollView];
}

#pragma mark - data

- (void)fetchGroupInfo
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"loadData", @"Load data...")];
    [[EaseMob sharedInstance].chatManager asyncFetchGroupInfo:_chatGroup.groupId completion:^(EMGroup *group, EMError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
            if (!error) {
                weakSelf.chatGroup = group;
                [weakSelf reloadDataSource];
                
//                NSString *tmp = [group.members objectAtIndex:0];
//                NSString *tmp = @"zxcvbn";
//                [[EaseMob sharedInstance].chatManager asyncBlockOccupants:@[tmp] fromGroup:group.groupId completion:^(EMGroup *group, EMError *error){
//                    if (!error) {
//                        //
//                    }
//                    
//                } onQueue:nil];
                
//                [[EaseMob sharedInstance].chatManager asyncUnblockOccupants:@[tmp] forGroup:group.groupId completion:^(EMGroup *group, EMError *error) {
//                    if (!error) {
//                        //
//                    }
//                } onQueue:nil];
                
//                [[EaseMob sharedInstance].chatManager asyncFetchGroupBansList:group.groupId completion:^(NSArray *groupBans, EMError *error) {
//                    if (!error) {
//                        //
//                    }
//                } onQueue:nil];
                
//                [[EaseMob sharedInstance].chatManager asyncLeaveGroup:@"1413452243774" completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
//                    if (!error) {
//                        //
//                    }
//                } onQueue:nil];
            }
            else{
                [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
//                [weakSelf reloadDataSource];
            }
        });
    } onQueue:nil];
}

- (void)reloadDataSource
{
    [self.dataSource removeAllObjects];
    
    self.occupantType = GroupOccupantTypeMember;
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
    if ([self.chatGroup.owner isEqualToString:loginUsername]) {
        self.occupantType = GroupOccupantTypeOwner;
    }
    
    if (self.occupantType != GroupOccupantTypeOwner) {
        for (NSString *str in self.chatGroup.members) {
            if ([str isEqualToString:loginUsername]) {
                self.occupantType = GroupOccupantTypeMember;
                break;
            }
        }
    }
    
    [self.dataSource addObjectsFromArray:self.chatGroup.occupants];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshScrollView];
        [self refreshFooterView];
        [self hideHud];
    });
}
- (void)headImgOnclick:(UITapGestureRecognizer*)tap{
    WPCFriednMsgVC *friendInfo = [[WPCFriednMsgVC alloc] init];
    friendInfo.uid = [self.dataSource objectAtIndex:tap.view.tag-100];
    [self.navigationController pushViewController:friendInfo animated:YES];
}
- (void)refreshScrollView
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.scrollView removeGestureRecognizer:_longPress];
    [self.addButton removeFromSuperview];
    
    BOOL showAddButton = NO;
    if (self.occupantType == GroupOccupantTypeOwner) {
        [self.scrollView addGestureRecognizer:_longPress];
        [self.scrollView addSubview:self.addButton];
        showAddButton = YES;
    }
    else if (self.chatGroup.groupSetting.groupStyle == eGroupStyle_PrivateMemberCanInvite && self.occupantType == GroupOccupantTypeMember) {
        [self.scrollView addSubview:self.addButton];
        showAddButton = YES;
    }
    
    int tmp = ([self.dataSource count] + 1) % kColOfRow;
    int row = (int)([self.dataSource count] + 1) / kColOfRow;
    row += tmp == 0 ? 0 : 1;
    self.scrollView.tag = row;
    self.scrollView.frame = CGRectMake(10, 20, self.tableView.frame.size.width - 20, row * kContactSize);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, row * kContactSize);
    
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
    
    int i = 0;
    int j = 0;
    BOOL isEditing = self.addButton.hidden ? YES : NO;
    BOOL isEnd = NO;
    for (i = 0; i < row; i++) {
        for (j = 0; j < kColOfRow; j++) {
            NSInteger index = i * kColOfRow + j;
            if (index < [self.dataSource count]) {
                NSString *username = [self.dataSource objectAtIndex:index];
                NearByModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:[LVTools mGetLocalDataByKey:[NSString stringWithFormat:@"xd%@",username]]];
            
                ContactView *contactView = [[ContactView alloc] initWithFrame:CGRectMake(j * kContactSize, i * kContactSize, kContactSize, kContactSize)];
                contactView.tag = index +100;
                contactView.index = i * kColOfRow + j;
                if ([username isEqualToString:[LVTools mToString:[kUserDefault objectForKey:kUserId]]]) {
                    [contactView.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[kUserDefault objectForKey:KUserIcon]]] placeholderImage: [UIImage imageNamed:@"plhor_2"]];
                    contactView.remark = [LVTools mToString:[LVTools mToString:[kUserDefault objectForKey:kUserName]]];
                }
                else{
                [contactView.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,model.iconPath]] placeholderImage: [UIImage imageNamed:@"plhor_2"]];
                contactView.remark = [LVTools mToString:model.nickName];
                }
                if (![username isEqualToString:loginUsername]) {
                    contactView.editing = isEditing;
                }
                if(j==0&&i==0){
                    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contactView.width/2.0, 15)];
                    lab.font = Content_lbfont;
                    lab.textColor = [UIColor whiteColor];
                    lab.text = @"群主";
                    lab.textAlignment = NSTextAlignmentCenter;
                    lab.backgroundColor = NavgationColor;
                    lab.alpha = 0.8;
                    [contactView.imageView addSubview:lab];
                }
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImgOnclick:)];
                [contactView addGestureRecognizer:tap];
                __weak typeof(self) weakSelf = self;
                [contactView setDeleteContact:^(NSInteger index) {
                    [weakSelf showHudInView:weakSelf.view hint:NSLocalizedString(@"group.removingOccupant", @"deleting member...")];
                    NSArray *occupants = [NSArray arrayWithObject:[weakSelf.dataSource objectAtIndex:index]];
                    [[EaseMob sharedInstance].chatManager asyncRemoveOccupants:occupants fromGroup:weakSelf.chatGroup.groupId completion:^(EMGroup *group, EMError *error) {
                        [weakSelf hideHud];
                        if (!error) {
                            weakSelf.chatGroup = group;
                            [weakSelf.dataSource removeObjectAtIndex:index];
                            [weakSelf refreshScrollView];
                        }
                        else{
                            [weakSelf showHint:error.description];
                        }
                    } onQueue:nil];
//                    [weakSelf showHudInView:weakSelf.view hint:@"正在将成员加入黑名单..."];
//                    NSArray *occupants = [NSArray arrayWithObject:[weakSelf.dataSource objectAtIndex:index]];
//                    [[EaseMob sharedInstance].chatManager asyncBlockOccupants:occupants fromGroup:weakSelf.chatGroup.groupId completion:^(EMGroup *group, EMError *error) {
//                        [weakSelf hideHud];
//                        if (!error) {
//                            weakSelf.chatGroup = group;
//                            [weakSelf.dataSource removeObjectAtIndex:index];
//                            [weakSelf refreshScrollView];
//                        }
//                        else{
//                            [weakSelf showHint:error.description];
//                        }
//                    } onQueue:nil];
                }];
                
                [self.scrollView addSubview:contactView];
            }
            else{
                if(showAddButton && index == self.dataSource.count)
                {
                    self.addButton.frame = CGRectMake(j * kContactSize + 5, i * kContactSize + 10, kContactSize - 10, kContactSize - 10);
                }
                
                isEnd = YES;
                break;
            }
        }
        
        if (isEnd) {
            break;
        }
    }
    
    [self.tableView reloadData];
}

- (void)refreshFooterView
{
    if (self.occupantType == GroupOccupantTypeOwner) {
        [_exitButton removeFromSuperview];
        [_footerView addSubview:self.dissolveButton];
    }
    else{
        [_dissolveButton removeFromSuperview];
        [_footerView addSubview:self.exitButton];
    }
}

#pragma mark - action

- (void)tapView:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        if (self.addButton.hidden) {
            [self setScrollViewEditing:NO];
        }
    }
}

- (void)deleteContactBegin:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
        for (ContactView *contactView in self.scrollView.subviews)
        {
            CGPoint locaton = [longPress locationInView:contactView];
            if (CGRectContainsPoint(contactView.bounds, locaton))
            {
                if ([contactView isKindOfClass:[ContactView class]]) {
                    if ([contactView.remark isEqualToString:loginUsername]) {
                        return;
                    }
                    _selectedContact = contactView;
                    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"delete", @"deleting member..."), nil];
                    //, NSLocalizedString(@"friend.block", @"add to black list")
                    [sheet showInView:self.view];
                }
            }
        }
    }
}

- (void)setScrollViewEditing:(BOOL)isEditing
{
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
    
    for (ContactView *contactView in self.scrollView.subviews)
    {
        if ([contactView isKindOfClass:[ContactView class]]) {
            if ([contactView.remark isEqualToString:loginUsername]) {
                continue;
            }
            
            [contactView setEditing:isEditing];
        }
    }
    
    self.addButton.hidden = isEditing;
}

- (void)addContact:(id)sender
{
    ZHInviteFriendController *selectionController = [[ZHInviteFriendController alloc] initWithBlockSelectedUsernames:_chatGroup.occupants];
    selectionController.chuanBlock = ^(NSArray *arr){
        
        NSInteger maxUsersCount = _chatGroup.groupSetting.groupMaxUsersCount;
        if (([arr count] + _chatGroup.groupOccupantsCount) > maxUsersCount) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.maxUserCount", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
            
            
        }
        
        [self showHudInView:self.view hint:NSLocalizedString(@"group.addingOccupant", @"add a group member...")];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *source = [NSMutableArray array];
            for (NearByModel *buddy in arr) {
                [source addObject:[LVTools mToString: buddy.userId]];
            }
            
            NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
            NSString *username = [loginInfo objectForKey:kSDKUsername];
            NSString *messageStr = [NSString stringWithFormat:NSLocalizedString(@"group.somebodyInvite", @"%@ invite you to join group \'%@\'"), username, weakSelf.chatGroup.groupSubject];
            EMError *error = nil;
            weakSelf.chatGroup = [[EaseMob sharedInstance].chatManager addOccupants:source toGroup:weakSelf.chatGroup.groupId welcomeMessage:messageStr error:&error];
            if (!error) {
                [weakSelf reloadDataSource];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf hideHud];
                    [weakSelf showHint:error.description];
                });
            }
        });

    };
    [self.navigationController pushViewController:selectionController animated:YES];
}

//清空聊天记录
- (void)clearAction
{
    __weak typeof(self) weakSelf = self;
    [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"sureToDelete", @"please make sure to delete") customizationBlock:nil completionBlock:
     ^(NSUInteger buttonIndex, WCAlertView *alertView) {
         if (buttonIndex == 1) {
             [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:weakSelf.chatGroup.groupId];
         }
     } cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
}

//解散群组
- (void)dissolveAction
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"group.destroy", @"dissolution of the group")];
    [[EaseMob sharedInstance].chatManager asyncDestroyGroup:_chatGroup.groupId completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
        [weakSelf hideHud];
        if (error) {
            [weakSelf showHint:NSLocalizedString(@"group.destroyFail", @"dissolution of group failure")];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
        }
    } onQueue:nil];
    
//    [[EaseMob sharedInstance].chatManager asyncLeaveGroup:_chatGroup.groupId];
}

//设置群组
- (void)configureAction {
// todo
    [[[EaseMob sharedInstance] chatManager] asyncIgnoreGroupPushNotification:_chatGroup.groupId
                                                                    isIgnore:_chatGroup.isPushNotificationEnabled];

    return;
//    UIViewController *viewController = [[UIViewController alloc] init];
//    [self.navigationController pushViewController:viewController animated:YES];
}

//退出群组
- (void)exitAction
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"group.leave", @"quit the group")];
    [[EaseMob sharedInstance].chatManager asyncLeaveGroup:_chatGroup.groupId completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
        [weakSelf hideHud];
        if (error) {
            [weakSelf showHint:NSLocalizedString(@"group.leaveFail", @"exit the group failure")];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
        }
    } onQueue:nil];
    
//    [[EaseMob sharedInstance].chatManager asyncLeaveGroup:_chatGroup.groupId];
}

//- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error {
//    __weak ChatGroupDetailViewController *weakSelf = self;
//    [weakSelf hideHud];
//    if (error) {
//        if (reason == eGroupLeaveReason_UserLeave) {
//            [weakSelf showHint:@"退出群组失败"];
//        } else {
//            [weakSelf showHint:@"解散群组失败"];
//        }
//    }
//}

- (void)didIgnoreGroupPushNotification:(NSArray *)ignoredGroupList error:(EMError *)error {
// todo
    NSLog(@"ignored group list:%@.", ignoredGroupList);
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 501) {
        if (buttonIndex!=2) {
            [self presentImagePickerControllerWithIndex:buttonIndex];
        }
    }
    else{
    NSInteger index = _selectedContact.index;
    if (buttonIndex == 0)
    {
        //delete
        _selectedContact.deleteContact(index);
    }
//    else if (buttonIndex == 1)
//    {
//        //add to black list
//        [self showHudInView:self.view hint:@"Adding to black list"];
//        NSArray *occupants = [NSArray arrayWithObject:[self.dataSource objectAtIndex:_selectedContact.index]];
//        __weak ChatGroupDetailViewController *weakSelf = self;
//        [[EaseMob sharedInstance].chatManager asyncBlockOccupants:occupants fromGroup:self.chatGroup.groupId completion:^(EMGroup *group, EMError *error) {
//            if (weakSelf)
//            {
//                __weak ChatGroupDetailViewController *strongSelf = weakSelf;
//                [strongSelf hideHud];
//                if (!error) {
//                    strongSelf.chatGroup = group;
//                    [strongSelf.dataSource removeObjectAtIndex:index];
//                    [strongSelf refreshScrollView];
//                }
//                else{
//                    [strongSelf showHint:error.description];
//                }
//            }
//        } onQueue:nil];
//    }
    _selectedContact = nil;
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    _selectedContact = nil;
}
- (void)imgclick {
    UIActionSheet *action=[[UIActionSheet alloc]initWithTitle:@"请选择需要的操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"从相册选取" otherButtonTitles:@"拍照", nil];
    action.tag = 501;
    [action showInView:self.view];
}
-(void)presentImagePickerControllerWithIndex:(NSInteger)index
{
    UIImagePickerControllerSourceType sourceType;
    if (index==0) {
        sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else
    {
        sourceType =UIImagePickerControllerSourceTypeCamera;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *pickerController=[[UIImagePickerController alloc]init];
        pickerController.delegate=self;
        pickerController.sourceType=sourceType;
        pickerController.allowsEditing=YES;
        [self presentViewController:pickerController animated:YES completion:nil];
    }
}

#pragma mark-UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    CGSize imageSize=image.size;
    imageSize.height=121;
    imageSize.width=121;
    //image=[self imageWithImage:image scaledToSize:imageSize];
    [self performSelector:@selector(selectPickerImage:) withObject:image afterDelay:0.1];
}
-(void)selectPickerImage:(UIImage *)image
{
    
    [self showHudInView:self.view hint:@"图片上传中...."];
    NSData *imageData=UIImageJPEGRepresentation(image, kCompressqulitaty);
    if (imageData==nil) {
        imageData=UIImagePNGRepresentation(image);
    }
    NSMutableDictionary *dic=[LVTools getTokenApp];
    ZHupdateImage *update=[[ZHupdateImage alloc]init];
    [update requestWithURL:imageupdata WithParams:@{@"param":dic,@"type":@"GROUP_SHOW"} WithType:nil WithData:imageData With:^(NSDictionary * result) {
        NSString *iconPath=nil;
        NSLog(@"result  ====  %@",result);
        if ([[result objectForKey:@"status"] boolValue])
        {
            iconPath = result[@"data"][@"path"];
            [dic setValue:iconPath forKey:@"path"];
            [dic setValue:[LVTools mToString: _chatGroup.groupId] forKey:@"groupid"];
            //[dic setObject:_dict[@"userName"] forKey:@"userName"];
            [DataService requestWeixinAPI:insertGroupShow parsms:
             @{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                 
                 NSDictionary *dic=(NSDictionary *)result;
                 NSLog(@"result=%@",result);
                 if ([[dic objectForKey:@"statusCodeInfo"] isEqualToString:@"成功"])
                 {
                     [self hideHud];
                     [kUserDefault setObject:iconPath forKey:[LVTools mToString: _chatGroup.groupId]];
                     [kUserDefault synchronize];
                     [img setImage:image];
                     //刷新约战首页
                    // [[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshAppoint object:nil];
                 }
                 else{
                     [self hideHud];
                     UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"图片上传失败!" message:@"请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                     [alertView show];
                 }
             }];
        }
        else
        {
            [self hideHud];
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"图片上传失败!" message:
                                    @"请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
        }
        
    }];
}
//对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}


@end
