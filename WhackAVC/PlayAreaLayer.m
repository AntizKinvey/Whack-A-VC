//
//  PlayAreaLayer.m
//  WhackAVC
//
//  
//  Copyright Antiz Technologies Pvt Ltd 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "PlayAreaLayer.h"
#import "TimeUpLayer.h"
#import "LabelOutlineLayer.h"
#import "CCTouchDispatcher.h"
#import "SimpleAudioEngine.h"

// PlayAreaLayer implementation
@implementation PlayAreaLayer

//Loads a Tilemap
@synthesize tileMap = _tileMap;

//Background layer of Tilemap
@synthesize background = _background;

//Player that is the monster
@synthesize player = _player;

//Head Up Display
@synthesize hud = _hud;

//Meta layer for collision
@synthesize meta = _meta;

//Foreground layer for Tilemap
@synthesize foreground = _foreground;

@synthesize _dbmanager;

CCLabelTTF *timer;//countdown timer

CCLabelTTF *vcname;//VC names
CCLabelTTF *vcorg;//VC firm names
CCRenderTexture *stroke;//Outline border

CCSprite *enemy;//VC's that display in the middle
CCSprite *enemy1;//VC's that display in the left
CCSprite *enemy2;//VC's that display in the right

CCSprite *_energyPellet;//Energy pellet

CGPoint touchLocation;//Touch location
CGPoint diff;//Difference between touches
CGPoint playerPos;//Player position
int _animforward = 0;//animate player forward
int scoreCount = 0;//Score Count when VC's are whacked
int movex = 0;//Movement of player in +x direction
int moveminusx = 0;//Movement of player in -x direction
int movey = 0;//Movement of player in +y direction
int moveminusy = 0;//Movement of player in -y direction
int sec = 60;//Number of seconds to count down
int hour = 0;

//These are variables used when game play is paused
int _pauseMovingPlayerInX = 0;
int _pauseMovingPlayerInY = 0;
int _pauseMovingPlayerInMinusX = 0;
int _pauseMovingPlayerInMinusY = 0;

//Status that shows whether game play is under pause. The game is paused when this flag is set to TRUE.
BOOL _gamePaused = FALSE;

UIButton *playPauseButton;
UIButton *quitButton;

//Positions on the screen to display energy pellets in random
int _energyPelletPosX[10] = {48,160,160,432,240,48,240,432,368,304};
int _energyPelletPosY[10] = {64,128,192,64,80,240,144,240,144,208};

BOOL _pelletEaten = TRUE;//Flag is set to TRUE when the monster eats a power pellet
BOOL _powerOfPlayer = TRUE;//Flag is set to FALSE when the monster is grayed out

int _blink = 0;//Variable used to blink the countdown timer for last 10 seconds

//The lives of the monster
CCSprite *life1;
CCSprite *life2;
CCSprite *life3;

//Hint screen animations
CCSprite *_hintScreen;
int _hintAnim = 0;

//3-2-1 go screen animations
CCSprite *_countDownScreen;
int _countDownAnim = 0;

int _animPlayer = 0;
int _animPlayerOnCollision = 0;
int _blinkPlayer;

//VC image frames that are used to detect collision
CGRect enemyRect;
CGRect enemy1Rect;
CGRect enemy2Rect;

//Number of lives
int lives = 2;

//Flags that detect the presence of VC's positions on the screen
BOOL _VC1_Present = FALSE;
BOOL _VC2_Present = FALSE;
BOOL _VC3_Present = FALSE;

//Flags that detect the presence of VC's positions on the screen that are whacked
BOOL _VC1_Whacked = FALSE;
BOOL _VC2_Whacked = FALSE;
BOOL _VC3_Whacked = FALSE;

//Flag that is set when the player turns backward
BOOL _turnForward = FALSE;

//Variable used for energy pellet animation
int _energyPelletAnim = 0;

//Pause screen for the game play
CCSprite *_pauseScreen;

BOOL _showTimeUpScreen = FALSE;

//Total number of images from database
int _totalNoOfImagesFromDB;
int x = 0;
int y = 0;
extern int _pressedPlayFromMainMenu;
BOOL _skipButtonPresent = FALSE;

//To display Skip button int hint animation screen
UIButton *skipButton;

//To refer to VC game play images and Id's from local cache
NSMutableArray *_totalVCImagesArray;
NSMutableArray *_totalVCImageIdsArray;

//For each session of game randomly selecting VC's 
int _totalCountOfVCImages;
int _totalImagesInEachDiv;

//Total number of VC shouts that are to be played randomly when a VC is whacked
int _totalCountOfAudioFiles;

//Game screen is divided into 3 sections to display VC's randomly
NSMutableArray *_VC1ImageArray;
NSMutableArray *_VC2ImageArray;
NSMutableArray *_VC3ImageArray;

NSMutableArray *_VC1ImageArrayIds;
NSMutableArray *_VC2ImageArrayIds;
NSMutableArray *_VC3ImageArrayIds;

NSMutableArray *_VC1ImageArrayToLoad;
NSMutableArray *_VC2ImageArrayToLoad;
NSMutableArray *_VC3ImageArrayToLoad;

NSMutableArray *_VC1ImageIdsArrayToLoad;
NSMutableArray *_VC2ImageIdsArrayToLoad;
NSMutableArray *_VC3ImageIdsArrayToLoad;

NSMutableArray *_VCLoadedToDisplay;
NSMutableArray *_VCIdsLoadedToDisplay;

//Array that holds VC shouts from local cache
NSMutableArray *_whackAudio;


int _arrCount = 0;

/*************************/
//Variables used to generate unique random number
int _track1 = 0;
int _track2 = 0;
int _track3 = 0;
int _track4 = 0;
int _track5 = 0;
/*************************/
int randomVCs = 0;
int rand1 = 0;
int rand2 = 0;
int rand3 = 0;
int _whackCountArray[15];

int _initialVC1Whacked = 0;
int _initialVC2Whacked = 0;

//Sound effect ID's
ALuint _soundEffectID;
ALuint _loseLifeID;
ALuint _powerUpID;



