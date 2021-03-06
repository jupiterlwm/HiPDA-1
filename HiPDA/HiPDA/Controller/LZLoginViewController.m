//
//  LZLoginViewController.m
//  HiPDA
//
//  Created by leizh007 on 15/3/21.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZLoginViewController.h"
#import "LZLoginView.h"
#import "ActionSheetStringPicker.h"
#import "NSString+extension.h"
#import "SVProgressHUD.h"
#import "LZNetworkHelper.h"
#import "LZAccount.h"

@interface LZLoginViewController ()

@property (strong, nonatomic) LZLoginView  *loginView;
@property (strong, nonatomic) NSString     *userName;
@property (strong, nonatomic) NSString     *userPassword;
@property (strong, nonatomic) NSString     *safeQuestionNumber;
@property (strong, nonatomic) NSString     *safeQuestionAnswer;
@property (strong, nonatomic) NSArray      *safeQuestionArray;
@property (strong, nonatomic) NSDictionary *safeQuestionDic;

@end

@implementation LZLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[LZAccount sharedAccount] clearAccountInfo];
    [[LZAccount sharedAccount] clearCookies];
    self.loginView=[[LZLoginView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.view=self.loginView;
    [self.loginView.safeQuestionNumberButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView.loginButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.safeQuestionArray=@[@"安全提问",@"母亲的名字",@"爷爷的名字",@"父亲出生的城市",@"您其中一位老师的名字",@"您个人计算机的型号",@"您最喜欢的餐馆名称",@"驾驶执照的最后四位数字"];
    self.safeQuestionDic=@{@"安全提问":@"0",@"母亲的名字":@"1",@"爷爷的名字":@"2",@"父亲出生的城市":@"3",@"您其中一位老师的名字":@"4",@"您个人计算机的型号":@"5",@"您最喜欢的餐馆名称":@"6",@"驾驶执照的最后四位数字":@"7"};
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

-(void)buttonPressed:(id)sender{
//    NSLog(@"%d button pressed!",(int)((UIButton *)sender).tag);
    [self.loginView dismissKeyboard:nil];
    [UIView animateWithDuration:0.2
                     animations:^{
                         [sender setAlpha:0.4];
                     } completion:^(BOOL finished) {
                         [sender setAlpha:1.0];
                     }];
    NSInteger tag=((UIButton *)sender).tag;
    if (1==tag) {
        [ActionSheetStringPicker showPickerWithTitle:@"请选择安全提问"
                                                rows:self.safeQuestionArray
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               [self.loginView.safeQuestionNumberButton setTitle:self.safeQuestionArray[selectedIndex] forState:UIControlStateNormal];
                                               if (selectedIndex!=0) {
                                                   [self.loginView.safeQuestionNumberButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                                               }else{
                                                   [self.loginView.safeQuestionNumberButton setTitleColor:[UIColor colorWithRed:0.791 green:0.791 blue:0.811 alpha:1] forState:UIControlStateNormal];
                                               }
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {

                                           }
                                              origin:self.view];
    }else if(2==tag){
        self.userName=[NSString ifTheStringIsNilReturnAEmptyString:self.loginView.userNameTextField.text];
        self.userPassword=[NSString ifTheStringIsNilReturnAEmptyString:self.loginView.userPassWoldTextField.text];
        self.safeQuestionNumber=self.safeQuestionDic[self.loginView.safeQuestionNumberButton.currentTitle];
        if ([self.safeQuestionNumber isEqualToString:@"0"]) {
            self.safeQuestionAnswer=@"";
        }else{
            self.safeQuestionAnswer=[NSString ifTheStringIsNilReturnAEmptyString:self.loginView.safeQuestionAnswerTextField.text];
        }
        [SVProgressHUD showWithStatus:@"奋力登录中..." maskType:SVProgressHUDMaskTypeGradient];
        LZNetworkHelper *networkHelper=[LZNetworkHelper sharedLZNetworkHelper];
        NSDictionary *parameters=@{@"loginfield":@"username",
                                   @"username":self.userName,
                                   @"password":[self.userPassword md5],
                                   @"questionid":self.safeQuestionNumber,
                                   @"answer":self.safeQuestionAnswer,
                                   @"cookietime":@"2592000",
                                   @"Referer":@"http://www.hi-pda.com/forum/index.php"};
        [networkHelper login:parameters block:^(BOOL isSuccess, NSError *error) {
                if (isSuccess) {
                    [SVProgressHUD showSuccessWithStatus:@"登录成功！" maskType:SVProgressHUDMaskTypeGradient];
                    [[LZAccount sharedAccount] setAccountInfo:@[self.userName,self.userPassword,self.safeQuestionNumber,self.safeQuestionAnswer]];
                    [[LZAccount sharedAccount] saveCookies];
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGINCOMPLETENOTIFICATION object:nil userInfo:nil];
                    [self dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                }else{
                    [SVProgressHUD showErrorWithStatus:[error localizedDescription] maskType:SVProgressHUDMaskTypeGradient];
                }
            [self performSelector:@selector(dismissSVProgressHUD:) withObject:nil afterDelay:3];
        }];
        
    }
}

-(void)dismissSVProgressHUD:(id)sender{
    [SVProgressHUD dismiss];
}
@end
