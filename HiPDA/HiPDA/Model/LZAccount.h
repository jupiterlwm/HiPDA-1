//
//  LZAccount.h
//  HiPDA
//
//  Created by leizh007 on 15/3/21.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LZAccount : NSObject

+(id)sharedAccount;
-(BOOL)checkIfThereIsAValidAccount;
-(id)getAccountInfo;
-(BOOL)setAccountInfo:(NSArray *)info;
-(BOOL)clearAccountInfo;
-(void)saveCookies;
-(void)loadCookies;
-(void)clearCookies;
-(void)checkAccountIfNoValidThenLogin:(UIViewController *)viewController;
-(void)setAccountUid:(NSString *)uid;
-(id)getAccountUid;
-(void)setFormhash:(NSString*)formhash;
-(id)getFormhash;

@end
