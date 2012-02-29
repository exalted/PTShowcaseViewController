//
//  PTShowcaseViewController.m
//  ShowcaseDemo
//
//  Created by Ali Servet Donmez on 10.2.12.
//  Copyright (c) 2012 Apex-net srl. All rights reserved.
//

#import "PTShowcaseViewController.h"

#import "GMGridView.h"
#import "GMGridViewLayoutStrategies.h"

// Thumbnail
#import "PTVideoThumbnailImageView.h"
#import "PTPdfThumbnailImageView.h"

// Detail
#import "PTGroupDetailViewController.h"
#import "PTImageDetailViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#define PREVIEW_SIZE_PHONE   CGSizeMake(75.0, 100.0)
#define PREVIEW_SIZE_PAD     CGSizeMake(120.0, 180.0)

@interface PTShowcaseViewController () <GMGridViewDataSource, GMGridViewActionDelegate>

- (void)setupShowcaseViewForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

// Supported cells for content types
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForContentType:(PTContentType)contentType withOrientation:(PTItemOrientation)orientation;
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView groupCellWithOrientation:(PTItemOrientation)orientation;
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView imageCellWithOrientation:(PTItemOrientation)orientation;
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView videoCellWithOrientation:(PTItemOrientation)orientation;
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView pdfCellWithOrientation:(PTItemOrientation)orientation;

// Methods generating thumbnails for content types
- (void)thumbnailView:(NINetworkImageView *)thumbnailView createImageForContentType:(PTContentType)contentType withSource:(NSString *)source;

@end

@implementation PTShowcaseViewController

@synthesize showcaseView = _showcaseView;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _showcaseView = [[PTShowcaseView alloc] initWithUniqueName:nil];
        _showcaseView.showcaseDelegate = self;
        _showcaseView.showcaseDataSource = self;
    }
    return self;
}

- (id)initWithUniqueName:(NSString *)uniqueName
{
    self = [super init];
    if (self) {
        // Custom initialization
        _showcaseView = [[PTShowcaseView alloc] initWithUniqueName:uniqueName];
        _showcaseView.showcaseDelegate = self;
        _showcaseView.showcaseDataSource = self;
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

    // Internal
    self.showcaseView.dataSource = self; // this will trigger 'reloadData' automatically
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
    // TODO these pre-calculated values *will* cause trouble at some point
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            self.showcaseView.minEdgeInsets = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);
            self.showcaseView.itemSpacing = 4;
        }
        else {
            self.showcaseView.minEdgeInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
            self.showcaseView.itemSpacing = 4;
        }
    }
    else {
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            self.showcaseView.minEdgeInsets = UIEdgeInsetsMake(28.0, 28.0, 0.0, 0.0);
            self.showcaseView.itemSpacing = 28;
        }
        else {
            self.showcaseView.minEdgeInsets = UIEdgeInsetsMake(23.0, 23.0, 0.0, 0.0);
            self.showcaseView.itemSpacing = 23;
        }
    }
}

/* =============================================================================
 * Supported cells for content types
 * =============================================================================
 */
