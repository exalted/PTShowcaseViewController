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
    // TODO temporary implementation
    // return original sized image's size
    return [[UIImage imageWithContentsOfFile:[self imageAlbumView:imageAlbumView sourceForImageAtIndex:index]] size];
}

- (NSString *)imageAlbumView:(PTImageAlbumView *)imageAlbumView sourceForThumbnailImageAtIndex:(NSInteger)index
{
    // TODO temporary implementation
    // replace with:
    // - create a thumbnail once the original image has been downloaded
    // - return thumbnail's sourcs
    // current:
    // - return original sized image
    return [self imageAlbumView:imageAlbumView sourceForImageAtIndex:index];
}

@end
