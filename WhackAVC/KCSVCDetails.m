//
//  KCSVCDetails.m
//  WhackAVC
//
//  Created by Antiz Technologies on 4/16/12.
//  Copyright (c) 2012 Antiz Technologies Pvt Ltd. All rights reserved.
//

#import "KCSVCDetails.h"

@implementation KCSVCDetails

@synthesize vcDetailsId = _vcDetailsId;
@synthesize vcName = _vcName;
@synthesize vcFirm = _vcFirm;
@synthesize vcImageNameInGame = _vcImageNameInGame;
@synthesize vcImageNameInProfile = _vcImageNameInProfile;
@synthesize vcTwitterHandle = _vcTwitterHandle;

@synthesize vcIdArrayFromKinvey;
@synthesize vcNameArrayFromKinvey;
@synthesize vcFirmArrayFromKinvey;
@synthesize vcInGamePlayArrayFromKinvey;
@synthesize vcInProfileArrayFromKinvey;
@synthesize vcTwitterArrayFromKinvey;

// Default initializer
-(id)init
{
    if(self = [super init])
    {
        _vcDetailsId = nil;
        _vcName = nil;
        _vcFirm = nil;
        _vcImageNameInGame = nil;
        _vcImageNameInProfile = nil;
        _vcTwitterHandle = nil;
    }
    return self;
}

// Destroy our objects when we're done
- (void)dealloc {
    [_vcDetailsId release];
    [_vcName release];
    [_vcFirm release];
    [_vcImageNameInGame release];
    [_vcImageNameInProfile release];
    [_vcTwitterHandle release];
    [super dealloc];
}

// KINVEY USAGE NOTE
// This method is overridden to provide a mapping from local instance variable names
// to names on the Kinvey backend.  The backend gives each unique entity a unique ID
// which is stored in the property "_id".  We must map an instance variable to that property
// In this case we use "vcDetailsId"
- (NSDictionary *)hostToKinveyPropertyMapping{
    
    // Note that we define this as a static variable so we don't create a new one each time the function
    // is called, just the first time.
    static NSDictionary *mapping = nil;
    
    if (mapping == nil){
        mapping = [[NSDictionary dictionaryWithObjectsAndKeys:
                    @"_id", @"vcDetailsId",     // The id of the VC: Local vcId maps to _id on Kinvey
                    @"name", @"vcName",  // Local VC name to text on Kinvey
                    @"firm", @"vcFirm",  //Local firm name to text on Kinvey
                    @"gameImageNameInBlob", @"vcImageNameInGame", //Local image name that is displayed in game play to image name in Kinvey
                    @"profileImageNameInBlob", @"vcImageNameInProfile", //Local image name that is displayed in profiling to image name in Kinvey
                    @"twitter_handle", @"vcTwitterHandle", //VC Twitter handles from Kinvey backend
                    nil] retain];
    }
    
    return mapping;
}

// KINVEY USAGE NOTE
//Override the initializer that KinveyKit uses to build objects of this type.
+ (id)kinveyDesignatedInitializer
{
    return nil;
}

// KINVEY USAGE NOTE
//Returns an NSDictionary that details advanced object building options.
+ (NSDictionary *)kinveyObjectBuilderOptions
{
    return nil;
}

// KINVEY USAGE NOTE
//Save an Entity into KCS for a given KCS client and register a delegate to notify when complete.
- (void)saveToCollection:(KCSCollection *)collection withDelegate:(id<KCSPersistableDelegate>)delegate
{
    
}

// KINVEY USAGE NOTE
//Delete an entity from Kinvey and register a delegate for notification
- (void)deleteFromCollection:(KCSCollection *)collection withDelegate:(id<KCSPersistableDelegate>)delegate
{
    
}

@end
