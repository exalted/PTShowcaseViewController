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

#import "PTShowcaseViewController.h"

#import "GMGridViewLayoutStrategies.h"

// Detail
#import "PTGroupDetailViewController.h"
#import "PTImageAlbumViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PTShowcaseView () <GMGridViewDataSource>

@end

@interface PTShowcaseViewController () <GMGridViewActionDelegate, PTImageAlbumViewDataSource>

- (void)setupShowcaseViewForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)dismissImageDetailViewController;

@end

@implementation PTShowcaseViewController

@synthesize showcaseView = _showcaseView;
@synthesize hidesBottomBarInDetails = _hidesBottomBarInDetails;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _showcaseView = [[PTShowcaseView alloc] initWithUniqueName:nil];

        _hidesBottomBarInDetails = NO;
    }
    return self;
}

- (id)initWithUniqueName:(NSString *)uniqueName
{
    self = [super init];
    if (self) {
        // Custom initialization
        _showcaseView = [[PTShowcaseView alloc] initWithUniqueName:uniqueName];
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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.showcaseView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.showcaseView.centerGrid = NO;
    [self setupShowcaseViewForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];

    self.view = self.showcaseView;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.showcaseView.showcaseDelegate == nil) {
        self.showcaseView.showcaseDelegate = self;
    }

    if (self.showcaseView.showcaseDataSource == nil) {
        self.showcaseView.showcaseDataSource = self;
    }

    // Internal
    self.showcaseView.dataSource = self.showcaseView; // this will trigger 'reloadData' automatically
    self.showcaseView.actionDelegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.showcaseView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return interfaceOrientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationIsLandscape(interfaceOrientation);
    }
    
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setupShowcaseViewForInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark - Private

- (void)setupShowcaseViewForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.showcaseView.minEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.showcaseView.itemSpacing = 0;
}

- (void)dismissImageDetailViewController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - GMGridViewActionDelegate

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    PTContentType contentType = [self.showcaseView contentTypeForItemAtIndex:position];

    switch (contentType)
    {
        case PTContentTypeGroup:
        {
            NSString *uniqueName = [self.showcaseView uniqueNameForItemAtIndex:position];
            NSString *text = [self.showcaseView textForItemAtIndex:position];

            PTGroupDetailViewController *detailViewController = [[PTGroupDetailViewController alloc] initWithUniqueName:uniqueName];
            detailViewController.showcaseView.showcaseDelegate = self.showcaseView.showcaseDelegate;
            detailViewController.showcaseView.showcaseDataSource = self.showcaseView.showcaseDataSource;
            
            detailViewController.title = text;
            detailViewController.view.backgroundColor = self.view.backgroundColor;

            detailViewController.hidesBottomBarWhenPushed = self.hidesBottomBarInDetails;

            [self.navigationController pushViewController:detailViewController animated:YES];
            
            break;
        }
            
        case PTContentTypeImage:
        {
            NSInteger relativeIndex = [self.showcaseView relativeIndexForItemAtIndex:position withContentType:contentType];

            PTImageAlbumViewController *detailViewController = [[PTImageAlbumViewController alloc] initWithImageAtIndex:relativeIndex];
            detailViewController.imageAlbumView.imageAlbumDataSource = self;

            detailViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            [detailViewController.navigationItem setLeftBarButtonItem:
             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                           target:self
                                                           action:@selector(dismissImageDetailViewController)]];
            
            UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:detailViewController];
            
            // TODO zoom in/out (just like in Photos.app in the iPad)
            [self presentViewController:navCtrl animated:YES completion:NULL];
            
            break;
        }
            
        case PTContentTypeVideo:
        {
            NSString *path = [self.showcaseView pathForItemAtIndex:position];
            NSString *text = [self.showcaseView textForItemAtIndex:position];

            // TODO remove duplicate
            // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            NSURL *url = nil;

            // Check for file URLs.
            if ([path hasPrefix:@"/"]) {
                // If the url starts with / then it's likely a file URL, so treat it accordingly.
                url = [NSURL fileURLWithPath:path];
            }
            else {
                // Otherwise we assume it's a regular URL.
                url = [NSURL URLWithString:path];
            }
            // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

            MPMoviePlayerViewController *detailViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
            detailViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

            detailViewController.title = text;

            // TODO zoom in/out (just like in Photos.app in the iPad)
            [self presentMoviePlayerViewControllerAnimated:detailViewController];
            
            break;
        }
            
        case PTContentTypePdf:
        {
            NSString *path = [self.showcaseView pathForItemAtIndex:position];
            NSString *text = [self.showcaseView textForItemAtIndex:position];

            // TODO remove duplicate
            // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            NSURL *url = nil;
            
            // Check for file URLs.
            if ([path hasPrefix:@"/"]) {
                // If the url starts with / then it's likely a file URL, so treat it accordingly.
                url = [NSURL fileURLWithPath:path];
            }
            else {
                // Otherwise we assume it's a regular URL.
                url = [NSURL URLWithString:path];
            }
            // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            
            PSPDFDocument *document = [PSPDFDocument PDFDocumentWithURL:url];
            document.title = text;

            PSPDFViewController *detailViewController = [[PSPDFViewController alloc] initWithDocument:document];
            detailViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            detailViewController.backgroundColor = self.view.backgroundColor;
            
            UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:detailViewController];

            // TODO zoom in/out (just like in Photos.app in the iPad)
            [self presentViewController:navCtrl animated:YES completion:NULL];
            
            break;
        }
            
        default: NSAssert(NO, @"Unknown content-type.");
    }
}

#pragma mark - PTImageAlbumViewDataSource

- (NSInteger)numberOfImagesInAlbumView:(PTImageAlbumView *)imageAlbumView
{
    return [self.showcaseView.imageItems count];
}

- (NSString *)imageAlbumView:(PTImageAlbumView *)imageAlbumView sourceForImageAtIndex:(NSInteger)index
{
    NSInteger i = [self.showcaseView indexForItemAtRelativeIndex:index withContentType:PTContentTypeImage];
    return [self.showcaseView pathForItemAtIndex:i];
}

- (NSString *)imageAlbumView:(PTImageAlbumView *)imageAlbumView sourceForThumbnailImageAtIndex:(NSInteger)index
{
    NSInteger i = [self.showcaseView indexForItemAtRelativeIndex:index withContentType:PTContentTypeImage];
    return [self.showcaseView sourceForThumbnailImageOfItemAtIndex:i];
}

- (NSString *)imageAlbumView:(PTImageAlbumView *)imageAlbumView captionForImageAtIndex:(NSInteger)index
{
    NSInteger i = [self.showcaseView indexForItemAtRelativeIndex:index withContentType:PTContentTypeImage];
    return [self.showcaseView detailTextForItemAtIndex:i];
}

#pragma mark - PTShowcaseViewDataSource

- (NSInteger)numberOfItemsInShowcaseView:(PTShowcaseView *)showcaseView
{
    NSAssert(NO, @"missing required method implementation 'numberOfItemsInShowcaseView:'");
    abort();
}

- (PTContentType)showcaseView:(PTShowcaseView *)showcaseView contentTypeForItemAtIndex:(NSInteger)index
{
    NSAssert(NO, @"missing required method implementation 'showcaseView:contentTypeForItemAtIndex:'");
    abort();
}

- (NSString *)showcaseView:(PTShowcaseView *)showcaseView pathForItemAtIndex:(NSInteger)index
{
    NSAssert(NO, @"missing required method implementation 'showcaseView:pathForItemAtIndex:'");
    abort();
}

@end
