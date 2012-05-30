//
//  HelloWorldLayer.m
//  WhackAVC
//
//  
//  Copyright Antiz Technologies Pvt Ltd 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "PlayAreaLayer.h"
#import "AboutKinveyLayer.h"
#import "HelpScreenLayer.h"
#import "VcsScreenLayer.h"
#import "GameOverLayer.h"
#import "DBManager.h"
#import "Reachability.h"
#import "KCSBlobDetails.h"
#import "KCSPhrases.h"
#import "KCSVCDetails.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize dbmanager;
@synthesize blobCollection = _blobCollection;
@synthesize phrasesCollection = _phrasesCollection;
@synthesize vcDetailsCollection = _vcDetailsCollection;

BOOL _blobLoadedSuccess = FALSE; //This flag will be TRUE when all the metadata related to BLOB is read from the Kinvey backend
BOOL _phraseLoadedSuccess = FALSE;//This flag will be TRUE when all the appdata related to phrases is read from the Kinvey backend
BOOL _vcDetailsLoadedSuccess = FALSE;//This flag will be TRUE when all the appdata related to VC Details is read from the Kinvey backend
BOOL _whackListTableLoaded = FALSE;//This flag will be TRUE when all the appdata related to number of whacks on VC's is read from the Kinvey backend

BOOL _updatedToMetadataTable = FALSE;
BOOL _insertedToMetadataTable = FALSE;

KCSBlobDetails *_blobDetails;
KCSPhrases *_phraseDetails;
KCSVCDetails *_vcDetails;

BOOL _splashOnce = FALSE;//This flag is set to TRUE when splashScreen is executed


int _totalRowsInUserTable = 0;//Number of rows in Table User
int _totalRowsInWhacklistTable = 0;//Number of rows in Table Whacklist
int _totalRowsInVClistTable = 0;//Number of rows in Table VClist

NSString *imagePath;//The path of the VC game images that are stored in Documents Directory
NSString *snapimagePath;//The path of the VC profile images that are stored in Documents Directory
NSString *soundPath;//The path of the VC audio shouts that are stored in Documents Directory

NSArray *_firms;//Static array of Firm names
NSArray *_names;//Static array of VC names
NSArray *_phrases;//Static array of Phrases
NSArray *_twitter_handle;//Static array of VC twitter handles
NSArray *_resources;//Static array of resources
NSArray *_vcIdInKinvey;//Static array of VC kinvey Id

NSMutableArray *_downloadArray;//Array that consists of elements that are downloaded from Kinvey backend
NSMutableArray *_downloadResourceTimeArray;//Array that consists of timestamp of elements that are to be downloaded from Kinvey backend

NSString *_kinveyUserId;//Kinvey User handle

BOOL _executeOnce = FALSE;//This flag is set when the database operations are executed and to be done only once

int _pressedPlayFromMainMenu = 0;//Set the value if the play button is pressed from the main menu
int _audioFilesIndexInDB = 0;//Audio Id that is to be inserted to the Audiolist table

UIButton *fbButton;
UIButton *twButton;

int _noOfRowsInMetaDataFromLocalDB = 0;//To detect number of rows in Metadata table
int _noOfRowsInWhacklistFromLocalDB = 0;//To detect number of rows in Whacklist table

