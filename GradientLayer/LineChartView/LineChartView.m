//
//  LineChartView.m
//  GradientLayer
//
//  Created by MenThu on 2017/12/14.
//  Copyright © 2017年 MenThu. All rights reserved.
//

#define MTColor(r,g,b,a)     [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:a]
#define MTRandomColor      MTColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), 1.f)
#define VerticalSpace 5.f

#import "LineChartView.h"
#import "UIColor+Work.h"
#import "MTTimer.h"

@interface LineChartView ()

@property (nonatomic, weak) CAGradientLayer *backGradientLayer;
@property (nonatomic, weak) UILabel *hintLabel;//'步数标签'
@property (nonatomic, weak) UILabel *theVeryDayWalkCount;//'当天步数'
@property (nonatomic, weak) CAShapeLayer *topLine;//'步数标签下方的横线'
@property (nonatomic, weak) CAShapeLayer *middleDashLine;//'参考虚线'
@property (nonatomic, weak) CATextLayer *textLayer;//'参考值'
@property (nonatomic, weak) CAShapeLayer *bottomLine;//'步数标签下方的横线'
@property (nonatomic, weak) CAShapeLayer *animateLayer;//'更改frame，产生动画效果的layer'
@property (nonatomic, assign) CGRect animataterLayerFrame;//'正常宽度'
@property (nonatomic, weak) CAGradientLayer *white2ClearLayer;//'折线下方的渐变层'
@property (nonatomic, weak) CAShapeLayer *foldLineLayer;//'折线'
@property (nonatomic, weak) CAShapeLayer *dotLayer;//'折线的点点'
@property (nonatomic, strong) UIBezierPath *circlePath;//'圆点的路径'
@property (nonatomic, strong) NSArray <NSValue *> *foldPointArray;//'相对于white2ClearLayer，转折点的坐标'
@property (nonatomic, strong) NSMutableArray <UILabel *> *bottomLabelArray;//'底部表坐标label'
@property (nonatomic, assign) CGFloat bottomLabelHeight;//底部label的高度
@property (nonatomic, strong) MTTimer *animateTimer;
@property (nonatomic, assign) NSInteger timerCount;
@property (nonatomic, assign) BOOL isAnimationOn;//'是否正在执行动画'

@end

@implementation LineChartView

#pragma mark - LifeCircle
- (instancetype)init{
    if (self = [super init]) {
        [self configView];
    }
    return self;
}

#pragma mark - Public
- (void)startAnimation{
    if (_isAnimationOn == YES) {
        NSLog(@"1111");
        return;
    }
    NSLog(@"2222");
    _isAnimationOn = YES;
    __weak typeof(self) weakSelf = self;
    self.animateLayer.hidden = YES;
    self.timerCount = 0;
    self.animateLayer.frame = CGRectMake(self.animataterLayerFrame.origin.x, self.animataterLayerFrame.origin.y, 0, self.animataterLayerFrame.size.height);
    self.animateLayer.masksToBounds = YES;
    self.white2ClearLayer.locations = @[@0, @0];
    self.dotLayer.path = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.animateLayer.hidden = NO;
        [weakSelf.animateTimer startTimer];
    });
}

- (void)pauseAnimation{
    [self.animateTimer pauseTimer];
}

- (void)restartTimer{
    [self.animateTimer startTimer];
}

#pragma mark - Private
- (void)configView{
    _isAnimationOn = NO;
    _standardWalk = 10000;
    _standardProportion = 0.5;
    _bottomLabelHeight = 20.f;
    _bottomLabelArray = @[].mutableCopy;
    [self addBackGradientLayer];
    [self addTitleLabel];
    [self drawLineLayer];
}

/**
 *  画上方，中间，底部的线条
 **/
