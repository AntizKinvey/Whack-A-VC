//
//  AppDelegate.h
//  WhackAVC
//
//  
//  Copyright Antiz Technologies Pvt Ltd 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KinveyKit/KinveyKit.h>
#import "FBConnect.h"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, FBSessionDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    
    Facebook *facebook;
}

@property (nonatomic, retain) UIWindow *window;

@property (nonatomic, retain) Facebook *facebook;

@end