int _noOfResourcesToDownload = 0;//To detect number of resources that are to be downloaded from Kinvey backend
int _noOfResourcesDownloaded = 0;//To detect number of resources that are downloaded from Kinvey backend

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
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
        
        //Create an object of DBManager
        dbmanager = [[DBManager alloc] init];
        
        //Array that of resource names that are present in local cache
        dbmanager._resourcesInDB = [[[NSMutableArray alloc] init] autorelease];
        
        //Array that consists of timestamp of resources that are present in local cache
        dbmanager._resourcesLastModifiedInDB = [[[NSMutableArray alloc] init] autorelease];

        //Array that consists of VC Ids from VClist table
        dbmanager._vcIdFromVClistArray = [[[NSMutableArray alloc] init] autorelease];
        
        //Array that consists of VC Kinvey Ids from VClist table
        dbmanager._vcKinveyIdFromVClistArray = [[[NSMutableArray alloc] init] autorelease];
        
        //Array that consists of VC Whack count Ids from Whacklist table
        dbmanager._vcIdFromWhacklistArray = [[[NSMutableArray alloc] init] autorelease];
        
        //Array that consists of elements that are downloaded from Kinvey backend
        _downloadArray = [[NSMutableArray alloc] init];
        
        //Array that consists of timestamp of elements that are to be downloaded from Kinvey backend
        _downloadResourceTimeArray = [[NSMutableArray alloc] init];
        
        //Create an object of KCSBlobDetails
        _blobDetails = [[KCSBlobDetails alloc] init];
        
        //Blob Array that consists of the Resources names that are to be downloaded from Kinvey backend
        _blobDetails.blobArray = [[[NSMutableArray alloc] init] autorelease];
        
        //Blob Array that consists of the timestamp of Resources that are to be downloaded from Kinvey backend
        _blobDetails.lastModifiedArray = [[[NSMutableArray alloc] init] autorelease];
        
        //Create an object of KCSPhrases
        _phraseDetails = [[KCSPhrases alloc] init];
        
        //Phrases Array that consists of the Resources names that are to be downloaded from Kinvey backend
        _phraseDetails.phraseArrayFromKinvey = [[[NSMutableArray alloc] init] autorelease];
        
        //Create an object of KCSVCDetails
        _vcDetails = [[KCSVCDetails alloc] init];
        
        //Array of VC Ids retrieved from VC Details collection from Kinvey
        _vcDetails.vcIdArrayFromKinvey = [[[NSMutableArray alloc] init] autorelease];
        
        //Array of VC Names retrieved from VC Details collection from Kinvey
        _vcDetails.vcNameArrayFromKinvey = [[[NSMutableArray alloc] init] autorelease];
        
        //Array of VC Firm names retrieved from VC Details collection from Kinvey
        _vcDetails.vcFirmArrayFromKinvey = [[[NSMutableArray alloc] init] autorelease];
        
        //Array of VC game play images retrieved from VC Details collection from Kinvey
        _vcDetails.vcInGamePlayArrayFromKinvey = [[[NSMutableArray alloc] init] autorelease];
        
        //Array of VC profile images retrieved from VC Details collection from Kinvey
        _vcDetails.vcInProfileArrayFromKinvey = [[[NSMutableArray alloc] init] autorelease];
        
        //Array of VC Twitter handles retrieved from VC Details collection from Kinvey
        _vcDetails.vcTwitterArrayFromKinvey = [[[NSMutableArray alloc] init] autorelease];
        
        
        
        if(_executeOnce == FALSE) {
            _executeOnce = TRUE;
            //Creating and Inserting data to Database Only Once when the application starts
            [self preProcessingDB];
        }
        
        if(_splashOnce == FALSE)
        {   
            _splashOnce = TRUE;
            //Show splash screen only once when application starts
            [self showSplashScreen];
        }
        else
        {
            //Call to a function to show main menu
            [self showMainMenu];
        }
        
	}
	return self;
}

