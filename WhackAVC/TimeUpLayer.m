//
//  TimeUpLayer.m
//  WhackAVC
//
//  Created by Ram Charan on 3/9/12.
//  Copyright Antiz Technologies Pvt Ltd 2012. All rights reserved.
//


// Import the interfaces
#import "TimeUpLayer.h"
#import "GuessWhatLayer.h"
#import "SimpleAudioEngine.h"

// TimeUpLayer implementation
@implementation TimeUpLayer

CCSprite *_showScreen;

extern BOOL _showTimeUpScreen;

extern int lives;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TimeUpLayer *layer = [TimeUpLayer node];
	
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
		
		//Stop the background music
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        
		//If _showTimeUpScreen flag is set to TRUE in PlayAreaLayer then the controls flows to if block otherwise else
        if((_showTimeUpScreen == TRUE) && (lives!=-1))
		{
            _showScreen = [CCSprite spriteWithFile:@"timesUpscreen.png" 
                                         rect:CGRectMake(0, 0, 480, 320)];
            _showScreen.position = ccp(240, 160);
        }
        else
        {
            _showScreen = [CCSprite spriteWithFile:@"gameoverbg.png" 
                                         rect:CGRectMake(0, 0, 480, 320)];
            _showScreen.position = ccp(240, 160);
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"loser.mp3"];
        }
        
        self.isTouchEnabled = YES;
        
        [self addChild: _showScreen];
        
        [self schedule:@selector(countDown:) interval:3.0];
	}
	return self;
}

//Count down to display the scene for 3 seconds
-(void) countDown:(ccTime)dt
{
    [self unschedule:@selector(countDown:)];
    _showTimeUpScreen = FALSE;
    lives = 2;
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[GuessWhatLayer scene]]];
}

//Method to detect touches on screen
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    [self unschedule:@selector(countDown:)];
    _showTimeUpScreen = FALSE;
    lives = 2;
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[GuessWhatLayer scene]]];
    
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
