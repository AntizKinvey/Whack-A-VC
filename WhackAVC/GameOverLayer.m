//
//  GameOverLayer.m
//  WhackAVC
//
//  
//  Copyright Antiz Technologies Pvt Ltd 2012. All rights reserved.
//


// Import the interfaces
#import "GameOverLayer.h"
#import "HelloWorldLayer.h"
#import "VcsScreenLayer.h"
#import "PlayAreaLayer.h"
#import "AboutKinveyLayer.h"
#import "SimpleAudioEngine.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "KCSWhacks.h"
#import "JSON.h"
#import "Accounts/ACAccount.h"

// GameOverLayer implementation
@implementation GameOverLayer

@synthesize _dbmanager;

@synthesize whackDetailsCollection = _whackDetailsCollection;//Reference to whacks collection in Kinvey

@synthesize facebook;

@synthesize twit;

@synthesize account;

KCSWhacks *_whackDetails;

//Scroll View to display the whack counts of each VC
UIScrollView *gameOverScrollView;

//Background image to display a particular contents of VC
UIImage *_vcImage;
UIImageView *_vcDisplayImage;
UIImage *_whackBackGround;
UIImageView *_whacksListBackGroundImage;

//Question mark image that blinks
UIImage *questionMarkImage;
UIImageView *questionMarkBackgroundImage;

//Label to display VC firm name
UILabel *firmNameLabel;
//Label to display VC name
UILabel *vcNameLabel;
//Label to display VC whack count
UILabel *vcWhackLabel;

//VClist button
UIButton *_vcListButton;
//Play again button
UIButton *_playAgainButton;

UIImage *_webCloseBandImage;
UIImageView *_webCloseBand;
UIButton *_closeButton;
UIWebView *webView;

//Label to display total whacks for a particular game play
UILabel *scoreLabel;

UIButton *_ownAVCButton;

extern int scoreCount;

extern int _pressedPlayFromMainMenu;

extern int check_button_pressed;

extern int _whackCountArray[15];

extern NSMutableArray *_VCIdsLoadedToDisplay;

//Variable used to blink question mark image
int _animateQuestionMark = 0;

int tagID = -1;
int twtagID = -1;
int animationCount = 330;

extern BOOL _once;
extern int _touchCount;

UIViewController *btnView;

extern NSString *_kinveyUserId;

NSArray *arrayOfAccounts;

BOOL _connected = FALSE;
BOOL _saveFbUserDetails = FALSE;
BOOL _saveTwUserDetails = FALSE;

