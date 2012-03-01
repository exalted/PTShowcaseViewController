//
//  PTImageDetailViewController.m
//  ShowcaseDemo
//
//  Created by Ali Servet Donmez on 17.2.12.
//  Copyright (c) 2012 Apex-net srl. All rights reserved.
//

#import "PTImageDetailViewController.h"

@implementation PTImageDetailViewController

@synthesize images = _images;

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
    
    self.images = nil;
}

#pragma mark - PTImageAlbumViewDataSource

- (NSInteger)numberOfImagesInAlbumView:(PTImageAlbumView *)imageAlbumView
{
    return [self.images count];
}

- (NSString *)imageAlbumView:(PTImageAlbumView *)imageAlbumView sourceForImageAtIndex:(NSInteger)index
{
    return [[self.images objectAtIndex:index] objectForKey:@"source"];
}

- (CGSize)imageAlbumView:(PTImageAlbumView *)imageAlbumView sizeForImageAtIndex:(NSInteger)index
{
    // TODO missing implementation
    // ...
    
    // TODO temporary implementation
    // return original sized image's size
    return [[UIImage imageWithContentsOfFile:[self imageAlbumView:imageAlbumView sourceForImageAtIndex:index]] size];
}

- (NSString *)imageAlbumView:(PTImageAlbumView *)imageAlbumView sourceForThumbnailImageAtIndex:(NSInteger)index
{
    // TODO missing implementation
    // - create a thumbnail once the original image has been downloaded
    // - return thumbnail's sourcs
    
    // TODO temporary implementation
    // return original sized image
    return [self imageAlbumView:imageAlbumView sourceForImageAtIndex:index];
}

@end
