//
//  SHBarChartBrokenLine.m
//  SHChartWithBrokenLineExample
//
//  Created by SunHong on 15/11/17.
//  Copyright © 2015年 Sunhong. All rights reserved.
//

#import "SHBarChartBrokenLine.h"

#import "PNChartDelegate.h"

@interface SHBarChartBrokenLine () <PNChartDelegate>

//区分 点击的位置是否发生了变化以及是否点击
@property (nonatomic, assign) NSInteger touchIndex;//记录上一次点击的柱子索引
@property (nonatomic, assign) CGPoint fromValue;//记录前一次点击的位置
@property (nonatomic, assign) CGFloat brokenLineXvalue;
@property (nonatomic, assign) BOOL isCreateLineLayer;

@property (nonatomic, assign) NSInteger beforeIndexChildAry;
@property (nonatomic, assign) NSInteger indexChildAry;
@property (nonatomic, assign) CGFloat brokeLineXValue;

@property (nonatomic, strong) UIView * lineLayerMaskView;
@property (nonatomic, strong) CAShapeLayer * lineLayer;

@property (nonatomic, strong) UIView * maskView;
@property (nonatomic, strong) UILabel * yValueLabel;

@end

@implementation SHBarChartBrokenLine

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initFlagsValues];
    }
    return self;
}

- (void)initFlagsValues {
    //初始化
    _touchIndex = -1;
    _fromValue.x = -1;
    _isCreateLineLayer = NO;
    
    _brokenLineColor = nil;
    
    _beforeIndexChildAry = -1;
    
    self.delegate = self;
    
    if (_maskView) {
        [_lineLayerMaskView removeFromSuperview];
        [_maskView removeFromSuperview];
        [_yValueLabel removeFromSuperview];
        [_lineLayer removeFromSuperlayer];
    }
    
    //初始化bar上显示详情的label
    [self createBarChartLabel];
    
    //初始化bar上的竖直虚线
    [self createBarChartBrokenLine];
}

//初始化bar上显示详情的label
- (void)createBarChartLabel {
    //初始化 显示label的视图 背景透明黑色
    self.maskView = [[UIView alloc] initWithFrame:CGRectZero];//需要改变的数值
    
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = .4;
    self.maskView.userInteractionEnabled = NO;
    
    self.maskView.layer.cornerRadius = 5;
    self.maskView.layer.borderColor = [UIColor grayColor].CGColor;
    
    [self addSubview:self.maskView];
    
    //初始化 显示详情的label
    self.yValueLabel = [[UILabel alloc] initWithFrame:self.maskView.frame];
    self.yValueLabel.numberOfLines = self.yValues.count;
    self.yValueLabel.textAlignment = NSTextAlignmentLeft;
    self.yValueLabel.backgroundColor = [UIColor clearColor];
    self.yValueLabel.textColor = [UIColor whiteColor];
    
    self.yValueLabel.userInteractionEnabled = NO;
    //    self.yValueLabel.text = labelText;//需要改变的数值
    
    [self.yValueLabel sizeToFit];
    
    [self addSubview:self.yValueLabel];
}

//初始化bar上的竖直虚线
- (void)createBarChartBrokenLine {
    //create shape layer
    CAShapeLayer * beforeLineLayer = [CAShapeLayer layer];
    
    beforeLineLayer.strokeColor = [UIColor clearColor].CGColor;
    beforeLineLayer.fillColor = [UIColor clearColor].CGColor;
    beforeLineLayer.lineWidth = 3;
    beforeLineLayer.lineJoin = kCALineJoinRound;
    beforeLineLayer.lineCap = kCALineCapRound;
    
    beforeLineLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:10], [NSNumber numberWithInt:10], [NSNumber numberWithInt:10], [NSNumber numberWithInt:10], nil];
    
    self.lineLayer = beforeLineLayer;
    
    self.lineLayerMaskView = [[UIView alloc] init];
    self.lineLayerMaskView.backgroundColor = [UIColor clearColor];
    [self insertSubview:self.lineLayerMaskView belowSubview:self.maskView];
}

#pragma mark - PNChartDelegate
#pragma mark - Bar Chart Delegate
- (void)userClickedOnBarAtIndex:(NSInteger)barIndex atPoint:(CGPoint)touchPoint{
    
    //随着点击事件 改变 bar的透明度
    [self barChartAlphaChangesWithBarIndex:barIndex];
    
    //让label飞起来
    [self barChartLabelMoveAtIndex:barIndex atPoint:touchPoint];
    
    //移动虚线
    if (!_isCreateLineLayer) {
        [self barChartLabelLineDrawPathAtIndex:barIndex];
    } else {
        [self barChartLabelLineMoveAtIndex:barIndex];
    }
}

/**
 *  随着点击事件 改变 bar的透明度
 *
 *  @param barIndex bar的索引值
 */