int _whackArrayFromTemp[15];

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameOverLayer *layer = [GameOverLayer node];
	
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
	if( (self=[super init])) 
    {
        //Call to function to check Internet connectivity
        [self checkNetworkConnectivity];
        
        if(_connected == TRUE)
        {  
            //Reference to whacks collection in Kinvey
            _whackDetailsCollection = [[[KCSClient sharedClient]
                                        collectionFromString:@"whacks"
                                        withClass:[KCSWhacks class]] retain];
        }
        
        _dbmanager = [[DBManager alloc] init];
        
        //Call to a function that open connection to database
        [_dbmanager openDB];
        
        //Arrays that hold VC firm name, VC profile image, VC names and their twitter handles
        _dbmanager._vcFirmArrayFromDB = [[[NSMutableArray alloc] init] autorelease];
        _dbmanager._vcSnapsArrayFromDB = [[[NSMutableArray alloc] init] autorelease];
        _dbmanager._vcNamesArrayFromDB = [[[NSMutableArray alloc] init] autorelease];
        _dbmanager._vcTwitterHandleArrayFromDB = [[[NSMutableArray alloc] init] autorelease];
        
        //Arrays that hold VC Ids, VC firm name, VC profile image, VC names, VC whack counts and their twitter handles from the temporary table
        _dbmanager._vcIdsFromTemp = [[[NSMutableArray alloc] init] autorelease];
        _dbmanager._vcNamesFromTemp = [[[NSMutableArray alloc] init] autorelease];
        _dbmanager._vcFirmsFromTemp = [[[NSMutableArray alloc] init] autorelease];
        _dbmanager._vcSnapsFromTemp = [[[NSMutableArray alloc] init] autorelease];
        _dbmanager._vcWhacksFromTemp = [[[NSMutableArray alloc] init] autorelease];
        _dbmanager._vcTwHandlesFromTemp = [[[NSMutableArray alloc] init] autorelease];
        
        //Since only 15 VC's are used in the game play area the for loop condition holds values from [0...14]
        for(int i=0; i<15; i++)
        {
            //Get the VC firm name, profile image, VC names and twitter handles by using the SELECT statement based on VC ID's
            NSString *sqls = [[NSString alloc] initWithFormat:@"SELECT vcfirm,vcsnaps,vcname,vctwhandle FROM VClist where vcid=%@",[_VCIdsLoadedToDisplay objectAtIndex:i]];
            [_dbmanager retrieveVCSnapPathsAndFirms:sqls];
            [sqls release];
        }

        //Since only 15 VC's are used in the game play area the for loop condition holds values from [0...14]
        for(int i=0; i<15; i++)
        {
            NSString *whackCount = [[NSString alloc] initWithFormat:@"%d",_whackCountArray[i]];
            
            //Insert the records to temporary table in local cache
            [_dbmanager insertRecordIntoTempTable:@"Temp" withField1:@"vcid" field1Value:[_VCIdsLoadedToDisplay objectAtIndex:i] andField2:@"vcname" field2Value:[_dbmanager._vcNamesArrayFromDB objectAtIndex:i] andField3:@"vcfirm" field3Value:[_dbmanager._vcFirmArrayFromDB objectAtIndex:i] andField4:@"vcsnaps" field4Value:[_dbmanager._vcSnapsArrayFromDB objectAtIndex:i] andField5:@"vctwhandle" field5Value:[_dbmanager._vcTwitterHandleArrayFromDB objectAtIndex:i] andField6:@"whackcount" field6Value:whackCount];
            
            [whackCount release];
        }
       
        //Retrieve Records From Table Temp
        [_dbmanager retrieveRecordsFromTemp];
        
        
        //Convert String to Integer Value
        for(int i=0; i<15; i++)
        {
            NSString *whacks = [[NSString alloc] initWithString:[_dbmanager._vcWhacksFromTemp objectAtIndex:i]];
            _whackArrayFromTemp[i] = [whacks intValue];
            [whacks release];
        }
        
        //SORT
        for(int i=0; i<15; i++)
        {
            for(int j=0; j<14-i; j++)
            {
                if(_whackArrayFromTemp[j] < _whackArrayFromTemp[j+1])
                {
                    //Swap the objects in descending order
                    int temp = _whackArrayFromTemp[j];
                    _whackArrayFromTemp[j] = _whackArrayFromTemp[j+1];
                    _whackArrayFromTemp[j+1] = temp;
                    
                    [_dbmanager._vcIdsFromTemp exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                    [_dbmanager._vcNamesFromTemp exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                    [_dbmanager._vcFirmsFromTemp exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                    [_dbmanager._vcSnapsFromTemp exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                    [_dbmanager._vcTwHandlesFromTemp exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                    [_dbmanager._vcWhacksFromTemp exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                }
            }
        }
        
       
        //Init facebook using the facebook App ID
        facebook = [[Facebook alloc] initWithAppId:@"367944663248652" andDelegate:(AppDelegate *) [[UIApplication sharedApplication] delegate]];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        appDelegate.facebook = facebook;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
        
        //Add a background image to scene
        CCSprite *backgroundImage = [CCSprite spriteWithFile:@"vcs_screen.png" 
                                                        rect:CGRectMake(0, 0, 480, 320)];
        backgroundImage.position = ccp(240, 160);
        
        //Add a title bar to scene
        CCSprite *phraseTitleBarImage = [CCSprite spriteWithFile:@"phrasetitlebar.png" 
                                                            rect:CGRectMake(0, 0, 480, 76)];
        
        phraseTitleBarImage.position = ccp(240,282);
        
        //Scroll View to display the scores of each VC
        gameOverScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 76, 480, 210)];
        [gameOverScrollView setScrollEnabled:YES];
        [gameOverScrollView setContentSize:CGSizeMake(480, 1365)];
        
        //Main menu button
        CCMenuItem *mainmenuItem = [CCMenuItemImage itemFromNormalImage:@"transparent.png"
                                                          selectedImage: @"transparent.png"
                                                                 target:self
                                                               selector:@selector(goto_Main_Menu:)];
        
        
        // Create a menu and add your menu items to it
        CCMenu *myMenus = [CCMenu menuWithItems:mainmenuItem, nil];
        
        
        
        
        [mainmenuItem setPosition:ccp(155,-145)];
        
        CCSprite *mainmenubtn = [CCSprite spriteWithFile:@"mainmenubutton.png" 
                                                    rect:CGRectMake(0, 0, 480, 34)];
        
        mainmenubtn.position = ccp(240, 15);
        
        //Add children to scene
        [self addChild:backgroundImage];
        [self addChild:phraseTitleBarImage];
        [self addChild:myMenus z:5];
        [self addChild:mainmenubtn z:2];
        
	}
	return self;
}

//Functionality to blink the question mark image
-(void) animateQuestionMark:(ccTime)dt
{
    if(_animateQuestionMark%2 == 0)
    {
        questionMarkBackgroundImage.hidden = TRUE;
        _animateQuestionMark++;
    }
    else
    {
        questionMarkBackgroundImage.hidden = FALSE;
        _animateQuestionMark++;
    }
}

-(void) onEnterTransitionDidFinish {
	//Don't show web view until transition finishes
    
    //Label to display total whack score of game play
    scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(265, 15, 100, 50)];
    scoreLabel.text = [NSString stringWithFormat:@"%d",scoreCount];
    [scoreLabel setTextAlignment:UITextAlignmentCenter];
    scoreLabel.backgroundColor = [UIColor clearColor];
    
    //Add score label to scene
    [[[CCDirector sharedDirector] openGLView] addSubview:scoreLabel];
    
    //Button that redirects to apps.kinvey.com to know the ownership of VC's
    _ownAVCButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_ownAVCButton addTarget:self action:@selector(vcOwnership:) forControlEvents:UIControlStateHighlighted];
    UIImage *ownavcbtn = [UIImage imageNamed:@"ownavcbutton.png"];
    [_ownAVCButton setImage:ownavcbtn forState:UIControlStateNormal];
    [_ownAVCButton setFrame:CGRectMake(20, -5, 235, 72)];
    
    //Add button to scene
    [[[CCDirector sharedDirector] openGLView] addSubview:_ownAVCButton];
    
    //Add the question mark image to scene
    questionMarkImage = [UIImage imageNamed:@"question.png"];
    questionMarkBackgroundImage = [[UIImageView alloc] initWithImage:questionMarkImage];
    questionMarkBackgroundImage.frame = CGRectMake(211, 15, 21, 32);
    [[[CCDirector sharedDirector] openGLView] addSubview:questionMarkBackgroundImage];
    
    //Call to a function to animate question mark
    [self schedule:@selector(animateQuestionMark:) interval:0.1];
    
    //Add the VC list button to scene
    _vcListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_vcListButton addTarget:self action:@selector(goto_VCsList:) forControlEvents:UIControlEventTouchDown];
    UIImage *scorebtn = [UIImage imageNamed:@"myscore.png"];
    [_vcListButton setImage:scorebtn forState:UIControlStateNormal];
    [_vcListButton setFrame:CGRectMake(350,7,63,59)];
    [[[CCDirector sharedDirector] openGLView] addSubview:_vcListButton];
    
    //Add the play again button to scene
    _playAgainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playAgainButton addTarget:self action:@selector(restart_Level:) forControlEvents:UIControlEventTouchDown];
    UIImage *playAgainbtn = [UIImage imageNamed:@"playagain.png"];
    [_playAgainButton setImage:playAgainbtn forState:UIControlStateNormal];
    [_playAgainButton setFrame:CGRectMake(407,7,63,59)];
    [[[CCDirector sharedDirector] openGLView] addSubview:_playAgainButton];
    
    
    //Add the Scroll View to scene
    [[[CCDirector sharedDirector] openGLView] addSubview:gameOverScrollView];
    
    //Image that holds close button when web View is open
    _webCloseBandImage = [UIImage imageNamed:@"webcloseband.png"];
    _webCloseBand = [[UIImageView alloc] initWithImage:_webCloseBandImage];
    _webCloseBand.frame = CGRectMake(0, 0, 480, 30);
    
    [[[CCDirector sharedDirector] openGLView] addSubview:_webCloseBand];
    
    //Close Button image
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlStateHighlighted];
    UIImage *_closeButtonImage = [UIImage imageNamed:@"closebutton.png"];
    [_closeButton setImage:_closeButtonImage forState:UIControlStateNormal];
    [_closeButton setFrame:CGRectMake(454, 5, 24, 24)];
    
    [[[CCDirector sharedDirector] openGLView] addSubview:_closeButton];
    
    //Add the webview to scene
    NSString *urlAddress=@"http://apps.kinvey.com";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *reqObject=[NSURLRequest requestWithURL:url];
    webView = [[UIWebView alloc] init];
    webView.frame = CGRectMake(0, 330, 480, 290);
    [webView loadRequest:reqObject]; 
    
    [[[CCDirector sharedDirector] openGLView] addSubview:webView];
    
    _webCloseBand.hidden = TRUE;
    _closeButton.hidden = TRUE;
    webView.hidden = TRUE;
    
    //----------------------------------------------------------------------------------------------------------------------------
    
    int _yVal = 0;//This variable is used to add buttons and labels to each row in scroll view
    
    //Since there will be only 15 VC's used in gameplay the loop contains values from [0...14]
    for(int i=0; i<15; i++)
    {
        //Background for each row 
        _whackBackGround = [UIImage imageNamed:@"whackedvc.png"];
        _whacksListBackGroundImage = [[UIImageView alloc] initWithImage:_whackBackGround];
        _whacksListBackGroundImage.frame = CGRectMake(0, (i*91), 480, 91);
        
        //Image View to display VC profile images
        _vcImage = [UIImage imageWithContentsOfFile:[_dbmanager._vcSnapsFromTemp objectAtIndex:i]];
        _vcDisplayImage = [[UIImageView alloc] initWithImage:_vcImage];
        _vcDisplayImage.frame = CGRectMake(12, 6, 89, 80);
        
        //Label to display names of VC's
        vcNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 15, 200, 30)];
        vcNameLabel.text = [_dbmanager._vcNamesFromTemp objectAtIndex:i];
        [vcNameLabel setTextAlignment:UITextAlignmentLeft];
        vcNameLabel.backgroundColor = [UIColor clearColor];
        
        //Label to display firm names of VC's
        firmNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 35, 220, 30)];
        firmNameLabel.text = [_dbmanager._vcFirmsFromTemp objectAtIndex:i];
        [firmNameLabel setTextAlignment:UITextAlignmentLeft];
        firmNameLabel.backgroundColor = [UIColor clearColor];
        
        //Label to display VC whack Counts
        vcWhackLabel = [[UILabel alloc] initWithFrame:CGRectMake(360, 37, 20, 20)];
        vcWhackLabel.text = [NSString stringWithFormat:@"%d",_whackArrayFromTemp[i]];
        [vcWhackLabel setTextAlignment:UITextAlignmentCenter];
        vcWhackLabel.backgroundColor = [UIColor clearColor];
        
        //Facebook and Twitter buttons that are added to scroll view
        UIButton *fbButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [fbButton addTarget:self action:@selector(fbAction:) forControlEvents:UIControlStateHighlighted];
        UIImage *fbbtn = [UIImage imageNamed:@"facebook.png"];
        [fbButton setImage:fbbtn forState:UIControlStateNormal];
        [fbButton setFrame:CGRectMake(410,(22 + _yVal),65,20)];
        fbButton.tag = i;
        
        UIButton *twButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [twButton addTarget:self action:@selector(twAction:) forControlEvents:UIControlStateHighlighted];
        UIImage *twbtn = [UIImage imageNamed:@"twitter.png"];
        [twButton setImage:twbtn forState:UIControlStateNormal];
        [twButton setFrame:CGRectMake(410,(47 + _yVal),65,23)];
        twButton.tag = i;
        
        _yVal = _yVal + 91;//'91' is the difference in height of the background image
        
        
        //Add the contents to the Scroll view
        [[[CCDirector sharedDirector] openGLView] addSubview:_whacksListBackGroundImage];
        
        [gameOverScrollView addSubview:_whacksListBackGroundImage];
        [_whacksListBackGroundImage addSubview:_vcDisplayImage];
        [_whacksListBackGroundImage addSubview:vcNameLabel];
        [_whacksListBackGroundImage addSubview:firmNameLabel];
        [_whacksListBackGroundImage addSubview:vcWhackLabel];
        
        [gameOverScrollView addSubview:fbButton];
        [gameOverScrollView addSubview:twButton];
    }
}

