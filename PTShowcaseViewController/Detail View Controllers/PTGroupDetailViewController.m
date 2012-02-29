//
//  PTGroupDetailViewController.m
//  ShowcaseDemo
//
//  Created by Ali Servet Donmez on 29.2.12.
//  Copyright (c) 2012 Apex-net srl. All rights reserved.
//

#import "PTGroupDetailViewController.h"

@implementation PTGroupDetailViewController

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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    
    return [[self.navigationController.viewControllers objectAtIndex:0] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end