- (void)barChartAlphaChangesWithBarIndex:(NSInteger)barIndex {
    PNBar * beforeBar;
    PNBar * beforeBarNext;
    PNBar * beforeBarNextTo;
    
    NSArray * childAry = self.yValues[0];
    NSInteger childCount = childAry.count;
    
    NSInteger subCount;
    NSInteger subDCount;
    NSInteger addCount;
    NSInteger addDCount;
    
    if (_touchIndex >= 0) {
        
        subCount = _touchIndex - childCount;
        subDCount = _touchIndex - childCount*2;
        addCount = _touchIndex + childCount;
        addDCount = _touchIndex + childCount*2;
        
        beforeBar = self.bars[_touchIndex];

        if (_touchIndex < childAry.count) {
            
            if (self.yValues.count > 1) {
                //2.
                beforeBarNext = self.bars[addCount];
            }
            if (self.yValues.count > 2) {
                //3.
                beforeBarNextTo = self.bars[addDCount];
            }
            
            
        } else if (_touchIndex < childCount*2){
            //1.
            beforeBarNext = self.bars[subCount];
            if (self.yValues.count > 2) {
                //3.
                beforeBarNextTo = self.bars[addCount];
            }
            
        } else {
            //确信 并排 3个柱子以上
            //2.
            beforeBarNext = self.bars[subCount];
            //1.
            beforeBarNextTo = self.bars[subDCount];
        }
    }
    
    PNBar * nowBar = [self.bars objectAtIndex:barIndex];
    PNBar * nowBarNext = [[PNBar alloc] init];
    PNBar * nowBarNextTo = [[PNBar alloc] init];
    
    subCount = barIndex - childAry.count;
    subDCount = barIndex - childAry.count*2;
    addCount = barIndex + childAry.count;
    addDCount = barIndex + childAry.count*2;
    
    //3.
    if (barIndex >= childCount*2) {
        nowBarNext = self.bars[subCount];
        nowBarNextTo = self.bars[subDCount];
        
        //2.
    } else if (barIndex >= childCount){
        //1.
        nowBarNextTo = self.bars[subCount];
        if (self.yValues.count > 2) {
            //3.
            nowBarNext = self.bars[addCount];
        }
        
        //1.
    } else {
        if (self.yValues.count > 2) {
            //3.
            nowBarNext = self.bars[addDCount];
        }
        if (self.yValues.count > 1) {
            //2.
            nowBarNextTo = self.bars[addCount];
        }
    }
    
    self.touchIndex = barIndex;
    
    //实现柱子颜色的改变
    [UIView animateWithDuration:.2 animations:^{
        beforeBar.alpha = 1;
        beforeBarNext.alpha = 1;
        beforeBarNextTo.alpha = 1;
        
        nowBar.alpha = .5;
        nowBarNext.alpha = .5;
        nowBarNextTo.alpha = .5;
    }];
}

/**
 *  label飞起来
 *
 *  @param barIndex   点击的bar的索引位置 索引从0开始
 *  @param touchPoint 手势点击的 点坐标
 */
- (void)barChartLabelMoveAtIndex:(NSInteger)barIndex atPoint:(CGPoint)touchPoint {
    
    CGFloat labelX;
    
    [self setPropertiesValueByBarIndex:barIndex];
    
    NSArray * childAry = self.yValues[0];
    NSArray * nextAry = [[NSArray array] copy];
    NSArray * nextDAry = [[NSArray array] copy];
    
    NSString * yLabelText;
    
    
    switch (self.yValues.count) {
        case 1:
            yLabelText = [NSString stringWithFormat:@"%@",childAry[_indexChildAry]];
            break;
        case 2:
            nextAry = self.yValues[1];
            yLabelText = [NSString stringWithFormat:@"%@\n%@",childAry[_indexChildAry],nextAry[_indexChildAry]];
            break;
        case 3:
            nextAry = self.yValues[1];
            nextDAry = self.yValues[2];
            yLabelText = [NSString stringWithFormat:@"%@\n%@\n%@",childAry[_indexChildAry],nextAry[_indexChildAry],nextDAry[_indexChildAry]];
            break;
        default:
            NSLog(@"浮动label显示详细数据出错-让label飞起来");
            break;
    }
    
    labelX = (_indexChildAry + 1.5) * self.xLabelWidth;
    
    _yValueLabel.text = yLabelText;
    
    //记录点击的位置
    CGFloat labelY = touchPoint.y;
    
    CGPoint toValue = CGPointMake(labelX, labelY);
    
    self.maskView.frame = CGRectMake(labelX, labelY, 50, self.yValues.count*30);
    self.yValueLabel.frame = self.maskView.frame;
    
    [self bringSubviewToFront:self.maskView];
    [self bringSubviewToFront:self.yValueLabel];
    
    
    if (CGPointEqualToPoint(_fromValue, toValue)) {
        return;
    }
    
    if (_fromValue.x < 0) {
        _fromValue = toValue;
    }
    
    //1.创建移动动画
    CABasicAnimation * animation = [CABasicAnimation animation];
    
    animation.keyPath = @"position";
    animation.duration = .5;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    animation.fromValue = [NSValue valueWithCGPoint:_fromValue];
    animation.toValue=[NSValue valueWithCGPoint:toValue];
    
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = NO;
    
    //2.添加核心动画到layer
    [_maskView.layer addAnimation:animation forKey:@"maskView-position"];
    [_yValueLabel.layer addAnimation:animation forKey:@"yValueLabel-position"];
    
    _fromValue = toValue;
}


