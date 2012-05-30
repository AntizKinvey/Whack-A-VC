//
//  GuessWhatLayer.h
//  WhackAVC
//
//  Created by Antiz Technologies on 4/4/12.
//  Copyright 2012 Antiz Technologies Pvt Ltd. All rights reserved.
//

#import "cocos2d.h"
#import "DBManager.h"

@interface GuessWhatLayer : CCLayer {
    DBManager *dbmanager;
}

@property(nonatomic, retain)DBManager *dbmanager;

+(CCScene *) scene;

@end