//Functionality to create database
-(void) preProcessingDB
{
    //Array of firm names related to specific VC's that are to be present initially
    _firms = [[NSArray arrayWithObjects:@"Matrix Partners",
               @"Polaris",
               @"Highland",
               @"General Catalyst",
               @"Battery Ventures",
               @"Avalon Ventures",
               @"Bessemer Venture Partners",
               @"Bain Capital Ventures",
               @"Charles River Ventures",
               @"North Bridge",
               @"Matrix Partners",
               @"Bain Capital Ventures",
               @"Polaris",
               @"Mc Venture Partners",
               @"Spark Capital",
               @"SoftTech VC",
               @"Lighter Capital",
               @"Accel Partners",
               @"Sequoia Capita",
               @"Greylock Partners",
               nil] retain];
    
    //Array of VC names that are to be present initially
    _names = [[NSArray arrayWithObjects:@"David Skok",
               @"Terry McGuire",
               @"Sean Dalton",
               @"Joel Cutler",
               @"Neeraj Agrawl",
               @"Rich Levandov",
               @"Chris Gabrieli",
               @"Ben Nye",
               @"Bruce Sachs",
               @"Ed Anderson",
               @"Tim Barrows",
               @"Michael Krupka",
               @"Amir Nashat",
               @"Jim Wade",
               @"Bijan Sabet",
               @"Jeff Clavier",
               @"Andy Sack",
               @"Jim Breyer",
               @"Michael Mortiz",
               @"Reid Hoffman",
               nil] retain];
    
    //Array of Word Phrases that are to be present initially
    _phrases = [[NSArray arrayWithObjects:@"You need more market traction",
                 @"Find better product market fit",
                 @"Get some social proof",
                 @"Find more customers",
                 @"Get a better valuation",
                 @"Make more sales calls",
                 @"Are you hiring enough?",
                 @"Increase your sales funnel",
                 @"Improve your UI/UX",
                 @"Focus on your MVP",
                 @"Get more deal flow",
                 @"Always be selling",
                 @"Better your COCA!",
                 @"Whats your APRU?",
                 @"Have you crossed the chasm?",
                 @"Have you tried being lean?",
                 @"Have you considered a pivot?",
                 @"Have you done A/B testing?",
                 @"Have you found your MVP?",
                 @"Have you applied to an accelerator?",
                 nil] retain];
    
    //Array of Twitter handles of related VC's 
    _twitter_handle = [[NSArray arrayWithObjects:@"BostonVC",
                        @"",
                        @"daltonsean",
                        @"",
                        @"",
                        @"",
                        @"",
                        @"",
                        @"",
                        @"",
                        @"",
                        @"",
                        @"",
                        @"",
                        @"bijan",
                        @"jeff",
                        @"AndySack",
                        @"jimihendrixlive",
                        @"",
                        @"quixotic",
                        nil] retain];
    
    //VC Ids In Kinvey
    _vcIdInKinvey = [[NSArray arrayWithObjects:@"4f8bcc0b0a981c035b000c8c",
                      @"4f8bcc6e0a981c035b000c8d",
                      @"4f8bcc880a981c035b000c8e",
                      @"4f8bccd60a981c035b000c8f",
                      @"4f8bcd1e0a981c035b000c90",
                      @"4f8bcd420a981c035b000c91",
                      @"4f8bcd730a981c035b000c92",
                      @"4f8bcd970a981c035b000c93",
                      @"4f8bcdb90a981c035b000c94",
                      @"4f8bcdff0a981c035b000c95",
                      @"4f8bce1b0a981c035b000c96",
                      @"4f8bce350a981c035b000c97",
                      @"4f8bce670a981c035b000c98",
                      @"4f8bce820a981c035b000c99",
                      @"4f8bceaf0a981c035b000c9a",
                      nil] retain];
    
    //Array of Resources
    _resources = [[NSArray arrayWithObjects:@"vc1.png",
                   @"vc2.png",
                   @"vc3.png",
                   @"vc4.png",
                   @"vc5.png",
                   @"vc6.png",
                   @"vc7.png",
                   @"vc8.png",
                   @"vc9.png",
                   @"vc10.png",
                   @"vc11.png",
                   @"vc12.png",
                   @"vc13.png",
                   @"vc14.png",
                   @"vc15.png",
                   @"vcsnap1.png",
                   @"vcsnap2.png",
                   @"vcsnap3.png",
                   @"vcsnap4.png",
                   @"vcsnap5.png",
                   @"vcsnap6.png",
                   @"vcsnap7.png",
                   @"vcsnap8.png",
                   @"vcsnap9.png",
                   @"vcsnap10.png",
                   @"vcsnap11.png",
                   @"vcsnap12.png",
                   @"vcsnap13.png",
                   @"vcsnap14.png",
                   @"vcsnap15.png",
                   @"sound1.wav",
                   @"sound2.wav",
                   nil] retain];
    
    
    //Call to a function to open connection to Database
    [dbmanager openDB];
    
    //Create Table VClist
    _totalRowsInVClistTable = [dbmanager checkNumberOfRowsInVClistTable:@"SELECT count(*) FROM VClist"];
    if(_totalRowsInVClistTable == 0)
    {
        [dbmanager createTableVC:@"VClist" withField1:@"vcid" withField2:@"vcname" withField3:@"vcfirm" withField4:@"vcphoto" withField5:@"vcsnaps" withField6:@"vctwhandle" withField7:@"vcKinveyId"];
    }
    
    //Create Table Temp
    [dbmanager createTableTemp:@"Temp" withField1:@"vcid" withField2:@"vcname" withField3:@"vcfirm" withField4:@"vcsnaps" withField5:@"vctwhandle" withField6:@"whackcount"];
    
    //Create Table MetaData
    [dbmanager createTableMetaData:@"MetaData" withField1:@"resourceId" withField2:@"resourceName" withField3:@"lastModifiedTime"];
    
    //Create Table Audiolist
    [dbmanager createTableAudio:@"Audiolist" withField1:@"audioid" withField2:@"audioname"];
    //Create Table Phraselist
    [dbmanager createTablePhrase:@"Phraselist" withField1:@"phrid" withField2:@"phrlabel"];
    
    //Find total number of Rows in User Table
    _totalRowsInUserTable = [dbmanager retrieveNoOfRowsInUser:@"Select score from User"];
    
    if(_totalRowsInUserTable == 0)
    {
        //Create Table User
        [dbmanager createTableUser:@"User" withField1:@"usrid" withField2:@"score"];
        //Insert Records to  Table User 
        [dbmanager insertRecordIntoUserTable:@"User" withField1:@"usrid" field1Value:@"1" andField2:@"score" field2Value:@"0"];
    }
    
    //Find total number of Rows in Whacklist Table
    _totalRowsInWhacklistTable = [dbmanager checkNumberOfRowsInWhacklistTable:@"SELECT * FROM Whacklist"];
    if(_totalRowsInWhacklistTable == 0)
    {
        //Create Table Whacklist
        [dbmanager createTableWhacks:@"Whacklist" withField1:@"whackid" withField2:@"vcid" withField3:@"usrid" withField4:@"whackcount" withField5:@"vcKinveyId"];
    }
    
    if(_totalRowsInVClistTable == 0)
    {
    //Add a minimum of 15 VC's to database that will be used if there is no Internet connectivity when the application starts
    for(int i=1; i<16; i++)
    {
        //Variable for Whack ID in Whacklist Table
        NSString *whackid = [[NSString alloc] initWithFormat:@"%d",i];
        
        //Variable for VC ID in VClist Table
        NSString *vcid = [[NSString alloc] initWithFormat:@"%d",i];
        
        //Variable for VC name in VClist Table that is retrieved from VC names Array
        NSString *vcname = [[NSString alloc] initWithFormat:@"%@",[_names objectAtIndex:i-1]];
        
        //Variable for VC firm in VClist Table that is retrieved from VC firm names Array related to VC names
        NSString *vcfirm = [[NSString alloc] initWithFormat:@"%@",[_firms objectAtIndex:i-1]];
        
        //Copy items to Documents directory and get the full path to save in database. These images of VC's are displayed in Play Area
        imagePath = [dbmanager saveImagesToDocumentsDirectory:i];
        
        //Copy items to Documents directory and get the full path to save in database. These images of VC's are displayed in Game Over and VC list screens
        snapimagePath = [dbmanager saveSnapImagesToDocumentsDirectory:i];
        
        //Insert values to VClist
        [dbmanager insertRecordIntoVClistTable:@"VClist" withField1:@"vcid" field1Value:vcid andField2:@"vcname" field2Value:vcname andField3:@"vcfirm" field3Value:vcfirm andField4:@"vcphoto" field4Value:imagePath andField5:@"vcsnaps" field5Value:snapimagePath andField6:@"vctwhandle" field6Value:[_twitter_handle objectAtIndex:(i-1)] andField7:@"vcKinveyId" field7Value:[_vcIdInKinvey objectAtIndex:(i-1)]];
        
        if(_totalRowsInWhacklistTable == 0)
        {
            //Insert values to Whacklist table
            [dbmanager insertRecordIntoWhacklistTable:@"Whacklist" withField1:@"whackid" field1Value:whackid andField2:@"vcid" field2Value:vcid andField3:@"usrid" field3Value:@"1" andField4:@"whackcount" field4Value:@"0" andField5:@"vcKinveyId" field5Value:[_vcIdInKinvey objectAtIndex:(i-1)]];
        }
        
        //Release the variables allocated
        [whackid release];
        [vcid release];
        [vcname release];
        [vcfirm release];
        
    }
    }
    
    //Add a minimum of 5 VC Word Phrases to database that will be used if there is no Internet connectivity when the application starts
    for(int i=1; i<=5; i++)
    {
        //Variable for phrase ID in Phraselist Table
        NSString *phrid = [[NSString alloc] initWithFormat:@"%d",i];
        
        //Variable for VC Word Phrases in Phraselist Table that is retrieved from Phrases Array
        NSString *phraseToDb = [[NSString alloc] initWithFormat:@"%@",[_phrases objectAtIndex:(i-1)]];
        
        //Insert values into Phrase Table
        [dbmanager insertRecordIntoPhraseTable:@"Phraselist" withField1:@"phrid" field1Value:phrid andField2:@"phrlabel" field2Value:phraseToDb];
        
        //Release the variables allocated
        [phrid release];
        [phraseToDb release];
    }
    
    //Add a minimum of 2 VC shouts to database that will be used if there is no Internet connectivity when the application starts
    for(int i=1;i<3;i++)
    {
        //Variable for audio ID in Audiolist Table
        NSString *audioid = [[NSString alloc] initWithFormat:@"%d",i];
        
        //Copy items to Documents directory and get the full path to save in database. These VC shouts are used in Play Area
        soundPath = [dbmanager saveAudioFilesToDirectory:i];
        
        //Insert values to Audiolist
        [dbmanager insertRecordIntoAudioTable:@"Audiolist" withField1:@"audioid" field1Value:audioid andField2:@"audioname" field2Value:soundPath];
    }
    
    //Get the total number of Rows in Audiolist table, so that it will be used for incrementing the audio id in Audiolist table when the files are downloaded from Kinvey backend
    _audioFilesIndexInDB = [dbmanager retrieveVCWhackAudioPaths];
    
    //Get total number of rows in Metadata table, so that it will be used for incrementing the id in Metadata table when the files are downloaded from Kinvey backend 
    _noOfRowsInMetaDataFromLocalDB = [dbmanager retrieveNumberOfRecordsFromMetaData:@"SELECT count(*) FROM MetaData"];
    
    //If number of rows in Metadata table is zero then add a minimum of 32 details of resources that are present in local cache
    if(_noOfRowsInMetaDataFromLocalDB == 0)
    {
        for(int i=1; i<=32; i++)
        {
            NSString *resourceId = [[NSString alloc] initWithFormat:@"%d",i];
            NSString *lastModifiedTime = [[NSString alloc] initWithFormat:@"16/4/2012 19:12"];
            
            //Insert Values into MetaData Table
            [dbmanager insertRecordIntoMetaDataTable:@"MetaData" withField1:@"resourceId" field1Value:resourceId andField2:@"resourceName" field2Value:[_resources objectAtIndex:(i-1)] andField3:@"lastModifiedTime" field3Value:lastModifiedTime];
            
            [resourceId release];
            [lastModifiedTime release];
        }
    }
    
    //Get total number of rows in Metadata table
    _noOfRowsInMetaDataFromLocalDB = [dbmanager retrieveNumberOfRecordsFromMetaData:@"SELECT count(*) FROM MetaData"];
    
    //Retrieve all Records from Metadata Table
    [dbmanager retrieveRecordsFromMetaData];
    
    //Release the variables allocated
    _firms = nil;
    [_firms release];
    _names = nil;
    [_names release];
    _phrases = nil;
    [_phrases release];
    
    _twitter_handle = nil;
    [_twitter_handle release];
    _resources = nil;
    [_resources release];
    _vcIdInKinvey = nil;
    [_vcIdInKinvey release];
    
    //Call to load data and resources from Kinvey backend
    [self loadDataFromKinvey];
}

