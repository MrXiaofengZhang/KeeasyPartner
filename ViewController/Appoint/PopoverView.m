//
//  PopoverView.m
//  ArrowView
//
//  Created by guojiang on 4/9/14.
//  Copyright (c) 2014年 LINAICAI. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "PopoverView.h"


#define kArrowHeight 6.f
#define kArrowCurvature 6.f
#define SPACE 2.f
#define TITLE_FONT [UIFont systemFontOfSize:16]
#define RGB(r, g, b)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]

@interface PopoverView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic) CGPoint showPoint;

@property (nonatomic, strong) UIButton *handerView;

@end
static CGFloat cellheight;
@implementation PopoverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.borderColor = RGB(200, 199, 204);
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(id)initWithPoint:(CGPoint)point titles:(NSArray *)titles images:(NSArray *)images andStyle:(PopoverStyle)style
{
    self = [super init];
    if (self) {
        self.popStyle = style;
        self.showPoint = point;
        self.titleArray = titles;
        self.imageArray = images;
        if (style == PopoverStyleDefault) {
            cellheight = 40;
        } else {
            cellheight = 112*propotion;
        }
        if (style == PopoverStyleTrancent) {
            cellheight = 40;
        }
        self.frame = [self getViewFrameWith:[titles count]];
        
        [self addSubview:self.tableView];
        
    }
    return self;
}

-(CGRect)getViewFrameWith:(NSInteger)count
{
    CGRect frame = CGRectZero;
    if (self.popStyle == PopoverStyleDefault) {
        frame = CGRectMake(UISCREENWIDTH/8.0*5.0-15, UISCREENHEIGHT-(40*count+10)-45, UISCREENWIDTH/4+30, (10+40*count));
    }
    else if (self.popStyle == PopoverStyleTrancent) {
        frame = CGRectMake(UISCREENWIDTH-320*propotion+25, 55.0, UISCREENWIDTH/4+30, (10+40*count));
    }
    else {
        frame = CGRectMake(UISCREENWIDTH-320*propotion-5, 69, 320*propotion, 10+cellheight*count);
    }
   

    return frame;
}

-(void)show
{
    self.handerView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_handerView setFrame:[UIScreen mainScreen].bounds];
    _handerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_handerView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_handerView addSubview:self];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:_handerView];
    CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:_handerView];
    self.layer.anchorPoint = CGPointMake(arrowPoint.x / self.frame.size.width, arrowPoint.y / self.frame.size.height);
    self.frame = [self getViewFrameWith:self.titleArray.count];
    
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

-(void)dismiss
{
    [self dismiss:YES];
}

-(void)dismiss:(BOOL)animate
{
    if (!animate) {
        [_handerView removeFromSuperview];
        self.dismissBlock();
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_handerView removeFromSuperview];
        self.dismissBlock();
    }];
    
}


#pragma mark - UITableView

-(UITableView *)tableView
{
    if (_tableView != nil) {
        return _tableView;
    }
    
    CGRect rect = self.frame;
    if (self.popStyle == PopoverStyleDefault) {
        rect.origin.x = 0;
        rect.origin.y = 0;
        rect.size.width = self.frame.size.width;
        rect.size.height = cellheight*self.titleArray.count;
    }
    else if (self.popStyle == PopoverStyleTrancent) {
        rect.origin.x = 0;
        rect.origin.y = kArrowHeight;
        rect.size.width = self.frame.size.width;
        rect.size.height = cellheight*self.titleArray.count;
    }
    else {
        rect.origin.x = 0;
        rect.origin.y = kArrowHeight;
        rect.size.width = self.frame.size.width;
        rect.size.height = cellheight*self.titleArray.count;
    }
        self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.alwaysBounceHorizontal = NO;
    _tableView.alwaysBounceVertical = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    return _tableView;
}

