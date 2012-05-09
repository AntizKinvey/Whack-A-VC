//
//  TimeUpLayer.m
//  WhackAVC
//
//  Created by Antiz Technologies on 3/9/12.
//  Copyright Antiz Technologies Pvt Ltd 2012. All rights reserved.
//


// Import the interfaces
#import "PhraseScreenLayer.h"
#import "GuessWhatLayer.h"
#import "SimpleAudioEngine.h"

// PhraseScreenLayer implementation
@implementation GuessWhatLayer

@synthesize dbmanager = _dbmanager;

//NSString *_phraseLabels;
ALuint _soundEffectID;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GuessWhatLayer *layer = [GuessWhatLayer node];
	
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
        
        _dbmanager = [[DBManager alloc] init];
		
		//Call to a function to open connection to database
        [_dbmanager openDB];
        
		//Add a background Image to the scene
        CCSprite *backgroundImage = [CCSprite spriteWithFile:@"guesswhat.png" 
                                                        rect:CGRectMake(0, 0, 480, 320)];
        backgroundImage.position = ccp(240, 160);
        
		//Retrieve a phrase randomly from the local cache
        NSString *_retrievePhrase = [[NSString alloc] initWithFormat:@"SELECT phrlabel FROM Phraselist ORDER BY RANDOM() LIMIT 1"];
        [_dbmanager retrieveRandomPhrasesFromDB:_retrievePhrase];
        [_retrievePhrase release];
        
        //Label to display a phrase
        CCLabelTTF *_phraseLabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial Rounded MT BOLD" fontSize:20];
        _phraseLabel.position =  ccp( 240 , 240 );
        _phraseLabel.color = ccc3(0,0,0);
        [_phraseLabel boundingBox];
        [_phraseLabel setString:_dbmanager._topPhrase];
        
		//Add children to scene
        [self addChild:backgroundImage];
        [self addChild:_phraseLabel];
        
		//Enable touches on the screen
        self.isTouchEnabled = YES;
        
        _soundEffectID = [[SimpleAudioEngine sharedEngine] playEffect:@"mysterysound.mp3"];
        
        [self schedule:@selector(countDown:) interval:4.0];
	}
	return self;
}

//Count down to display the scene for 4 seconds
-(void) countDown:(ccTime)dt
{
    [self unschedule:@selector(countDown:)];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[PhraseScreenLayer scene]]];
}

//Method to detect touches on screen
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    [self unschedule:@selector(countDown:)];
    [[SimpleAudioEngine sharedEngine] stopEffect:_soundEffectID];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[PhraseScreenLayer scene]]];
    
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    _dbmanager._topPhrase = nil;
    [_dbmanager._topPhrase release];
    
	[super dealloc];
}
@end
