//
//  VcsScreenLayer.m
//  WhackAVC
//
//  
//  Copyright Antiz Technologies Pvt Ltd 2012. All rights reserved.
//


// Import the interfaces
#import "VcsScreenLayer.h"
#import "HelloWorldLayer.h"
#import "Reachability.h"

#import "AppDelegate.h"

// VcsScreenLayer implementation
@implementation VcsScreenLayer

@synthesize _dbmanager;

@synthesize facebook;

@synthesize twit;

@synthesize account;

//ScrollView for All VC's and My VC's
UIScrollView *scrollViewMyVcs;
UIScrollView *scrollViewAllVcs;

//Background image for each row in list
UIImageView *_whackListBackGroundImage;
UIImage *_vcsBackGroundImage;
//VC Images to display
UIImage *_vcsImage;
UIImageView *_vcsDisplayImage;

//Label for VC firm name, VC name and VC whack count
UILabel *_firmNameLabel;
UILabel *_vcNameLabel;
UILabel *_vcWhackLabel;

//Buttons for sharing to Facebook and Twitter
UIButton *fbButton_myVCs;
UIButton *twButton_myVCs;
UIButton *fbButton_allVCs;
UIButton *twButton_allVCs;

//Button for displaying My VC's and All VC's
UIButton *myVcsButton;

CCSprite *_VCsTitleBar;

BOOL allVcsGlobal = TRUE;

int _totalRowsInMyVCs = 0;
int _totalRowsInAllVCs = 0;

UILabel *_alertLabel;

int _myVcsfbTagId = -1;
int _allVcsfbTagId = -1;

int _myVCstwTagId = -1;
int _allVCstwTagId = -1;

int _clickedtw = 0;

BOOL _once = FALSE;

int _touchCount = 0;

extern NSMutableArray *arrayOfAccounts;


