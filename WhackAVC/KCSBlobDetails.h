//
//  KCSBlobDetails.h
//  KinveyTestSample
//
//  Created by Ram Charan on 4/5/12.
//  Copyright (c) 2012 Antiz Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KinveyKit/KinveyKit.h>

@interface KCSBlobDetails : NSObject <KCSPersistable>
{
    NSMutableArray *blobArray;
    NSMutableArray *lastModifiedArray;
}

@property (nonatomic, retain) NSString *blobid;
@property (nonatomic, retain) NSString *lastModified;
@property (nonatomic, retain) NSString *resourcename;
@property (nonatomic, retain) NSMutableArray *blobArray;
@property (nonatomic, retain) NSMutableArray *lastModifiedArray;

@end