+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PlayAreaLayer *layer = [PlayAreaLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        //Loading of Tile Map and different layers designed in Tiled Map using Tile Map editor
        
        _dbmanager = [[DBManager alloc] init];
        
        //Call to a function to open a connection to database
        [_dbmanager openDB];
        
        //Total number of game play images present in local cache
        _totalNoOfImagesFromDB = [_dbmanager retrieveVCImagesPaths];
        
        //Total number of audio files present in local cache
        _totalCountOfAudioFiles = [_dbmanager retrieveVCWhackAudioPaths];
        
        
        //Array that holds total number of VC shouts from local cache
        _whackAudio = [NSMutableArray alloc];
        _whackAudio = [_dbmanager _whackedAudioPaths];
        
        //Array to hold total number of game play images
        _totalVCImagesArray = [NSMutableArray alloc];
        _totalVCImagesArray = [_dbmanager _retrieveArray];
        
        //Array to hold total number of game play image Id's
        _totalVCImageIdsArray = [NSMutableArray alloc];
        _totalVCImageIdsArray = [_dbmanager _retrieveImageIdArray];
        
        //Total count of VC images
        _totalCountOfVCImages = [_totalVCImagesArray count];
        
        //The screen is divided into 3 divisions. Number of VC images that can be displayed in each division
        _totalImagesInEachDiv = _totalCountOfVCImages/3;
        
        //Arrays to hold VC images of each division
        _VC1ImageArray = [[NSMutableArray alloc] init];
        _VC2ImageArray = [[NSMutableArray alloc] init];
        _VC3ImageArray = [[NSMutableArray alloc] init];
        
        //Arrays to hold VC image Id's of each division
        _VC1ImageArrayIds = [[NSMutableArray alloc] init];
        _VC2ImageArrayIds = [[NSMutableArray alloc] init];
        _VC3ImageArrayIds = [[NSMutableArray alloc] init];
        
        //The VC's images and Id's that are loaded to display are the elements of these arrays
        _VCLoadedToDisplay = [[NSMutableArray alloc] init];
        _VCIdsLoadedToDisplay = [[NSMutableArray alloc] init];
        
        
        //Dividing the screen into 3 divisions based on i value
        for(int i=0;i<3;i++)
        {
            for(int j=0;j<_totalImagesInEachDiv;j++)
            {
                //Division 1
                if(i==0)
                {
                    [_VC1ImageArray addObject:[_totalVCImagesArray objectAtIndex:_arrCount]];
                    [_VC1ImageArrayIds addObject:[_totalVCImageIdsArray objectAtIndex:_arrCount]];
                    _arrCount++;
                }
                //Division 2
                if(i==1)
                {
                    [_VC2ImageArray addObject:[_totalVCImagesArray objectAtIndex:_arrCount]];
                    [_VC2ImageArrayIds addObject:[_totalVCImageIdsArray objectAtIndex:_arrCount]];
                    _arrCount++;
                }
                //Division 3
                if(i==2)
                {
                    [_VC3ImageArray addObject:[_totalVCImagesArray objectAtIndex:_arrCount]];
                    [_VC3ImageArrayIds addObject:[_totalVCImageIdsArray objectAtIndex:_arrCount]];
                    _arrCount++;
                }
            }
            
        }
        _arrCount = 0;
        
        //Arrays whose elements contain VC images to display in each division
        _VC1ImageArrayToLoad = [[NSMutableArray alloc] init];
        _VC2ImageArrayToLoad = [[NSMutableArray alloc] init];
        _VC3ImageArrayToLoad = [[NSMutableArray alloc] init];
        
        //Arrays whose elements contain VC image Id's to display in each division
        _VC1ImageIdsArrayToLoad = [[NSMutableArray alloc] init];
        _VC2ImageIdsArrayToLoad = [[NSMutableArray alloc] init];
        _VC3ImageIdsArrayToLoad = [[NSMutableArray alloc] init];
        
        _track1=0;
        _track2=0;
        _track3=0;
        _track4=0;
        _track5=0;
        
        //Each division can hold a maximum of 5 VC images which is represented in the for loop condition
        //Division 1
        for(int i=0; i<5; i++)
        {
            [self randomizeVC1];
            [_VCLoadedToDisplay addObject:[_VC1ImageArrayToLoad objectAtIndex:i]];
            [_VCIdsLoadedToDisplay addObject:[_VC1ImageIdsArrayToLoad objectAtIndex:i]];
        }
        
        _track1=0;
        _track2=0;
        _track3=0;
        _track4=0;
        _track5=0;
        
        //Division 2
        for(int i=0; i<5; i++)
        {
            [self randomizeVC2];
            [_VCLoadedToDisplay addObject:[_VC2ImageArrayToLoad objectAtIndex:i]];
            [_VCIdsLoadedToDisplay addObject:[_VC2ImageIdsArrayToLoad objectAtIndex:i]];
        }
        _track1=0;
        _track2=0;
        _track3=0;
        _track4=0;
        _track5=0;
        
        //Division 3
        for(int i=0; i<5; i++)
        {
            [self randomizeVC3];
            [_VCLoadedToDisplay addObject:[_VC3ImageArrayToLoad objectAtIndex:i]];
            [_VCIdsLoadedToDisplay addObject:[_VC3ImageIdsArrayToLoad objectAtIndex:i]];
        }
        _track1=0;
        _track2=0;
        _track3=0;
        _track4=0;
        _track5=0;
        
        //Arrays that hold VC firm names and VC names relative to VC Id's
        _dbmanager._retrieveImageFirmArray = [[NSMutableArray alloc] init];
        _dbmanager._retrieveVCNameArray = [[NSMutableArray alloc] init];
        
        //Since a maximum of only 15 VC's are selected to display the condition checks between [0...14]
        for(int i=0; i<15; i++)
        {
            NSString *sqls = [[NSString alloc] initWithFormat:@"SELECT vcfirm,vcname FROM VClist WHERE vcid=%@",[_VCIdsLoadedToDisplay objectAtIndex:i]];
            
            //Retrieve VC firm names and VC names
            [_dbmanager retrieveVCFirmsAndNames:sqls];
            [sqls release];
        }
        
        //Load the Tilemap and its layers to openGLView
        self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMap_Iphone.tmx"];
        self.background = [_tileMap layerNamed:@"Background"];
        self.foreground = [_tileMap layerNamed:@"Foreground"];
        self.meta = [_tileMap layerNamed:@"Meta"];
        _meta.visible = NO;
 
        //Label to display score in HUD (Head-Up-Display)
        score = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:15];
        score.position =  ccp( 400 , 300 );
        [score setString:[NSString stringWithFormat:@"%d", scoreCount]];
        score.color = ccc3(0, 0, 0);
        
        //Label to display count down timer in HUD (Head-Up-Display)
        timer = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:15];
        timer.position =  ccp( 300 , 300 );
        [timer setString:[NSString stringWithFormat:@"%d%d:%d", hour,hour,sec]];
        timer.color = ccc3(0, 0, 0);
        
        //Lives of the player
        life1 = [CCSprite spriteWithFile:@"life.png" 
                                    rect:CGRectMake(0, 0, 29, 26)];
        life1.position = ccp(220 , 305);
        
        life2 = [CCSprite spriteWithFile:@"life.png" 
                                    rect:CGRectMake(0, 0, 29, 26)];
        life2.position = ccp(237 , 305);
        
        life3 = [CCSprite spriteWithFile:@"life.png" 
                                    rect:CGRectMake(0, 0, 29, 26)];
        life3.position = ccp(228 , 292);
        
        //Screen that will be displayed whrn the game is paused
        _pauseScreen = [CCSprite spriteWithFile:@"pausescreen.png" 
                                           rect:CGRectMake(0, 0, 480, 288)];
        _pauseScreen.position = ccp(240 , 140);
        
        _pauseScreen.visible = NO;
        
		//Animated help screen
        _hintScreen = [CCSprite spriteWithFile:@"animation1.jpg"
                                          rect:CGRectMake(0, 0, 480, 320)];
        _hintScreen.position = ccp(240 , 160);
        
        _hintScreen.visible = NO;
        
		//Countdown animation screen
        _countDownScreen = [CCSprite spriteWithFile:@"countdown1.png"
                                               rect:CGRectMake(0, 0, 480, 320)];
        _countDownScreen.position = ccp(240 , 150);
        
        _countDownScreen.visible = NO;
        
        //Label to display VC firm name
        vcorg = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:12];
        vcorg.position =  ccp( 120 , 300 );
        vcorg.color = ccc3(0, 0, 0);
        
		//Label to display VC name
        vcname = [CCLabelTTF labelWithString:@"" fontName:@"Lithograph" fontSize:20];
        vcname.position =  ccp( 240 , 160 );
        vcname.color = ccc3(255, 243, 62);
        stroke = [LabelOutlineLayer createStroke:vcname  size:3  color:ccBLACK];
        
        //Loading the object group and Spawn Point of the Tilemap
        CCTMXObjectGroup *objects = [_tileMap objectGroupNamed:@"Objects"];
        NSAssert(objects != nil, @"'Objects' object group not found");
        NSMutableDictionary *spawnPoint = [objects objectNamed:@"SpawnPoint"];        
        NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
        x = [[spawnPoint valueForKey:@"x"] intValue];
        y = [[spawnPoint valueForKey:@"y"] intValue];
        
		//Set the monster's position
        self.player = [CCSprite spriteWithFile:@"playerforwardleft1.png"];
        _player.position = ccp(x, y);
        _player.visible = NO;
        
        self.hud = [CCSprite spriteWithFile:@"hud.png"];
        _hud.position = ccp(240, 303);
        
        
        _energyPellet = [CCSprite spriteWithFile:@"energypellet.png" 
                                            rect:CGRectMake(0, 0, 32, 32)];
        _energyPellet.visible = NO;
        
        
        
        enemy = [CCSprite spriteWithFile:@"vc1.png" 
                                    rect:CGRectMake(0, 0, 58, 72)];
        enemy.position = ccp(-100,-100);
        
        enemy1 = [CCSprite spriteWithFile:@"vc2.png" 
                                     rect:CGRectMake(0, 0, 58, 72)];
        enemy1.position = ccp(-100,-100);
        
        enemy2 = [CCSprite spriteWithFile:@"vc3.png" 
                                     rect:CGRectMake(0, 0, 58, 72)];
        enemy2.position = ccp(-100,-100);
        
        
        //Add all children to scene
        [self addChild:_player];
        [self addChild:_hud];
        
        [self addChild:enemy z:1];
        [self addChild:enemy1 z:1];
        [self addChild:enemy2 z:1];
        
        [self addChild:_energyPellet z:0];
        
        [self addChild:timer];
        [self addChild:_tileMap z:-1];
        
        [self addChild:score];
        
        
        [self addChild: vcorg z:20];
        [self addChild: stroke z:20];
        [self addChild: vcname z:20];
        
        [self addChild:life1];
        [self addChild:life2];
        [self addChild:life3];
        
        [self addChild:_pauseScreen z:5];
        [self addChild:_hintScreen z:10];
        
        [self addChild:_countDownScreen z:10];
        
        
        
        if(_pressedPlayFromMainMenu == 1)
        {
            _hintScreen.visible = YES;
            _skipButtonPresent = TRUE;
            [self schedule:@selector(gameHint:) interval:0.1];
        }
        else
        {
            _countDownScreen.visible = YES;
            _skipButtonPresent = FALSE;
            [self schedule:@selector(countDownStart:) interval:0.04];
        }
        
        
        
        [self schedule:@selector(checkCollisionWithPellet:)];   
        
	}
	return self;
}

