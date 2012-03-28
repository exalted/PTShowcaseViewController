//
// Copyright (C) 2012 Ali Servet Donmez. All rights reserved.
//
// This file is part of PTShowcaseViewController.
// modify it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// PTShowcaseViewController is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PTShowcaseViewController. If not, see <http://www.gnu.org/licenses/>.
// PTShowcaseViewController is free software: you can redistribute it and/or
//

#import "PTDemoViewController.h"

@interface PTDemoViewController ()

@property (nonatomic, readonly) NSArray *demoItems;

- (NSArray *)recursiveSearchForItems:(NSArray *)root forUniqueName:(NSString *)uniqueName;

@end

@implementation PTDemoViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - private

- (NSArray *)recursiveSearchForItems:(NSArray *)root forUniqueName:(NSString *)uniqueName
{
    if (root == nil) {
        return nil;
    }
    
    if (uniqueName == nil) {
        return root;
    }
    
    for (NSDictionary *item in root) {
        if ([[item objectForKey:@"ContentType"] integerValue] == PTContentTypeGroup) {
            if ([uniqueName isEqualToString:[item objectForKey:@"UniqueName"]]) {
                return [item objectForKey:@"Items"];
            }
            
            NSArray *result = [self recursiveSearchForItems:[item objectForKey:@"Items"] forUniqueName:uniqueName];
            if (result) {
                return result;
            }
        }
    }
    
    return nil;
}

- (NSArray *)demoItems
{
    return [[NSDictionary dictionaryWithContentsOfFile:NIPathForBundleResource(nil, @"ShowcaseDemo.plist")]
            objectForKey:@"Root"];
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
    return [[[[self recursiveSearchForItems:self.demoItems forUniqueName:showcaseView.uniqueName] objectAtIndex:index]
             objectForKey:@"Orientation"] integerValue];
}

#pragma mark - PTShowcaseViewDataSource

- (NSInteger)numberOfItemsInShowcaseView:(PTShowcaseView *)showcaseView
{
    return [[self recursiveSearchForItems:self.demoItems forUniqueName:showcaseView.uniqueName] count];
}

- (PTContentType)showcaseView:(PTShowcaseView *)showcaseView contentTypeForItemAtIndex:(NSInteger)index
{
    return [[[[self recursiveSearchForItems:self.demoItems forUniqueName:showcaseView.uniqueName] objectAtIndex:index]
             objectForKey:@"ContentType"] integerValue];
}

- (NSString *)showcaseView:(PTShowcaseView *)showcaseView pathForItemAtIndex:(NSInteger)index
{
    NSString *source = [[[self recursiveSearchForItems:self.demoItems forUniqueName:showcaseView.uniqueName] objectAtIndex:index]
                        objectForKey:@"Source"];
    if (source != nil) {
        return NIPathForBundleResource(nil, [NSString stringWithFormat:@"ShowcaseDemo.bundle/%@", source]);
    }
    
    return nil;
}

- (NSString *)showcaseView:(PTShowcaseView *)showcaseView uniqueNameForItemAtIndex:(NSInteger)index
{
    return [[[self recursiveSearchForItems:self.demoItems forUniqueName:showcaseView.uniqueName] objectAtIndex:index]
            objectForKey:@"UniqueName"];
}

- (NSString *)showcaseView:(PTShowcaseView *)showcaseView sourceForThumbnailImageOfItemAtIndex:(NSInteger)index
{
    NSString *source = [[[self recursiveSearchForItems:self.demoItems forUniqueName:showcaseView.uniqueName] objectAtIndex:index]
                        objectForKey:@"Thumbnail"];
    if (source != nil) {
        return NIPathForBundleResource(nil, [NSString stringWithFormat:@"ShowcaseDemo.bundle/%@", source]);
    }
    
    return nil;
}

- (NSString *)showcaseView:(PTShowcaseView *)showcaseView textForItemAtIndex:(NSInteger)index
{
    return [[[self recursiveSearchForItems:self.demoItems forUniqueName:showcaseView.uniqueName] objectAtIndex:index]
            objectForKey:@"Title"];
}

////////////////////////////////////////////////////////////////////////////////

@end
