//
//  HelloWorldLayer.h
//  WhackAVC
//
//  
//  Copyright Antiz Technologies Pvt Ltd 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import <KinveyKit/KinveyKit.h>

@class DBManager;

@interface HelloWorldLayer : CCLayer<KCSCollectionDelegate, KCSPersistableDelegate, KCSResourceDelegate, KCSEntityDelegate>
{
    DBManager *dbmanager;
    KCSCollection *blobCollection;
    KCSCollection *phrasesCollection;
    KCSCollection *vcDetailsCollection;
}


@property(nonatomic, retain) DBManager *dbmanager;
//Blob Collection in Kinvey backend
@property (nonatomic, retain) KCSCollection *blobCollection;
//Phrases Collection in Kinvey backend
@property (nonatomic, retain) KCSCollection *phrasesCollection;
//VC-Details Collection in Kinvey backend
@property (nonatomic, retain) KCSCollection *vcDetailsCollection;

//Functional prototype to show Main Menu
-(void) showMainMenu;
//Functional prototype to show Splash Screen
-(void) showSplashScreen;
//Functional prototype to execute the database operations
-(void) preProcessingDB;
//Functional prototype to load data and resources from kinvey
-(void) loadDataFromKinvey;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