- (void)drawLineLayer{
    CGColorRef lineColor = [UIColor colorWithHexString:@"FFFFFF" alpha:0.3].CGColor;
    CGFloat lineWidth = 0.7f;
    
    CAShapeLayer *topLine = [CAShapeLayer layer];
    topLine.lineWidth = lineWidth;
    topLine.strokeColor = lineColor;
    [self.layer addSublayer:(_topLine = topLine)];
    
    //画底部坐标线
    CAShapeLayer *bottomLine = [CAShapeLayer layer];
    bottomLine.lineWidth = lineWidth;
    bottomLine.strokeColor = lineColor;
    [self.layer addSublayer:(_bottomLine = bottomLine)];
    
    //画参考虚线(一万步)
    CAShapeLayer *middleDashLine = [CAShapeLayer layer];
    middleDashLine.lineDashPattern = @[@3.f, @1.5f];
    middleDashLine.strokeColor = lineColor;
    middleDashLine.lineWidth = 1;
    [self.layer addSublayer:(_middleDashLine = middleDashLine)];
    
    //增加文字layer
    [self addTextLayer];
    
    CAShapeLayer *animateLayer = [CAShapeLayer layer];
    animateLayer.masksToBounds = YES;
    [self.layer addSublayer:(_animateLayer = animateLayer)];
    
    //增加白色到透明的渐变
    CGColorRef startColor = [UIColor colorWithHexString:@"FFFFFF" alpha:0.7].CGColor;
    CGColorRef endColor = [UIColor colorWithHexString:@"FFFFFF" alpha:0].CGColor;
    CAGradientLayer *white2ClearLayer = [CAGradientLayer layer];
    white2ClearLayer.startPoint = CGPointZero;
    white2ClearLayer.endPoint = CGPointMake(0, 1);
    white2ClearLayer.colors = @[(__bridge id)startColor, (__bridge id)endColor];
    white2ClearLayer.locations = @[@0.f, @0.f];
    [animateLayer addSublayer:(_white2ClearLayer = white2ClearLayer)];
    
    //折线
    CAShapeLayer *foldLineLayer = [CAShapeLayer layer];
    foldLineLayer.fillColor = [UIColor clearColor].CGColor;
    foldLineLayer.lineWidth = 1.5f;
    foldLineLayer.strokeColor = [UIColor whiteColor].CGColor;
    [animateLayer addSublayer:(_foldLineLayer = foldLineLayer)];
    
    //折线上面的点
    CAShapeLayer *dotLayer = [CAShapeLayer layer];
    dotLayer.strokeColor = [UIColor clearColor].CGColor;
    dotLayer.fillColor = [UIColor whiteColor].CGColor;
    [animateLayer addSublayer:(_dotLayer = dotLayer)];
}

/**
 *  虚线右侧指示值
 **/
- (void)addTextLayer{
    CGColorRef lineColor = [UIColor colorWithHexString:@"FFFFFF" alpha:0.3].CGColor;
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.contentsScale = [UIScreen mainScreen].scale;//解决屏幕模糊
    textLayer.foregroundColor = lineColor;
    textLayer.alignmentMode = kCAAlignmentJustified;
    textLayer.wrapped = YES;
    UIFont *font = [UIFont systemFontOfSize:13];
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    textLayer.font = fontRef;
    textLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    NSString *text = @"1w";
    textLayer.string = text;
    [self.layer addSublayer:(_textLayer = textLayer)];
}

/**
 *  增加背景色渐变层
 **/
- (void)addBackGradientLayer{
    CGColorRef startColor = [UIColor colorWithHexString:@"19BC85"].CGColor;
    CGColorRef endColor = [UIColor colorWithHexString:@"159A9D"].CGColor;
    CAGradientLayer *backGradientLayer = [[CAGradientLayer alloc] init];
    if (CGRectEqualToRect(CGRectZero, self.bounds) == NO) {
        backGradientLayer.frame = self.layer.bounds;
    }
    backGradientLayer.startPoint = CGPointZero;
    backGradientLayer.endPoint = CGPointMake(1, 0);
    backGradientLayer.colors = @[(__bridge id)startColor, (__bridge id)endColor];
    backGradientLayer.locations = @[@0.f, @1.f];
    [self.layer addSublayer:(_backGradientLayer = backGradientLayer)];
}

/**
 *  增加标签Label
 **/
- (void)addTitleLabel{
    UIFont *font = [UIFont systemFontOfSize:36];
    UIColor *textColor = [UIColor whiteColor];
    
    UILabel *hintLabel = [UILabel new];
    hintLabel.text = @"步数";
    hintLabel.font = font;
    hintLabel.textColor = textColor;
    [self addSubview:(_hintLabel = hintLabel)];
    
    UILabel *theVeryDayWalkCount = [UILabel new];
    theVeryDayWalkCount.text = @"  ";
    theVeryDayWalkCount.font = font;
    theVeryDayWalkCount.textColor = textColor;
    [self addSubview:(_theVeryDayWalkCount = theVeryDayWalkCount)];
}

/**
 *  更改子控件Frame
 **/
