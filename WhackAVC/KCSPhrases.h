//
//  KCSPhrases.h
//  WhackAVC
//
//  Created by Antiz Technologies on 4/12/12.
//  Copyright (c) 2012 Antiz Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <KinveyKit/KinveyKit.h>

@interface KCSPhrases : NSObject <KCSPersistable>
{
    NSMutableArray *phraseArrayFromKinvey;
}
@property (nonatomic, retain) NSString *phraseId;

// The phrase text that we'll send to the backend
@property (nonatomic, retain) NSString *phraseText;

@property (nonatomic, retain) NSMutableArray *phraseArrayFromKinvey;

@end
