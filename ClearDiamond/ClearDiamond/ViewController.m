//
//  ViewController.m
//  ClearDiamond
//
//  Created by terrPang on 2018/2/1.
//  Copyright © 2018年 terrPang. All rights reserved.
//

#import "ViewController.h"

#define k_DiamondMargin 10 //方块之间的间隔
#define k_DiamondNumOneLine 6 //一行多少个方块
#define k_DiamondAnimateTimeTap 0.1 //点击方块时的动画时间
#define k_DiamondAnimateTimeReplace 0.2 //点击正确时切换方块的动画时间
#define k_DiamondAnimateTimeBGColor 0.3 //换背景色时的动画时间
#define k_DiamondBoxBackgroundColorNum 10 //背景色的总颜色数开立方

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *diamondBox;
@property (weak, nonatomic) IBOutlet UILabel *lbScore;
@property (weak, nonatomic) IBOutlet UIButton *btDog;
@property (weak, nonatomic) IBOutlet UIProgressView *progressViewTime;
@property (weak, nonatomic) IBOutlet UIView *viStartGameBox;
@property (weak, nonatomic) IBOutlet UIButton *btStartGame;
@property (weak, nonatomic) IBOutlet UILabel *lbGameOverScore;
@property (weak, nonatomic) IBOutlet UILabel *lbGameOverMessage;

@end

@implementation ViewController{
    
    NSInteger selectDiamondTag;
    int randomMax;//方块的总颜色数开立方
    NSTimer* progressTimer;//进读条定时器
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _progressViewTime.transform = CGAffineTransformMakeScale(1.0f, 10.0f);//设定高
    
    CGFloat diamondWidth = (self.view.frame.size.width-k_DiamondMargin*(k_DiamondNumOneLine+1))/k_DiamondNumOneLine;
    
    for (int r=1; r*r*r<k_DiamondNumOneLine*k_DiamondNumOneLine; r++) {
        randomMax = r;
    }
    
    for (int i=1; i<=k_DiamondNumOneLine*k_DiamondNumOneLine ; i++) {
        UIButton* diamondView = [[UIButton alloc] initWithFrame:CGRectMake((k_DiamondMargin+diamondWidth) * ((i-1)%k_DiamondNumOneLine) + k_DiamondMargin, (i-1)/k_DiamondNumOneLine * (k_DiamondMargin+diamondWidth) + k_DiamondMargin, diamondWidth, diamondWidth)];
        diamondView.tag = i;
    
        [diamondView addTarget:self action:@selector(tapDiamond:) forControlEvents:UIControlEventTouchDown];
        
        [_diamondBox addSubview:diamondView];
    }
}

- (void)tapDiamond:(UIButton *)diamondBt{
    
    if (selectDiamondTag == 0) {
        selectDiamondTag = diamondBt.tag;
        [UIView animateWithDuration:k_DiamondAnimateTimeTap animations:^{
            diamondBt.layer.cornerRadius = diamondBt.frame.size.width/2;
        }];
        
    }else{
        UIButton* selectBt = [_diamondBox viewWithTag:selectDiamondTag];
        if ([diamondBt.layer.name isEqual:selectBt.layer.name] && selectDiamondTag!=diamondBt.tag) {
            
            
            
            [UIView animateWithDuration:k_DiamondAnimateTimeReplace animations:^{
                selectBt.layer.cornerRadius = 0;
                [self randomColor:selectBt withRandomMax:randomMax];
                
                [self randomColor:diamondBt withRandomMax:randomMax];
            }];
            
            if ([_btDog.titleLabel.text isEqual:@"关闭瞎狗眼模式"]) {
                [self clickCheckBackgroundColor];
                [_progressViewTime setProgress:_progressViewTime.progress+0.03];
            }else{
                [_progressViewTime setProgress:_progressViewTime.progress+0.02];
            }
            
            
            NSInteger score = [_lbScore.text integerValue];
            [_lbScore setText:[NSString stringWithFormat:@"%ld",(long)score+1]];
            
            selectDiamondTag = 0;
        }else{
            
            [UIView animateWithDuration:k_DiamondAnimateTimeTap animations:^{
                selectBt.layer.cornerRadius = 0;
            }];
            
            selectDiamondTag = 0;
        }
    }
    
}

- (IBAction)clickDog {
    if ([_btDog.titleLabel.text isEqual:@"关闭瞎狗眼模式"]) {
        [_btDog setTitle:@"开启瞎狗眼模式" forState:UIControlStateNormal];
    }else{
        [_btDog setTitle:@"关闭瞎狗眼模式" forState:UIControlStateNormal];
    }
}

- (IBAction)clickCheckBackgroundColor {
    
    [UIView animateWithDuration:k_DiamondAnimateTimeBGColor animations:^{
        [self randomColor:_diamondBox withRandomMax:k_DiamondBoxBackgroundColorNum];
    }];
    
}
- (IBAction)startGame {
    
    [_diamondBox setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1]];
    
    for (int i=1; i<=k_DiamondNumOneLine*k_DiamondNumOneLine ; i++) {
        UIButton* diamondBt = [_diamondBox viewWithTag:i];
        
        [self randomColor:diamondBt withRandomMax:randomMax];
    }
    
    [_lbScore setText:@"0"];
    [_progressViewTime setProgress:1 animated:YES];
    
    [_viStartGameBox setHidden:YES];
    
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(progressTime) userInfo:nil repeats:YES];
}

- (void)progressTime{
    if (_progressViewTime.progress<0.002) {
        [progressTimer invalidate];
        
        [_progressViewTime setProgress:0];
        
        [_lbGameOverScore setText:_lbScore.text];
        [_lbScore setText:@""];
        [_btStartGame setTitle:@"再来一盘" forState:UIControlStateNormal];
        [_lbGameOverScore setHidden:NO];
        [_lbGameOverMessage setHidden:NO];
        [_viStartGameBox setHidden:NO];
    }else{
        [_progressViewTime setProgress:_progressViewTime.progress-0.002 animated:YES];
    }
}

- (void)randomColor:(UIView *)theVi withRandomMax:(int )randomMaxItem{
    
    u_int32_t randomItem = arc4random_uniform(randomMaxItem*randomMaxItem*randomMaxItem);
    theVi.layer.name = [NSString stringWithFormat:@"%u",randomItem];
    theVi.backgroundColor = [UIColor colorWithRed:(CGFloat)((randomItem/randomMaxItem/randomMaxItem)%randomMaxItem)/(randomMaxItem-1) green:(CGFloat)((randomItem/randomMaxItem)%randomMaxItem)/(randomMaxItem-1) blue:(CGFloat)(randomItem%randomMaxItem)/(randomMaxItem-1) alpha:1];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