- (void)changeSubViewsFrame{
    if ([self canDrawFoldLine] == NO) {
        return;
    }
    self.backGradientLayer.frame = self.layer.bounds;
    
    //'步数'
    CGFloat hintLabelHeight = self.hintLabel.font.lineHeight;
    CGFloat hintLabelX = 10;
    CGFloat hintLabelY = VerticalSpace;
    CGSize hintLabelMaxSize = CGSizeMake(MAXFLOAT, hintLabelHeight);
    CGFloat hintLabelWidth = [self.hintLabel sizeThatFits:hintLabelMaxSize].width;
    self.hintLabel.frame = CGRectMake(hintLabelX, hintLabelY, hintLabelWidth, hintLabelHeight);
    
    //'当日步数'
    CGFloat theVeryDayWalkCountWidth = [self.theVeryDayWalkCount sizeThatFits:hintLabelMaxSize].width;
    CGFloat theVeryDayWalkCountX = self.bounds.size.width - hintLabelX - theVeryDayWalkCountWidth;
    self.theVeryDayWalkCount.frame = CGRectMake(theVeryDayWalkCountX, hintLabelY, theVeryDayWalkCountWidth, hintLabelHeight);
    
    //上方横线
    CGPoint topLineStartPoint = CGPointMake(hintLabelX, CGRectGetMaxY(self.hintLabel.frame)+VerticalSpace);
    CGPoint topLineEndPoint = CGPointMake(CGRectGetMaxX(self.theVeryDayWalkCount.frame), topLineStartPoint.y);
    CGMutablePathRef topLinePath = CGPathCreateMutable();
    CGPathMoveToPoint(topLinePath, NULL, topLineStartPoint.x, topLineStartPoint.y);
    CGPathAddLineToPoint(topLinePath, NULL, topLineEndPoint.x, topLineEndPoint.y);
    self.topLine.path = topLinePath;
    CGPathRelease(topLinePath);
    
    //布局底部label
    [self changeBottomLabelFrame];
    
    //底部坐标线
    CGPoint bottomLineStartPoint = CGPointMake(topLineStartPoint.x, self.frame.size.height - VerticalSpace - _bottomLabelHeight - VerticalSpace - self.bottomLine.lineWidth);
    CGPoint bottomLineEndPoint = CGPointMake(topLineEndPoint.x, bottomLineStartPoint.y);
    CGMutablePathRef bottomLinePath = CGPathCreateMutable();
    CGPathMoveToPoint(bottomLinePath, NULL, bottomLineStartPoint.x, bottomLineStartPoint.y);
    CGPathAddLineToPoint(bottomLinePath, NULL, bottomLineEndPoint.x, bottomLineEndPoint.y);
    self.bottomLine.path = bottomLinePath;
    CGPathRelease(bottomLinePath);
    
    //渐变层
    CGFloat animateLayerX = hintLabelX;
    CGFloat animateLayerY = topLineStartPoint.y;
    CGFloat animateLayerWidth = self.frame.size.width - 2*animateLayerX;
    CGFloat animateLayerHeight = self.frame.size.height - animateLayerY - _bottomLabelHeight - 2*VerticalSpace;
    self.animataterLayerFrame = CGRectMake(animateLayerX, animateLayerY, animateLayerWidth, animateLayerHeight);
    self.animateLayer.frame = CGRectMake(self.animataterLayerFrame.origin.x, self.animataterLayerFrame.origin.y, 0, self.animataterLayerFrame.size.height);
    self.white2ClearLayer.frame = CGRectMake(0, 0, self.animataterLayerFrame.size.width, self.animataterLayerFrame.size.height);
    self.foldLineLayer.frame = self.white2ClearLayer.frame;
    self.dotLayer.frame = self.white2ClearLayer.frame;
    
    [self reDrawGradientFoldLine];
}

/**
 *  更改底部label的frame
 **/
- (void)changeBottomLabelFrame{
    CGFloat originX = CGRectGetMinX(self.hintLabel.frame);
    CGFloat originY = self.frame.size.height - VerticalSpace - _bottomLabelHeight;
    //第一个与最后一个label只有其余label的0.5
    CGFloat labelWidth = (self.frame.size.width - 2*originX) / (self.bottomLabelArray.count-1);
    CGRect firstFrame = CGRectMake(originX, originY, labelWidth/2, _bottomLabelHeight);
    self.bottomLabelArray[0].frame = firstFrame;
    originX = CGRectGetMaxX(firstFrame);
    for (NSInteger index = 1; index < self.bottomLabelArray.count-1; index ++) {
        CGRect tempFrame = CGRectMake(originX, firstFrame.origin.y, labelWidth, _bottomLabelHeight);
        self.bottomLabelArray[index].frame = tempFrame;
        originX = CGRectGetMaxX(tempFrame);
    }
    self.bottomLabelArray.lastObject.frame = CGRectMake(originX, firstFrame.origin.y, labelWidth/2, _bottomLabelHeight);
}

