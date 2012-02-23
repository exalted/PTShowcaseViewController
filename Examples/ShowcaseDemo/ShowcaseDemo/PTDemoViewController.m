//
//  PTDemoViewController.m
//  ShowcaseDemo
//
//  Created by Ali Servet Donmez on 10.2.12.
//  Copyright (c) 2012 Apex-net srl. All rights reserved.
//

#import "PTDemoViewController.h"

@interface PTDemoViewController ()

- (NSArray *)itemsForUniqueName:(NSString *)uniqueName;

@end

@implementation PTDemoViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - private

- (NSArray *)itemsForUniqueName:(NSString *)uniqueName
{
    // Root
    NSArray *exampleData = [[NSDictionary dictionaryWithContentsOfFile:NIPathForBundleResource(nil, @"ShowcaseDemo.plist")]
                            objectForKey:@"Root"];
    
    if ([@"83a115dfcdce56aeb39a75df77d58ddf" isEqualToString:uniqueName]) {
        // Deplian
        return [[exampleData objectAtIndex:0] objectForKey:@"Items"];
    }
    else if ([@"a5163fe21f330316158294f4b906f597" isEqualToString:uniqueName]) {
        // Foto
        return [[exampleData objectAtIndex:2] objectForKey:@"Items"];
    }
    else if ([@"ec90da36bb5cae03932cfab1d996f67e" isEqualToString:uniqueName]) {
        // Laminati Plastici
        return [[[[exampleData objectAtIndex:2] objectForKey:@"Items"] 
                 objectAtIndex:0] objectForKey:@"Items"];
    }
    else if ([@"16c45e82ec19d52989d695c3b464be2d" isEqualToString:uniqueName]) {
        // Listellari
        return [[[[exampleData objectAtIndex:2] objectForKey:@"Items"] 
                 objectAtIndex:1] objectForKey:@"Items"];
    }
    else if ([@"043110ffb6e2f2bb8b7f35b31bc35ed1" isEqualToString:uniqueName]) {
        // Mdf
        return [[[[exampleData objectAtIndex:2] objectForKey:@"Items"] 
                 objectAtIndex:2] objectForKey:@"Items"];
    }
    
    return exampleData;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Showcase";

    ////////////////////////////////////////////////////////////////////////////

    /*
     * Optionally change navigation bar color application-wide via appearance
     * proxy (as below), or any other method as you see fit
     */
    [UINavigationBar.appearance setBarStyle:UIBarStyleBlack];
    
    /*
     * Some example 'backgroundColor' values are below, but you can come up with
     * anything you like:
     *
     * - 2.0 and later: [UIColor viewFlipsideBackgroundColor]
     *                  [UIColor blackColor]
     *                  [UIColor whiteColor]
     * - 3.2 and later: [UIColor scrollViewTexturedBackgroundColor]
     * - 5.0 and later: [UIColor underPageBackgroundColor]
     */
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor]; // this is the default by the way ;-)
    
    ////////////////////////////////////////////////////////////////////////////
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
    
    ////////////////////////////////////////////////////////////////////////////
    
    /*
     * Decide which interface orientations do you want to support (we can handle
     * them all!)
     */
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return interfaceOrientation == UIInterfaceOrientationPortrait;
    }

    ////////////////////////////////////////////////////////////////////////////
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////

/*
 * Implement required and optional protocols.
 */

#pragma mark - PTShowcaseViewDelegate

- (PTItemOrientation)showcaseView:(PTShowcaseView *)showcaseView orientationForItemAtIndex:(NSInteger)index
{
    return [[[[self itemsForUniqueName:showcaseView.uniqueName] objectAtIndex:index]
             objectForKey:@"Orientation"] integerValue];
}

#pragma mark - PTShowcaseViewDataSource

- (NSInteger)numberOfItemsInShowcaseView:(PTShowcaseView *)showcaseView
{
    return [[self itemsForUniqueName:showcaseView.uniqueName] count];
}

- (NSString *)showcaseView:(PTShowcaseView *)showcaseView uniqueNameForItemAtIndex:(NSInteger)index
{
    return [[[self itemsForUniqueName:showcaseView.uniqueName] objectAtIndex:index]
            objectForKey:@"UniqueName"];
}

- (PTContentType)showcaseView:(PTShowcaseView *)showcaseView contentTypeForItemAtIndex:(NSInteger)index
{
    return [[[[self itemsForUniqueName:showcaseView.uniqueName] objectAtIndex:index]
             objectForKey:@"ContentType"] integerValue];
}

- (NSString *)showcaseView:(PTShowcaseView *)showcaseView sourceForItemAtIndex:(NSInteger)index
{
    NSString *source = [[[self itemsForUniqueName:showcaseView.uniqueName] objectAtIndex:index]
                        objectForKey:@"Source"];
    if (source != nil) {
        return NIPathForBundleResource(nil, [NSString stringWithFormat:@"ShowcaseDemo.bundle/%@", source]);
    }

    return nil;
}

////////////////////////////////////////////////////////////////////////////////

@end