//Functionalityu to load data and resources from Kinvey backend
-(void) loadDataFromKinvey
{
    //Check whether there is an availability of Internet
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        //Call to function to show main menu even if Internet is not connected
        [self showMainMenu];
    }
    else
    {
        //Reference to the collection metaData in Kinvey
        _blobCollection = [[[KCSClient sharedClient]
                            collectionFromString:@"metaData"
                            withClass:[KCSBlobDetails class]] retain];
        
        //Reference to the collection phrases in Kinvey
        _phrasesCollection = [[[KCSClient sharedClient]
                               collectionFromString:@"phrases"
                               withClass:[KCSPhrases class]] retain];
        
        //Reference to the collection VC-Details in Kinvey
        _vcDetailsCollection = [[[KCSClient sharedClient]
                                 collectionFromString:@"VC-Details"
                                 withClass:[KCSVCDetails class]] retain];
        
        
        //Load the details of the current user from Kinvey
        [[[KCSClient sharedClient] currentUser] loadWithDelegate:self];

        //Querying data from the referenced collections. The returned objects will be notified in the delegate in the form of objects of their particular class type having KVC(key-value-coding)
        [_blobCollection fetchAllWithDelegate:self];
        [_phrasesCollection fetchAllWithDelegate:self];
        [_vcDetailsCollection fetchAllWithDelegate:self];
        
        //Call to function to show main menu
        [self showMainMenu];
    }
    
}

