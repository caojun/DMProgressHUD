#import "DMProgressHUD.h"
#import "PlatformConst.h"
#import "NSString+Category.h"

#define kLabelFontSize              (17)

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
    Log(@"%@ dealloc", _CURFUNCTIONNAME_);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

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
    CGSize size = [self.statusString calcTextDisplaySizeWithWidth:self.bounds.size.width font:self.m_statusFont];
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