//Method that redirects to apps.kinvey.com to check owning A VC
-(void) vcOwnership:(id)sender
{
    //Check for Internet Connectivity
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertView *myAlert = [[[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please turn on wi-fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [myAlert show];
    }
    else
    {
        _ownAVCButton.enabled = FALSE;
        _vcListButton.enabled = FALSE;
        _playAgainButton.enabled = FALSE;
        
        _webCloseBand.hidden = FALSE;
        _closeButton.hidden = FALSE;
        webView.hidden = FALSE;
        
        [self schedule:@selector(animateWebView:) interval:0.0];
    }
}

//Remove all views from super view before transitioning from current view
-(void) removeAllFromSuperView
{
    [gameOverScrollView removeFromSuperview];
    [gameOverScrollView release];
    
    [_ownAVCButton removeFromSuperview];
    [_vcListButton removeFromSuperview];
    [_playAgainButton removeFromSuperview];
    [questionMarkBackgroundImage removeFromSuperview];
    
    [_whacksListBackGroundImage release];
    [questionMarkBackgroundImage release];
    
    [vcNameLabel release];
    [firmNameLabel release];
    [vcWhackLabel release];
    [scoreLabel removeFromSuperview];
    [scoreLabel release];
    
    scoreCount = 0;
    _animateQuestionMark = 0;
    [self unschedule:@selector(animateQuestionMark:)];
}

//Method to Update whack counts of each VC to local cache
-(void) updateDB
{
    //Retrieve whackcounts of all VC's used in gameplay based on VC ID's from Whacklist table in local cache
    for(int i=0; i<15; i++)
    {
        int _whacksOfVC = 0;
        NSString *sqlw = [[NSString alloc] initWithFormat:@"SELECT whackcount FROM Whacklist where vcid=%@",[_VCIdsLoadedToDisplay objectAtIndex:i]];
        _whacksOfVC = [_dbmanager retrieveRecordsForWhackCount:sqlw];
        _whackCountArray[i] = _whackCountArray[i] + _whacksOfVC;
        [sqlw release];
       
    }
    
    //Update whackcounts of all VC's used in gameplay based on VC ID's to Whacklist table in local cache
    for(int i=0; i<15; i++)
    {
        
        NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE Whacklist SET whackcount = %d WHERE vcid = %@",_whackCountArray[i],[_VCIdsLoadedToDisplay objectAtIndex:i]];
        [_dbmanager updateRecordIntoWhacklistTable:sql];
        [sql release];
    }
    
    //Check for Internet connectivity
    [self checkNetworkConnectivity];
    
    if(_connected == TRUE)
    { 
        //Retrieve the records from Whacklist table to save data to Kinvey
        _dbmanager._vcKinveyIdFromWhacklistArray = [[[NSMutableArray alloc] init] autorelease];
        _dbmanager._vcWhackCountFromWhacklistArray = [[[NSMutableArray alloc] init] autorelease];
        [_dbmanager retrieveRecordsFromWhacklistToSave];
        
        //Call to method to save data to Kinvey
        [self saveWhackCountsToKinvey];
        
        //Reset the array for re-use
        for(int i=0;i<15;i++)
        {
            _whackCountArray[i] = 0;
        }
    }
}

//Method to save whack count data of VC's to Kinvey
-(void) saveWhackCountsToKinvey
{
    for(int i=0; i<[_dbmanager._vcKinveyIdFromWhacklistArray count]; i++)
    {
        _whackDetails = [[KCSWhacks alloc] init];
        //Set the vcID 
        _whackDetails.vcID = [_dbmanager._vcKinveyIdFromWhacklistArray objectAtIndex:i];
        //Set the whackcount of VC 
        _whackDetails.whackCount = [_dbmanager._vcWhackCountFromWhacklistArray objectAtIndex:i];
        //Set the kinvey handle 
        _whackDetails.userID = [NSString stringWithFormat:@"%@",_kinveyUserId];
        
        //Save vcId, whackcount, kinvey handle to whacks collection in Kinvey
        [_whackDetails saveToCollection:_whackDetailsCollection withDelegate:self];
        [_whackDetails release];
    }
}

-(void) checkNetworkConnectivity
{
    //Check for Internet connection and set the flag
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        _connected = FALSE;
    }
    else
    {
        _connected = TRUE;
    }
}

//Functionality to animate Web View. This method is called when Do you own a VC? button is touched
-(void)animateWebView:(ccTime)dt
{
    animationCount = animationCount - 15;
    if(animationCount > 15)
    {
        webView.frame = CGRectMake(0, animationCount, 480, 290);
    }
    else
    {
        [self unschedule:@selector(animateWebView:)];
    }
}

//Method to close web View
-(void) closeAction:(id)sender
{
    _webCloseBand.hidden = TRUE;
    _closeButton.hidden = TRUE;
    webView.hidden = TRUE;
    animationCount = 330;
    webView.frame = CGRectMake(0, 330, 480, 290);
    [self unschedule:@selector(animateWebView:)];
    _ownAVCButton.enabled = TRUE;
    _vcListButton.enabled = TRUE;
    _playAgainButton.enabled = TRUE;
}

//Functionality to transit to VClist. Called when VClist button is touched
-(void) goto_VCsList:(id)sender
{
    //Delete all Records from temporary table
    [_dbmanager deleteRecordsFromTemp];
    [self removeAllFromSuperView];
    [self updateDB];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[VcsScreenLayer scene]]];
}