//Functionality to show Splash Screen
-(void) showSplashScreen
{
    [self schedule:@selector(transitToMainMenu:) interval:4.0];
    
    CCSprite *splashscreen = [CCSprite spriteWithFile:@"splashscreen.png" 
                                                 rect:CGRectMake(0, 0, 480, 320)];
    splashscreen.position = ccp(240, 160);
    
    [self addChild:splashscreen];
}

//Functionality for transition to Main Menu
-(void) transitToMainMenu:(ccTime)dt
{
    [self unschedule:@selector(transitToMainMenu:)];
    [self showMainMenu];
}

//Functionality to show Main Menu
-(void) showMainMenu
{
    
    CCSprite *mainscreen = [CCSprite spriteWithFile:@"mainscreen.png" 
                                               rect:CGRectMake(0, 0, 480, 320)];
    
    mainscreen.position = ccp(240, 160);
    
    
    CCMenuItem *menuItem1 = [CCMenuItemImage itemFromNormalImage:@"play.png"
                                                   selectedImage: @"play.png"
                                                          target:self
                                                        selector:@selector(goto_Play_Area:)];
    
    
    CCMenuItem *menuItem2 = [CCMenuItemImage itemFromNormalImage:@"helpbutton.png"
                                                   selectedImage: @"helpbutton.png"
                                                          target:self
                                                        selector:@selector(goto_Help_Screen:)];
    
    
    
    
    CCMenuItem *menuItem3 = [CCMenuItemImage itemFromNormalImage:@"vc.png"
                                                   selectedImage: @"vc.png"
                                                          target:self
                                                        selector:@selector(goto_VC_Screen:)];
    
    
    
    
    // Create a menu and add your menu items to it
    CCMenu *myMenu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, nil];
    
    [menuItem1 setPosition:ccp(140,35)];
    [menuItem2 setPosition:ccp(100,-45)];
    [menuItem3 setPosition:ccp(190,-45)];
    
    //Add the children that are initialized earlier
    [self addChild:mainscreen];
    [self addChild:myMenu];
    
}

//Functionality for transition to Play Area
- (void) goto_Play_Area: (CCMenuItem  *) menuItem 
{
    _pressedPlayFromMainMenu = 1;
    [fbButton removeFromSuperview];
    [twButton removeFromSuperview];
    
    //Transition from one scene to another
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[PlayAreaLayer scene]]];
}
//Functionality for transition to Help Screen
- (void) goto_Help_Screen: (CCMenuItem  *) menuItem 
{
    [fbButton removeFromSuperview];
    [twButton removeFromSuperview];
    
    //Transition from one scene to another
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[HelpScreenLayer scene]]];
}

//Functionality for transition to VC's Screen
- (void) goto_VC_Screen: (CCMenuItem  *) menuItem 
{
    [fbButton removeFromSuperview];
    [twButton removeFromSuperview];
    
    //Transition from one scene to another
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[VcsScreenLayer scene]]];
}

/*******************************************************************************************************************/
/*                                     Kinvey Delegate Methods                                                     */
/*******************************************************************************************************************/

// KINVEY SPECIFIC NOTE
// This is the delegate notified when a fetch completes
- (void)entity:(id<KCSPersistable>)entity fetchDidCompleteWithResult:(NSUserDefaults *)result
{
    //Get the current username from Kinvey and assign it to a variable that will be used to store whack counts of each VC
    _kinveyUserId = [[NSString alloc] initWithString:[result objectForKey:@"username"]];
}

