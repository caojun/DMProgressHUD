//
//  ViewController.m
//  DMProgressHUDDemo
//
//  Created by Dream on 15/5/22.
//  Copyright (c) 2015年 GoSing. All rights reserved.
//

#import "ViewController.h"
#import "DMProgressHUD.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *m_btnShowStatus;
@property (weak, nonatomic) IBOutlet UIButton *m_btnShowStatusWithDelay;
@property (weak, nonatomic) IBOutlet UIButton *m_btnDismiss;

@property (weak, nonatomic) IBOutlet UIView *m_backgroundView;

@property (nonatomic, weak) DMProgressHUD *m_hud;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self cornerWithView:self.m_btnShowStatus];
    [self cornerWithView:self.m_btnShowStatusWithDelay];
    [self cornerWithView:self.m_btnDismiss];
}

- (void)cornerWithView:(UIView *)view
{
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 10;
    view.layer.borderWidth = 0.5;
    view.layer.borderColor = [UIColor grayColor].CGColor;
}

- (IBAction)btnShowStatus
{
    [self btnDismiss];
    
    NSString *status = @"正在加载中...";
    self.m_hud = [DMProgressHUD showWithStatus:status inView:self.m_backgroundView];
}

- (IBAction)btnShowStatusWithDelay
{
    [self btnDismiss];
    
    __block __weak typeof(self) weakSelf = self;
    NSString *status = @"定时加载中...";
    self.m_hud = [DMProgressHUD showWithStatus:status inView:self.m_backgroundView delay:5 finishBlock:^{
        [weakSelf finishHandle];
    }];
}

- (void)finishHandle
{
    NSLog(@"finishHandle");
}

- (IBAction)btnDismiss
{
    [self.m_hud dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
