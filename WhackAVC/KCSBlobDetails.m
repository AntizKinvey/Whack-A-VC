//
//  KCSBlobDetails.m
//  KinveyTestSample
//
//  Created by Ram Charan on 4/5/12.
//  Copyright (c) 2012 Antiz Technologies Pvt Ltd. All rights reserved.
//

#import "KCSBlobDetails.h"

@implementation KCSBlobDetails

@synthesize blobid = _blobId;
@synthesize lastModified = _lastModified;
@synthesize resourcename = _resourcename;
@synthesize blobArray;
@synthesize lastModifiedArray;

// Default initializer
- (id)init {
    self = [super init];
    if (self) {
        _lastModified = nil;
        _resourcename = nil;
        _blobId = nil;
        
    }
    return self;
}

// Destroy our objects when we're done
- (void)dealloc {
    [_blobId release];
    [_lastModified release];
    [_resourcename release];
    [super dealloc];
}

// KINVEY USAGE NOTE
// This method is overridden to provide a mapping from local instance variable names
// to names on the Kinvey backend.  The backend gives each unique entity a unique ID
// which is stored in the property "_id".  We must map an instance variable to that property
// In this case we use "_blobId"
- (NSDictionary *)hostToKinveyPropertyMapping{
    
    // Note that we define this as a static variable so we don't create a new one each time the function
    // is called, just the first time.
    static NSDictionary *mapping = nil;
    
    if (mapping == nil){
        mapping = [[NSDictionary dictionaryWithObjectsAndKeys:
                    @"_id", @"_blobId",   // The id of the resource: Local _blobId maps to _id on Kinvey
                    @"lastModified", @"_lastModified",   // The lastmodified timestamp to be saved on Kinvey
                    @"resourceName", @"_resourcename",   // The resource name to be saved on Kinvey
                    nil] retain];
    }
    
    return mapping;
}

@end
