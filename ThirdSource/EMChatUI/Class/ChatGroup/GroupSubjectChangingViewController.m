//
//  GroupSubjectChangingViewController.m
//  ChatDemo-UI2.0
//
//  Created by Neil on 15-2-25.
//  Copyright (c) 2014年 Neil. All rights reserved.
//

#import "GroupSubjectChangingViewController.h"

@interface GroupSubjectChangingViewController () <UITextFieldDelegate>
{
    EMGroup         *_group;
    BOOL            _isOwner;
    UITextField     *_subjectField;
}

@end

@implementation GroupSubjectChangingViewController

- (instancetype)initWithGroup:(EMGroup *)group
{
    self = [self init];
    if (self) {
        _group = group;
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
        _isOwner = [_group.owner isEqualToString:loginUsername];
        self.view.backgroundColor = [UIColor whiteColor];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"title.groupSubjectChanging", @"Change group name");

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];

    if (_isOwner)
    {
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save", @"Save") style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
        saveItem.tintColor = [UIColor whiteColor];
        [self.navigationItem setRightBarButtonItem:saveItem];
    }

    CGRect frame = CGRectMake(20, 20, self.view.frame.size.width - 40, 40);
    _subjectField = [[UITextField alloc] initWithFrame:frame];
    _subjectField.layer.cornerRadius = 5.0;
    _subjectField.layer.borderWidth = 1.0;
    _subjectField.placeholder = @"请输入群聊名称";
    _subjectField.text = _group.groupSubject;
    if (!_isOwner)
    {
        _subjectField.enabled = NO;
    }
    frame.origin = CGPointMake(frame.size.width - 5.0, 0.0);
    frame.size = CGSizeMake(5.0, 40.0);
    UIView *holder = [[UIView alloc] initWithFrame:frame];
    _subjectField.rightView = holder;
    _subjectField.rightViewMode = UITextFieldViewModeAlways;
    frame.origin = CGPointMake(0.0, 0.0);
    holder = [[UIView alloc] initWithFrame:frame];
    _subjectField.leftView = holder;
    _subjectField.leftViewMode = UITextFieldViewModeAlways;
    _subjectField.delegate = self;
    [self.view addSubview:_subjectField];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - action
- (void)back
{
    if ([_subjectField isFirstResponder])
    {
        [_subjectField resignFirstResponder];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save:(id)sender
{
    if (_subjectField.text.length == 0) {
        [self showHint:@"群聊名不能为空"];
    }
    else{
    [self saveSubject];
    [self back];
    }
}

- (void)saveSubject
{
    [[EaseMob sharedInstance].chatManager asyncChangeGroupSubject:_subjectField.text forGroup:_group.groupId];
    self.backBlock(_subjectField.text);
}

@end
