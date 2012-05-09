//
//  AboutKinveyLayer.m
//  WhackAVC
//
//  
//  Copyright Antiz Technologies Pvt Ltd 2012. All rights reserved.
//


// Import the interfaces
#import "AboutKinveyLayer.h"
#import "HelloWorldLayer.h"
#import "Reachability.h"

// AboutKinveyLayer implementation
@implementation AboutKinveyLayer

UIWebView *webView;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	AboutKinveyLayer *layer = [AboutKinveyLayer node];
	
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
                
                NSString *urlAddress=@"http://apps.kinvey.com";
                NSURL *url = [NSURL URLWithString:urlAddress];
                NSURLRequest *reqObject=[NSURLRequest requestWithURL:url];
                webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 480, 285)];
                NSLog(@"%@",reqObject);
                [webView loadRequest:reqObject];   
        }
        
        CCMenuItem *mainmenuItem = [CCMenuItemImage itemFromNormalImage:@"transparent.png"
                                                       selectedImage: @"transparent.png"
                                                              target:self
                                                            selector:@selector(goto_Main_Menu:)];
        
        
        // Create a menu and add your menu items to it
        CCMenu *myMenus = [CCMenu menuWithItems:mainmenuItem, nil];

        [mainmenuItem setPosition:ccp(155,-150)];
                
        CCSprite *mainmenubtn = [CCSprite spriteWithFile:@"mainmenubutton.png" 
                                                    rect:CGRectMake(0, 0, 480, 50)];
        mainmenubtn.position = ccp(240, 10);
        
        //Add children to scene
        [self addChild:myMenus z:5];
        [self addChild:mainmenubtn z:2];
        
        
        
	}
	return self;
}


-(void) onEnterTransitionDidFinish {
	//Don't show web view until transition completes
	[[[CCDirector sharedDirector] openGLView] addSubview:webView];
}

//Functionality to transit to Main menu
- (void) goto_Main_Menu: (CCMenuItem  *) menuItem 
{
    [webView removeFromSuperview];
    [webView release];
    
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[HelloWorldLayer scene]]];
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
