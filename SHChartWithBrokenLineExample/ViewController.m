//
//  ViewController.m
//  SHChartWithBrokenLineExample
//
//  Created by SunHong on 15/11/17.
//  Copyright © 2015年 Sunhong. All rights reserved.
//

#import "ViewController.h"

#import "PNChart.h"
#import "SHBarChartBrokenLine.h"

@interface ViewController ()

@property (nonatomic) SHBarChartBrokenLine * barChart;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //初始化坐标轴和bar
    [self createBarChartBar];
    [self upDateBarChart];
}

//For Bar Chart
- (void)createBarChartBar {
    //前面加了个$符号
    static NSNumberFormatter *barChartFormatter;
    if (!barChartFormatter){
        barChartFormatter = [[NSNumberFormatter alloc] init];
        barChartFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        barChartFormatter.allowsFloats = NO;
        barChartFormatter.maximumFractionDigits = 0;
    }
    
    self.barChart = [[SHBarChartBrokenLine alloc] initWithFrame:CGRectMake(0, 100.0, SCREEN_WIDTH, 300.0)];
    
    self.barChart.backgroundColor = PNWhite;
    self.barChart.yLabelFormatter = ^(CGFloat yValue){
        return [barChartFormatter stringFromNumber:[NSNumber numberWithFloat:yValue]];
    };
    
    //改变 柱子的高度 和总体与视图的相对布局
    self.barChart.yChartLabelWidth = 20.0;
    
    self.barChart.chartMarginLeft = 30.0;
    self.barChart.chartMarginRight = 10.0;
    self.barChart.chartMarginTop = 5.0;
    self.barChart.chartMarginBottom = 10.0;
    
    self.barChart.labelMarginTop = 0.0;
    self.barChart.barRadius = 5;
    
    self.barChart.showChartBorder = YES;
    
    self.barChart.labelTextColor = [UIColor redColor];
    
    [self.barChart setXLabels:@[@"Mon",@"Thues",@"Wednes",@"Thurs",@"Fri",@"Satur",@"Sun"]];
    
    self.barChart.yLabels = @[@0,@10,@20,@30,@40,@50,@70,@80];

    
    self.barChart.barBackgroundColor = [UIColor clearColor];
    NSArray *line1 = @[@-10.82,@1.88,@6.96,@20.93,@10.82,@6.96,@33.93];
    NSArray *line2 = @[@-22.5,@54.3,@15.7,@30.1,@42.3,@57.4,@43.7];
    NSArray *line3 = @[@10.82,@20.87,@48.88,@32.98,@76.34,@11.00,@11];
    [self.barChart setYValues:@[line1,line2,line3]];
    
    //    self.barChart.showLevelLine = YES;//显示负数
    
    //    self.barChart.brokenLineColor = PNBlue;
    
    //下面两个属性 strokeColor会影响strokeColors属相
    //    self.barChart.strokeColor = PNGreen;
    [self.barChart setStrokeColors:@[PNGreen,PNLightBlue,PNRed,PNStarYellow,PNBlue,PNYellow,PNTwitterColor,
                                     PNTwitterColor,PNStarYellow,PNBlue,PNGreen,PNGreen,PNStarYellow,PNLightBlue,
                                     PNRed,PNRed,PNStarYellow,PNGreen,PNTwitterColor,PNLightBlue,PNYellow]];
    
    self.barChart.isGradientShow = NO;
    self.barChart.isShowNumbers = NO;
    
    [self.barChart strokeChart];
    [self.view addSubview:self.barChart];
    
}

//test barChart
- (void)upDateBarChart {
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(50, height-60, 200, 50);
    [btn setBackgroundColor:[UIColor greenColor]];
    [btn setTitle:@"重置" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(changeValues) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

/**
 *  动态改变柱状图的值
 */
- (void)changeValues {
    
    NSArray *line1 = @[@-10.82,@1.88,@6.96,@20.93,@10.82,@6.96,@33.93];
    NSArray *line2 = @[@"-22.5",@"54.3",@"15.7",@"30.1",@"42.3",@"77.4",@"43.7"];
    [self.barChart updateChartData:@[line2,line1]];
    
    //注意：至少需要给brokenLineColor、strokeColor、strokeColors中任意一个赋值，否则 虚线不显示
    self.barChart.brokenLineColor = PNGreen;
    
    [self.barChart strokeChart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