/**
 *  绘制虚线的path
 *
 *  @param barIndex    bar的索引
 *  @param xLabelWidth 每个x坐标的宽度
 *  @param barsCount   二维数组中每个数组的容量
 */
- (void)barChartLabelLineDrawPathAtIndex:(NSInteger)barIndex{
    PNBar * sender = [self.bars objectAtIndex:barIndex];
    
    NSArray * childAry = self.yValues[0];
    [self setPropertiesValueByBarIndex:barIndex];
    
    CGFloat yValueLineFrom = 5;
    CGFloat yValueLineTo = sender.bounds.size.height+5;
    
    //create path
    UIBezierPath * path = [[UIBezierPath alloc] init];
    
    [path moveToPoint:CGPointMake(0, yValueLineTo)];
    [path addLineToPoint:CGPointMake(0, yValueLineFrom)];
    
    _lineLayer.path = path.CGPath;
    
    //创建时 动画
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = .5;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = @0.0f;
    pathAnimation.toValue   = @1.0f;
    
    [_lineLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    _lineLayer.strokeEnd = 1.0;
    
    //1020新增 实现showLevelLine时，虚线显示在下方
    NSString * currentNumber = [NSString stringWithFormat:@"%@",childAry[_indexChildAry]];
    BOOL isNegative = [[currentNumber substringToIndex:1] isEqualToString:@"-"];
    if (isNegative && self.showLevelLine) {
        yValueLineFrom = yValueLineTo;
    }
    
    //创建
    UIColor * lineColor = sender.barColor;
    if (_brokenLineColor != nil) {
        lineColor = _brokenLineColor;
    }
    self.lineLayer.strokeColor = lineColor.CGColor;
    self.lineLayerMaskView.frame = CGRectMake(_brokeLineXValue, yValueLineFrom, 3, yValueLineTo);
    
    [self.lineLayerMaskView.layer addSublayer:self.lineLayer];
    
    _isCreateLineLayer = YES;;
}


/**
 *  移动中间的虚线
 *
 *  @param sender 点击的柱子
 */
- (void)barChartLabelLineMoveAtIndex:(NSInteger)barIndex{
    
    PNBar * sender = [self.bars objectAtIndex:barIndex];
    
    NSArray * childAry = self.yValues[0];
    
    [self setPropertiesValueByBarIndex:barIndex];
    
    if (_beforeIndexChildAry == _indexChildAry) {
        return;
    }
    _beforeIndexChildAry = _indexChildAry;
    
    CGFloat yValueLineFrom = 5;
    CGFloat yValueLineTo = sender.bounds.size.height + 5;
    
    //1020新增 实现showLevelLine时，虚线显示在下方
    NSString * currentNumber = [NSString stringWithFormat:@"%@",childAry[_indexChildAry]];
    BOOL isNegative = [[currentNumber substringToIndex:1] isEqualToString:@"-"];
    if (isNegative && self.showLevelLine) {
        yValueLineFrom = yValueLineTo;
    }
    
    UIColor * lineColor = sender.barColor;
    if (_brokenLineColor != nil) {
        lineColor = _brokenLineColor;
    }
    [UIView animateWithDuration:.5 animations:^{
        
        self.lineLayer.strokeColor = lineColor.CGColor;
        self.lineLayerMaskView.frame = CGRectMake(_brokeLineXValue, yValueLineFrom, 3, yValueLineTo);
    }];
}

#pragma mark - 对label和brokenLine操作过程中得数值计算
- (void)setPropertiesValueByBarIndex:(NSInteger)barIndex {
    
    PNBar * sender = [self.bars objectAtIndex:barIndex];
    
    _indexChildAry = barIndex;
    NSArray * childAry = self.yValues[0];
    _brokeLineXValue = sender.frame.origin.x + sender.bounds.size.width *.5;
    
    if (barIndex >= childAry.count*2) {
        
        _indexChildAry = barIndex - childAry.count*2;
        //        _childAry = self.yValues[2];
        _brokeLineXValue = sender.frame.origin.x - sender.bounds.size.width*.5;
        
    } else if (barIndex >= childAry.count) {
        
        _indexChildAry = barIndex - childAry.count;
        //        _childAry = self.yValues[1];
        _brokeLineXValue = sender.frame.origin.x;
        //3.
        if (self.yValues.count > 2) {
            _brokeLineXValue = sender.frame.origin.x + sender.bounds.size.width*.5;
        }
        
    } else {
        //3.
        if (self.yValues.count > 2) {
            _brokeLineXValue = sender.frame.origin.x + sender.bounds.size.width*1.5;
            //2.
        } else if (self.yValues.count > 1) {
            _brokeLineXValue = sender.frame.origin.x + sender.bounds.size.width;
        }
    }
}

#pragma mark - override 更新数据
-(void)updateChartData:(NSArray *)data {
    [super updateChartData:data];
    [self initFlagsValues];
}


@end
