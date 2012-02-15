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

// TODO remove unnecessary import statement
#import <QuartzCore/QuartzCore.h>

#define PREVIEW_SIZE_PHONE   CGSizeMake(75.0, 75.0)
#define PREVIEW_SIZE_PAD     CGSizeMake(120.0, 180.0)

@interface PTShowcaseViewController () <GMGridViewDataSource>

- (void)setupShowcaseViewForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView setCellWithImage:(UIImage *)image inOrientation:(PTItemOrientation)orientation;
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView imageCellWithImage:(UIImage *)image inOrientation:(PTItemOrientation)orientation;
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView videoCellWithImage:(UIImage *)image;
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView pdfCellWithImage:(UIImage *)image inOrientation:(PTItemOrientation)orientation;

@end

@implementation PTShowcaseViewController

@synthesize showcaseView = _showcaseView;

- (id)init
{
    self = [super init];
    if (self != nil) {
        // Custom initialization
        _showcaseView = [[PTShowcaseView alloc] init];
        _showcaseView.showcaseDelegate = self;
        _showcaseView.showcaseDataSource = self;

        _showcaseView.dataSource = self;
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView setCellWithImage:(UIImage *)image inOrientation:(PTItemOrientation)orientation;
{
    NSString *cellIdentifier = orientation == PTItemOrientationPortrait ? @"SetPortraitCell" : @"SetLandscapeCell";

    GMGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[GMGridViewCell alloc] init];
        cell.reuseIdentifier = cellIdentifier;
        
        NSString *imageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png",
                               @"item-set",
                               orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
        
        CGRect imageViewFrame = orientation == PTItemOrientationPortrait
        ? CGRectMake(-16.5, -15.0, 154.0, 158.0)
        : CGRectMake(-18.5, -15.0, 155.0, 158.0);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        imageView.image = [UIImage imageNamed:imageName];
        [cell addSubview:imageView];
        
        // TODO missing implementation
        UIView *foo = [[UIView alloc] initWithFrame:orientation == PTItemOrientationPortrait ? CGRectMake(15.0, 0.0, 90.0, 120.0) : CGRectMake(0.0, 15.0, 120.0, 90.0)];
        foo.backgroundColor = [UIColor lightGrayColor];
        [cell addSubview:foo];
    }
    
    // Configure the cell...
    
    return cell;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView imageCellWithImage:(UIImage *)image inOrientation:(PTItemOrientation)orientation;
{
    NSString *cellIdentifier = orientation == PTItemOrientationPortrait ? @"ImagePortraitCell" : @"ImageLandscapeCell";

    GMGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[GMGridViewCell alloc] init];
        cell.reuseIdentifier = cellIdentifier;
        
        NSString *imageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png",
                               @"image-frame",
                               orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
        
        CGRect imageViewFrame = orientation == PTItemOrientationPortrait
        ? CGRectMake(8.5, -4.5, 103.0, 137.0)
        : CGRectMake(-6.5, 11.0, 133.0, 107.0);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        imageView.image = [UIImage imageNamed:imageName];
        [cell addSubview:imageView];
        
        // TODO missing implementation
        UIView *foo = [[UIView alloc] initWithFrame:orientation == PTItemOrientationPortrait ? CGRectMake(15.0, 0.0, 90.0, 120.0) : CGRectMake(0.0, 15.0, 120.0, 90.0)];
        foo.backgroundColor = [UIColor lightGrayColor];
        [cell addSubview:foo];
    }
    
    // Configure the cell...
    
    return cell;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView videoCellWithImage:(UIImage *)image;
{
    static NSString *CellIdentifier = @"VideoCell";

    GMGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GMGridViewCell alloc] init];
        cell.reuseIdentifier = CellIdentifier;

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

        CGRect imageViewFrame = CGRectMake(0.0, 15.0, 120.0, 90.0);
        
        UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(20.0, 35.0, 80.0, 50.0)];
        blankView.backgroundColor = [UIColor whiteColor];
        [cell addSubview:blankView];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        imageView.image = maskedImage;
        [cell addSubview:imageView];
    }
    
    // Configure the cell...
    
    return cell;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView pdfCellWithImage:(UIImage *)image inOrientation:(PTItemOrientation)orientation;
{
    NSString *cellIdentifier = orientation == PTItemOrientationPortrait ? @"PdfPortraitCell" : @"PdfLandscapeCell";

    GMGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[GMGridViewCell alloc] init];
        cell.reuseIdentifier = cellIdentifier;
        
        NSString *imageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png",
                               @"document-pages",
                               orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
        
        CGRect imageViewFrame = orientation == PTItemOrientationPortrait
        ? CGRectMake(4.0, -11.0, 116.0, 146.0)
        : CGRectMake(-26.0, -11.0, 176.0, 146.0);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        imageView.image = [UIImage imageNamed:imageName];
        [cell addSubview:imageView];
        
        // TODO missing implementation
        UIView *foo = [[UIView alloc] initWithFrame:orientation == PTItemOrientationPortrait ? CGRectMake(15.0, 0.0, 90.0, 120.0) : CGRectMake(0.0, 15.0, 120.0, 90.0)];
        foo.backgroundColor = [UIColor lightGrayColor];
        [cell addSubview:foo];
    }
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [self.showcaseView.showcaseDataSource numberOfItemsInShowcaseView:self.showcaseView];
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
    PTContentType contentType = [self.showcaseView.showcaseDataSource showcaseView:self.showcaseView contentTypeForItemAtIndex:index];
    PTItemOrientation orientation = [self.showcaseView.showcaseDelegate showcaseView:self.showcaseView orientationForItemAtIndex:index];
    
    GMGridViewCell *cell = nil;
    switch (contentType)
    {
        case PTContentTypeSet:
        {
            // TODO missing implementation 'image = nil'
            cell = [self GMGridView:gridView setCellWithImage:nil inOrientation:orientation];
            break;
        }
            
        case PTContentTypeImage:
        {
            // TODO missing implementation 'image = nil'
            cell = [self GMGridView:gridView imageCellWithImage:nil inOrientation:orientation];
            break;
        }
            
        case PTContentTypeVideo:
        {
            // TODO missing implementation 'image = nil'
            
            UIView *foo = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 120.0, 90.0)];
            foo.backgroundColor = [UIColor lightGrayColor];
            
            UIGraphicsBeginImageContext(foo.bounds.size);
            [foo.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *fooImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            cell = [self GMGridView:gridView videoCellWithImage:fooImage];
            break;
        }
            
        case PTContentTypePdf:
        {
            // TODO missing implementation 'image = nil'
            cell = [self GMGridView:gridView pdfCellWithImage:nil inOrientation:orientation];
            break;
        }
            
        default: NSAssert(NO, @"Unknown content-type.");
    }
    
    // Configure the cell...
    
//    cell.backgroundColor = [UIColor greenColor];
    
    return cell;
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

@end
