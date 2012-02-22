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

#import "PTShowcaseView.h"
#import "PTImageDetailViewController.h"

#define PREVIEW_SIZE_PHONE   CGSizeMake(75.0, 75.0)
#define PREVIEW_SIZE_PAD     CGSizeMake(120.0, 180.0)

@interface PTShowcaseViewController () <GMGridViewDataSource, GMGridViewActionDelegate, NINetworkImageViewDelegate>

- (void)setupShowcaseViewForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

// Supported cells for content types
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForContentType:(PTContentType)contentType withOrientation:(PTItemOrientation)orientation;
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView setCellWithOrientation:(PTItemOrientation)orientation;
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
        _showcaseView = [[PTShowcaseView alloc] init];
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
    [self setupShowcaseViewForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];

    self.view = self.showcaseView;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.showcaseView.showcaseDelegate = self;
    self.showcaseView.showcaseDataSource = self;
    
    // Internal
    self.showcaseView.dataSource = self;
    self.showcaseView.actionDelegate = self;
    
    [self.showcaseView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.showcaseView = nil;
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
        case PTContentTypeSet:
        {
            return [self GMGridView:gridView setCellWithOrientation:orientation];
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

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView setCellWithOrientation:(PTItemOrientation)orientation;
{
    NSString *cellIdentifier = orientation == PTItemOrientationPortrait ? @"SetPortraitCell" : @"SetLandscapeCell";

    GMGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[GMGridViewCell alloc] init];
        cell.reuseIdentifier = cellIdentifier;
        
        // Back Image
        
        NSString *backImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"item-set",
                                   orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
        CGRect backImageViewFrame = orientation == PTItemOrientationPortrait
        ? CGRectMake(-16.5, -15.0, 154.0, 158.0)
        : CGRectMake(-18.5, -15.0, 155.0, 158.0);
        
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewFrame];
        backImageView.image = [UIImage imageNamed:backImageName];
        [cell addSubview:backImageView];
        
        // Thumbnail
        
        NSString *loadingImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"item-set-loading",
                                      orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
        CGRect loadingImageViewFrame = orientation == PTItemOrientationPortrait
        ? CGRectMake(15.0, 0.0, 90.0, 120.0)
        : CGRectMake(0.0, 15.0, 120.0, 90.0);
        
        NINetworkImageView *thumbnailView = [[NINetworkImageView alloc] initWithFrame:loadingImageViewFrame];
        thumbnailView.tag = THUMBNAIL_TAG;
        thumbnailView.initialImage = [UIImage imageNamed:loadingImageName];
        [cell addSubview:thumbnailView];
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
    
    return cell;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView videoCellWithOrientation:(PTItemOrientation)orientation;
{
    static NSString *CellIdentifier = @"VideoCell";

    GMGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GMGridViewCell alloc] init];
        cell.reuseIdentifier = CellIdentifier;
        
        // Blank White View
        
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(20.0, 35.0, 80.0, 50.0)];
        whiteView.backgroundColor = [UIColor whiteColor];
        [cell addSubview:whiteView];
        
        // Thumbnail
        
        NSString *loadingImageName = @"PTShowcase.bundle/video-loading.png";
        CGRect loadingImageViewFrame = CGRectMake(0.0, 15.0, 120.0, 90.0);
        
        // TODO remove duplicate: 'networkImageView:didLoadImage:'
        CGImageRef maskImageRef = [[UIImage imageNamed:@"PTShowcase.bundle/video-mask.png"] CGImage];
        CGImageRef maskRef = CGImageMaskCreate(CGImageGetWidth(maskImageRef),
                                               CGImageGetHeight(maskImageRef),
                                               CGImageGetBitsPerComponent(maskImageRef),
                                               CGImageGetBitsPerPixel(maskImageRef),
                                               CGImageGetBytesPerRow(maskImageRef),
                                               CGImageGetDataProvider(maskImageRef),
                                               NULL,
                                               NO);
        CGImageRef maskedImageRef = CGImageCreateWithMask([[UIImage imageNamed:loadingImageName] CGImage], maskRef);
        CGImageRelease(maskRef);
        
        UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
        CGImageRelease(maskedImageRef);
        
        NINetworkImageView *thumbnailView = [[NINetworkImageView alloc] initWithFrame:loadingImageViewFrame];
        thumbnailView.tag = THUMBNAIL_TAG;
        thumbnailView.delegate = self;
        thumbnailView.initialImage = maskedImage;
        [cell addSubview:thumbnailView];
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
        
        NSString *loadingImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"document-pages-loading",
                                      orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
        CGRect loadingImageViewFrame = orientation == PTItemOrientationPortrait
        ? CGRectMake(15.0, 0.0, 90.0, 120.0)
        : CGRectMake(0.0, 15.0, 120.0, 90.0);
        
        NINetworkImageView *thumbnailView = [[NINetworkImageView alloc] initWithFrame:loadingImageViewFrame];
        thumbnailView.tag = THUMBNAIL_TAG;
        thumbnailView.initialImage = [UIImage imageNamed:loadingImageName];
        [cell addSubview:thumbnailView];
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
        case PTContentTypeSet:
        {
            // TODO missing implementation
            [thumbnailView setPathToNetworkImage:source];
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
            [thumbnailView setPathToNetworkImage:source];
            break;
        }
            
        case PTContentTypePdf:
        {
            // TODO missing implementation
            [thumbnailView setPathToNetworkImage:source];
            break;
        }
            
        default: NSAssert(NO, @"Unknown content-type.");
    }
}

#pragma mark - GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [self.showcaseView numberOfImages];
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
    PTContentType contentType = [self.showcaseView contentTypeForImageAtIndex:index];
    PTItemOrientation orientation = [self.showcaseView orientationForImageAtIndex:index];
    NSString *source = [self.showcaseView sourceForImageAtIndex:index];

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
    PTContentType contentType = [self.showcaseView contentTypeForImageAtIndex:position];

    switch (contentType)
    {
        case PTContentTypeSet:
        {
            // TODO missing implementation
            break;
        }
            
        case PTContentTypeImage:
        {
            PTImageDetailViewController *detailViewController = [[PTImageDetailViewController alloc] init];
            detailViewController.images = self.showcaseView.imageItems;
            
            // TODO fade in/out (just like in Photos.app in the iPad) instead of a simple push
            [self.navigationController pushViewController:detailViewController animated:YES];

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

#pragma mark - NINetworkImageViewDelegate

- (void)networkImageView:(NINetworkImageView *)imageView didLoadImage:(UIImage *)image
{
    CGImageRef maskImageRef = [[UIImage imageNamed:@"PTShowcase.bundle/video-mask.png"] CGImage];
    CGImageRef maskRef = CGImageMaskCreate(CGImageGetWidth(maskImageRef),
                                           CGImageGetHeight(maskImageRef),
                                           CGImageGetBitsPerComponent(maskImageRef),
                                           CGImageGetBitsPerPixel(maskImageRef),
                                           CGImageGetBytesPerRow(maskImageRef),
                                           CGImageGetDataProvider(maskImageRef),
                                           NULL,
                                           NO);
    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], maskRef);
    CGImageRelease(maskRef);
    
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    CGImageRelease(maskedImageRef);
    
    imageView.image = maskedImage;
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
