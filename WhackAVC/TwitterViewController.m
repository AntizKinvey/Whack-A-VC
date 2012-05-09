//
//  TwitterViewController.m
//  FbandTw
//
//  Created by Ram Charan on 3/30/12.
//  Copyright (c) 2012 Antiz Technologies Pvt Ltd. All rights reserved.
//

#import "TwitterViewController.h"

@implementation TwitterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    [self canTweetStatus];
//}


-(void) viewWillAppear
{
    [UIApplication sharedApplication].statusBarOrientation = self.interfaceOrientation;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
   // return YES;
}

@end
