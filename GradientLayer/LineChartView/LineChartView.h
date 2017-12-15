//
//  LineChartView.h
//  GradientLayer
//
//  Created by MenThu on 2017/12/14.
//  Copyright © 2017年 MenThu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoldLineData.h"

@interface LineChartView : UIView

/**
 *  基准步数
 *  默认为10000
 **/
@property (nonatomic, assign) NSInteger standardWalk;

/**
 *  基准步数高度所占坐标轴比例
 *  默认为0.5
 **/
@property (nonatomic, assign) CGFloat standardProportion;

/**
 *  行走的数据
 **/
@property (nonatomic, strong) FoldLineData *chartData;

/**
 *  开始路线渐变
 **/
- (void)startAnimation;

/**
 *  暂时路线渐变
 **/
- (void)pauseAnimation;

/**
 *  pause后调用
 **/
- (void)restartTimer;

@end
