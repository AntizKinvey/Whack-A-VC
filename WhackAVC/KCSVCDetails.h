//
//  KCSVCDetails.h
//  WhackAVC
//
//  Created by Antiz Technologies on 4/16/12.
//  Copyright (c) 2012 Antiz Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <KinveyKit/KinveyKit.h>

@interface KCSVCDetails : NSObject <KCSPersistable>
{
    NSMutableArray *vcIdArrayFromKinvey;
    NSMutableArray *vcNameArrayFromKinvey;
    NSMutableArray *vcFirmArrayFromKinvey;
    NSMutableArray *vcInGamePlayArrayFromKinvey;
    NSMutableArray *vcInProfileArrayFromKinvey;
    NSMutableArray *vcTwitterArrayFromKinvey;
}

@property (nonatomic, retain) NSString *vcDetailsId;
@property (nonatomic, retain) NSString *vcName;
@property (nonatomic, retain) NSString *vcFirm;
@property (nonatomic, retain) NSString *vcImageNameInGame;
@property (nonatomic, retain) NSString *vcImageNameInProfile;
@property (nonatomic, retain) NSString *vcTwitterHandle;

@property (nonatomic, retain) NSMutableArray *vcIdArrayFromKinvey;
@property (nonatomic, retain) NSMutableArray *vcNameArrayFromKinvey;
@property (nonatomic, retain) NSMutableArray *vcFirmArrayFromKinvey;
@property (nonatomic, retain) NSMutableArray *vcInGamePlayArrayFromKinvey;
@property (nonatomic, retain) NSMutableArray *vcInProfileArrayFromKinvey;
@property (nonatomic, retain) NSMutableArray *vcTwitterArrayFromKinvey;

@end