#define THUMBNAIL_TAG 1

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForContentType:(PTContentType)contentType withOrientation:(PTItemOrientation)orientation
{
    switch (contentType)
    {
        case PTContentTypeGroup:
        {
            return [self GMGridView:gridView groupCellWithOrientation:orientation];
        }
            
        case PTContentTypeImage:
        {
            return [self GMGridView:gridView imageCellWithOrientation:orientation];
        }
            
        case PTContentTypeVideo:
        {
            return [self GMGridView:gridView videoCellWithOrientation:orientation];
        }
            
        case PTContentTypePdf:
        {
            return [self GMGridView:gridView pdfCellWithOrientation:orientation];
        }
            
        default: NSAssert(NO, @"Unknown content-type.");
    }
    
    return nil;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView groupCellWithOrientation:(PTItemOrientation)orientation;
{
    NSString *cellIdentifier = orientation == PTItemOrientationPortrait ? @"GroupPortraitCell" : @"GroupLandscapeCell";

    GMGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[GMGridViewCell alloc] init];
        cell.reuseIdentifier = cellIdentifier;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            // Placeholder
            
            NSString *placeholderImageName = @"PTShowcase.bundle/group.png";
            CGRect placeholderImageNameImageViewFrame = CGRectMake(0.0, 0.0, 75.0, 75.0);
            
            UIImageView *placeholderImageView = [[UIImageView alloc] initWithFrame:placeholderImageNameImageViewFrame];
            placeholderImageView.image = [UIImage imageNamed:placeholderImageName];
            [cell addSubview:placeholderImageView];
        }
        else {
            // Back Image
            
            NSString *backImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"group",
                                       orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
            CGRect backImageViewFrame = orientation == PTItemOrientationPortrait
            ? CGRectMake(-16.5, -15.0, 154.0, 158.0)
            : CGRectMake(-18.5, -15.0, 155.0, 158.0);
            
            UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewFrame];
            backImageView.image = [UIImage imageNamed:backImageName];
            [cell addSubview:backImageView];
            
            // Thumbnail
            
            NSString *loadingImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"group-loading",
                                          orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
            CGRect loadingImageViewFrame = orientation == PTItemOrientationPortrait
            ? CGRectMake(15.0, 0.0, 90.0, 120.0)
            : CGRectMake(0.0, 15.0, 120.0, 90.0);
            
            NINetworkImageView *thumbnailView = [[NINetworkImageView alloc] initWithFrame:loadingImageViewFrame];
            thumbnailView.tag = THUMBNAIL_TAG;
            thumbnailView.initialImage = [UIImage imageNamed:loadingImageName];
            [cell addSubview:thumbnailView];
        }
    }
    
    return cell;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView imageCellWithOrientation:(PTItemOrientation)orientation;
{
    NSString *cellIdentifier = orientation == PTItemOrientationPortrait ? @"ImagePortraitCell" : @"ImageLandscapeCell";

    GMGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[GMGridViewCell alloc] init];
        cell.reuseIdentifier = cellIdentifier;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            // Thumbnail
            
            NSString *loadingImageName = @"PTShowcase.bundle/image-loading.png";
            CGRect loadingImageViewFrame = CGRectMake(0.0, 0.0, 75.0, 75.0);
            
            NINetworkImageView *thumbnailView = [[NINetworkImageView alloc] initWithFrame:loadingImageViewFrame];
            thumbnailView.tag = THUMBNAIL_TAG;
            thumbnailView.initialImage = [UIImage imageNamed:loadingImageName];
            [cell addSubview:thumbnailView];
            
            // Overlap
            
            UIImageView *overlapView = [[UIImageView alloc] initWithFrame:loadingImageViewFrame];
            overlapView.image = [UIImage imageNamed:@"PTShowcase.bundle/image-overlap.png"];
            [cell addSubview:overlapView];
        }
        else {
            // Back Image
            
            NSString *backImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"image-frame",
                                       orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
            CGRect backImageViewFrame = orientation == PTItemOrientationPortrait
            ? CGRectMake(8.5, -4.5, 103.0, 137.0)
            : CGRectMake(-6.5, 11.0, 133.0, 107.0);
            
            UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewFrame];
            backImageView.image = [UIImage imageNamed:backImageName];
            [cell addSubview:backImageView];
            
            // Thumbnail
            
            NSString *loadingImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"image-loading",
                                          orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
            CGRect loadingImageViewFrame = orientation == PTItemOrientationPortrait
            ? CGRectMake(15.0, 0.0, 90.0, 120.0)
            : CGRectMake(0.0, 15.0, 120.0, 90.0);
            
            NINetworkImageView *thumbnailView = [[NINetworkImageView alloc] initWithFrame:loadingImageViewFrame];
            thumbnailView.tag = THUMBNAIL_TAG;
            thumbnailView.initialImage = [UIImage imageNamed:loadingImageName];
            [cell addSubview:thumbnailView];
        }
    }
    
    return cell;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView videoCellWithOrientation:(PTItemOrientation)orientation;
{
    static NSString *CellIdentifier = @"VideoCell";

    GMGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GMGridViewCell alloc] init];
        cell.reuseIdentifier = CellIdentifier;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            // Thumbnail
            
            NSString *loadingImageName = @"PTShowcase.bundle/video-loading.png";
            CGRect loadingImageViewFrame = CGRectMake(0.0, 0.0, 75.0, 75.0);
            UIImage *maskedImage = [PTVideoThumbnailImageView applyMask:[UIImage imageNamed:loadingImageName]];
            
            PTVideoThumbnailImageView *thumbnailView = [[PTVideoThumbnailImageView alloc] initWithFrame:loadingImageViewFrame];
            thumbnailView.tag = THUMBNAIL_TAG;
            thumbnailView.initialImage = maskedImage;
            [cell addSubview:thumbnailView];
            
            // Overlap
            
            UIImageView *overlapView = [[UIImageView alloc] initWithFrame:loadingImageViewFrame];
            overlapView.image = [UIImage imageNamed:@"PTShowcase.bundle/video-overlap.png"];
            [cell addSubview:overlapView];
        }
        else {
            // Thumbnail
            
            NSString *loadingImageName = @"PTShowcase.bundle/video-loading.png";
            CGRect loadingImageViewFrame = CGRectMake(0.0, 15.0, 120.0, 90.0);
            UIImage *maskedImage = [PTVideoThumbnailImageView applyMask:[UIImage imageNamed:loadingImageName]];
            
            PTVideoThumbnailImageView *thumbnailView = [[PTVideoThumbnailImageView alloc] initWithFrame:loadingImageViewFrame];
            thumbnailView.tag = THUMBNAIL_TAG;
            thumbnailView.initialImage = maskedImage;
            [cell addSubview:thumbnailView];
            
            // Overlap
            
            UIImageView *overlapView = [[UIImageView alloc] initWithFrame:loadingImageViewFrame];
            overlapView.image = [UIImage imageNamed:@"PTShowcase.bundle/video-overlap.png"];
            [cell addSubview:overlapView];
        }
    }
    
    return cell;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView pdfCellWithOrientation:(PTItemOrientation)orientation;
{
    NSString *cellIdentifier = orientation == PTItemOrientationPortrait ? @"PdfPortraitCell" : @"PdfLandscapeCell";

    GMGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[GMGridViewCell alloc] init];
        cell.reuseIdentifier = cellIdentifier;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            // Thumbnail
            
            NSString *loadingImageName = @"PTShowcase.bundle/document-loading.png";
            CGRect loadingImageViewFrame = CGRectMake(0.0, 0.0, 75.0, 75.0);
            UIImage *maskedImage = [PTPdfThumbnailImageView applyMask:[UIImage imageNamed:loadingImageName]];
            
            PTPdfThumbnailImageView *thumbnailView = [[PTPdfThumbnailImageView alloc] initWithFrame:loadingImageViewFrame];
            thumbnailView.tag = THUMBNAIL_TAG;
            thumbnailView.initialImage = maskedImage;
            [cell addSubview:thumbnailView];
            
            // Overlap
            
            UIImageView *overlapView = [[UIImageView alloc] initWithFrame:loadingImageViewFrame];
            overlapView.image = [UIImage imageNamed:@"PTShowcase.bundle/document-overlap.png"];
            [cell addSubview:overlapView];
        }
        else {
            // Back Image
            
            NSString *backImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"document-pages",
                                       orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
            CGRect backImageViewFrame = orientation == PTItemOrientationPortrait
            ? CGRectMake(4.0, -11.0, 116.0, 146.0)
            : CGRectMake(-26.0, -11.0, 176.0, 146.0);
            
            UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewFrame];
            backImageView.image = [UIImage imageNamed:backImageName];
            [cell addSubview:backImageView];
            
            // Thumbnail
            
            NSString *loadingImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"document-loading",
                                          orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
            CGRect loadingImageViewFrame = orientation == PTItemOrientationPortrait
            ? CGRectMake(15.0, 0.0, 90.0, 120.0)
            : CGRectMake(0.0, 15.0, 120.0, 90.0);
            
            NINetworkImageView *thumbnailView = [[NINetworkImageView alloc] initWithFrame:loadingImageViewFrame];
            thumbnailView.tag = THUMBNAIL_TAG;
            thumbnailView.initialImage = [UIImage imageNamed:loadingImageName];
            [cell addSubview:thumbnailView];
        }
    }
    
    return cell;
}

