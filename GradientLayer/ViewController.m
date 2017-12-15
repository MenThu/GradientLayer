//
//  ViewController.m
//  GradientLayer
//
//  Created by MenThu on 2017/12/6.
//  Copyright © 2017年 MenThu. All rights reserved.
//

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "UIColor+Work.h"
#import "UIImage+Clip.h"
#import "LineChartView.h"
#import "MTTimer.h"

@interface ViewController ()

@property (nonatomic, strong) MTTimer *tempTimer;
@property (nonatomic, weak) LineChartView *chartView;
@property (nonatomic, weak) UIButton *restartBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat width = kScreenWidth - 20;
    CGFloat height = 300;
    CGFloat x = kScreenWidth/2 - width/2;
    CGFloat y = kScreenHeight/2- height/2;
    CGRect chartFrame = CGRectMake(x, y, width, height);
    LineChartView *chartView = [[LineChartView alloc] init];
    chartView.layer.cornerRadius = 8.f;
    chartView.layer.masksToBounds = YES;
    chartView.standardProportion = 0.5;
    chartView.frame = chartFrame;
    [self.view addSubview:(_chartView = chartView)];
    
    UIButton *restartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    restartBtn.layer.cornerRadius = 8.f;
    restartBtn.backgroundColor = [UIColor orangeColor];
    restartBtn.titleLabel.font = [UIFont systemFontOfSize:18.f];
    [restartBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [restartBtn setTitle:@"绘图" forState:UIControlStateNormal];
    [restartBtn addTarget:self action:@selector(reDrawChartView) forControlEvents:UIControlEventTouchUpInside];
    CGFloat btnWidth = 200;
    CGFloat btnHeight = 80;
    CGFloat btnX = kScreenWidth/2 - btnWidth/2;
    CGFloat btnY = CGRectGetMaxY(chartView.frame) + 20;
    restartBtn.frame = CGRectMake(btnX, btnY, btnWidth, btnHeight);
    [self.view addSubview:(_restartBtn = restartBtn)];
    
    [self reDrawChartView];
}

- (void)reDrawChartView{
    [self prePareData];
    [self.chartView startAnimation];
}

- (void)prePareData{
    NSMutableDictionary *day1 = @{}.mutableCopy;
    day1[@"walkDate"] = @"12月8";
    
    NSMutableDictionary *day2 = @{}.mutableCopy;
    day2[@"walkDate"] = @"9";
    
    NSMutableDictionary *day3 = @{}.mutableCopy;
    day3[@"walkDate"] = @"10";
    
    NSMutableDictionary *day4 = @{}.mutableCopy;
    day4[@"walkDate"] = @"11";
    
    NSMutableDictionary *day5 = @{}.mutableCopy;
    day5[@"walkDate"] = @"12";
    
    NSMutableDictionary *day6 = @{}.mutableCopy;
    day6[@"walkDate"] = @"13";
    
    NSMutableDictionary *day7 = @{}.mutableCopy;
    day7[@"walkDate"] = @"14";
    
    NSArray <NSMutableDictionary *> *lastSeveDayArray = @[day1, day2, day3, day4, day5, day6, day7];
    for (NSMutableDictionary *dict in lastSeveDayArray) {
        dict[@"walkCount"] = @(arc4random_uniform(10000) + 3000);
    }
    FoldLineData *chartViewData = [[FoldLineData alloc] init];
    chartViewData.walkArray = lastSeveDayArray;
    self.chartView.chartData = chartViewData;
}




@end
