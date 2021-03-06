//
//  BaseViewController.m
//  XunChangApp
//
//  Created by MrZhang on 16/5/5.
//  Copyright © 2016年 zhangyong. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationController.interactivePopGestureRecognizer.delegate=(id<UIGestureRecognizerDelegate>)self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.view.backgroundColor=[UIColor whiteColor];
    
}
-(void)setNavBarColor:(UIColor*)color
{
    self.navigationController.navigationBar.barTintColor=color;
}
-(void)createNavBackButt
{
    UIButton *leftButt=[UIButton buttonWithType:UIButtonTypeCustom];
    
    leftButt.frame=CGRectMake(0, 0, 15, 20);
    [leftButt setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
//    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:17]};
//    if ([backColor isEqualToString:@"黑色"]) {
//    [leftButt setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
//    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:17]};
//    }
    [leftButt addTarget:self action:@selector(backToFrontViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem=[[UIBarButtonItem alloc]initWithCustomView:leftButt];
    self.navigationItem.leftBarButtonItem=leftItem;
}
-(void)backToFrontViewController
{
    [self.navigationController popViewControllerAnimated:YES];
   
}
-(NSMutableAttributedString*)createAttributStringWithString:(NSString*)originalString changeString:(NSString*)specialString andAttributDic:(NSDictionary*)attributDic
{
    NSMutableAttributedString *originalStr=[[NSMutableAttributedString alloc]initWithString:originalString];
    NSRange range=[originalString rangeOfString:specialString];
    [originalStr addAttributes:attributDic range:range];
    return originalStr;
}
-(void)dialTelephoneWithTelephoneNum:(NSString*)telNum
{
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",telNum];
    
    UIWebView * callWebview = [[UIWebView alloc] init];
    
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    
    [self.view addSubview:callWebview];
}
-(NSString*)bytesToMBOrKB:(NSString*)bytes
{
    NSString *sizeOfImage;
    CGFloat bytesNum=[bytes floatValue];
    if (bytesNum/1024>1024) {
        sizeOfImage=[NSString stringWithFormat:@"%.1fM",bytesNum/1024/1024];
    }else
    {
        sizeOfImage=[NSString stringWithFormat:@"%.1fk",bytesNum/1024];
    }
    return sizeOfImage;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