//Functionality to animate VC name label
-(void)animLabel:(ccTime)dt
{
    [self schedule:@selector(label_opaque:) interval:1.2];
}

-(void)label_opaque:(ccTime)dt
{
    [self unschedule:@selector(label_opaque:)];
    [self schedule:@selector(fadeLabel:) interval:0.9];
}

-(void)fadeLabel:(ccTime)dt
{
    vcname.visible = NO;
    [self removeChild:stroke cleanup:YES];
    [self unschedule:@selector(fadeLabel:)];
}

//Selecting 5 VC's randomly for first division
-(void)randomizeVC1
{
    
    int rand = arc4random() % [_VC1ImageArray count];
    
    if(rand == 0 && _track1 == 0)
    {
        [_VC1ImageArrayToLoad addObject:[_VC1ImageArray objectAtIndex:rand]];
        [_VC1ImageIdsArrayToLoad addObject:[_VC1ImageArrayIds objectAtIndex:rand]];
        _track1 = 1;
    }
    else if(rand == 1 && _track2 == 0)
    {
        [_VC1ImageArrayToLoad addObject:[_VC1ImageArray objectAtIndex:rand]];
        [_VC1ImageIdsArrayToLoad addObject:[_VC1ImageArrayIds objectAtIndex:rand]];
        _track2 = 1;
    }
    else if(rand == 2 && _track3 == 0)
    {
        [_VC1ImageArrayToLoad addObject:[_VC1ImageArray objectAtIndex:rand]];
        [_VC1ImageIdsArrayToLoad addObject:[_VC1ImageArrayIds objectAtIndex:rand]];
        _track3 = 1;
    }
    else if(rand == 3 && _track4 == 0)
    {
        [_VC1ImageArrayToLoad addObject:[_VC1ImageArray objectAtIndex:rand]];
        [_VC1ImageIdsArrayToLoad addObject:[_VC1ImageArrayIds objectAtIndex:rand]];
        _track4 = 1;
    }
    else if(rand == 4 && _track5 == 0)
    {
        [_VC1ImageArrayToLoad addObject:[_VC1ImageArray objectAtIndex:rand]];
        [_VC1ImageIdsArrayToLoad addObject:[_VC1ImageArrayIds objectAtIndex:rand]];
        _track5 = 1;
    }
    else
    {
        [self randomizeVC1];
    }
    if(_track1 == 1 && _track2 == 1 && _track3 == 1 && _track4 == 1 && _track5 == 1)
    {
        _track1=0;
        _track2=0;
        _track3=0;
        _track4=0;
        _track5=0;
        [self randomizeVC1];
    }
}

//Selecting 5 VC's randomly for second division
-(void)randomizeVC2
{
    
    int rand = arc4random() % [_VC2ImageArray count];
    if(rand == 0 && _track1 == 0)
    {
        [_VC2ImageArrayToLoad addObject:[_VC2ImageArray objectAtIndex:rand]];
        [_VC2ImageIdsArrayToLoad addObject:[_VC2ImageArrayIds objectAtIndex:rand]];
        _track1 = 1;
    }
    else if(rand == 1 && _track2 == 0)
    {
        [_VC2ImageArrayToLoad addObject:[_VC2ImageArray objectAtIndex:rand]];
        [_VC2ImageIdsArrayToLoad addObject:[_VC2ImageArrayIds objectAtIndex:rand]];
        _track2 = 1;
    }
    else if(rand == 2 && _track3 == 0)
    {
        [_VC2ImageArrayToLoad addObject:[_VC2ImageArray objectAtIndex:rand]];
        [_VC2ImageIdsArrayToLoad addObject:[_VC2ImageArrayIds objectAtIndex:rand]];
        _track3 = 1;
    }
    else if(rand == 3 && _track4 == 0)
    {
        [_VC2ImageArrayToLoad addObject:[_VC2ImageArray objectAtIndex:rand]];
        [_VC2ImageIdsArrayToLoad addObject:[_VC2ImageArrayIds objectAtIndex:rand]];
        _track4 = 1;
    }
    else if(rand == 4 && _track5 == 0)
    {
        [_VC2ImageArrayToLoad addObject:[_VC2ImageArray objectAtIndex:rand]];
        [_VC2ImageIdsArrayToLoad addObject:[_VC2ImageArrayIds objectAtIndex:rand]];
        _track5 = 1;
    }
    else
    {
        [self randomizeVC2];
    }
    if(_track1 == 1 && _track2 == 1 && _track3 == 1 && _track4 == 1 && _track5 == 1)
    {
        _track1=0;
        _track2=0;
        _track3=0;
        _track4=0;
        _track5=0;
        [self randomizeVC2];
    }
}

//Selecting 5 VC's randomly for third division
-(void)randomizeVC3
{
    
    int rand = arc4random() % [_VC3ImageArray count];
    if(rand == 0 && _track1 == 0)
    {
        [_VC3ImageArrayToLoad addObject:[_VC3ImageArray objectAtIndex:rand]];
        [_VC3ImageIdsArrayToLoad addObject:[_VC3ImageArrayIds objectAtIndex:rand]];
        _track1 = 1;
    }
    else if(rand == 1 && _track2 == 0)
    {
        [_VC3ImageArrayToLoad addObject:[_VC3ImageArray objectAtIndex:rand]];
        [_VC3ImageIdsArrayToLoad addObject:[_VC3ImageArrayIds objectAtIndex:rand]];
        _track2 = 1;
    }
    else if(rand == 2 && _track3 == 0)
    {
        [_VC3ImageArrayToLoad addObject:[_VC3ImageArray objectAtIndex:rand]];
        [_VC3ImageIdsArrayToLoad addObject:[_VC3ImageArrayIds objectAtIndex:rand]];
        _track3 = 1;
    }
    else if(rand == 3 && _track4 == 0)
    {
        [_VC3ImageArrayToLoad addObject:[_VC3ImageArray objectAtIndex:rand]];
        [_VC3ImageIdsArrayToLoad addObject:[_VC3ImageArrayIds objectAtIndex:rand]];
        _track4 = 1;
    }
    else if(rand == 4 && _track5 == 0)
    {
        [_VC3ImageArrayToLoad addObject:[_VC3ImageArray objectAtIndex:rand]];
        [_VC3ImageIdsArrayToLoad addObject:[_VC3ImageArrayIds objectAtIndex:rand]];
        _track5 = 1;
    }
    else
    {
        [self randomizeVC3];
    }
    if(_track1 == 1 && _track2 == 1 && _track3 == 1 && _track4 == 1 && _track5 == 1)
    {
        _track1=0;
        _track2=0;
        _track3=0;
        _track4=0;
        _track5=0;
        [self randomizeVC3];
    }
}

//Functionality to play VC shouts when a VC is whacked
-(void) playWhackSounds
{
    int _randomWhackSound = arc4random() % _totalCountOfAudioFiles;
    _soundEffectID = [[SimpleAudioEngine sharedEngine] playEffect:[_whackAudio objectAtIndex:_randomWhackSound]];
}

//Functionality to play sounds when player loses life
-(void) playerLostLife
{
    _loseLifeID = [[SimpleAudioEngine sharedEngine] playEffect:@"sound3.wav"];
}

//Functionality to show animated help screen
-(void) gameHint:(ccTime)dt
{
    _hintAnim++;
    [_hintScreen setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"animation%d.jpg",_hintAnim]]];
    if(_hintAnim == 101)
    {
        [self unschedule:@selector(gameHint:)];
        _hintScreen.visible = NO;
        _hintAnim = 0;
        _countDownScreen.visible = YES;
        [skipButton removeFromSuperview];
        _skipButtonPresent = FALSE;
        playPauseButton.hidden = FALSE;
        quitButton.hidden = FALSE;
        [self schedule:@selector(countDownStart:) interval:0.04];
        
    }
}

//Functionality to show 3-2-1 screen
-(void) countDownStart:(ccTime)dt
{
    _countDownAnim++;
    [_countDownScreen setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"countdown%d.png",_countDownAnim]]];
    if(_countDownAnim == 42)
    {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"backgroundmusic.mp3"];
    }
    if(_countDownAnim == 72)
    {
        [self unschedule:@selector(countDownStart:)];
        _countDownScreen.visible = NO;
        _countDownAnim=0;
        [self startPlayer];
    }
}


//Functionality to start player movement when game starts
-(void) startPlayer
{
    if(_gamePaused == FALSE)
    {
        //[self unschedule:@selector(startPlayer:) ];
        
        _player.visible = YES;
        
        [playPauseButton setUserInteractionEnabled:TRUE];
        
        self.isTouchEnabled = YES;
        
        [self schedule:@selector(animatePlayerForward:) interval:0.3];
        
        [self schedule:@selector(moveinx:) ];
        
        [self schedule:@selector(placeEnergyPellets:) interval:5.0];
        
        [self schedule:@selector(countDownTimer:) interval:1.0];
        
        [self addVCs];
    }
}