/* =============================================================================
 * Methods generating thumbnails for content types
 * =============================================================================
 */
- (void)thumbnailView:(NINetworkImageView *)thumbnailView createImageForContentType:(PTContentType)contentType withSource:(NSString *)source
{
    thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    
    switch (contentType)
    {
        case PTContentTypeGroup:
        {
            // TODO missing implementation
            break;
        }
            
        case PTContentTypeImage:
        {
            // TODO missing implementation
            [thumbnailView setPathToNetworkImage:source];
            break;
        }
            
        case PTContentTypeVideo:
        {
            // TODO missing implementation
            break;
        }
            
        case PTContentTypePdf:
        {
            // TODO missing implementation
            break;
        }
            
        default: NSAssert(NO, @"Unknown content-type.");
    }
}

#pragma mark - GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [self.showcaseView numberOfItems];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return PREVIEW_SIZE_PHONE;
    }

    return PREVIEW_SIZE_PAD;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    PTContentType contentType = [self.showcaseView contentTypeForItemAtIndex:index];
    PTItemOrientation orientation = [self.showcaseView orientationForItemAtIndex:index];
    NSString *source = [self.showcaseView sourceForItemAtIndex:index];

    // Generate a cell
    GMGridViewCell *cell = [self GMGridView:gridView cellForContentType:contentType withOrientation:orientation];

    // Configure the cell...
    [self thumbnailView:(NINetworkImageView *)[cell viewWithTag:THUMBNAIL_TAG] createImageForContentType:contentType withSource:source];
    