/**
 *  是否可以绘制折线图
 **/
- (BOOL)canDrawFoldLine{
    if (CGSizeEqualToSize(CGSizeZero, self.bounds.size)) {
        return NO;
    }
    if (self.isAnimationOn == YES) {
        return NO;
    }
    if ([self.chartData isKindOfClass:[FoldLineData class]] == NO
        ||
        [self.chartData.walkArray isKindOfClass:[NSArray class]] == NO
        ||
        self.chartData.walkArray.count <= 0) {
        return NO;
    }
    if (self.standardWalk <= 0) {
        return NO;
    }
    if (self.standardProportion <= 0 ) {
        return NO;
    }
    return YES;
}

/**
 *  重新绘制渐变折线图
 **/
- (void)reDrawGradientFoldLine{
    if ([self canDrawFoldLine] == NO) {
        return;
    }
    CGFloat bottomLineY = CGRectGetMaxY(self.animateLayer.frame);
    CGFloat coordinateSystemHeight = CGRectGetHeight(self.animateLayer.frame);
    CGFloat standardHeight = _standardProportion * coordinateSystemHeight;
    CGFloat everyWalkValue = standardHeight / _standardWalk;
    CGFloat standardY = bottomLineY - standardHeight;
    
    //参考textLayer
    CGFloat textLayerWidth = 15.f;
    CGFloat textLayerHeight = 15.f;
    CGFloat textLayerX = CGRectGetWidth(self.frame) - 2 - textLayerWidth;
    CGFloat textLayerY = standardY - textLayerHeight/2;
    self.textLayer.frame = CGRectMake(textLayerX, textLayerY, textLayerWidth, textLayerHeight);
    
    //参考虚线
    CGFloat standardStartX = CGRectGetMinX(self.hintLabel.frame);
    CGFloat standardEndX = CGRectGetMinX(self.textLayer.frame) - 4;
    CGMutablePathRef middleDashLinePath = CGPathCreateMutable();
    CGFloat dashLineStartY = standardY - self.middleDashLine.lineWidth/2;
    CGPathMoveToPoint(middleDashLinePath, NULL, standardStartX, dashLineStartY);
    CGPathAddLineToPoint(middleDashLinePath, NULL, standardEndX, dashLineStartY);
    self.middleDashLine.path = middleDashLinePath;
    CGPathRelease(middleDashLinePath);
    
    CGMutablePathRef clipPath = CGPathCreateMutable();//裁剪路径
    CGMutablePathRef foldLinePath = CGPathCreateMutable();//折线路径
    UIBezierPath *circlePath = [UIBezierPath bezierPath];//折线转角圆点
    CGFloat circleRadius = 3.f;

    NSDictionary *firstDayDict = _chartData.walkArray[0];
    NSInteger firstWalkCount = [firstDayDict[@"walkCount"] integerValue];
    CGFloat tempX = 0;
    CGFloat tempY = coordinateSystemHeight - (firstWalkCount*everyWalkValue);
    CGPathMoveToPoint(clipPath, NULL, tempX, tempY);//起点
    CGPoint startPoint = CGPointMake(tempX, tempY);
    CGPathMoveToPoint(foldLinePath, NULL, startPoint.x, startPoint.y);
    [circlePath moveToPoint:startPoint];
    [circlePath addArcWithCenter:startPoint radius:circleRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    CGFloat gradientX = CGRectGetMinX(self.animateLayer.frame);
    for (NSInteger index = 1; index < _chartData.walkArray.count; index ++) {
        NSDictionary *dict = _chartData.walkArray[index];
        NSInteger walkCount = [dict[@"walkCount"] integerValue];
        CGFloat foldPointX = CGRectGetMidX(self.bottomLabelArray[index].frame) - gradientX;
        CGFloat foldPointY = coordinateSystemHeight - (walkCount*everyWalkValue);
        CGPathAddLineToPoint(clipPath, NULL, foldPointX, foldPointY);
        CGPoint foldPoint = CGPointMake(foldPointX, foldPointY);
        CGPathAddLineToPoint(foldLinePath, NULL, foldPoint.x, foldPoint.y);
        [circlePath moveToPoint:foldPoint];
        [circlePath addArcWithCenter:foldPoint radius:circleRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
        if (index == _chartData.walkArray.count-1) {
            [circlePath addArcWithCenter:foldPoint radius:circleRadius*1.5 startAngle:0 endAngle:M_PI*2 clockwise:YES];
        }else{
            [circlePath addArcWithCenter:foldPoint radius:circleRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
        }
    }
    self.foldLineLayer.path = foldLinePath;
    CGPathRelease(foldLinePath);
    
    self.circlePath = circlePath;
    
    tempX = CGRectGetMidX(self.bottomLabelArray.lastObject.frame) - gradientX;
    tempY = coordinateSystemHeight;
    CGPathAddLineToPoint(clipPath, NULL, tempX, tempY);
    
    tempX = 0;
    tempY = coordinateSystemHeight;
    CGPathAddLineToPoint(clipPath, NULL, tempX, tempY);
    CGPathCloseSubpath(clipPath);
    
    CAShapeLayer *clipLayer = [CAShapeLayer layer];
    clipLayer.path = clipPath;
    CGPathRelease(clipPath);
    self.white2ClearLayer.mask = clipLayer;
}

#pragma mark - Getter
- (MTTimer *)animateTimer{
    if (_animateTimer == nil) {
        __weak typeof(self) weakSelf = self;
        CGFloat interVal = 1/60.f;
        NSInteger totalSec = 3;
        CGFloat addWidthPerInterval = (self.animataterLayerFrame.size.width / totalSec) * interVal;
        MTTimerInfo *timerInfo = [MTTimerInfo new];
        timerInfo.timeInterval = interVal;
        timerInfo.countBlock = ^(NSInteger count, CGFloat interval) {
            CGFloat currentWidth = ++weakSelf.timerCount*addWidthPerInterval;
            if (currentWidth >= weakSelf.animataterLayerFrame.size.width) {
                currentWidth = weakSelf.animataterLayerFrame.size.width;
                [weakSelf.animateTimer pauseTimer];
                weakSelf.animateLayer.masksToBounds = NO;
                [UIView animateWithDuration:0.25 animations:^{
                    weakSelf.white2ClearLayer.locations = @[@0.f, @1.f];
                    weakSelf.dotLayer.path = weakSelf.circlePath.CGPath;
                } completion:^(BOOL finished) {
                    if (finished) {
                        weakSelf.isAnimationOn = NO;
                    }
                }];
            }
            weakSelf.animateLayer.frame = CGRectMake(weakSelf.animataterLayerFrame.origin.x, weakSelf.animataterLayerFrame.origin.y, currentWidth, weakSelf.animataterLayerFrame.size.height);
        };
        _animateTimer = [MTTimer createWith:timerInfo];
    }
    return _animateTimer;
}

#pragma mark - Setter
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self changeSubViewsFrame];
}

- (void)setChartData:(FoldLineData *)chartData{
    if (self.isAnimationOn) {
        return;
    }
    _chartData = chartData;
    //生成底部label
    NSInteger minusCount = self.bottomLabelArray.count - chartData.walkArray.count;
    if (minusCount > 0) {//有多余label,多余label需要删除
        for (NSInteger index = chartData.walkArray.count; index < self.bottomLabelArray.count; index++) {
            [self.bottomLabelArray[index] removeFromSuperview];
        }
        [self.bottomLabelArray removeObjectsInRange:NSMakeRange(chartData.walkArray.count, minusCount)];
    }else if (minusCount < 0){//label不够，需要继续生成
        for (NSInteger index = 0; index < -minusCount; index ++) {
            UILabel *label = [UILabel new];
            label.backgroundColor = [UIColor clearColor];
            label.alpha = 0.6;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:11];
            [self addSubview:label];
            [self.bottomLabelArray addObject:label];
        }
    }
    for (NSInteger index = 0; index < self.bottomLabelArray.count; index ++) {
        self.bottomLabelArray[index].text = [chartData.walkArray[index] objectForKey:@"walkDate"];
    }
    self.theVeryDayWalkCount.text = [NSString stringWithFormat:@"%@", _chartData.walkArray.lastObject[@"walkCount"]];
    [self changeSubViewsFrame];
}

- (void)setStandardWalk:(NSInteger)standardWalk{
    if (_standardWalk == standardWalk) {
        return;
    }
    _standardWalk = standardWalk;
    [self reDrawGradientFoldLine];//只需要更改折线图就可以了
}

- (void)setStandardProportion:(CGFloat)standardProportion{
    if (_standardProportion == standardProportion) {
        return;
    }
    _standardProportion = standardProportion;
    [self reDrawGradientFoldLine];//只需要更改折线图就可以了
}

@end