// KINVEY SPECIFIC NOTE
// This is the delegate notified when a fetch fails
- (void)entity:(id<KCSPersistable>)entity fetchDidFailWithError:(NSError *)error
{
    
}

// KINVEY SPECIFIC NOTE
// This is the delegate notified when a save completes
- (void)entity:(id<KCSPersistable>)entity operationDidCompleteWithResult:(NSObject *)result{

}

// KINVEY SPECIFIC NOTE
// This is the delegate notified when a save fails
- (void)entity:(id)entity operationDidFailWithError:(NSError *)error{
    
}

// KINVEY SPECIFIC NOTE
// This is the delegate called when a collection is fetched
- (void)collection:(KCSCollection *)collection didCompleteWithResult:(NSArray *)result{
    
    for(int i=0; i< [result count];i++)
    {
        //Get the class name of the type of object returned in result array
        NSString *className = NSStringFromClass([[result objectAtIndex:i] class]); 
        
        if([className isEqualToString:@"KCSBlobDetails"])
        {
            //Add resource names to the array that are present in Kinvey
            [_blobDetails.blobArray addObject:[[result objectAtIndex:i] resourcename]];
            
            //Add timestamp of the resources to the array that are present in Kinvey
            [_blobDetails.lastModifiedArray addObject:[[result objectAtIndex:i] lastModified]];
            
            //Set the flag to initiate the download process of the resources from Kinvey
            _blobLoadedSuccess = TRUE;
        }
        if([className isEqualToString:@"KCSPhrases"])
        {
            //Add phrases to the array that are present in Kinvey
            [_phraseDetails.phraseArrayFromKinvey addObject:[[result objectAtIndex:i] phraseText]];
            
            //Set the flag to insert all the phrases to local cache
            _phraseLoadedSuccess = TRUE;
        }
        if([className isEqualToString:@"KCSVCDetails"])
        {
            //Add VC Id to array that are present Kinvey
            [_vcDetails.vcIdArrayFromKinvey addObject:[[result objectAtIndex:i] vcDetailsId]];
            
            //Add VC names Id to array that are present Kinvey
            [_vcDetails.vcNameArrayFromKinvey addObject:[[result objectAtIndex:i] vcName]];
            
            //Add VC Firm names to array that are present Kinvey
            [_vcDetails.vcFirmArrayFromKinvey addObject:[[result objectAtIndex:i] vcFirm]];
            
            //Add VC game play images to array that are present Kinvey
            [_vcDetails.vcInGamePlayArrayFromKinvey addObject:[[result objectAtIndex:i] vcImageNameInGame]];
            
            //Add VC profile images to array that are present Kinvey
            [_vcDetails.vcInProfileArrayFromKinvey addObject:[[result objectAtIndex:i] vcImageNameInProfile]];
            
            if([[[result objectAtIndex:i] vcTwitterHandle] isEqualToString:@"NA"])
            {
                [_vcDetails.vcTwitterArrayFromKinvey addObject:@""];
            }
            else
            {
                //Add VC Twitter handles to array that are present Kinvey
                [_vcDetails.vcTwitterArrayFromKinvey addObject:[[result objectAtIndex:i] vcTwitterHandle]];
            }
            
            //Set the flag to insert all the VC details to local cache
            _vcDetailsLoadedSuccess = TRUE;
        }
    }
    
    if(_blobLoadedSuccess == TRUE)
    {
        NSComparisonResult res; 
        
        //Set date format using the date formatter
        NSDateFormatter *date_formater1=[[NSDateFormatter alloc] init];
        [date_formater1 setDateFormat:@"dd/mm/yyyy HH:MM"];
        
        //Set date format using the date formatter
        NSDateFormatter *date_formater2=[[NSDateFormatter alloc] init];
        [date_formater2 setDateFormat:@"dd/mm/yyyy HH:MM"];
        
        for(int i=0; i<_noOfRowsInMetaDataFromLocalDB; i++)
        {
            //Set the date format for the elements in the array that are retrieved from Metadata table in local cache
            NSDate *localDBDate = [date_formater1 dateFromString:[dbmanager._resourcesLastModifiedInDB objectAtIndex:i]];
            
            for(int j=0; j<[_blobDetails.blobArray count]; j++)
            {
                //Set the date format for the elements in the array that are retrieved from metaData collection in Kinvey
                NSDate *backendDBDate = [date_formater2 dateFromString:[_blobDetails.lastModifiedArray objectAtIndex:j]];
                
                //Check if Resource name are same
                if([[dbmanager._resourcesInDB objectAtIndex:i] isEqualToString: [_blobDetails.blobArray objectAtIndex:j]])
                {
                    //Check if both dates are equal
                    res = [localDBDate compare:backendDBDate];
                    
                    //If localDBdate is less than backendDBdate, value of res is NSOrderedAscending
                    if(res == NSOrderedAscending)
                    {
                        [_downloadArray addObject:[_blobDetails.blobArray objectAtIndex:j]];
                        [_downloadResourceTimeArray addObject:[_blobDetails.lastModifiedArray objectAtIndex:j]];
                        [_blobDetails.blobArray removeObjectAtIndex:j];
                        [_blobDetails.lastModifiedArray removeObjectAtIndex:j];
                    }
                    
                    //If both dates are equal, value of res is NSOrderedAscending
                    else if(res == NSOrderedSame)
                    {
                        [_blobDetails.blobArray removeObjectAtIndex:j];
                        [_blobDetails.lastModifiedArray removeObjectAtIndex:j];
                    }
                }
            }
        }
        
        [date_formater1 release];
        [date_formater2 release];
        //Total number of Resources to be downloaded
        _noOfResourcesToDownload = [_blobDetails.blobArray count] + [_downloadArray count];
        
        //To download resources that are not present in local cache from Kinvey 
        for(int i=0; i<[_blobDetails.blobArray count]; i++)
        {
            //Download the resources to the Documents directory of the app.   
            NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString* outFile = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[_blobDetails.blobArray objectAtIndex:i]]];
            [KCSResourceService downloadResource:[NSString stringWithFormat:@"%@",[_blobDetails.blobArray objectAtIndex:i]]
                                          toFile:outFile
                            withResourceDelegate:self];
            
            _insertedToMetadataTable = TRUE;
        }
        
        
        //To download resources that are present in local cache from Kinvey with updated time
        for(int i=0; i<[_downloadArray count]; i++)
        {  
            //Download the resources to the Documents directory of the app. 
            NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString* outFile = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[_downloadArray objectAtIndex:i]]];
            [KCSResourceService downloadResource:[NSString stringWithFormat:@"%@",[_downloadArray objectAtIndex:i]]
                                          toFile:outFile
                            withResourceDelegate:self];
            
            _updatedToMetadataTable = TRUE;
        }
        
    }
    
    if(_phraseLoadedSuccess == TRUE)
    {
        for(int i=1; i<= [_phraseDetails.phraseArrayFromKinvey count]; i++)
        {
            NSString *phrId = [[NSString alloc] initWithFormat:@"%d",i];
            
            //Insert the values that are retrieved from Kinvey to Phraselist table in local cache 
            [dbmanager insertRecordIntoPhraseTable:@"Phraselist" withField1:@"phrid" field1Value:phrId andField2:@"phrlabel" field2Value:[_phraseDetails.phraseArrayFromKinvey objectAtIndex:(i-1)]];
            
            [phrId release];
        }
    }
    
}