//Functionality to add buttons when the view is loaded
-(void) onEnterTransitionDidFinish {
    
	//Adding a Play and pause button
    playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playPauseButton addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchDown];
    UIImage *pausebtn = [UIImage imageNamed:@"pauseButton.png"];
    [playPauseButton setImage:pausebtn forState:UIControlStateNormal];
    [playPauseButton setFrame:CGRectMake(1,5,29,29)];
    playPauseButton.hidden = TRUE;
    [playPauseButton setUserInteractionEnabled:FALSE];
    [[[CCDirector sharedDirector] openGLView] addSubview:playPauseButton];
    
	//Adding a quit button
    quitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [quitButton addTarget:self action:@selector(goto_Main_Menu:) forControlEvents:UIControlEventTouchDown];
    UIImage *quitbtn = [UIImage imageNamed:@"quitButton.png"];
    [quitButton setImage:quitbtn forState:UIControlStateNormal];
    [quitButton setFrame:CGRectMake(445,5,29,29)];
    quitButton.hidden = TRUE;
    [[[CCDirector sharedDirector] openGLView] addSubview:quitButton];
    
	//Adding a skip button during animated help
    skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [skipButton addTarget:self action:@selector(skipIntro:) forControlEvents:UIControlEventTouchDown];
    UIImage *skipbtn = [UIImage imageNamed:@"skip.png"];
    [skipButton setImage:skipbtn forState:UIControlStateNormal];
    [skipButton setFrame:CGRectMake(350,280,120,54)];
    
    if(_pressedPlayFromMainMenu == 1)
    {
        [[[CCDirector sharedDirector] openGLView] addSubview:skipButton];
    }
    else
    {
        playPauseButton.hidden = FALSE;
        quitButton.hidden = FALSE;
    }
    
}

//Functionality to skip animated help when skip button is touched
-(void) skipIntro:(id)sender
{
    [self unschedule:@selector(gameHint:)];
    _hintScreen.visible = NO;
    _hintAnim = 0;
    _countDownScreen.visible = YES;
    _skipButtonPresent = FALSE;
    [skipButton removeFromSuperview];
    playPauseButton.hidden = FALSE;
    quitButton.hidden = FALSE;
    [self schedule:@selector(countDownStart:) interval:0.04];
}

//Functionality to add VC's
-(void) addVCs
{ 
    //middle and right to display
    if((_VC1_Present == FALSE) && (_VC2_Present == FALSE) && (_VC3_Present == FALSE))
    {
        randomVCs = arc4random()%15;
        
        if(randomVCs == 0)
        {
            rand2 = 1;
        }
        if(randomVCs == 14)
        {
            rand2 = 13;
        }
        rand1 = randomVCs;
        [enemy setTexture:[[CCTextureCache sharedTextureCache] addImage:[_VCLoadedToDisplay objectAtIndex:rand1]]];
        enemy.position = ccp(160,110);
        [self schedule:@selector(animateVC1:)];
        _VC1_Present = TRUE;
        
        [enemy2 setTexture:[[CCTextureCache sharedTextureCache] addImage:[_VCLoadedToDisplay objectAtIndex:rand2]]];
        enemy2.position = ccp(370,60);
        [self schedule:@selector(animateVC2:)];
        _VC2_Present = TRUE;
        return;
    }
    
    //middle whacked
    if(_VC1_Whacked == TRUE)
    {
        _VC1_Whacked = FALSE;
        
        if(_VC2_Present == TRUE)
        {
            randomVCs = arc4random()%2;
            rand3 = randomVCs;
            [enemy1 setTexture:[[CCTextureCache sharedTextureCache] addImage:[_VCLoadedToDisplay objectAtIndex:rand3]]];
            enemy1.position = ccp(50,235);
            [self schedule:@selector(animateVC3:)];
            _VC3_Present = TRUE;
            return;
        }
        if(_VC3_Present == TRUE)
        {
            randomVCs = arc4random()%3 + 2;
            rand2 = randomVCs;
            [enemy2 setTexture:[[CCTextureCache sharedTextureCache] addImage:[_VCLoadedToDisplay objectAtIndex:rand2]]];
            enemy2.position = ccp(370,60);
            [self schedule:@selector(animateVC2:)];
            _VC2_Present = TRUE;
            return;
        }
    }
    
    //right whacked
    if(_VC2_Whacked == TRUE)
    {
        _VC2_Whacked = FALSE;
        
        if(_VC1_Present == TRUE)
        {
            randomVCs = arc4random()%2 + 5;
            rand3 = randomVCs;
            [enemy1 setTexture:[[CCTextureCache sharedTextureCache] addImage:[_VCLoadedToDisplay objectAtIndex:rand3]]];
            enemy1.position = ccp(50,235);
            [self schedule:@selector(animateVC3:)];
            _VC3_Present = TRUE;
            return;
        }
        if(_VC3_Present == TRUE)
        {
            randomVCs = arc4random()%3 + 7;
            rand1 = randomVCs;
            [enemy setTexture:[[CCTextureCache sharedTextureCache] addImage:[_VCLoadedToDisplay objectAtIndex:rand1]]];
            enemy.position = ccp(160,110);
            [self schedule:@selector(animateVC1:)];
            _VC1_Present = TRUE;
            return;
        }
    }
    
    //left whacked
    if(_VC3_Whacked == TRUE)
    {
        _VC3_Whacked = FALSE;
        
        if(_VC1_Present == TRUE)
        {
            randomVCs = arc4random()%2 + 10;
            rand2 = randomVCs;
            [enemy2 setTexture:[[CCTextureCache sharedTextureCache] addImage:[_VCLoadedToDisplay objectAtIndex:rand2]]];
            enemy2.position = ccp(370,60);
            [self schedule:@selector(animateVC2:)];
            _VC2_Present = TRUE;
            return;
        }
        if(_VC2_Present == TRUE)
        {
            randomVCs = arc4random()%3 + 12;
            rand1 = randomVCs;
            [enemy setTexture:[[CCTextureCache sharedTextureCache] addImage:[_VCLoadedToDisplay objectAtIndex:rand1]]];
            enemy.position = ccp(160,110);
            [self schedule:@selector(animateVC1:)];
            _VC1_Present = TRUE;
            return;
        }
    }
}