int _noOfElementsInMyVCs = 0;
int _noOfElementsInAllVCs = 0;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	VcsScreenLayer *layer = [VcsScreenLayer node];
	
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
        
        _dbmanager = [[DBManager alloc] init];
        
        //Call to function to open connection to database
        [_dbmanager openDB];
        
        //Arrays that hold VC profile images, firm names, whack count, names and twitter handles of VC's whacked by user
        _dbmanager._myVCSnapsFromDB = [[NSMutableArray alloc] init];
        _dbmanager._myVCFirmsFromDB = [[NSMutableArray alloc] init];
        _dbmanager._myVCWhackCountFromDB = [[NSMutableArray alloc] init];
        _dbmanager._myVCNamesFromDB = [[NSMutableArray alloc] init];
        _dbmanager._myVCTwitterHandleFromDB = [[NSMutableArray alloc] init];
        
        //Arrays that hold VC profile images, firm names, whack count, names and twitter handles of all VC's
        _dbmanager._allVCSnapsFromDB = [[NSMutableArray alloc] init];
        _dbmanager._allVCFirmsFromDB = [[NSMutableArray alloc] init];
        _dbmanager._allVCWhackCountFromDB = [[NSMutableArray alloc] init];
        _dbmanager._allVCNamesFromDB = [[NSMutableArray alloc] init];
        _dbmanager._allVCTwitterHandleFromDB = [[NSMutableArray alloc] init];
        
        //Sql query to retrieve My VC's 
        NSString *myVClist = [[NSString alloc] initWithString:@"SELECT v.vcsnaps,v.vcfirm,w.whackcount,v.vcname,v.vctwhandle FROM VClist v JOIN Whacklist w WHERE w.vcid = v.vcid and w.whackcount > 0 ORDER BY v.vcname"];
        
        //Sql query to retrieve All VC's
        NSString *allVClist = [[NSString alloc] initWithString:@"SELECT v.vcsnaps,v.vcfirm,w.whackcount,v.vcname,v.vctwhandle FROM VClist v JOIN Whacklist w WHERE w.vcid = v.vcid ORDER BY v.vcname"];
        
        //Retrieve records and number of rows from Whacklist table for My VC's
        _totalRowsInMyVCs =[_dbmanager retrieveRecordsFromWhacklistTableForMyVCs:myVClist];
        
        //Retrieve records and number of rows from Whacklist table for All VC's
        _totalRowsInAllVCs =[_dbmanager retrieveRecordsFromWhacklistTableForAllVCs:allVClist];
        
        
        
        
        //Determine number of elements in All VC's
        _noOfElementsInAllVCs = [_dbmanager._allVCWhackCountFromDB count];
        
        //Declare an array that holds whackCount of All VC's
        int _whackCountArrayInAllVCs[_noOfElementsInAllVCs];
        
        for(int i=0; i<[_dbmanager._allVCWhackCountFromDB count]; i++)
        {
            _whackCountArrayInAllVCs[i] = 0;
        }
        
        //Convert String to Integer Value of Whacks for All VC's
        for(int i=0; i<[_dbmanager._allVCWhackCountFromDB count]; i++)
        {
            NSString *_allVCWhacks = [[NSString alloc] initWithString:[_dbmanager._allVCWhackCountFromDB objectAtIndex:i]];
            _whackCountArrayInAllVCs[i] = [_allVCWhacks intValue];
            [_allVCWhacks release];
        }
        
        
        //SORT for All VC's
        for(int i=0; i<_noOfElementsInAllVCs; i++)
        {
            for(int j=0; j<(_noOfElementsInAllVCs-1)-i; j++)
            {
                if(_whackCountArrayInAllVCs[j] < _whackCountArrayInAllVCs[j+1])
                {
                    //Swap the elements of array
                    int temp = _whackCountArrayInAllVCs[j];
                    _whackCountArrayInAllVCs[j] = _whackCountArrayInAllVCs[j+1];
                    _whackCountArrayInAllVCs[j+1] = temp;
                    

                    [_dbmanager._allVCSnapsFromDB exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                    [_dbmanager._allVCFirmsFromDB exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                    [_dbmanager._allVCWhackCountFromDB exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                    [_dbmanager._allVCNamesFromDB exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                    [_dbmanager._allVCTwitterHandleFromDB exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                    
                }
            }
        }
        
        
        //Determine number of elements in My VC's
        _noOfElementsInMyVCs = [_dbmanager._myVCWhackCountFromDB count];
        
        //Declare an array that holds whackCount of My VC's
        int _whackCountArrayInMyVCs[_noOfElementsInMyVCs];
        
        //Convert String to Integer Value of Whacks for My VC's
        for(int i=0; i<[_dbmanager._myVCWhackCountFromDB count]; i++)
        {
            NSString *_myVCWhacks = [[NSString alloc] initWithString:[_dbmanager._myVCWhackCountFromDB objectAtIndex:i]];
            _whackCountArrayInMyVCs[i] = [_myVCWhacks integerValue];
            [_myVCWhacks release];
        }
        
        //SORT for My VC's
        for(int i=0; i<_noOfElementsInMyVCs; i++)
        {
            for(int j=0; j<(_noOfElementsInMyVCs-1)-i; j++)
            {
                if(_whackCountArrayInMyVCs[j] < _whackCountArrayInMyVCs[j+1])
                {
                    //Swap the elements of array
                    int temp = _whackCountArrayInMyVCs[j];
                    _whackCountArrayInMyVCs[j] = _whackCountArrayInMyVCs[j+1];
                    _whackCountArrayInMyVCs[j+1] = temp;
                    
                    [_dbmanager._myVCSnapsFromDB exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                    [_dbmanager._myVCFirmsFromDB exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                    [_dbmanager._myVCWhackCountFromDB exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                    [_dbmanager._myVCNamesFromDB exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                    [_dbmanager._myVCTwitterHandleFromDB exchangeObjectAtIndex:(j+1) withObjectAtIndex:j];
                    
                }
            }
        }
        
        [myVClist release];
        [allVClist release];
        
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
        
        //Add background for the scene
        CCSprite *backgroundImage = [CCSprite spriteWithFile:@"vcs_screen.png" 
                                                        rect:CGRectMake(0, 0, 480, 320)];
        backgroundImage.position = ccp(240, 160);
        
        //Add title bar to scene
        _VCsTitleBar = [CCSprite spriteWithFile:@"allvcstitlebar.png" 
                                           rect:CGRectMake(0, 0, 480, 76)];
        
        _VCsTitleBar.position = ccp(240,282);
        
		
        CCSprite *buttonImage = [CCSprite spriteWithFile:@"button.png" 
                                                    rect:CGRectMake(0, 0, 135, 31)];
        buttonImage.position = ccp(75, 14);
		
        //Scroll View for All VC's
		scrollViewAllVcs = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 55, 480, 232)];
        [scrollViewAllVcs setScrollEnabled:YES];
        [scrollViewAllVcs setContentSize:CGSizeMake(480, (91*_totalRowsInAllVCs))];
		
        //Scroll View for My VC's
		scrollViewMyVcs = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 55, 480, 232)];
        [scrollViewMyVcs setScrollEnabled:YES];
        [scrollViewMyVcs setContentSize:CGSizeMake(480, (91*_totalRowsInMyVCs))];
		
        
		
		
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
        [self addChild:_VCsTitleBar];
        [self addChild:myMenus z:5];
        [self addChild:mainmenubtn z:2];
        [self addChild:buttonImage z:5];  
        
	}
	return self;
}


//Functionality to display the scene after fading completes
-(void) onEnterTransitionDidFinish {
	
	int _yValInMyVCs = 0;//Variable that hold values to add share buttons to My VC's scrollView
    int _yValInAllVCs = 0;//Variable that hold values to add share buttons to All VC's scrollView
    
    //Add button for displaying My VC's and All VC's
    myVcsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myVcsButton addTarget:self action:@selector(showAllVcs:) forControlEvents:UIControlEventTouchDown];
    [myVcsButton setTitle:@"My VC's" forState:UIControlStateNormal];
    [myVcsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [myVcsButton setFrame:CGRectMake(16,297,119,23)];
    [[[CCDirector sharedDirector] openGLView] addSubview:myVcsButton];
    
    //Add My VC's Scroll View to scene
	[[[CCDirector sharedDirector] openGLView] addSubview:scrollViewMyVcs];
	
    //If number of rows in My VC's is '0' then display the alert label
    if(_totalRowsInMyVCs == 0)
    {
        _alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 130, 200, 30)];
        _alertLabel.text = @"No VCs present";
        [_alertLabel setTextAlignment:UITextAlignmentCenter];
        _alertLabel.backgroundColor = [UIColor clearColor];
        _alertLabel.hidden = YES;
        [[[CCDirector sharedDirector] openGLView] addSubview:_alertLabel];
    }
    
    //Add the rows to scroll view in My VC's
	for(int i=0; i<_totalRowsInMyVCs; i++)
    {
        //Background for each row in My VC's
		_vcsBackGroundImage = [UIImage imageNamed:@"whackedvc.png"];
        _whackListBackGroundImage = [[UIImageView alloc] initWithImage:_vcsBackGroundImage];
        _whackListBackGroundImage.frame = CGRectMake(0, (i*91), 480, 91);
		
        //Image View to display VC profile images
        _vcsImage = [UIImage imageWithContentsOfFile:[_dbmanager._myVCSnapsFromDB objectAtIndex:i]];
        _vcsDisplayImage = [[UIImageView alloc] initWithImage:_vcsImage];
        _vcsDisplayImage.frame = CGRectMake(12, 6, 89, 80);
		
        //Label to display names of VC's
        _vcNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 15, 200, 30)];
        _vcNameLabel.text = [_dbmanager._myVCNamesFromDB objectAtIndex:i];
        [_vcNameLabel setTextAlignment:UITextAlignmentLeft];
        _vcNameLabel.backgroundColor = [UIColor clearColor];
        
        //Label to display firm names of VC's
		_firmNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 35, 220, 30)];
        _firmNameLabel.text = [_dbmanager._myVCFirmsFromDB objectAtIndex:i];
        [_firmNameLabel setTextAlignment:UITextAlignmentLeft];
        _firmNameLabel.backgroundColor = [UIColor clearColor];
		
        //Label to display VC whack Counts
		_vcWhackLabel = [[UILabel alloc] initWithFrame:CGRectMake(360, 37, 20, 20)];
        _vcWhackLabel.text = [_dbmanager._myVCWhackCountFromDB objectAtIndex:i];
        [_vcWhackLabel setTextAlignment:UITextAlignmentCenter];
        _vcWhackLabel.backgroundColor = [UIColor clearColor];
        
        //Facebook and Twitter buttons that are added to scroll view
        
        fbButton_myVCs = [UIButton buttonWithType:UIButtonTypeCustom];
        [fbButton_myVCs addTarget:self action:@selector(fbActionMyVCs:) forControlEvents:UIControlEventTouchDown];
        UIImage *fbbtn = [UIImage imageNamed:@"facebook.png"];
        [fbButton_myVCs setImage:fbbtn forState:UIControlStateNormal];
        [fbButton_myVCs setFrame:CGRectMake(410,(22 + _yValInMyVCs),65,20)];
        fbButton_myVCs.tag = i;
        
        
        
        twButton_myVCs = [UIButton buttonWithType:UIButtonTypeCustom];
        [twButton_myVCs addTarget:self action:@selector(twActionMyVCs:) forControlEvents:UIControlEventTouchDown];
        UIImage *twbtn = [UIImage imageNamed:@"twitter.png"];
        [twButton_myVCs setImage:twbtn forState:UIControlStateNormal];
        [twButton_myVCs setFrame:CGRectMake(410,(47 + _yValInMyVCs),65,23)];
        twButton_myVCs.tag = i;
        
        _yValInMyVCs = _yValInMyVCs + 91;//'91' is the difference in height of the background image
        
		//Add the contents to the My VC's scroll view
		[[[CCDirector sharedDirector] openGLView] addSubview:_whackListBackGroundImage];
        [scrollViewMyVcs addSubview:_whackListBackGroundImage];
		[_whackListBackGroundImage addSubview:_vcsDisplayImage];
		[_whackListBackGroundImage addSubview:_firmNameLabel];
        [_whackListBackGroundImage addSubview:_vcNameLabel];
		[_whackListBackGroundImage addSubview:_vcWhackLabel];
        [scrollViewMyVcs addSubview:fbButton_myVCs];
        [scrollViewMyVcs addSubview:twButton_myVCs];
        
	}
	scrollViewMyVcs.hidden = YES;
    
    //Add All VC's Scroll View to scene
    [[[CCDirector sharedDirector] openGLView] addSubview:scrollViewAllVcs];
	
    //Add the rows to scroll view in All VC's
	for(int i=0; i<_totalRowsInAllVCs; i++)
    {
        //Background for each row in All VC's
		_vcsBackGroundImage = [UIImage imageNamed:@"whackedvc.png"];
        _whackListBackGroundImage = [[UIImageView alloc] initWithImage:_vcsBackGroundImage];
        _whackListBackGroundImage.frame = CGRectMake(0, (i*91), 480, 91);
		
        //Image View to display VC profile images
		_vcsImage = [UIImage imageWithContentsOfFile:[_dbmanager._allVCSnapsFromDB objectAtIndex:i]];
        _vcsDisplayImage = [[UIImageView alloc] initWithImage:_vcsImage];
        _vcsDisplayImage.frame = CGRectMake(12, 6, 89, 80);
		
        //Label to display names of VC's
        _vcNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 15, 200, 30)];
        _vcNameLabel.text = [_dbmanager._allVCNamesFromDB objectAtIndex:i];
        [_vcNameLabel setTextAlignment:UITextAlignmentLeft];
        _vcNameLabel.backgroundColor = [UIColor clearColor];
        
        //Label to display firm names of VC's
		_firmNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 35, 220, 30)];
        _firmNameLabel.text = [_dbmanager._allVCFirmsFromDB objectAtIndex:i];
        [_firmNameLabel setTextAlignment:UITextAlignmentLeft];
        _firmNameLabel.backgroundColor = [UIColor clearColor];
		
        //Label to display VC whack Counts
		_vcWhackLabel = [[UILabel alloc] initWithFrame:CGRectMake(360, 37, 20, 20)];
        _vcWhackLabel.text = [_dbmanager._allVCWhackCountFromDB objectAtIndex:i];
        [_vcWhackLabel setTextAlignment:UITextAlignmentCenter];
        _vcWhackLabel.backgroundColor = [UIColor clearColor];
        
        //Facebook and Twitter buttons that are added to scroll view
        
        fbButton_allVCs = [UIButton buttonWithType:UIButtonTypeCustom];
        [fbButton_allVCs addTarget:self action:@selector(fbActionAllVCs:) forControlEvents:UIControlEventTouchDown];
        UIImage *fbbtn = [UIImage imageNamed:@"facebook.png"];
        [fbButton_allVCs setImage:fbbtn forState:UIControlStateNormal];
        [fbButton_allVCs setFrame:CGRectMake(410,(22 + _yValInAllVCs),65,20)];
        fbButton_allVCs.tag = i;
        
        twButton_allVCs = [UIButton buttonWithType:UIButtonTypeCustom];
        [twButton_allVCs addTarget:self action:@selector(twActionAllVCs:) forControlEvents:UIControlEventTouchDown];
        UIImage *twbtn = [UIImage imageNamed:@"twitter.png"];
        [twButton_allVCs setImage:twbtn forState:UIControlStateNormal];
        [twButton_allVCs setFrame:CGRectMake(410,(47 + _yValInAllVCs),65,23)];
        twButton_allVCs.tag = i;
        
        _yValInAllVCs = _yValInAllVCs + 91;//'91' is the difference in height of the background image
		
        //Add the contents to the All VC's scroll view
		[[[CCDirector sharedDirector] openGLView] addSubview:_whackListBackGroundImage];
        [scrollViewAllVcs addSubview:_whackListBackGroundImage];
		[_whackListBackGroundImage addSubview:_vcsDisplayImage];
        [_whackListBackGroundImage addSubview:_vcNameLabel];
		[_whackListBackGroundImage addSubview:_firmNameLabel];
		[_whackListBackGroundImage addSubview:_vcWhackLabel];
        [scrollViewAllVcs addSubview:fbButton_allVCs];
        [scrollViewAllVcs addSubview:twButton_allVCs];
	}
}


