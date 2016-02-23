//
//  PayView.m
//  yuezhan123
//
//  Created by admin on 15/9/10.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "PayView.h"

@implementation PayView
//123
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.selectIndex = 0;
        self.userInteractionEnabled = YES;
        [self.mainView addSubview:self.table];
        [self.mainView addSubview:self.cancelBtn];
        [self addSubview:self.mainView];
        [self addSubview:self.confirmBtn];
        imgArray = @[@"yinlian_wpc",@"zhifubao_wpc",@"weixin_wpc"];
        contentArray = @[@"银联支付,有银行卡就行",@"支付宝快捷支付",@"微信支付，方便快捷"];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectIndex = indexPath.row;
    for (int i = 700; i < 703; i++) {
        UITableViewCell *cell = (UITableViewCell *)[tableView viewWithTag:i];
        UIButton *btn = (UIButton *)[cell.contentView viewWithTag:i+50];
        if (i-700 == indexPath.row) {
            btn.selected = YES;
        } else {
            btn.selected = NO;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = 700+indexPath.row;
    cell.imageView.image = [UIImage imageNamed:imgArray[indexPath.row]];
    cell.textLabel.text = contentArray[indexPath.row];
    cell.textLabel.font = Btn_font;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(UISCREENWIDTH-55, 15, 20, 20);
    [btn setBackgroundImage:[UIImage imageNamed:@"selected_wpc"] forState:UIControlStateSelected];
    [btn setBackgroundImage:[UIImage imageNamed:@"disSelected_wpc"] forState:UIControlStateNormal];
    btn.tag = cell.tag+50;
    btn.selected = NO;
    if (indexPath.row == 0) {
        btn.selected = YES;
    }
    [cell.contentView addSubview:btn];
    
    return cell;
}

- (UIView *)backGround {
    if (!_backGround) {
        _backGround = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _backGround.backgroundColor = [UIColor blackColor];
        _backGround.alpha = 0.6;
    }
    return _backGround;
}

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(10, UISCREENHEIGHT-280, UISCREENWIDTH-20, 200)];
        _mainView.layer.cornerRadius = 10;
        _mainView.userInteractionEnabled = YES;
        _mainView.backgroundColor = RGBACOLOR(240, 240, 240, 1);
        _mainView.layer.masksToBounds = YES;
        _mainView.layer.shadowOffset = CGSizeMake(1, 1);
        _mainView.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
        UILabel *titlelabe = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
        titlelabe.text = @"手机支付";
        titlelabe.center = CGPointMake(UISCREENWIDTH/2-5, 25);
        titlelabe.textAlignment = NSTextAlignmentCenter;
        titlelabe.textColor = [UIColor blackColor];
        titlelabe.font = [UIFont systemFontOfSize:16.5];
        [_mainView addSubview:titlelabe];
    }
    return _mainView;
}

- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, UISCREENWIDTH-20, 150) style:UITableViewStylePlain];
        _table.dataSource = self;
        _table.delegate = self;
     }
    return _table;
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.frame = CGRectMake(10, UISCREENHEIGHT-60, UISCREENWIDTH-20, 50);
        _confirmBtn.backgroundColor = [UIColor whiteColor];
        _confirmBtn.layer.cornerRadius = 5;
        _confirmBtn.layer.masksToBounds = YES;
        [_confirmBtn setTitle:@"立即支付" forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:NavgationColor forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(UISCREENWIDTH-60, 15, 40, 20);
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn.titleLabel setFont:Btn_font];
        [_cancelBtn setTitleColor:NavgationColor forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (void)cancelAction:(UIButton *)sender {
    [self.delegate cancelAction];
}

- (void)confirmAction:(UIButton *)sender {
    [self.delegate confirmAction:self.selectIndex];
}

@end