//Functionality to Update Score
-(void) updateScore
{
    if((_VC1_Whacked == TRUE) || (_VC2_Whacked == TRUE) || (_VC3_Whacked == TRUE))
    {
        _whackCountArray[randomVCs] = _whackCountArray[randomVCs] + 1;
    }
    scoreCount = scoreCount + 1;
    [score setString:[NSString stringWithFormat:@"%d", scoreCount]];
}
//Functionality to place Energy Pellets in Random positions
-(void)placeEnergyPellets:(ccTime)dt
{
    int randPos = arc4random()%10;
    _energyPellet.position = ccp(_energyPelletPosX[randPos], _energyPelletPosY[randPos]);
    _energyPellet.visible = YES;
    
    [self schedule:@selector(animPellet:) interval:0.2f];
}
//Functionality to animate Energy Pellet
-(void) animPellet:(ccTime)dt
{
    if((_energyPelletAnim%2)==0)
    {
        [_energyPellet setTexture:[[CCTextureCache sharedTextureCache] addImage:@"energypelletanim.png"]];
        _energyPelletAnim++;
    }
    else
    {
        [_energyPellet setTexture:[[CCTextureCache sharedTextureCache] addImage:@"energypellet.png"]];
        _energyPelletAnim++;
    }
}
//Functionality to check Collision with Pellet
-(void)checkCollisionWithPellet:(ccTime)dt
{
    CGRect playerRect = CGRectMake(_player.position.x, _player.position.y, 32, 32);
    CGRect energyPelletRect = CGRectMake(_energyPellet.position.x, _energyPellet.position.y, 32, 32);
    
	//VC images bounds that is used is used for collision detection with the player
    enemyRect = CGRectMake(enemy.position.x, enemy.position.y, 29, 36);
    enemy1Rect = CGRectMake(enemy1.position.x, enemy1.position.y, 29, 36);
    enemy2Rect = CGRectMake(enemy2.position.x, enemy2.position.y, 29, 36);
    
    //Block to check collision with Energy Pellet
    if(CGRectIntersectsRect(playerRect, energyPelletRect))
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"pellet.mp3"];
        _energyPellet.visible = NO;
        [self unschedule:@selector(animPellet:)];
        _energyPelletAnim = 0;
        _energyPellet.position = ccp(-100,-100);
        _pelletEaten = TRUE;
        _powerOfPlayer = TRUE;
        _animforward = 0;
        _powerUpID = [[SimpleAudioEngine sharedEngine] playEffect:@"powergreen.wav"];
    }
    //Block to check collision with VC in middle
    if(CGRectIntersectsRect(playerRect, enemyRect))
    {
        if(_pelletEaten == TRUE)
        {
            [self unschedule:@selector(animateVC1:)];
            [self unschedule:@selector(moveinx:) ];
            [self unschedule:@selector(moveiny:) ];
            [self unschedule:@selector(moveinminusx:) ];
            [self unschedule:@selector(moveinminusy:) ];
            [self unschedule:@selector(animatePlayerForward:)];
            [self unschedule:@selector(animatePlayerBackward:)];
            
            
            _VC1_Present = FALSE;
            _VC1_Whacked = TRUE;
            
            [self schedule:@selector(animateOnCollisionWithVC1:) interval:0.1f];
        }
        else
        {
            _player.position = ccp(x, y);
            [self playerLostLife];
            [self schedule:@selector(animatePlayerBlink:) interval:0.1f];
        }
        
    }
    //Block to check collision with VC in left
    if(CGRectIntersectsRect(playerRect, enemy1Rect))
    {
        
        if(_pelletEaten == TRUE)
        {
            [self unschedule:@selector(animateVC3:)];
            [self unschedule:@selector(moveinx:) ];
            [self unschedule:@selector(moveiny:) ];
            [self unschedule:@selector(moveinminusx:) ];
            [self unschedule:@selector(moveinminusy:) ];
            [self unschedule:@selector(animatePlayerForward:)];
            [self unschedule:@selector(animatePlayerBackward:)];
            
            _VC3_Present = FALSE;
            _VC3_Whacked = TRUE;
            
            [self schedule:@selector(animateOnCollisionWithVC3:) interval:0.1f];
        }
        else
        {
            _player.position = ccp(x, y);
            [self playerLostLife];
            [self schedule:@selector(animatePlayerBlink:) interval:0.1f];
        }
    }
    
    //Block to check collision with VC in right
    if(CGRectIntersectsRect(playerRect, enemy2Rect))
    {
        if(_pelletEaten == TRUE)
        {
            [self unschedule:@selector(animateVC2:)];
            [self unschedule:@selector(moveinx:) ];
            [self unschedule:@selector(moveiny:) ];
            [self unschedule:@selector(moveinminusx:) ];
            [self unschedule:@selector(moveinminusy:) ];
            [self unschedule:@selector(animatePlayerForward:)];
            [self unschedule:@selector(animatePlayerBackward:)];
            
            _VC2_Present = FALSE;
            _VC2_Whacked = TRUE;
            
            [self schedule:@selector(animateOnCollisionWithVC2:) interval:0.1f];
        }
        else
        {
            _player.position = ccp(x, y);
            [self playerLostLife];
            [self schedule:@selector(animatePlayerBlink:) interval:0.1f];
        }
        
    }
}

//Functionality to eat a VC in middle and animate the monster
-(void) animateOnCollisionWithVC1:(ccTime)dt
{
    if((_animPlayerOnCollision%4)==0)
    {
        if(_turnForward == TRUE)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerstopwalkforward.png"]];
        }
        else
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerstopwalkbackward.png"]];
        }
        _animPlayerOnCollision++;
    }
    else if((_animPlayerOnCollision%4)==1)
    {
        if(_turnForward == TRUE)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playereatvcforward.png"]];
        }
        else
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playereatvcbackward.png"]];
        }
        [enemy setTexture:[[CCTextureCache sharedTextureCache] addImage:@"vc1thump1.png"]];
        [self playWhackSounds];
        
        if((_initialVC1Whacked == 0) && (_VC1_Whacked == TRUE))
        {
            [vcorg setString:[_dbmanager._retrieveImageFirmArray objectAtIndex:rand1]];
            [vcname setString:[_dbmanager._retrieveVCNameArray objectAtIndex:rand1]];
            vcname.visible = YES;
            [self removeChild:stroke cleanup:YES];
            stroke = [LabelOutlineLayer createStroke:vcname  size:3  color:ccBLACK];
            [self addChild:stroke];
            [self schedule:@selector(animLabel:) interval:0.09];
            _initialVC1Whacked = 1;
        }
        else
        {
            [vcorg setString:[_dbmanager._retrieveImageFirmArray objectAtIndex:rand1]];
            [vcname setString:[_dbmanager._retrieveVCNameArray objectAtIndex:rand1]];
            vcname.visible = YES;
            [self removeChild:stroke cleanup:YES];
            stroke = [LabelOutlineLayer createStroke:vcname  size:3  color:ccBLACK];
            [self addChild:stroke];
            [self schedule:@selector(animLabel:) interval:0.09];
        }
        _animPlayerOnCollision++;
    }
    else if((_animPlayerOnCollision%4)==2)
    {
        if(_turnForward == TRUE)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerstopwalkforward.png"]];
        }
        else
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerstopwalkbackward.png"]];
        }
        [enemy setTexture:[[CCTextureCache sharedTextureCache] addImage:@"vc1thump2.png"]];
        _animPlayerOnCollision++;
        
        enemyRect = CGRectMake(-100, -100, 58, 72);
    }
    else if((_animPlayerOnCollision%4)==3)
    {
        [self unschedule:@selector(animateOnCollisionWithVC1:)];
        enemy.position = ccp(-100,-100);
        _animPlayerOnCollision=0;
        [[SimpleAudioEngine sharedEngine] stopEffect:_powerUpID];
        
        [self updateScore];
        [self addVCs];
        [self schedule:@selector(animatePlayerForward:) interval:0.3];
    }
}
//Functionality to eat a VC in right and animate the monster
-(void) animateOnCollisionWithVC2:(ccTime)dt
{
    if((_animPlayerOnCollision%4)==0)
    {
        if(_turnForward == TRUE)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerstopwalkforward.png"]];
        }
        else
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerstopwalkbackward.png"]];
        }
        _animPlayerOnCollision++;
    }
    else if((_animPlayerOnCollision%4)==1)
    {
        if(_turnForward == TRUE)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playereatvcforward.png"]];
        }
        else
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playereatvcbackward.png"]];
        }
        [enemy2 setTexture:[[CCTextureCache sharedTextureCache] addImage:@"vc2thump1.png"]];
        [self playWhackSounds];
        
        if((_initialVC2Whacked == 0) && (_VC2_Whacked == TRUE))
        {
            [vcorg setString:[_dbmanager._retrieveImageFirmArray objectAtIndex:rand2]];
            [vcname setString:[_dbmanager._retrieveVCNameArray objectAtIndex:rand2]];
            vcname.visible = YES;
            [self removeChild:stroke cleanup:YES];
            stroke = [LabelOutlineLayer createStroke:vcname  size:3  color:ccBLACK];
            [self addChild:stroke];
            [self schedule:@selector(animLabel:) interval:0.09];
            _initialVC2Whacked = 1;
        }
        else
        {
            [vcorg setString:[_dbmanager._retrieveImageFirmArray objectAtIndex:rand2]];
            [vcname setString:[_dbmanager._retrieveVCNameArray objectAtIndex:rand2]];
            vcname.visible = YES;
            [self removeChild:stroke cleanup:YES];
            stroke = [LabelOutlineLayer createStroke:vcname  size:3  color:ccBLACK];
            [self addChild:stroke];
            [self schedule:@selector(animLabel:) interval:0.09];
        }
        _animPlayerOnCollision++;
    }
    else if((_animPlayerOnCollision%4)==2)
    {
        if(_turnForward == TRUE)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerstopwalkforward.png"]];
        }
        else
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerstopwalkbackward.png"]];
        }
        [enemy2 setTexture:[[CCTextureCache sharedTextureCache] addImage:@"vc2thump2.png"]];
        _animPlayerOnCollision++;
        enemy2Rect = CGRectMake(-100, -100, 58, 72);  
    }
    else if((_animPlayerOnCollision%4)==3)
    {
        [self unschedule:@selector(animateOnCollisionWithVC2:)];
        enemy2.position = ccp(-100,-100);
        _animPlayerOnCollision=0;
        [[SimpleAudioEngine sharedEngine] stopEffect:_powerUpID];
        
        [self updateScore];
        [self addVCs];
        
        [self schedule:@selector(animatePlayerForward:) interval:0.3];
    }
}
//Functionality to eat a VC in left and animate the monster
-(void) animateOnCollisionWithVC3:(ccTime)dt
{
    if((_animPlayerOnCollision%4)==0)
    {
        if(_turnForward == TRUE)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerstopwalkforward.png"]];
        }
        else
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerstopwalkbackward.png"]];
        }
        _animPlayerOnCollision++;
    }
    else if((_animPlayerOnCollision%4)==1)
    {
        if(_turnForward == TRUE)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playereatvcforward.png"]];
        }
        else
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playereatvcbackward.png"]];
        }
        [enemy1 setTexture:[[CCTextureCache sharedTextureCache] addImage:@"vc2thump1.png"]];
        [self playWhackSounds];
        
        [vcorg setString:[_dbmanager._retrieveImageFirmArray objectAtIndex:rand3]];
        [vcname setString:[_dbmanager._retrieveVCNameArray objectAtIndex:rand3]];
        vcname.visible = YES;
        [self removeChild:stroke cleanup:YES];
        stroke = [LabelOutlineLayer createStroke:vcname  size:3  color:ccBLACK];
        [self addChild:stroke];
        [self schedule:@selector(animLabel:) interval:0.09];
        _animPlayerOnCollision++;
    }
    else if((_animPlayerOnCollision%4)==2)
    {
        if(_turnForward == TRUE)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerstopwalkforward.png"]];
        }
        else
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerstopwalkbackward.png"]];
        }
        [enemy1 setTexture:[[CCTextureCache sharedTextureCache] addImage:@"vc2thump2.png"]];
        _animPlayerOnCollision++;
        enemy1Rect = CGRectMake(-100, -100, 58, 72);  
    }
    else if((_animPlayerOnCollision%4)==3)
    {
        [self unschedule:@selector(animateOnCollisionWithVC3:)];
        enemy1.position = ccp(-100,-100);
        _animPlayerOnCollision=0;
        [[SimpleAudioEngine sharedEngine] stopEffect:_powerUpID];
        
        [self updateScore];
        [self addVCs];
        
        [self schedule:@selector(animatePlayerForward:) interval:0.3];
    }
}