#pragma mark - UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_titleArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    if ([_imageArray count] == [_titleArray count]) {
        cell.imageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row]];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.text = [_titleArray objectAtIndex:indexPath.row];
    if (self.popStyle == PopoverStyleDefault) {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    else if (self.popStyle == PopoverStyleTrancent) {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = Btn_font;
    }
    else {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.textColor = [UIColor whiteColor];
    }
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    if (indexPath.row < _titleArray.count-1) {
        UIView *gapView = [[UIView alloc] initWithFrame:CGRectMake(0, cellheight-0.5, self.width, 0.5)];
        gapView.backgroundColor = RGBACOLOR(205, 205, 205, 1);
        [cell.contentView addSubview:gapView];
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.selectRowAtIndex) {
        self.selectRowAtIndex(indexPath.row);
    }
    [self dismiss:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellheight;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.


- (void)drawRect:(CGRect)rect
{
    [self.borderColor set]; //设置线条颜色
    UIBezierPath *popoverPath = [UIBezierPath bezierPath];
    if (self.popStyle == PopoverStyleDefault) {
        CGRect frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - kArrowHeight);
        float xMin = CGRectGetMinX(frame);
        float yMin = CGRectGetMinY(frame);
        float xMax = CGRectGetMaxX(frame);
        float yMax = CGRectGetMaxY(frame);
        NSLog(@"%@",NSStringFromCGPoint(self.showPoint));
        CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:_handerView];
        NSLog(@"%@",NSStringFromCGPoint(arrowPoint));
        [popoverPath moveToPoint:CGPointMake(xMin, yMin)];
        [popoverPath addLineToPoint:CGPointMake(xMax, yMin)];
        [popoverPath addLineToPoint:CGPointMake(xMax, yMax)];
        [popoverPath addLineToPoint:CGPointMake(arrowPoint.x+kArrowHeight, yMax)];
        [popoverPath addLineToPoint:CGPointMake(arrowPoint.x, arrowPoint.y)];
        [popoverPath addLineToPoint:CGPointMake(arrowPoint.x-kArrowHeight, yMax)];
        [popoverPath addLineToPoint:CGPointMake(xMin, yMax)];
        [RGB(245, 245, 245) setFill];
    }
    else if (self.popStyle == PopoverStyleTrancent){
        CGRect frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - kArrowHeight);
        float xMin = CGRectGetMinX(frame);
        float yMin = CGRectGetMinY(frame);
        float xMax = CGRectGetMaxX(frame);
        float yMax = CGRectGetMaxY(frame);
        NSLog(@"%@",NSStringFromCGPoint(self.showPoint));
        CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:_handerView];
        NSLog(@"%@",NSStringFromCGPoint(arrowPoint));
        [popoverPath moveToPoint:CGPointMake(xMin, yMin)];
        [popoverPath addLineToPoint:CGPointMake(xMax, yMin)];
        [popoverPath addLineToPoint:CGPointMake(xMax, yMax)];
        [popoverPath addLineToPoint:CGPointMake(arrowPoint.x+kArrowHeight, yMax)];
        [popoverPath addLineToPoint:CGPointMake(arrowPoint.x, arrowPoint.y)];
        [popoverPath addLineToPoint:CGPointMake(arrowPoint.x-kArrowHeight, yMax)];
        [popoverPath addLineToPoint:CGPointMake(xMin, yMax)];
        [[UIColor clearColor] setFill];
    }
    else {
        CGRect frame = CGRectMake(0, kArrowHeight, self.bounds.size.width, self.bounds.size.height - kArrowHeight);
        float xMin = CGRectGetMinX(frame);
        float yMin = CGRectGetMinY(frame);
        float xMax = CGRectGetMaxX(frame);
        float yMax = CGRectGetMaxY(frame);
        NSLog(@"%@",NSStringFromCGPoint(self.showPoint));
        CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:_handerView];
        NSLog(@"%@",NSStringFromCGPoint(arrowPoint));
        [popoverPath moveToPoint:CGPointMake(xMin, yMin)];//左上角
        [popoverPath addLineToPoint:CGPointMake(arrowPoint.x-kArrowHeight, yMin)];
        [popoverPath addLineToPoint:CGPointMake(arrowPoint.x, arrowPoint.y)];
        [popoverPath addLineToPoint:CGPointMake(arrowPoint.x+kArrowHeight, yMin)];
        [popoverPath addLineToPoint:CGPointMake(xMax, yMin)];//右上角
        [popoverPath addLineToPoint:CGPointMake(xMax, yMax)];//右下角
        [popoverPath addLineToPoint:CGPointMake(xMin, yMax)];//左下角
        [RGB(70, 70, 70) setFill];
    }
    [popoverPath fill];
    [popoverPath closePath];
    [popoverPath stroke];
}

@end
