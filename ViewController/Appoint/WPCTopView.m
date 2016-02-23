//
//  WPCTopView.m
//  yuezhan123
//
//  Created by admin on 15/6/11.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCTopView.h"

@implementation WPCTopView

- (id)initWithFrame:(CGRect)frame andArray:(NSArray *)arr
{
    self = [super initWithFrame:frame];
    if (self) {
        _secondSelect = NO;
        _flagForCollection = NO;
        _layerArrays = [NSMutableArray array];
        _countArray = [NSArray arrayWithArray:arr];
        [self createUI:_countArray];
        _selectedIndex = 0;
        [self initializeFirstChoose];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeSelctIndex:)];
        [self addGestureRecognizer:tap];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDirection) name:SPORT_TYPE_CHANGE_NOTIFICATION object:nil];
    }
    return self;
}

- (void)changeDirection
{
    _secondSelect = YES;
    CAShapeLayer *layer = (CAShapeLayer *)_layerArrays[2];
    UILabel *lab = (UILabel *)[self viewWithTag:(2+5555)];
    [self changeSelectIndex:_selectedIndex andLayer:layer andLabel:lab show:NO];
}

- (void)createUI:(NSArray *)array
{
    for (int i = 0; i < array.count; i ++) {
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(self.width/12+self.width/3*i-5, self.height/4, self.width/6+10, self.height/2)];
        lab.text = array[i];
        lab.tag = 5555+i;
        lab.font = Btn_font;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = [UIColor blackColor];
        [self addSubview:lab];
        
        //创建layer层
        CAShapeLayer *layer = [CAShapeLayer new];
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(8, 0)];
        [path addLineToPoint:CGPointMake(4, -5)];
        [path closePath];
        
        layer.path = path.CGPath;
        layer.lineWidth = 0.8;
        layer.fillColor = [UIColor grayColor].CGColor;
        
        CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
        layer.bounds = CGPathGetBoundingBox(bound);
        CGPathRelease(bound);
        layer.position = CGPointMake(lab.right+5, 20);
        
        [self.layer addSublayer:layer];
        
        [_layerArrays addObject:layer];
    }
}

- (void)initializeFirstChoose
{
    UILabel *lab = (UILabel *)[self viewWithTag:5555];
    lab.textColor = [UIColor redColor];
    CAShapeLayer *layer = (CAShapeLayer *)_layerArrays[0];
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    [layer setValue:@(M_PI) forKeyPath:anim.keyPath];
    layer.fillColor = [[UIColor redColor] CGColor];
}

- (void)changeSelctIndex:(UITapGestureRecognizer *)tap
{
    CGPoint touchPoint = [tap locationInView:self];
    NSInteger tapIndex = touchPoint.x / (self.frame.size.width / [_countArray count]);
    
    if (_selectedIndex == tapIndex) {
        //点击的是当前选中的，只走对外代理
        if (tapIndex == 2) {
            //此情况下，约战首页的collection弹出，收入。循环操作
            
            CAShapeLayer *layer = (CAShapeLayer *)_layerArrays[tapIndex];
            UILabel *lab = (UILabel *)[self viewWithTag:(tapIndex+5555)];
            [self changeSelectIndex:_selectedIndex andLayer:layer andLabel:lab show:_secondSelect];
            _secondSelect = !_secondSelect;
        }
        [self.delegate menuClickWithIndex:tapIndex];
        
    } else {
        //走对外代理，同时要对内部的lab和layer层做处理
        _secondSelect = NO;
        [self.delegate menuClickWithIndex:tapIndex];
        CAShapeLayer *layer = (CAShapeLayer *)_layerArrays[tapIndex];
        UILabel *lab = (UILabel *)[self viewWithTag:(tapIndex+5555)];
        [self changeSelectIndex:tapIndex andLayer:layer andLabel:lab show:YES];
        //反转其他的已经选中的
        CAShapeLayer *layer1 = (CAShapeLayer *)_layerArrays[_selectedIndex];
        UILabel *lab1 = (UILabel *)[self viewWithTag:_selectedIndex+5555];
        [self changeSelectIndex:_selectedIndex andLayer:layer1 andLabel:lab1 show:NO];
    }
    _selectedIndex = tapIndex;
    
}

- (void)changeSelectIndex:(NSInteger)index andLayer:(CAShapeLayer *)layer andLabel:(UILabel *)lab show:(BOOL)nowshow
{
    //点击时三角的动画
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = nowshow ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];
    
    if (!anim.removedOnCompletion) {
        [layer addAnimation:anim forKey:anim.keyPath];
    } else {
        [layer addAnimation:anim forKey:anim.keyPath];
        [layer setValue:anim.values.lastObject forKeyPath:anim.keyPath];
    }
    
    [CATransaction commit];
    
    if (nowshow) {
        layer.fillColor = [UIColor redColor].CGColor;
        lab.textColor = [UIColor redColor];
    } else {
        layer.fillColor = [UIColor blackColor].CGColor;
        lab.textColor = [UIColor blackColor];
    }
}

@end
