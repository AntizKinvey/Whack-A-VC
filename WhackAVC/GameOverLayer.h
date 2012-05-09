//
//  GameOverLayer.h
//  WhackAVC
//
//  
//  Copyright (c) 2012 Antiz Technologies Pvt Ltd. All rights reserved.
//

#import "cocos2d.h"
#import "DBManager.h"
#import <KinveyKit/KinveyKit.h>


#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

#import "FBConnect.h"
#import "TwitterViewController.h"

@interface GameOverLayer : CCLayer<KCSCollectionDelegate, KCSPersistableDelegate, FBSessionDelegate, FBDialogDelegate, FBRequestDelegate, KCSResourceDelegate>
{
    DBManager *_dbmanager;
    
    KCSCollection *whackDetailsCollection;
    
    Facebook *facebook;   
    
    TwitterViewController *twit;
    
    ACAccountStore *account;
    
}

@property (nonatomic, retain) DBManager *_dbmanager;

//Whacks Collection in Kinvey backend
@property (nonatomic, retain) KCSCollection *whackDetailsCollection;

@property (nonatomic, retain) Facebook *facebook;

@property (nonatomic, retain) TwitterViewController *twit;

@property (nonatomic, retain) ACAccountStore *account;

-(void) closeWindow;

-(void) saveWhackCountsToKinvey;

-(void) checkNetworkConnectivity;

+(CCScene *) scene;

@end
