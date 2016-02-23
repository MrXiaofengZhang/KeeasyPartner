//
//  LVButton.m
//  yuezhan123
//
//  Created by apples on 15/3/19.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "LVButton.h"

#define indexImgHeight CGRectGetWidth(self.frame)/4.4
#define itemImgHeight CGRectGetWidth(self.frame)/3

static NSInteger flagMatch = 1;

@interface LVButton ()
{
    UILabel * titleLabel;
    UIImageView * imgView;
    
    //记住选中和没选中的图片
    UIImage * _selectImage;
    UIImage * _unSelectImage;
    
    UIImageView * _SiftImageView;
}
@end

@implementation LVButton
- (void)setLabelFont:(UIFont*)font{
    titleLabel.font = font;
}

- (void)setlabelText:(NSString *)text {
    titleLabel.text = text;
}

//透明色/红色+图标+左上角标题【index界面】
- (instancetype)initWithFrame:(CGRect)frame WithTitle:(NSString *)title WithImg:(NSString *)imgStr WithColor:(NSInteger)redOrClear WithTag:(NSInteger)btnTag{
    self = [super initWithFrame:frame];
    if (self) {
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, frame.size.width - 20, 20)];
        titleLabel.text = title;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:titleLabel];
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)/2 - indexImgHeight, CGRectGetHeight(frame)/2 - indexImgHeight, indexImgHeight*2, indexImgHeight *2)];
        imgView.image = [UIImage imageNamed:imgStr];
        //        imgView.backgroundColor = [UIColor redColor];
        imgView.userInteractionEnabled = NO;
        [self addSubview:imgView];
        
        if (redOrClear == 0) {
            //透明色
            self.layer.borderColor = [[UIColor grayColor] CGColor];
            self.layer.borderWidth = 0.5;
            self.layer.masksToBounds = YES;
            
            self.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor grayColor];
            
        }else if (redOrClear == 1){
            //红色
            self.backgroundColor = INDEX_IMG_BG_COLOR;
            titleLabel.textColor = [UIColor whiteColor];
        }
        
        self.tag = btnTag;
    }
    return self;
}



//图片背静 + 中心标题【index界面】
- (instancetype)initWithFrame:(CGRect)frame WithTitle:(NSString *)titleStr WithBgImg:(NSString *)imgStr WithTag:(NSInteger)btnTag{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame)/2-indexImgHeight/2, CGRectGetWidth(frame), indexImgHeight)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = titleStr;
        [self addSubview:titleLabel];
        
        self.tag = btnTag;
    }
    return self;
}

//滑动轮转图效果【一级界面轮转图btn】球类的筛选
- (instancetype)initWithFrame:(CGRect)frame selectWithImage:(NSString *)imgStr UnSelectWithImag:(NSString *)imgStr2 WithTitle:(NSString *)title WithTag:(NSInteger)tag{
    self = [super initWithFrame:frame];
    if (self) {
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(itemImgHeight/2, 10, itemImgHeight*2, itemImgHeight*2)];
        imgView.userInteractionEnabled = NO;
        [self addSubview:imgView];
        [self SetImage:imgStr WithImage2:imgStr2 WithNum:0];
        _unSelectImage = [UIImage imageNamed:imgStr];
        _selectImage = [UIImage imageNamed:imgStr2];
        self.tag = tag;
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imgView.frame) + 6, CGRectGetWidth(self.frame), 20)];
        titleLabel.textColor = garyLineColor;
        titleLabel.text = title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
    }
    return self;
}

//筛选按钮
- (instancetype)initWithFrame:(CGRect)frame Sifttile:(NSString *)title WithTag:(NSInteger)btnTag{
    self = [super initWithFrame:frame];
    if (self)
    {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, CGRectGetWidth(frame), CGRectGetHeight(frame)-10)];
        titleLabel.text = title;
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = garyLineColor;
        [self addSubview:titleLabel];
        
        _SiftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame)-20, 1)];
        _SiftImageView.backgroundColor = color_red_dan;
        [self addSubview:_SiftImageView];
        _SiftImageView.hidden = YES;
        
        [self SetImage:nil WithImage2:nil WithNum:1];
        
        self.tag = btnTag;
    }
    return self;
}

- (void)selectedOrNo:(BOOL)select WithNum:(NSInteger)number{
    if (number == 1)//轮转图的按钮
    {
        if (select) {
            titleLabel.textColor = color_red_dan;
            imgView.image = _selectImage;
        }else{
            titleLabel.textColor = garyLineColor;
            imgView.image = _unSelectImage;
        }
        
    }else if (number == 2)
    {
        if (select) {
            titleLabel.textColor = color_red_dan;
            _SiftImageView.hidden = NO;
        }else{
            titleLabel.textColor = garyLineColor;
            _SiftImageView.hidden = YES;
        }
    }
}

- (void)SetImage:(NSString *)imgStr WithImage2:(NSString *)imgStr2 WithNum:(NSInteger)number{
    
    if (self.state == UIControlStateSelected) {
        if (number == 0) {
            titleLabel.textColor = INDEX_IMG_BG_COLOR;
            imgView.image = [UIImage imageNamed:imgStr2];
        }else if (number == 1){
            titleLabel.textColor = NavgationColor;
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(self.frame)-1+mygap, CGRectGetWidth(self.frame)-20, 1)];
            imageView.backgroundColor = color_red_dan;
            [self addSubview:imageView];
        }
    }else{
        if (number == 0) {
            titleLabel.textColor = [UIColor grayColor];
            imgView.image = [UIImage imageNamed:imgStr];
        }else if (number == 1){
            titleLabel.textColor = [UIColor grayColor];
        }
    }
}

//约战一级界面中筛选的按钮
- (instancetype)initWithFrame:(CGRect)frame WithSiftBtn:(NSString *)siftName WithLine:(BOOL)isLine{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setTitle:siftName forState:UIControlStateNormal];
        [self setTitleColor:NavgationColor forState:UIControlStateSelected];
        [self setTitleColor:garyLineColor forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        
        [self setImage:[UIImage imageNamed:@"xia"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"shang"] forState:UIControlStateSelected];
        
//        self.titleLabel.backgroundColor = [UIColor blackColor];
        
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
        [self setImageEdgeInsets:UIEdgeInsetsMake(0, CGRectGetWidth(self.frame)/2+22, 0, 0)];
        
        if (isLine) {
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-0.5, 10, 0.5, CGRectGetHeight(self.frame)-20)];
            imageView.backgroundColor = [UIColor lightGrayColor];
            [self addSubview:imageView];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame WithMatch:(BOOL)isClick{
    self = [super initWithFrame:frame];
    if (self) {
        
        //设置序列图
        UIImageView *bgImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:bgImage];
        
        NSArray *array = [NSArray arrayWithObjects:[UIImage imageNamed:@"animation1"],[UIImage imageNamed:@"animation2"], nil];
        bgImage.animationImages = array;
        bgImage.animationDuration = 0.4;
        bgImage.animationRepeatCount = 0;
        [bgImage startAnimating];

    }
    return self;
}
- (void)repeatImg:(NSTimer*)time{
    flagMatch ++;
    NSString * image ;
    if (flagMatch % 2 == 0) {
        image =@"yuezhan";
    }else{
        image = @"yuezhan2";
    }
    [self setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
}

@end
