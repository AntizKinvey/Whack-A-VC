//
//  VcsScreenLayer.h
//  WhackAVC
//
//  
//  Copyright (c) 2012 Antiz Technologies Pvt Ltd. All rights reserved.
//

#import "cocos2d.h"
#import "DBManager.h"


#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TwitterViewController.h"

#import <KinveyKit/KinveyKit.h>

#import "FBConnect.h"

@interface VcsScreenLayer : CCLayer <FBSessionDelegate, FBDialogDelegate, FBRequestDelegate, KCSResourceDelegate, KCSPersistableDelegate>
{
    DBManager *_dbmanager;
    
    Facebook *facebook;
    
    TwitterViewController *twit;
    
    ACAccountStore *account;
}

@property (nonatomic, retain) DBManager *_dbmanager;

@property (nonatomic, retain) Facebook *facebook;

@property (nonatomic, retain) TwitterViewController *twit;

@property (nonatomic, retain) ACAccountStore *account;

-(void) postToTwitter;

+(CCScene *) scene;

@end
