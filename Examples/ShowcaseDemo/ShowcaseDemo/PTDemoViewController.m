//
// Copyright (C) 2012 Ali Servet Donmez. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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

- (NSString *)showcaseView:(PTShowcaseView *)showcaseView detailTextForItemAtIndex:(NSInteger)index
{
    return [[[self recursiveSearchForItems:self.demoItems forUniqueName:showcaseView.uniqueName] objectAtIndex:index]
            objectForKey:@"Description"];
}

////////////////////////////////////////////////////////////////////////////////

@end
