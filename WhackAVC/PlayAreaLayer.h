//
//  PlayAreaLayer.h
//  WhackAVC
//
//  
//  Copyright Antiz Technologies Pvt Ltd 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "DBManager.h"

//int const kScreenDivisions = 3;

// HelloWorldLayer
@interface PlayAreaLayer : CCLayer
{
    CCLabelTTF *score;    
    CCTMXTiledMap *_tileMap;
    CCTMXLayer *_background;
    
    CCSprite *_player;
    
    CCSprite *_hud;
    
    CCTMXLayer *_meta;
    
    CCTMXLayer *_foreground;
    
    DBManager *_dbmanager;
    
}

//Tilemap that is to be loaded to play area
@property (nonatomic, retain) CCTMXTiledMap *tileMap;

//Layer of Tilemap that displays the background 
@property (nonatomic, retain) CCTMXLayer *background;

//Player
@property (nonatomic, retain) CCSprite *player;

//HUD(Head up display)
@property (nonatomic, retain) CCSprite *hud;

//Meta layer for collosion in Tilemap
@property (nonatomic, retain) CCTMXLayer *meta;

//Foreground layer in Tilemap
@property (nonatomic, retain) CCTMXLayer *foreground;

@property (nonatomic,retain) DBManager *_dbmanager;

-(void)checkCollision:(CGPoint)position;

-(void) addVCs;

-(void) startPlayer;

-(void)randomizeVC1;
-(void)randomizeVC2;
-(void)randomizeVC3;

-(void) playWhackSounds;

-(void) addPhraseTable;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
