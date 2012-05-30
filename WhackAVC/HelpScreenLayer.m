//
//  HelpScreenLayer.m
//  WhackAVC
//
//  
//  Copyright Antiz Technologies Pvt Ltd 2012. All rights reserved.
//


// Import the interfaces
#import "HelpScreenLayer.h"
#import "HelloWorldLayer.h"
#import "AboutKinveyLayer.h"
#import "Reachability.h"

// HelpScreenLayer implementation
@implementation HelpScreenLayer

UIButton *backButton;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelpScreenLayer *layer = [HelpScreenLayer node];
	
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
        
        
        CCSprite *helpscreen = [CCSprite spriteWithFile:@"helpscreen.png" 
                                                     rect:CGRectMake(0, 0, 480, 320)];
        helpscreen.position = ccp(240, 160);
        
        
        CCMenuItem *mainmenuItem = [CCMenuItemImage itemFromNormalImage:@"aboutkinvey.png"
                                                          selectedImage: @"aboutkinvey.png"
                                                                 target:self
                                                               selector:@selector(goto_Kinvey_Site:)];
        
        [mainmenuItem setPosition:ccp(160,130)];
        
        // Create a menu and add your menu items to it
        CCMenu *myMenus = [CCMenu menuWithItems:mainmenuItem, nil];
        
        
        //Add children to the scene
        [self addChild:myMenus z:5];
        [self addChild:helpscreen];
	}
	return self;
}

//Functionality that displays the screen after the fading completes
-(void) onEnterTransitionDidFinish
{
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(goto_Main_Menu:) forControlEvents:UIControlEventTouchDown];
    UIImage *backbtn = [UIImage imageNamed:@"backbtn.png"];
    [backButton setImage:backbtn forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(10,7,147,51)];
    
    //Add the button to openGL view
    [[[CCDirector sharedDirector] openGLView] addSubview:backButton];
}

//Functionality to transit to main menu
-(void) goto_Main_Menu:(id)sender
{
    [backButton removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[HelloWorldLayer scene]]];
}

//Functionality to transit About kinvey layer
- (void) goto_Kinvey_Site: (CCMenuItem  *) menuItem 
{
    //Check for the availability of Internet
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertView *myAlert = [[[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please turn on wi-fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [myAlert show];
    }
    else
    {
        [backButton removeFromSuperview];
        [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[AboutKinveyLayer scene]]];
    }
}



// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