//Functionality to check the lives remaining for the player
-(void) animatePlayerBlink:(ccTime)dt
{
    
    if(_blinkPlayer < 10)
    {
        if(_blinkPlayer==0)
        {
            lives--;
            if(lives == 1)
            {
                life3.visible = NO;
            }
            if(lives == 0)
            {
                life2.visible = NO;
            }
            if(lives == -1)
            {
                life1.visible = NO;
                [self schedule:@selector(gotoGameOver:) interval:0.5];
            }  
        }
        
        
        if((_blinkPlayer%2)==0)
        {
            _player.visible = NO;
            _blinkPlayer++;
        }
        else
        {
            _player.visible = YES;
            _blinkPlayer++;
        }
    }
    else
    {
        [self unschedule:@selector(animatePlayerBlink:)];
        _blinkPlayer = 0;
    }
}

//Functionality to transit to Game Over Screen
-(void) gotoGameOver:(ccTime)dt
{
	//Reset all variables and unschedule all timers
    [[SimpleAudioEngine sharedEngine] stopEffect:_soundEffectID];
    [[SimpleAudioEngine sharedEngine] stopEffect:_loseLifeID];
    [playPauseButton removeFromSuperview];
    [quitButton removeFromSuperview];
    sec = 60;
    _blink = 0;
    _gamePaused = FALSE;
    _pelletEaten = TRUE;
    _powerOfPlayer = TRUE;
    _animforward = 0;
    _animPlayer = 0;
    
    _VC1_Present = FALSE;
    _VC2_Present = FALSE;
    _VC3_Present = FALSE;
    
    _VC1_Whacked = FALSE;
    _VC2_Whacked = FALSE;
    _VC3_Whacked = FALSE;
    
    _turnForward = FALSE;
    
    _energyPelletAnim = 0;
    
    _initialVC1Whacked = 0;
    _initialVC2Whacked = 0;
    
    //Unscheduling the animation timer
    [self unschedule:@selector(animateVC1:)];
    [self unschedule:@selector(animateVC2:)];
    [self unschedule:@selector(animateVC3:)];
    [self unschedule:@selector(moveinx:) ];
    [self unschedule:@selector(moveiny:) ];
    [self unschedule:@selector(moveinminusx:) ];
    [self unschedule:@selector(moveinminusy:) ];
    [self unschedule:@selector(animatePlayerForward:)];
    [self unschedule:@selector(animatePlayerBackward:)];
    [self unschedule:@selector(blinkText:)];
    [self unschedule:@selector(placeEnergyPellets:)];
    [self unschedule:@selector(checkCollisionWithPellet:)];
    [self unschedule:@selector(animPellet:)];
    
    //Unscheduling the countdown timer
    [self unschedule:@selector(countDownTimer:)];
    [self unschedule:@selector(gotoGameOver:)];

    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[TimeUpLayer scene]]];
}


//Functionality to have a 60 sec countdown timer
-(void)countDownTimer:(ccTime)dt
{
    if(_gamePaused == FALSE)
    {
        if(sec > 0)
        {
            sec--;
            if(sec < 10)
            {
                [timer setString:[NSString stringWithFormat:@"%d%d:%d%d", hour,hour,hour,sec]];
                [self schedule:@selector(blinkText:) interval:0.2f];
                timer.color=ccc3(255,0,0);
            }
            else
            {
                [timer setString:[NSString stringWithFormat:@"%d%d:%d", hour,hour,sec]];
            } 
        }
        else
        {
            [playPauseButton removeFromSuperview];
            [quitButton removeFromSuperview];
            sec = 60;
            _blink = 0;
            _gamePaused = FALSE;
            _pelletEaten = TRUE;
            _powerOfPlayer = TRUE;
            _animforward = 0;
            _animPlayer = 0;
            
            _VC1_Present = FALSE;
            _VC2_Present = FALSE;
            _VC3_Present = FALSE;
            
            _VC1_Whacked = FALSE;
            _VC2_Whacked = FALSE;
            _VC3_Whacked = FALSE;
            
            _turnForward = FALSE;
            
            _energyPelletAnim = 0;
            
            _initialVC1Whacked = 0;
            _initialVC2Whacked = 0;
            
            //Unscheduling the animation timer
            [self unschedule:@selector(animateVC1:)];
            [self unschedule:@selector(animateVC2:)];
            [self unschedule:@selector(animateVC3:)];
            [self unschedule:@selector(moveinx:) ];
            [self unschedule:@selector(moveiny:) ];
            [self unschedule:@selector(moveinminusx:) ];
            [self unschedule:@selector(moveinminusy:) ];
            [self unschedule:@selector(animatePlayerForward:)];
            [self unschedule:@selector(animatePlayerBackward:)];
            [self unschedule:@selector(blinkText:)];
            [self unschedule:@selector(placeEnergyPellets:)];
            [self unschedule:@selector(checkCollisionWithPellet:)];
            [self unschedule:@selector(animPellet:)];
            
            //Unscheduling the countdown timer
            [self unschedule:@selector(countDownTimer:)];
            
            _showTimeUpScreen = TRUE;
            [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[TimeUpLayer scene]]];
        }
    }
}

//Functionality to indicate timer blink for last 10 sec
-(void) blinkText:(ccTime)dt
{
    if(_blink%2==0)
    {
        timer.visible=YES;
        _blink++;
    }
    else
    {
        timer.visible=NO;
        _blink++;
    }
}

//Functionality to pause a GamePlay
-(void) pauseAction:(id)sender
{
    //Pause Action
    if(_gamePaused == FALSE)
    {
         self.isTouchEnabled = NO;
        _pauseScreen.visible = YES;
        
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        
        [self unschedule:@selector(animatePlayerForward:)];
        [self unschedule:@selector(animatePlayerBackward:)];
        
        UIImage *playbtn = [UIImage imageNamed:@"playButton.png"];
        [playPauseButton setImage:playbtn forState:UIControlStateNormal];
        self.isTouchEnabled = NO;
        if(_pauseMovingPlayerInX == 1)
        {
            [self unschedule:@selector(moveinx:) ];
            [self unschedule:@selector(placeEnergyPellets:)];
            [self unschedule:@selector(checkCollisionWithPellet:)];
        }
        if(_pauseMovingPlayerInY == 1)
        {
            [self unschedule:@selector(moveiny:) ];
            [self unschedule:@selector(placeEnergyPellets:)];
            [self unschedule:@selector(checkCollisionWithPellet:)];
        }
        if(_pauseMovingPlayerInMinusX == 1)
        {
            [self unschedule:@selector(moveinminusx:) ];
            [self unschedule:@selector(placeEnergyPellets:)];
            [self unschedule:@selector(checkCollisionWithPellet:)];
        }
        if(_pauseMovingPlayerInMinusY == 1)
        {
            [self unschedule:@selector(moveinminusy:) ];
            [self unschedule:@selector(placeEnergyPellets:)];
            [self unschedule:@selector(checkCollisionWithPellet:)];
        }
        _gamePaused = TRUE;
    }
    //Play Action
    else
    {
        self.isTouchEnabled = YES;
        _pauseScreen.visible = NO;
        
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
        
        [self schedule:@selector(animatePlayerForward:) interval:0.3];
        
        UIImage *playbtn = [UIImage imageNamed:@"pauseButton.png"];
        [playPauseButton setImage:playbtn forState:UIControlStateNormal];
        self.isTouchEnabled = YES;
        if(_pauseMovingPlayerInX == 1)
        {
            [self schedule:@selector(moveinx:) ];
            [self schedule:@selector(placeEnergyPellets:) interval:5.0];
            [self schedule:@selector(checkCollisionWithPellet:)];
        }
        if(_pauseMovingPlayerInY == 1)
        {
            [self schedule:@selector(moveiny:) ];
            [self schedule:@selector(placeEnergyPellets:) interval:5.0];
            [self schedule:@selector(checkCollisionWithPellet:)];
        }
        if(_pauseMovingPlayerInMinusX == 1)
        {
            [self schedule:@selector(moveinminusx:) ];
            [self schedule:@selector(placeEnergyPellets:) interval:5.0];
            [self schedule:@selector(checkCollisionWithPellet:)];
        }
        if(_pauseMovingPlayerInMinusY == 1)
        {
            [self schedule:@selector(moveinminusy:) ];
            [self schedule:@selector(placeEnergyPellets:) interval:5.0];
            [self schedule:@selector(checkCollisionWithPellet:)];
        }
        _gamePaused = FALSE;
    }
}