//Functionality to restart the game. Called when play again button is touched
-(void) restart_Level:(id)sender
{   
    _pressedPlayFromMainMenu = 0;
    //Reset the array to re-use
    for(int i=0;i<15;i++)
    {
        _whackCountArray[i] = 0;
    }
    //Delete all Records from temporary table
    [_dbmanager deleteRecordsFromTemp];
    [self removeAllFromSuperView];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[PlayAreaLayer scene]]];
}

//Functionality to transit to main menu. Called when main menu button is touched
- (void) goto_Main_Menu: (CCMenuItem  *) menuItem 
{
    //Delete all Records from temporary table
    [_dbmanager deleteRecordsFromTemp];
    [self removeAllFromSuperView];
    [self updateDB];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[HelloWorldLayer scene]]];
}

//Method for posting the scores to facebook
-(void) fbAction:(id)sender
{
    _touchCount++;
    tagID = [sender tag];
    
    //Check for Internet connectivity
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertView *myAlert = [[[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please turn on wi-fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [myAlert show];
    }
    else
    {
        if(_once == FALSE)
        {
            if (![facebook isSessionValid]) {
                //Ask the user for permissions to post scores and access user details. Allow the user to accept permissions only once
                NSArray *permissions = [[NSArray alloc] initWithObjects:
                                        @"user_likes", 
                                        @"read_stream",
                                        nil];
                [facebook authorize:permissions];
                [permissions release];
                _once = TRUE;
            }
            else
            {
                _touchCount = 2;
            }
            
        }
        
        //Get the user details using graph API provided by facebook
        [facebook requestWithGraphPath:@"me" andDelegate:self];
        
        NSString *postString;
        if(_whackArrayFromTemp[tagID] == 1)
        {
            //Compose text to post to Facebook
            postString = [[NSString alloc] initWithFormat:@"I just whacked %@ %d time on @WhackAVC",[_dbmanager._vcNamesFromTemp objectAtIndex:tagID], _whackArrayFromTemp[tagID]];
        }
        else
        {
            //Compose text to post to Facebook
            postString = [[NSString alloc] initWithFormat:@"I just whacked %@ %d times on @WhackAVC",[_dbmanager._vcNamesFromTemp objectAtIndex:tagID], _whackArrayFromTemp[tagID]];
        }
        
        //Prompt the dialog to post scores to facebook wall
        NSString* propertiesString = @"  {\"Click here to play \":{\"href\":\"http://itunes.apple.com/in/app/facebook/id284882215?mt=8\",\"text\":\"On iTunes Appstore\"}}";
        
        NSMutableDictionary *params = 
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         postString, @"name",
         @"kinvey.com", @"caption",
         propertiesString, @"properties",
         @"http://fbrell.com/f8.jpg", @"picture",
         nil]; 
        
        if(_touchCount == 2)
        {
            [facebook dialog:@"feed"
                   andParams:params
                 andDelegate:nil];
            _touchCount = 1;
        }
        
        [postString release];
    }
}


//Tweet the scores
-(void) twAction:(id)sender
{
    
    twtagID = [sender tag];
    
    //Check for Internet connectivity
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertView *myAlert = [[[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please turn on wi-fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [myAlert show];
    }
    else
    {
        twit = [[TwitterViewController alloc] init];
        [twit setView:[[CCDirector sharedDirector]openGLView]];
        [twit setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        
        
        
        TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
        //No Twitter handle
        if([[_dbmanager._vcTwHandlesFromTemp objectAtIndex:twtagID] isEqualToString:@""])
        {
            NSString *tweet;
            if(_whackArrayFromTemp[twtagID] == 1)
            {
                //Compose the tweet text if whack count is '1'
                tweet = [NSString stringWithFormat:@"I just whacked %@ %d time on @WhackAVC",[_dbmanager._vcNamesFromTemp objectAtIndex:twtagID], _whackArrayFromTemp[twtagID]];
            }
            else
            {
                //Compose the tweet text
                tweet = [NSString stringWithFormat:@"I just whacked %@ %d times on @WhackAVC",[_dbmanager._vcNamesFromTemp objectAtIndex:twtagID], _whackArrayFromTemp[twtagID]];
            }
            
            [tweetViewController setInitialText:tweet];
        }
        //Twitter handle of VC's present
        else
        {
            NSString *tweet;
            if(_whackArrayFromTemp[twtagID] == 1)
            {
                tweet = [NSString stringWithFormat:@"I just whacked @%@ %d time on @WhackAVC",[_dbmanager._vcTwHandlesFromTemp objectAtIndex:twtagID], _whackArrayFromTemp[twtagID]];
            }
            else
            {
                tweet = [NSString stringWithFormat:@"I just whacked @%@ %d times on @WhackAVC",[_dbmanager._vcTwHandlesFromTemp objectAtIndex:twtagID], _whackArrayFromTemp[twtagID]];
            }
            [tweetViewController setInitialText:tweet];
        }
        
        [twit presentModalViewController:tweetViewController animated:YES];
        [tweetViewController release];
        
        if ([TWTweetComposeViewController canSendTweet]) 
        {
            // Create account store, followed by a Twitter account identifer
            account = [[ACAccountStore alloc] init];
            ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            // Request access from the user to use their Twitter accounts.
            [account requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) 
             {
                 // Did user allow us access?
                 if (granted == YES)
                 {
                     // Populate array with all available Twitter accounts
                     arrayOfAccounts = [account accountsWithAccountType:accountType];
                     [arrayOfAccounts retain];
                     
                     // Populate the tableview
                     if ([arrayOfAccounts count] > 0) 
                         [self performSelectorOnMainThread:@selector(updateTableview) withObject:NULL waitUntilDone:NO];
                 }
             }];
        }
    }
}


-(void)updateTableview
{
    //Get the twitter account and the corresponding user id and username
    ACAccount *twitterAccount = [ arrayOfAccounts objectAtIndex:0];
    NSString *twUserID = [[twitterAccount accountProperties] objectForKey:@"user_id"];
    NSString *twUserName = twitterAccount.username;
    
    //Get the profile image of the user using the twitter API
    NSString *urlPath = [[NSString alloc] initWithFormat:@"https://api.twitter.com/1/users/profile_image?user_id=%@&size=bigger",twUserID];
    NSURL *url = [NSURL URLWithString:urlPath];
    NSData *data = [NSData dataWithContentsOfURL:url];
    [urlPath release];
    
    //Download the profile image to local system
    NSString *twImageName = [[NSString alloc] initWithFormat:@"%@.jpg",twUserID];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:twImageName];
    
    [data writeToFile:savedImagePath atomically:NO];
    
    //Save the profile image to BLOB service in Kinvey backend
    [KCSResourceService saveLocalResource:savedImagePath withDelegate:self];     
    
    //Set the username ,name of profile image of user's twitter account to current user in Kinvey backend
    [[[KCSClient sharedClient] currentUser] setValue:twUserName forAttribute:@"twUserName"];
    
    [[[KCSClient sharedClient] currentUser] setValue:twImageName forAttribute:@"twProfileImage"];
    
    [[[KCSClient sharedClient] currentUser] saveWithDelegate:self];
    
    [twImageName release];
}

/*******************************************************************************************************************/
/*                                     Facebook Delegate Methods                                                   */
/*******************************************************************************************************************/

//This method is notified when the request loads and completes successfully
- (void)request:(FBRequest *)request didLoad:(id)result {

    NSDictionary* hash = result;
    //Get the facebook username
    NSString *fbUserName = (NSString*)[hash valueForKey:@"username"];
    //Get the facebook user email
    NSString *fbEmailId = (NSString*)[hash valueForKey:@"email"];
    //Get the facebook user id
    NSString *fbId = (NSString*)[hash valueForKey:@"id"];
    
    //Validate fbEmailId if the value is nil. Enter the null value to fbEmailId
    if(fbEmailId == nil)
    {
        fbEmailId = @"null";
    }
    
    //Set the username ,name of profile image of user's facebook account to current user in Kinvey backend
    [[[KCSClient sharedClient] currentUser] setValue:fbUserName forAttribute:@"fbUserName"];
    [[[KCSClient sharedClient] currentUser] setValue:fbEmailId forAttribute:@"fbEmailId"];
    
    
    
    if ([request.url isEqualToString:@"https://graph.facebook.com/me"]) 
    {
        
        NSString *jsonStringParams = [request.params JSONRepresentation];
        NSDictionary *userDict = [jsonStringParams JSONValue];
        NSString *accessToken = ((NSString*)[userDict objectForKey:@"access_token"]);
        
        //Get the profile image of the user using the facebook API
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/picture?access_token=%@", accessToken]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        NSString *fbImageName = [[NSString alloc] initWithFormat:@"%@.jpg",fbId];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:fbImageName];
        
        //Download the profile image to local system
        [data writeToFile:savedImagePath atomically:NO];
        
        //Set the facebook profile image of user to current user in Kinvey
        [[[KCSClient sharedClient] currentUser] setValue:fbImageName forAttribute:@"fbProfileImage"];
        //Save the facebook profile image of user to BLOB service kinvey
        [KCSResourceService saveLocalResource:savedImagePath withDelegate:self];
        
        [fbImageName release];
    }
    
    [[[KCSClient sharedClient] currentUser] saveWithDelegate:self];

}

//This method is notified when the request receives response successfully
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"\nRequest received response successfully");
}

