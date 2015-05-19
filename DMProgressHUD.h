#import <UIKit/UIKit.h>

@interface DMProgressHUD : UIView

@property (nonatomic, strong) UIColor *statusColor;

@property (nonatomic, copy) NSString *statusString;

@property (nonatomic, assign) UIActivityIndicatorViewStyle activityIndicatorViewStyle;


+ (instancetype)showWithStatus:(NSString *)status inView:(UIView *)inView;


+ (instancetype)showWithStatus:(NSString *)status
                        inView:(UIView *)inView
                         delay:(NSTimeInterval)delay
                   finishBlock:(dispatch_block_t)finishBlock;

- (void)dismiss;

@end