//Functionality to transit to Main Menu Screen
-(void) goto_Main_Menu:(id)sender
{
	//Stop all the audio and reset the variables and unschedule the timers
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[SimpleAudioEngine sharedEngine] stopEffect:_soundEffectID];
    [[SimpleAudioEngine sharedEngine] stopEffect:_loseLifeID];
    
    [playPauseButton removeFromSuperview];
    [quitButton removeFromSuperview];
    if(_skipButtonPresent == TRUE)
    {
        [skipButton removeFromSuperview];
    }
    sec = 60;
    scoreCount = 0;
    _gamePaused = FALSE;
    _pelletEaten = TRUE;
    _powerOfPlayer = TRUE;
    _animforward = 0;
    _animPlayer = 0;
    lives = 2;
    
    _VC1_Present = FALSE;
    _VC2_Present = FALSE;
    _VC3_Present = FALSE;
    
    _VC1_Whacked = FALSE;
    _VC2_Whacked = FALSE;
    _VC3_Whacked = FALSE;
    
    _turnForward = FALSE;
    
    _energyPelletAnim = 0;
    
    _hintAnim = 0;
    _countDownAnim = 0;
    
    _initialVC1Whacked = 0;
    _initialVC2Whacked = 0;
    
    [self unschedule:@selector(animateVC1:)];
    [self unschedule:@selector(animateVC2:)];
    [self unschedule:@selector(animateVC3:)];
    [self schedule:@selector(moveinx:) ];
    [self schedule:@selector(moveiny:) ];
    [self schedule:@selector(moveinminusx:) ];
    [self schedule:@selector(moveinminusy:) ];
    [self unschedule:@selector(animatePlayerForward:)];
    [self unschedule:@selector(animatePlayerBackward:)];
    [self unschedule:@selector(blinkText:)];
    [self unschedule:@selector(placeEnergyPellets:)];
    [self unschedule:@selector(checkCollisionWithPellet:)];
    [self unschedule:@selector(animPellet:)];
    [self unschedule:@selector(gameHint:)];
    [self unschedule:@selector(countDownStart:)];
    //Unscheduling the countdown timer
    [self unschedule:@selector(countDownTimer:)];

    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[HelloWorldLayer scene]]];
}

//Functionality for movement of VC1
-(void)animateVC1:(ccTime)dt
{
    if(_gamePaused == FALSE)
    {
        if((enemy.position.x > 159) && (enemy.position.x < 321))
        {
            if(enemy.position.y <= 80)
            {
                enemy.position = ccp(enemy.position.x + 100*dt , 80);
            }
            else if(enemy.position.y >= 196)
            {
                enemy.position = ccp(enemy.position.x - 100*dt , 196);
            }
        }
        
        if((enemy.position.y > 79) && (enemy.position.y < 197))
        {
            if(enemy.position.x >= 320)
            {
                enemy.position = ccp( 320, enemy.position.y + 100*dt );
            }
            else if(enemy.position.x <= 160)
            {
                enemy.position = ccp( 160, enemy.position.y - 100*dt );
            }
        }
        
    }
}

//Functionality for movement of VC2
-(void) animateVC2:(ccTime)dt
{
    if(_gamePaused == FALSE)
    {
        if((enemy2.position.x > 369) && (enemy2.position.x < 431))
        {
            if(enemy2.position.y <= 60)
            {
                enemy2.position = ccp(enemy2.position.x - 100*dt , 60);
            }
            else if(enemy2.position.y >= 235)
            {
                enemy2.position = ccp(enemy2.position.x + 100*dt , 235);
            }
        }
        
        if((enemy2.position.y > 59) && (enemy2.position.y < 236))
        {
            if(enemy2.position.x >= 430)
            {
                enemy2.position = ccp( 430, enemy2.position.y - 100*dt );
            }
            else if(enemy2.position.x <= 370)
            {
                enemy2.position = ccp( 370, enemy2.position.y + 100*dt );
            }
        }
    }
    
}

//Functionality for movement of VC3
-(void) animateVC3:(ccTime)dt
{
    if(_gamePaused == FALSE)
    {
        if((enemy1.position.x > 49) && (enemy1.position.x < 111))
        {
            if(enemy1.position.y <= 50)
            {
                enemy1.position = ccp(enemy1.position.x + 100*dt , 50);
            }
            else if(enemy1.position.y >= 235)
            {
                enemy1.position = ccp(enemy1.position.x - 100*dt , 235);
            }
        }
        
        if((enemy1.position.y > 49) && (enemy1.position.y < 236))
        {
            if(enemy1.position.x >= 110)
            {
                enemy1.position = ccp( 110, enemy1.position.y + 100*dt );
            }
            else if(enemy1.position.x <= 50)
            {
                enemy1.position = ccp( 50, enemy1.position.y - 100*dt );
            }
        }
    }
    
}

//Functionality for implementing the monster animation in forward direction(open and close) where the frames are to be played for 5 seconds and mod(16) provides the number of frames to be played for each second
-(void)animatePlayerForward:(ccTime)dt
{
    
    if(_powerOfPlayer == TRUE)
    {
        
        if((_animforward%16)==0)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardleft1.png"]];
            _animforward++;
        }
        else if((_animforward%16)==1)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardright1.png"]];
            _animforward++;
        }
        else if((_animforward%16)==2)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardleft1.png"]];
            _animforward++;
        }
        
        
        else if((_animforward%16)==3)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardright2.png"]];
            _animforward++;
        }
        else if((_animforward%16)==4)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardleft2.png"]];
            _animforward++;
        }
        else if((_animforward%16)==5)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardright2.png"]];
            _animforward++;
        }
        
        
        else if((_animforward%16)==6)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardleft3.png"]];
            _animforward++;
        }
        else if((_animforward%16)==7)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardright3.png"]];
            _animforward++;
        }
        else if((_animforward%16)==8)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardleft3.png"]];
            _animforward++;
        }
        
        
        
        else if((_animforward%16)==9)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardright4.png"]];
            _animforward++;
        }
        else if((_animforward%16)==10)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardleft4.png"]];
            _animforward++;
        }
        else if((_animforward%16)==11)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardright4.png"]];
            _animforward++;
        }
        
        
        else if((_animforward%16)==12)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardleft5.png"]];
            _animforward++;
        }
        else if((_animforward%16)==13)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardright5.png"]];
            _animforward++;
        }
        else if((_animforward%16)==14)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardleft5.png"]];
            _animforward++;
        }
        
        else if((_animforward%16)==15)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardright6.png"]];
            _animforward++;
            _powerOfPlayer = FALSE;
            _pelletEaten = FALSE;
            [[SimpleAudioEngine sharedEngine] stopEffect:_powerUpID];
        }
    }
    else
    {
        if((_animPlayer%2)==0)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardleft6.png"]];
            _animPlayer++;
        }
        else
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerforwardright6.png"]];
            _animPlayer++;
        }
    }
}