//This method is notified when the request fails
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
     NSLog(@"\nRequest failed with error");
}

//This delegate method is called when the user logs in to facebook
- (void)fbDidLogin {
    NSLog(@"\nUser logged in to facebook");
}

//This delegate method is called when the user logs out of facebook
- (void)fbDidLogout {
     NSLog(@"\nUser logged out of facebook");
}

//This delegate method is notified when the session becomes invalidated
- (void)fbSessionInvalidated {
     NSLog(@"\nFacebook session Invalidated");
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt {
     NSLog(@"\nExtend access token");
}

//This delegate method is called when the user cancels login to facebook
- (void)fbDidNotLogin:(BOOL)cancelled {
     NSLog(@"\nUser not logged in to facebook");
}

/*******************************************************************************************************************/
/*                                     Kinvey Delegate Methods                                                   */
/*******************************************************************************************************************/

// KINVEY SPECIFIC NOTE
// This is the delegate method notified when a save completes
- (void)entity:(id<KCSPersistable>)entity operationDidCompleteWithResult:(NSObject *)result{

    NSLog(@"\Entity Operation Save Success");
}

// KINVEY SPECIFIC NOTE
// This is the delegate notified when a save fails
- (void)entity:(id)entity operationDidFailWithError:(NSError *)error{
   NSLog(@"\nEntity Operation Save Failed");
    NSString *className = NSStringFromClass([entity class]); 

    if([className isEqualToString:@"KCSWhacks"])
    {
        [entity saveToCollection:_whackDetailsCollection withDelegate:self];
    }
    if([className isEqualToString:@"KCSUser"])
    {
       [[[KCSClient sharedClient] currentUser] saveWithDelegate:self];
    }
    NSLog(@"%@",[error localizedDescription]);
    NSLog(@"%@",[error localizedFailureReason]);
}


// KINVEY SPECIFIC NOTE
// This is the delegate called when a resource upload to or download from Kinvey successfully completes
-(void)resourceServiceDidCompleteWithResult:(KCSResourceResponse *)result
{
    NSLog(@"\nResource Saved Successfully to Kinvey");
}

// KINVEY SPECIFIC NOTE
// This is the delegate called when a resource upload to or download from Kinvey fails
- (void)resourceServiceDidFailWithError:(NSError *)error
{
    NSLog(@"\nResource Failed to Save to Kinvey");
    NSLog(@"\n%@",[error localizedDescription]);
    NSLog(@"\n%@",[error localizedFailureReason]);
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    
	// don't forget to call "super dealloc"
    
    for(int i=0;i<15;i++)
    {
        _whackCountArray[i] = 0;
    }

    [facebook release];
    
    //Call to a function to close database
    [_dbmanager closeDB];
    [_dbmanager release];
    
	[super dealloc];
}
@end
