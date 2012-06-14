//
//  KCSWhacks.h
//  WhackAVC
//
//  Created by Ram Charan on 4/16/12.
//  Copyright (c) 2012 Antiz Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <KinveyKit/KinveyKit.h>

@interface KCSWhacks : NSObject <KCSPersistable>
{
    NSString *whacksID;
    NSString *userID;
    NSString *vcID;
    NSString *whackCount;
}

@property (nonatomic, retain) NSString *whacksID;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *vcID;
@property (nonatomic, retain) NSString *whackCount;

@end
