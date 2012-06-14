//
//  KCSWhacks.m
//  WhackAVC
//
//  Created by Ram Charan on 4/16/12.
//  Copyright (c) 2012 Antiz Technologies Pvt Ltd. All rights reserved.
//

#import "KCSWhacks.h"

@implementation KCSWhacks

@synthesize whacksID = _whacksID;
@synthesize userID = _userID;
@synthesize vcID = _vcID;
@synthesize whackCount = _whackCount;

// Default initializer
-(id) init
{
    if(self = [super init])
    {
        _whacksID = nil;
        _userID = nil;
        _vcID = nil;
        _whackCount = nil;
    }
    return self;
}

// Destroy our objects when we're done
-(void)dealloc
{
    [_whacksID release];
    [_userID release];
    [_vcID release];
    [_whackCount release];
    
    [super dealloc];
}

// KINVEY USAGE NOTE
// This method is overridden to provide a mapping from local instance variable names
// to names on the Kinvey backend.  The backend gives each unique entity a unique ID
// which is stored in the property "_id".  We must map an instance variable to that property
// In this case we use "_whacksID"
- (NSDictionary *)hostToKinveyPropertyMapping{
    
    // Note that we define this as a static variable so we don't create a new one each time the function
    // is called, just the first time.
    static NSDictionary *mapping = nil;
    
    if (mapping == nil){
        mapping = [[NSDictionary dictionaryWithObjectsAndKeys:
                    @"_id", @"_whacksID",    // The id of the VC whack count: Local whackId maps to _id on Kinvey
                    @"userId", @"_userID",  //The id of user provided from Kinvey
                    @"vcId", @"_vcID",  //The id of VC presenty in Kinvey
                    @"whackCount", @"_whackCount", //Whack count of each VC that is stored in Kinvey
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
//- (void)saveToCollection:(KCSCollection *)collection withDelegate:(id<KCSPersistableDelegate>)delegate
//{
//
//}

// KINVEY USAGE NOTE
//Delete an entity from Kinvey and register a delegate for notification
- (void)deleteFromCollection:(KCSCollection *)collection withDelegate:(id<KCSPersistableDelegate>)delegate
{
    
}

@end
