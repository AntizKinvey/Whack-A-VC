//
//  TimeUpLayer.m
//  WhackAVC
//
//  Created by Antiz Technologies on 3/9/12.
//  Copyright Antiz Technologies Pvt Ltd 2012. All rights reserved.
//


// Import the interfaces
#import "PhraseScreenLayer.h"
#import "GameOverLayer.h"
#import "LabelOutlineLayer.h"
#import "SimpleAudioEngine.h"

// PhraseScreenLayer implementation
@implementation PhraseScreenLayer

extern int scoreCount;//Global variable for score
ALuint _soundEffectID;//Sound Effect ID

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PhraseScreenLayer *layer = [PhraseScreenLayer node];
	
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
        
		//Add a background Image to the scene
        CCSprite *backgroundImage = [CCSprite spriteWithFile:@"whackcountimage.png" 
                                                        rect:CGRectMake(0, 0, 480, 320)];
        backgroundImage.position = ccp(240, 160);
        
        
		//Add image 's' and '!' to the scene 
        CCSprite *pluralImage = [CCSprite spriteWithFile:@"plural.png" 
                                                        rect:CGRectMake(0, 0, 15, 21)];
        pluralImage.position = ccp(323, 92);
        pluralImage.visible = NO;
        
        CCSprite *exclaimImage = [CCSprite spriteWithFile:@"exclamatory.png" 
                                                    rect:CGRectMake(0, 0, 8, 21)];
        exclaimImage.position = ccp(335, 92);
        exclaimImage.visible = NO;
        
        if(scoreCount == 0)
        {
            _soundEffectID = [[SimpleAudioEngine sharedEngine] playEffect:@"sadsound.mp3"];
        }
        else
        {
            _soundEffectID = [[SimpleAudioEngine sharedEngine] playEffect:@"happysound.mp3"];
        }
        
        if(scoreCount != 1)
        {
            pluralImage.visible = YES;
            exclaimImage.visible = YES;
        }
        else
        {
            exclaimImage.position = ccp(323, 92);
            exclaimImage.visible = YES;
        }
        
		//Label to display number of VC's whacked
        CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",scoreCount]  fontName:@"Lithograph" fontSize:40];
        scoreLabel.position =  ccp( 254 , 92 );
        scoreLabel.color = ccc3(255, 202, 62);
        CCRenderTexture* stroke = [LabelOutlineLayer createStroke:scoreLabel  size:3  color:ccBLACK];
        [scoreLabel boundingBoxInPixels];
        
		//Add children to the scene
        [self addChild:backgroundImage];
        [self addChild:pluralImage];
        [self addChild:exclaimImage];
        [self addChild:stroke];
        [self addChild:scoreLabel];
        
		//Enable touches on the screen
        self.isTouchEnabled = YES;
        
        [self schedule:@selector(countDown:) interval:3.0];
	}
	return self;
}

//Count down to display the scene for 3 seconds
-(void) countDown:(ccTime)dt
{
    [self unschedule:@selector(countDown:)];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[GameOverLayer scene]]];
}

//Method to detect touches on screen
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    [[CCDirector sharedDirector] convertToGL:location];
    
    [self unschedule:@selector(countDown:)];
    [[SimpleAudioEngine sharedEngine] stopEffect:_soundEffectID];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[GameOverLayer scene]]];
    
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