//    cell.backgroundColor = [UIColor greenColor];
    
    return cell;
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
            
            PTGroupDetailViewController *detailViewController = [[PTGroupDetailViewController alloc] initWithUniqueName:uniqueName];
            detailViewController.showcaseView.showcaseDelegate = self.showcaseView.showcaseDelegate;
            detailViewController.showcaseView.showcaseDataSource = self.showcaseView.showcaseDataSource;
            
            detailViewController.view.backgroundColor = self.view.backgroundColor;

            [self.navigationController pushViewController:detailViewController animated:YES];
            
            break;
        }
            
        case PTContentTypeImage:
        {
            PTImageDetailViewController *detailViewController = [[PTImageDetailViewController alloc] init];
            detailViewController.images = self.showcaseView.imageItems;
            detailViewController.hidesBottomBarWhenPushed = YES;
            
            // TODO zoom in/out (just like in Photos.app in the iPad)
            [self.navigationController pushViewController:detailViewController animated:NO];

            break;
        }
            
        case PTContentTypeVideo:
        {
            NSString *source = [self.showcaseView sourceForItemAtIndex:position];
            
            // TODO remove duplicate code >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            NSURL *url = nil;

            // Check for file URLs.
            if ([source hasPrefix:@"/"]) {
                // If the url starts with / then it's likely a file URL, so treat it accordingly.
                url = [NSURL fileURLWithPath:source];
            }
            else {
                // Otherwise we assume it's a regular URL.
                url = [NSURL URLWithString:source];
            }
            // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

            MPMoviePlayerViewController *detailViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];

            // TODO zoom in/out (just like in Photos.app in the iPad)
            [self presentViewController:detailViewController animated:NO completion:NULL];
            
            break;
        }
            
        case PTContentTypePdf:
        {
            // TODO missing implementation
            break;
        }
            
        default: NSAssert(NO, @"Unknown content-type.");
    }
}

#pragma mark - PTShowcaseViewDelegate

- (PTItemOrientation)showcaseView:(PTShowcaseView *)showcaseView orientationForItemAtIndex:(NSInteger)index
{
    return PTItemOrientationLandscape;
}

#pragma mark - PTShowcaseViewDataSource

- (NSInteger)numberOfItemsInShowcaseView:(PTShowcaseView *)showcaseView
{
    NSAssert(NO, @"missing required method implementation 'numberOfItemsInShowcaseView:'");
    return -1;
}

- (NSString *)showcaseView:(PTShowcaseView *)showcaseView uniqueNameForItemAtIndex:(NSInteger)index;
{
    return nil;
}

- (PTContentType)showcaseView:(PTShowcaseView *)showcaseView contentTypeForItemAtIndex:(NSInteger)index
{
    NSAssert(NO, @"missing required method implementation 'showcaseView:contentTypeForItemAtIndex:'");
    return -1;
}

- (NSString *)showcaseView:(PTShowcaseView *)showcaseView sourceForItemAtIndex:(NSInteger)index
{
    NSAssert(NO, @"missing required method implementation 'showcaseView:sourceForItemAtIndex:'");
    return nil;
}

@end