//Functionality for implementing the monster animation in backward direction(open and close) where the frames are to be played for 5 seconds and mod(16) provides the number of frames to be played for each second
-(void)animatePlayerBackward:(ccTime)dt
{
    if(_powerOfPlayer == TRUE)
    {
        if((_animforward%16)==0)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardleft1.png"]];
            _animforward++;
        }
        else if((_animforward%16)==1)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardright1.png"]];
            _animforward++;
        }
        else if((_animforward%16)==2)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardleft1.png"]];
            _animforward++;
        }
        
        
        else if((_animforward%16)==3)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardright2.png"]];
            _animforward++;
        }
        else if((_animforward%16)==4)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardleft2.png"]];
            _animforward++;
        }
        else if((_animforward%16)==5)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardright2.png"]];
            _animforward++;
        }
        
        
        else if((_animforward%16)==6)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardleft3.png"]];
            _animforward++;
        }
        else if((_animforward%16)==7)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardright3.png"]];
            _animforward++;
        }
        else if((_animforward%16)==8)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardleft3.png"]];
            _animforward++;
        }
        
        
        
        else if((_animforward%16)==9)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardright4.png"]];
            _animforward++;
        }
        else if((_animforward%16)==10)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardleft4.png"]];
            _animforward++;
        }
        else if((_animforward%16)==11)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardright4.png"]];
            _animforward++;
        }
        
        
        else if((_animforward%16)==12)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardleft5.png"]];
            _animforward++;
        }
        else if((_animforward%16)==13)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardright5.png"]];
            _animforward++;
        }
        else if((_animforward%16)==14)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardleft5.png"]];
            _animforward++;
        }
        
        else if((_animforward%16)==15)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardright6.png"]];
            _animforward++;
            _powerOfPlayer = FALSE;
            _pelletEaten = FALSE;
            [[SimpleAudioEngine sharedEngine] stopEffect:_powerUpID];
        }
    }
    else
    {
        if((_animPlayer%2)==0)
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardleft6.png"]];
            _animPlayer++;
        }
        else
        {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerbackwardright6.png"]];
            _animPlayer++;
        }
    }
}

// Method to check the Tile coordinates
- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
    return ccp(x, y);
}

//Methods to detect the touches
-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
                                                     priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

//Method to detect swipe movement of the monster
-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    touchLocation = [touch locationInView: [touch view]];		
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    playerPos = _player.position;
    diff = ccpSub(touchLocation, playerPos);//difference between the touch location and player position

    movex = 0;
    moveminusx = 0;
    movey = 0;
    moveminusy = 0;
    
    if (abs(diff.x) > abs(diff.y)) {
        if (diff.x > 0) {
            [self unschedule:@selector(moveinminusx:)];
            [self schedule:@selector(moveinx:)];
            [self unschedule:@selector(moveinminusy:)];
            [self unschedule:@selector(moveiny:)];
            
            _turnForward = TRUE;
            
            [self schedule:@selector(animatePlayerForward:) interval:0.3];
            [self unschedule:@selector(animatePlayerBackward:)];
            
        } else {
            [self unschedule:@selector(moveinx:)];
            [self schedule:@selector(moveinminusx:)];
            [self unschedule:@selector(moveinminusy:)];
            [self unschedule:@selector(moveiny:)];
            
            _turnForward = FALSE;
            
            [self schedule:@selector(animatePlayerBackward:) interval:0.3];
            [self unschedule:@selector(animatePlayerForward:)];
        }    
    } else {
        if (diff.y > 0) {
            [self unschedule:@selector(moveinminusx:)];
            [self unschedule:@selector(moveinx:)];
            [self unschedule:@selector(moveinminusy:)];
            [self schedule:@selector(moveiny:)];
            
            
        } else {
            [self unschedule:@selector(moveinminusx:)];
            [self unschedule:@selector(moveinx:)];
            [self unschedule:@selector(moveiny:)];
            [self schedule:@selector(moveinminusy:)];
            
        }
    }
    
    
}

//Functionality to move the player in -x direction
-(void)moveinminusx:(ccTime)dt
{
    _pauseMovingPlayerInX = 0;
    _pauseMovingPlayerInY = 0;
    _pauseMovingPlayerInMinusX = 1;
    _pauseMovingPlayerInMinusY = 0;
    
    moveminusx = 1;
    
    if(_player.position.x > 20)
    {
        _player.position = ccp(_player.position.x - 2,_player.position.y);
    }
    else
    {
        _player.position = ccp(20,_player.position.y);
    }
    
    [self checkCollision:_player.position];
}

//Functionality to move the player in -y direction
-(void)moveinminusy:(ccTime)dt
{
    _pauseMovingPlayerInX = 0;
    _pauseMovingPlayerInY = 0;
    _pauseMovingPlayerInMinusX = 0;
    _pauseMovingPlayerInMinusY = 1;
    
    moveminusy = 1;
    
    _player.position = ccp(_player.position.x ,_player.position.y - 2);
    
    [self checkCollision:_player.position];
}

//Functionality to move the player in +x direction
-(void)moveinx:(ccTime)dt
{
    _pauseMovingPlayerInX = 1;
    _pauseMovingPlayerInY = 0;
    _pauseMovingPlayerInMinusX = 0;
    _pauseMovingPlayerInMinusY = 0;
    
    movex = 1;
    _player.position = ccp(_player.position.x + 2,_player.position.y);
    
    [self checkCollision:_player.position];
}

//Functionality to move the player in +y direction
-(void)moveiny:(ccTime)dt
{
    _pauseMovingPlayerInX = 0;
    _pauseMovingPlayerInY = 1;
    _pauseMovingPlayerInMinusX = 0;
    _pauseMovingPlayerInMinusY = 0;
    
    movey = 1;
    
    _player.position = ccp(_player.position.x ,_player.position.y + 2);
    
    [self checkCollision:_player.position];
}

//Method for collision detection of player and the walls of the Tilemap
-(void)checkCollision:(CGPoint)position
{
    CGPoint tileCoord = [self tileCoordForPosition:position];
    int tileGid = [_meta tileGIDAt:tileCoord];
    if (tileGid) {
        NSDictionary *properties = [_tileMap propertiesForGID:tileGid];
        if (properties) {
            
            //Functionality to detect collision and operation to be performed on collision
            NSString *collision = [properties valueForKey:@"Collidable"];
            if (collision && [collision compare:@"True"] == NSOrderedSame) {
                
                [self unschedule:@selector(moveinminusx:)];
                [self unschedule:@selector(moveinx:)];
                [self unschedule:@selector(moveinminusy:)];
                [self unschedule:@selector(moveiny:)];
                
                if(movex == 1)
                {
                    _player.position = ccp(_player.position.x-2,_player.position.y);
                    movex = 0;
                }
                if(moveminusx == 1)
                {
                    _player.position = ccp(_player.position.x+2,_player.position.y);
                    moveminusx = 0;
                }
                if(movey == 1)
                {
                    _player.position = ccp(_player.position.x,_player.position.y-5);
                    movey = 0;
                }
                if(moveminusy == 1)
                {
                    _player.position = ccp(_player.position.x,_player.position.y+20);
                    moveminusy = 0;
                }
            }
        }
    }
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    
    self.tileMap = nil;
    self.background = nil;
    self.foreground = nil;
    self.player=nil;
    self.meta = nil;
    self.hud = nil;
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    
    _dbmanager._retrieveArray = nil;
    [_dbmanager._retrieveArray release];
    _dbmanager._retrieveImageIdArray = nil;
    [_dbmanager._retrieveImageIdArray release];
    _dbmanager._whackedAudioPaths = nil;
    [_dbmanager._whackedAudioPaths release];
    _dbmanager._retrieveImageFirmArray = nil;
    [_dbmanager._retrieveImageFirmArray release];
    _dbmanager._retrieveVCNameArray = nil;
    [_dbmanager._retrieveVCNameArray release];
    
    //Call to a function to close database
    [_dbmanager closeDB];
    [_dbmanager release];
    
    
    _totalVCImagesArray = nil;
    _totalVCImageIdsArray = nil;
    _whackAudio = nil;
    
    _VC1ImageArray = nil;
    _VC2ImageArray = nil;
    _VC3ImageArray = nil;
    
    _VC1ImageArrayIds = nil;
    _VC2ImageArrayIds = nil;
    _VC3ImageArrayIds = nil;
    
    _VC1ImageArrayToLoad = nil;
    _VC2ImageArrayToLoad = nil;
    _VC3ImageArrayToLoad = nil;
    
    _VC1ImageIdsArrayToLoad = nil;
    _VC2ImageIdsArrayToLoad = nil;
    _VC3ImageIdsArrayToLoad = nil;
    
    _VCLoadedToDisplay = nil;
    
    [_totalVCImagesArray release];
    [_totalVCImageIdsArray release];
    
    [_VC1ImageArray release];
    [_VC2ImageArray release];
    [_VC3ImageArray  release];
    
    [_VC1ImageArrayIds release];
    [_VC2ImageArrayIds release];
    [_VC3ImageArrayIds release];
    
    [_VC1ImageArrayToLoad release];
    [_VC2ImageArrayToLoad release];
    [_VC3ImageArrayToLoad release];
    
    [_VC1ImageIdsArrayToLoad release];
    [_VC2ImageIdsArrayToLoad release];
    [_VC3ImageIdsArrayToLoad release];
    
    [_VCLoadedToDisplay release];
    
    [_whackAudio release];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