// KINVEY SPECIFIC NOTE
// This is the delegate called when a collection fetch fails
- (void)collection:(KCSCollection *)collection didFailWithError:(NSError *)error{

}

// KINVEY SPECIFIC NOTE
// This is the delegate notified when a resource operation completes
-(void)resourceServiceDidCompleteWithResult:(KCSResourceResponse *)result
{
    if(_blobLoadedSuccess == TRUE)
    {
        //Keep track the number of times that the download is complete
        _noOfResourcesDownloaded++;
        //Check if number of downloads and number of resources to download are equal
        if(_noOfResourcesDownloaded == _noOfResourcesToDownload)
        {
            if(_insertedToMetadataTable == TRUE)
            {
                for(int i=0; i<[_blobDetails.blobArray count];i++)
                {
                    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString* outFile = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[_blobDetails.blobArray objectAtIndex:i]]];
                    
                    //Check the extension of the file
                    NSString* pathExt = [outFile pathExtension];
                    
                    if([pathExt isEqualToString: @"wav"])
                    {
                        _audioFilesIndexInDB++;
                        NSString *audioid = [[NSString alloc] initWithFormat:@"%d",_audioFilesIndexInDB];
                        
                        //Insert the details to Audiolist of the files that are downloaded
                        [dbmanager insertRecordIntoAudioTable:@"Audiolist" withField1:@"audioid" field1Value:audioid andField2:@"audioname" field2Value:outFile];
                        
                        [audioid release];
                    }
                    
                    _noOfRowsInMetaDataFromLocalDB++;
                    NSString *resourceId = [[NSString alloc] initWithFormat:@"%d",_noOfRowsInMetaDataFromLocalDB];
                    
                    //Insert details of resources to Metadata table to keep track of the resources that are downloaded
                    [dbmanager insertRecordIntoMetaDataTable:@"MetaData" withField1:@"resourceId" field1Value:resourceId andField2:@"resourceName" field2Value:[_blobDetails.blobArray objectAtIndex:i] andField3:@"lastModifiedTime" field3Value:[_blobDetails.lastModifiedArray objectAtIndex:i]];
                    
                    [resourceId release];
                }
            }
            
            if(_updatedToMetadataTable == TRUE)
            {
                for(int i=0; i<[_downloadArray count]; i++)
                {
                    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString* outFile = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[_downloadArray objectAtIndex:i]]];
                    
                    NSString* pathExt = [outFile pathExtension];
                    
                    if([pathExt isEqualToString: @"wav"])
                    {
                        _audioFilesIndexInDB++;
                        NSString *audioid = [[NSString alloc] initWithFormat:@"%d",_audioFilesIndexInDB];
                        
                        //Insert the details to Audiolist of the files that are downloaded
                        [dbmanager insertRecordIntoAudioTable:@"Audiolist" withField1:@"audioid" field1Value:audioid andField2:@"audioname" field2Value:outFile];
                        
                        [audioid release];
                    }
                    
                    //Update details of resources to Metadata table to keep track of the resources that are downloaded
                    [dbmanager updateRecordIntoMetaDataTable:@"MetaData" withField1:@"lastModifiedTime" field1Value:[_downloadResourceTimeArray objectAtIndex:i] andField2:@"resourceName" field2Value:[_downloadArray objectAtIndex:i]];
                }
            }
            
            if(_vcDetailsLoadedSuccess == TRUE)
            {
                for(int i=1; i<=[_vcDetails.vcNameArrayFromKinvey count]; i++)
                {
                    NSString *vcid = [[NSString alloc] initWithFormat:@"%d",i];
                    
                    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    
                    NSString* vcphoto = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[_vcDetails.vcInGamePlayArrayFromKinvey objectAtIndex:(i-1)]]];
                    
                    NSString* vcsnaps = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[_vcDetails.vcInProfileArrayFromKinvey objectAtIndex:(i-1)]]];

                    //Insert the VC details to VClist table in local cache
                    [dbmanager insertRecordIntoVClistTable:@"VClist" withField1:@"vcid" field1Value:vcid andField2:@"vcname" field2Value:[_vcDetails.vcNameArrayFromKinvey objectAtIndex:(i-1)] andField3:@"vcfirm" field3Value:[_vcDetails.vcFirmArrayFromKinvey objectAtIndex:(i-1)] andField4:@"vcphoto" field4Value:vcphoto andField5:@"vcsnaps" field5Value:vcsnaps andField6:@"vctwhandle" field6Value:[_vcDetails.vcTwitterArrayFromKinvey objectAtIndex:(i-1)] andField7:@"vcKinveyId" field7Value:[_vcDetails.vcIdArrayFromKinvey objectAtIndex:(i-1)]];

                    [vcid release];
                    
                    //Set the flag to insert details of VC's to Whacklist table
                    _whackListTableLoaded = TRUE;
                    _noOfResourcesDownloaded = 0;
                    _blobLoadedSuccess = FALSE;
                }
                
                //Retrieve VC Id and VC Kinvey handle from VClist table
                [dbmanager retrieveVCIDsFromVClist];
                
                //Retrieve VC Id from Whacklist table
                [dbmanager retrieveVCIDsFromWhacklist];
                
                //Number of rows in Whacklist table
                _noOfRowsInWhacklistFromLocalDB = [dbmanager._vcIdFromWhacklistArray count];
            }
        }
    }
    
    if(_whackListTableLoaded == TRUE)
    {
        for(int i=0; i<[dbmanager._vcIdFromWhacklistArray count]; i++)
        {
            for(int j=0; j<[dbmanager._vcIdFromVClistArray count]; j++)
            {
                //Check if the VC ids from Whacklist table is equal to VC ids from VClist table
                if([[dbmanager._vcIdFromWhacklistArray objectAtIndex:i] isEqualToString: [dbmanager._vcIdFromVClistArray objectAtIndex:j]])
                {
                    [dbmanager._vcIdFromVClistArray removeObjectAtIndex:j];
                    [dbmanager._vcKinveyIdFromVClistArray removeObjectAtIndex:j];
                }
            }
        }
        for(int i=1; i<=[dbmanager._vcIdFromVClistArray count]; i++)
        {
            _noOfRowsInWhacklistFromLocalDB++;
            NSString *whackID = [[NSString alloc] initWithFormat:@"%d",_noOfRowsInWhacklistFromLocalDB];
            
            //Insert Records to whacklist table of all the VC images that are downloaded 
            [dbmanager insertRecordIntoWhacklistTable:@"Whacklist" withField1:@"whackid" field1Value:whackID andField2:@"vcid" field2Value:[dbmanager._vcIdFromVClistArray objectAtIndex:(i-1)] andField3:@"usrid" field3Value:@"1" andField4:@"whackcount" field4Value:@"0" andField5:@"vcKinveyId" field5Value:[dbmanager._vcKinveyIdFromVClistArray objectAtIndex:(i-1)]];
            
            [whackID release];
        }
        _whackListTableLoaded = FALSE;
    }
}

// KINVEY SPECIFIC NOTE
// This is the delegate notified when a resource operation fails
- (void)resourceServiceDidFailWithError:(NSError *)error
{
    
}

/*******************************************************************************************************************/

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    
    //Call to a function to close database
	[dbmanager closeDB];
    [dbmanager release];
    
    [_blobDetails release];
    
    [_phraseDetails release];
    
    _downloadArray = nil;
    [_downloadArray release];
    
    _downloadResourceTimeArray = nil;
    [_downloadResourceTimeArray release];
    
    [_vcDetails release];
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
