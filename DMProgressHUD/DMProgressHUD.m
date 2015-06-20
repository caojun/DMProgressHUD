/**
 The MIT License (MIT)
 
 Copyright (c) 2015 DreamCao
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "DMProgressHUD.h"


#if DEBUG
#   define DMHUDLog(...)  NSLog(__VA_ARGS__)
#else
#   define DMHUDLog(...)
#endif


static const CGFloat kLabelFontSize = 17.0f;

@interface DMProgressHUD ()

@property (nonatomic, weak) UIView *m_backgroundView;
@property (nonatomic, weak) UIActivityIndicatorView *m_indicatorView;
@property (nonatomic, weak) UILabel *m_label;

@property (nonatomic, copy) dispatch_block_t finishBlock;

@property (nonatomic, strong) UIFont *m_statusFont;

@property (nonatomic, weak) UIView *m_superView;
@property (nonatomic, strong) NSLayoutConstraint *m_backgroundConstX;
@property (nonatomic, strong) NSLayoutConstraint *m_backgroundConstY;

@end

#pragma mark -
@implementation DMProgressHUD

- (void)dealloc
{
    DMHUDLog(@"%@ dealloc", [self class]);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

/// 显示状态
+ (instancetype)showWithStatus:(NSString *)status inView:(UIView *)inView
{
    return [self showWithStatus:status inView:inView delay:0 finishBlock:nil];
}

+ (instancetype)showWithStatus:(NSString *)status inView:(UIView *)inView delay:(NSTimeInterval)delay finishBlock:(dispatch_block_t)finishBlock
{
    DMProgressHUD *hud = [[self alloc] initWithFrame:inView.bounds];
    if (nil != hud)
    {
        [inView addSubview:hud];
        hud.m_superView = inView;
        [hud hudAutolayout];
        hud.backgroundColor = [UIColor clearColor];
        hud.userInteractionEnabled = NO;
        
        hud.statusString = status;
        hud.finishBlock = finishBlock;
        
        hud.statusColor = [UIColor blackColor];
        hud.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        
        if (delay > 0.0001)
        {
            [hud performSelector:@selector(finishHandle) withObject:nil afterDelay:delay];
        }
    }
    
    return hud;
}

- (void)hudAutolayout
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *constH = @"H:|-0-[self]-0-|";
    NSString *constV = @"V:|-0-[self]-0-|";
    NSDictionary *dict = NSDictionaryOfVariableBindings(self);
    
    NSArray *tempArray = [NSLayoutConstraint constraintsWithVisualFormat:constH options:0 metrics:nil views:dict];
    [array addObjectsFromArray:tempArray];
    
    tempArray = [NSLayoutConstraint constraintsWithVisualFormat:constV options:0 metrics:nil views:dict];
    [array addObjectsFromArray:tempArray];
    
    [_m_superView addConstraints:array];
}

- (void)finishHandle
{
    if (nil != self.finishBlock)
    {
        self.finishBlock();
        
        self.finishBlock = nil;
    }
    
    [self dismiss];
}

- (void)createBackgroundView
{
    if (nil == self.m_backgroundView)
    {
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:backgroundView];
        self.m_backgroundView = backgroundView;
        
        [self createIndicatorView];
        [self createLabel];
    }
}

- (void)createIndicatorView
{
    if (nil == self.m_indicatorView)
    {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
        [self.m_backgroundView addSubview:indicator];
        self.m_indicatorView = indicator;
        
        if (self.statusString.length <= 0)
        {
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        }
        else
        {
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        }
    }

    [self.m_indicatorView startAnimating];
}

- (void)createLabel
{
    if (nil == self.m_label)
    {
        UILabel *label = [[UILabel alloc] init];
        [self.m_backgroundView addSubview:label];
        self.m_label = label;
        
        label.text = self.statusString;
        label.font = self.m_statusFont;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self adjustSubViewFrame];
}

- (UIFont *)m_statusFont
{
    return [UIFont systemFontOfSize:kLabelFontSize];
}

- (void)adjustSubViewFrame
{
    CGFloat width = self.bounds.size.width;
    UIFont *font = self.m_statusFont;
    NSString *string = self.statusString;
    CGSize size = CGSizeZero;
    
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 6.0 && systemVersion <= 7.0)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        size = [string sizeWithFont:font constrainedToSize:CGSizeMake(width, 2000)];
#pragma clang diagnostic pop
    }
    else
    {
        CGSize temp = CGSizeMake(width, 2000);
        NSStringDrawingOptions opt = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        NSDictionary *dic = @{NSFontAttributeName: font};
        
        size = [string boundingRectWithSize:temp options:opt attributes:dic context:nil].size;
    }
    
    CGFloat backgroundViewW = 0;
    CGFloat backgroundViewH = 0;
    CGFloat indicatorViewW = 0;
    CGFloat indicatorViewH = 0;
    if (self.statusString.length > 0)
    {
        indicatorViewW = 20;
        indicatorViewH = 20;
        
        backgroundViewH = indicatorViewH;
        backgroundViewW = indicatorViewW + size.width;
    }
    else
    {
        indicatorViewW = 40;
        indicatorViewH = 40;
        
        backgroundViewH = indicatorViewH;
        backgroundViewW = indicatorViewW + size.width;
    }
    
    if (indicatorViewH < size.height)
    {
        indicatorViewH = size.height;
    }
    
    CGRect frame = self.bounds;
    CGFloat backgroundViewX = (frame.size.width - backgroundViewW) / 2;
    CGFloat backgroundViewY = (frame.size.height - backgroundViewH) / 2;
    self.m_backgroundView.frame = CGRectMake(backgroundViewX, backgroundViewY, backgroundViewW, backgroundViewH);
    
    self.m_indicatorView.frame = CGRectMake(0, 0, indicatorViewW, indicatorViewH);
    self.m_label.frame = CGRectMake(indicatorViewW, (backgroundViewH - size.height)/2, size.width, size.height);
}

- (void)setStatusString:(NSString *)statusString
{
    _statusString = statusString;
    
    self.m_label.text = statusString;

    [self createBackgroundView];
    
    [self setNeedsLayout];
}

- (void)dismiss
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    self.finishBlock = nil;
    [self removeFromSuperview];
}


- (void)setStatusColor:(UIColor *)statusColor
{
    self.m_label.textColor = statusColor;
}

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    self.m_indicatorView.activityIndicatorViewStyle = activityIndicatorViewStyle;
}


@end