//Method for posting the scores to facebook in My VC's
-(void) fbActionMyVCs:(id)sender
{
    _touchCount++;
    _myVcsfbTagId = [sender tag];
    
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
            //Ask the user for permissions to post scores and access user details. Allow the user to accept permissions only once
            if (![facebook isSessionValid]) {
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
        if([[_dbmanager._myVCWhackCountFromDB objectAtIndex:_myVcsfbTagId] isEqualToString:@"1"])
        {
            //Compose text to post to Facebook
            postString = [[NSString alloc] initWithFormat:@"I just whacked %@ %@ time on @WhackAVC",[_dbmanager._myVCNamesFromDB objectAtIndex:_myVcsfbTagId], [_dbmanager._myVCWhackCountFromDB objectAtIndex:_myVcsfbTagId]];
        }
        else
        {
            //Compose text to post to Facebook
            postString = [[NSString alloc] initWithFormat:@"I just whacked %@ %@ times on @WhackAVC",[_dbmanager._myVCNamesFromDB objectAtIndex:_myVcsfbTagId], [_dbmanager._myVCWhackCountFromDB objectAtIndex:_myVcsfbTagId]];
        }
        
        //Prompt the dialog to post scores to facebook wall
        NSString* propertiesString = @"{\"Click here to play \":{\"href\":\"http://itunes.apple.com/in/app/facebook/id284882215?mt=8\",\"text\":\"On iTunes Appstore\"}}";
        
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

//Method for posting the scores to facebook in All VC's
-(void) fbActionAllVCs:(id)sender
{
    _touchCount++;
    _allVcsfbTagId = [sender tag];
    
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
            //Ask the user for permissions to post scores and access user details. Allow the user to accept permissions only once
            if (![facebook isSessionValid]) {
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
        if([[_dbmanager._allVCWhackCountFromDB objectAtIndex:_allVcsfbTagId] isEqualToString:@"1"])
        {
            //Compose text to post to Facebook
            postString = [[NSString alloc] initWithFormat:@"I just whacked %@ %@ time on @WhackAVC",[_dbmanager._allVCNamesFromDB objectAtIndex:_allVcsfbTagId], [_dbmanager._allVCWhackCountFromDB objectAtIndex:_allVcsfbTagId]];
        }
        else
        {
            //Compose text to post to Facebook
            postString = [[NSString alloc] initWithFormat:@"I just whacked %@ %@ times on @WhackAVC",[_dbmanager._allVCNamesFromDB objectAtIndex:_allVcsfbTagId], [_dbmanager._allVCWhackCountFromDB objectAtIndex:_allVcsfbTagId]];
        }
        
        //Prompt the dialog to post scores to facebook wall
        NSString* propertiesString = @"{\"Click here to play \":{\"href\":\"http://itunes.apple.com/in/app/facebook/id284882215?mt=8\",\"text\":\"On iTunes Appstore\"}}";
        
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

//Method for posting the scores to Twitter in My VC's
-(void) twActionMyVCs:(id)sender
{  
    _myVCstwTagId = [sender tag];
    
    _clickedtw = 1;//Set the variable to enter the block to tweet inside the method postToTwitter
    
    [self postToTwitter];
}

//Tweet the scores
-(void) postToTwitter
{
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
        if(_clickedtw == 1)
        {
            //No Twitter handle
            if([[_dbmanager._myVCTwitterHandleFromDB objectAtIndex:_myVCstwTagId] isEqualToString:@""])
            {
                NSString *tweet;
                if([[_dbmanager._myVCWhackCountFromDB objectAtIndex:_myVCstwTagId] isEqualToString:@"1"])
                {
                    //Compose the tweet text if whack count is '1'
                    tweet = [NSString stringWithFormat:@"I just whacked %@ %@ time on @WhackAVC",[_dbmanager._myVCNamesFromDB objectAtIndex:_myVCstwTagId], [_dbmanager._myVCWhackCountFromDB objectAtIndex:_myVCstwTagId]];
                }
                else
                {
                    //Compose the tweet text
                    tweet = [NSString stringWithFormat:@"I just whacked %@ %@ times on @WhackAVC",[_dbmanager._myVCNamesFromDB objectAtIndex:_myVCstwTagId], [_dbmanager._myVCWhackCountFromDB objectAtIndex:_myVCstwTagId]];
                }
                
                [tweetViewController setInitialText:tweet];
            }
            //Twitter handle of VC's present
            else
            {
                NSString *tweet;
                if([[_dbmanager._myVCWhackCountFromDB objectAtIndex:_myVCstwTagId] isEqualToString:@"1"])
                {
                    //Compose the tweet text if whack count is '1'
                    tweet = [NSString stringWithFormat:@"I just whacked @%@ %@ time on @WhackAVC",[_dbmanager._myVCTwitterHandleFromDB objectAtIndex:_myVCstwTagId], [_dbmanager._myVCWhackCountFromDB objectAtIndex:_myVCstwTagId]];
                }
                else
                {
                    //Compose the tweet text
                    tweet = [NSString stringWithFormat:@"I just whacked @%@ %@ times on @WhackAVC",[_dbmanager._myVCTwitterHandleFromDB objectAtIndex:_myVCstwTagId], [_dbmanager._myVCWhackCountFromDB objectAtIndex:_myVCstwTagId]];
                }
                [tweetViewController setInitialText:tweet];
            }
            
        }
        
        if(_clickedtw == 2)
        {
            //No Twitter handle
            if([[_dbmanager._allVCTwitterHandleFromDB objectAtIndex:_allVCstwTagId] isEqualToString:@""])
            {
                NSString *tweet;
                if([[_dbmanager._allVCWhackCountFromDB objectAtIndex:_allVCstwTagId] isEqualToString:@"1"])
                {
                    //Compose the tweet text if whack count is '1'
                    tweet = [NSString stringWithFormat:@"I just whacked %@ %@ time on @WhackAVC",[_dbmanager._allVCNamesFromDB objectAtIndex:_allVCstwTagId], [_dbmanager._allVCWhackCountFromDB objectAtIndex:_allVCstwTagId]];
                }
                else
                {
                    //Compose the tweet text
                    tweet = [NSString stringWithFormat:@"I just whacked %@ %@ times on @WhackAVC",[_dbmanager._allVCNamesFromDB objectAtIndex:_allVCstwTagId], [_dbmanager._allVCWhackCountFromDB objectAtIndex:_allVCstwTagId]];
                }
                [tweetViewController setInitialText:tweet];
            }
            //Twitter handle of VC's present
            else
            {
                NSString *tweet;
                if([[_dbmanager._allVCWhackCountFromDB objectAtIndex:_allVCstwTagId] isEqualToString:@"1"])
                {
                    //Compose the tweet text if whack count is '1'
                    tweet = [NSString stringWithFormat:@"I just whacked @%@ %@ time on @WhackAVC",[_dbmanager._allVCTwitterHandleFromDB objectAtIndex:_allVCstwTagId], [_dbmanager._allVCWhackCountFromDB objectAtIndex:_allVCstwTagId]];
                }
                else
                {
                    //Compose the tweet text
                    tweet = [NSString stringWithFormat:@"I just whacked @%@ %@ times on @WhackAVC",[_dbmanager._allVCTwitterHandleFromDB objectAtIndex:_allVCstwTagId], [_dbmanager._allVCWhackCountFromDB objectAtIndex:_allVCstwTagId]];
                }
                [tweetViewController setInitialText:tweet];
            }
            
        }
        
        [twit presentModalViewController:tweetViewController animated:YES];
        
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


//Method for posting the scores to Twitter in All VC's
-(void) twActionAllVCs:(id)sender
{
    _allVCstwTagId = [sender tag];
    
    _clickedtw = 2;//Set the variable to enter the block to tweet inside the method postToTwitter
    
    [self postToTwitter];
}

//Get the top twitter account configured from the settings table view
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
    
}

//Functionality to show all VC's and My VC's
-(void) showAllVcs:(id)sender
{
    if(allVcsGlobal == FALSE)
    {
        [myVcsButton setTitle:@"My VC's" forState:UIControlStateNormal];
        [_VCsTitleBar setTexture:[[CCTextureCache sharedTextureCache] addImage:@"allvcstitlebar.png"]];
        scrollViewMyVcs.hidden = YES;
        scrollViewAllVcs.hidden = NO;
        if(_totalRowsInMyVCs == 0)
        {
            _alertLabel.hidden = YES;
        }
        allVcsGlobal=TRUE;
    }
    else
    {
        [myVcsButton setTitle:@"All VC's" forState:UIControlStateNormal];
        [_VCsTitleBar setTexture:[[CCTextureCache sharedTextureCache] addImage:@"myvcstitlebar.png"]];
        scrollViewMyVcs.hidden = NO;
        scrollViewAllVcs.hidden = YES;
        if(_totalRowsInMyVCs == 0)
        {
            _alertLabel.hidden = NO;
        }
        allVcsGlobal=FALSE;
    }
}

//Functionality for transition to main menu
- (void) goto_Main_Menu: (CCMenuItem  *) menuItem 
{
    //Remove all views from superview and release the memory allocated
	[scrollViewAllVcs removeFromSuperview];
    [scrollViewAllVcs release];
	
	[scrollViewMyVcs removeFromSuperview];
    [scrollViewMyVcs release];
	
	[myVcsButton removeFromSuperview];
	
	[_vcWhackLabel release];
	[_vcsDisplayImage release];
    [_vcNameLabel release];
	[_firmNameLabel release];
	[_whackListBackGroundImage release];
    
    allVcsGlobal = TRUE;
    
    if(_totalRowsInMyVCs == 0)
    {
        [_alertLabel removeFromSuperview];
        [_alertLabel release];
    }
	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[HelloWorldLayer scene]]];
}

/*******************************************************************************************************************/
/*                                     Facebook Delegate Methods                                                   */
/*******************************************************************************************************************/

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
    }
    
    [[[KCSClient sharedClient] currentUser] saveWithDelegate:self];
}


- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {

}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {

}

/*******************************************************************************************************************/
/*                                     Kinvey Delegate Methods                                                     */
/*******************************************************************************************************************/

// KINVEY SPECIFIC NOTE
// This is the delegate method notified when a save completes
- (void)entity:(id<KCSPersistable>)entity operationDidCompleteWithResult:(NSObject *)result{
    
    
}

// KINVEY SPECIFIC NOTE
// This is the delegate notified when a save fails
- (void)entity:(id)entity operationDidFailWithError:(NSError *)error{
    
    
}

- (void)collection:(KCSCollection *)collection didCompleteWithResult:(NSArray *)result
{
    
}

// KINVEY SPECIFIC NOTE
// This is the delegate called when a collection fetch fails
- (void)collection:(KCSCollection *)collection didFailWithError:(NSError *)error{
    
    
}

-(void)resourceServiceDidCompleteWithResult:(KCSResourceResponse *)result
{
    
}

- (void)resourceServiceDidFailWithError:(NSError *)error
{
    
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    
	// don't forget to call "super dealloc"
    
    //Release all the objects allocated
    _dbmanager._myVCSnapsFromDB = nil;
    _dbmanager._myVCFirmsFromDB = nil;
    _dbmanager._myVCWhackCountFromDB = nil;
    _dbmanager._myVCNamesFromDB = nil;
    _dbmanager._myVCTwitterHandleFromDB = nil;
    
    _dbmanager._allVCSnapsFromDB = nil;
    _dbmanager._allVCFirmsFromDB = nil;
    _dbmanager._allVCWhackCountFromDB = nil;
    _dbmanager._allVCNamesFromDB = nil;
    _dbmanager._allVCTwitterHandleFromDB = nil;
    
    [_dbmanager._myVCSnapsFromDB release];
    [_dbmanager._myVCFirmsFromDB release];
    [_dbmanager._myVCWhackCountFromDB release];
    [_dbmanager._myVCNamesFromDB release];
    [_dbmanager._myVCTwitterHandleFromDB release];
    
    [_dbmanager._allVCSnapsFromDB release];
    [_dbmanager._allVCFirmsFromDB release];
    [_dbmanager._allVCWhackCountFromDB release];
    [_dbmanager._allVCNamesFromDB release];
    [_dbmanager._allVCTwitterHandleFromDB release];
    
    //Call to a function to close database
    [_dbmanager closeDB];
    [_dbmanager release];
    
    [facebook release];
    
    
	[super dealloc];
}
@end
