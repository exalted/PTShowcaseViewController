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

#import "PTShowcaseView.h"

#import <ImageIO/ImageIO.h>

#import "GMGridView.h"
#import "NINetworkImageView.h"

typedef enum {
    PTShowcaseTagThumbnail  = 10,
    PTShowcaseTagText       = 20,
    PTShowcaseTagDetailText = 30,
} PTShowcaseTag;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private APIs
////////////////////////////////////////////////////////////////////////////////
@interface PTShowcaseView () <GMGridViewDataSource> {
    NSArray *_imageItems; // ivar used in custom setter method
    NSArray *_itemUIProperties;
}

@property (retain, nonatomic, readwrite) NSString *uniqueName;

@property (retain, nonatomic, readwrite) NSArray *imageItems;

@property (retain, nonatomic) NSMutableArray *cachedData;

@property (retain, nonatomic, readonly) NSArray *itemUIProperties;

// Supported cells for content types
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView reusableCellForContentType:(PTContentType)contentType withOrientation:(PTItemOrientation)orientation;

- (GMGridViewCell *)reusableGroupCellWithReuseIdentifier:(NSString *)identifier forOrientation:(PTItemOrientation)orientation;
- (GMGridViewCell *)reusableImageCellWithReuseIdentifier:(NSString *)identifier forOrientation:(PTItemOrientation)orientation;
- (GMGridViewCell *)reusableVideoCellWithReuseIdentifier:(NSString *)identifier forOrientation:(PTItemOrientation)orientation;
- (GMGridViewCell *)reusablePdfCellWithReuseIdentifier:(NSString *)identifier forOrientation:(PTItemOrientation)orientation;

@end

#pragma mark - Video thumbnail

@interface PTVideoThumbnailImageView : NINetworkImageView

@property (assign, nonatomic) PTItemOrientation orientation;

+ (UIImage *)applyMask:(UIImage *)image forOrientation:(PTItemOrientation)orientation;

@end

@implementation PTVideoThumbnailImageView

+ (UIImage *)applyMask:(UIImage *)image forOrientation:(PTItemOrientation)orientation
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

    return maskedImage;
}

- (void)networkImageViewDidLoadImage:(UIImage *)image {
    self.image = [PTVideoThumbnailImageView applyMask:image forOrientation:self.orientation];
}

@end

#pragma mark - Pdf thumbnail

@interface PTPdfThumbnailImageView : NINetworkImageView

@property (assign, nonatomic) PTItemOrientation orientation;

+ (UIImage *)applyMask:(UIImage *)image forOrientation:(PTItemOrientation)orientation;

@end

@implementation PTPdfThumbnailImageView

+ (UIImage *)applyMask:(UIImage *)image forOrientation:(PTItemOrientation)orientation
{
    CGImageRef maskImageRef = [[UIImage imageNamed:@"PTShowcase.bundle/document-mask.png"] CGImage];
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

    return maskedImage;
}

- (void)networkImageViewDidLoadImage:(UIImage *)image {
    self.image = [PTPdfThumbnailImageView applyMask:image forOrientation:self.orientation];
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class implementation
////////////////////////////////////////////////////////////////////////////////
@implementation PTShowcaseView

#pragma mark Initializing

- (id)initWithUniqueName:(NSString *)uniqueName
{
    self = [super init];
    if (self) {
        self.uniqueName = uniqueName;

        self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        self.centerGrid = NO;
        self.minEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.itemSpacing = 0;
    }
    return self;
}

#pragma mark Instance properties

// TODO replace with much better 'imageItemsForContentType:'
- (NSArray *)imageItems
{
    if (_imageItems == nil) {
        // ask data source for all items that are not cached yet
        NSInteger numberOfItems = [self numberOfItems];
        for (int i = 0; i < numberOfItems; i++) {
            [self contentTypeForItemAtIndex:i];
            [self orientationForItemAtIndex:i];
            [self uniqueNameForItemAtIndex:i];
            [self pathForItemAtIndex:i];
            [self sourceForThumbnailImageOfItemAtIndex:i];
            [self textForItemAtIndex:i];
        }
        _imageItems = [self.cachedData filteredArrayUsingPredicate:
                       [NSPredicate predicateWithFormat:@"contentType = %d", PTContentTypeImage]];
    }
    return _imageItems;
}

- (NSArray *)itemUIProperties
{
    if (_itemUIProperties == nil) {
        // + PTContentType
        //  `-+ UIUserInterfaceIdiom
        //      `-+ PTItemOrientation
        //         `-+ { width, height }
        _itemUIProperties = @[
            /*
             * PTContentTypeGroup
             */
            @[
                /* UIUserInterfaceIdiomPhone */
                @[
                    @[ @75.0, @75.0 ], // PTItemOrientationPortrait
                    @[ @75.0, @75.0 ], // PTItemOrientationLandscape
                ],
                /* UIUserInterfaceIdiomPad */
                @[
                    @[ @135.0, @180.0 ], // PTItemOrientationPortrait
                    @[ @180.0, @135.0 ], // PTItemOrientationLandscape
                ],
            ],

            /*
             * PTContentTypeImage
             */
            @[
                /* UIUserInterfaceIdiomPhone */
                @[
                    @[ @75.0, @75.0 ], // PTItemOrientationPortrait
                    @[ @75.0, @75.0 ], // PTItemOrientationLandscape
                ],
                /* UIUserInterfaceIdiomPad */
                @[
                    @[ @180.0, @240.0 ], // PTItemOrientationPortrait
                    @[ @240.0, @180.0 ], // PTItemOrientationLandscape
                ],
            ],

            /*
             * PTContentTypeVideo
             */
            @[
                /* UIUserInterfaceIdiomPhone */
                @[
                    @[ @75.0, @75.0 ], // PTItemOrientationPortrait
                    @[ @75.0, @75.0 ], // PTItemOrientationLandscape
                ],
                /* UIUserInterfaceIdiomPad */
                @[
                    @[ @240.0, @180.0 ], // PTItemOrientationPortrait
                    @[ @240.0, @180.0 ], // PTItemOrientationLandscape
                ],
            ],

            /*
             * PTContentTypePdf
             */
            @[
                /* UIUserInterfaceIdiomPhone */
                @[
                    @[ @75.0, @75.0 ], // PTItemOrientationPortrait
                    @[ @75.0, @75.0 ], // PTItemOrientationLandscape
                ],
                /* UIUserInterfaceIdiomPad */
                @[
                    @[ @135.0, @180.0 ], // PTItemOrientationPortrait
                    @[ @180.0, @135.0 ], // PTItemOrientationLandscape
                ],
            ],
        ];
    }
    return _itemUIProperties;
}

#pragma mark Instance methods

- (NSInteger)numberOfItems
{
    if (self.cachedData == nil) {
        NSInteger numberOfItems = [self.showcaseDataSource numberOfItemsInShowcaseView:self];
        self.cachedData = [[NSMutableArray alloc] initWithCapacity:numberOfItems];
        for (NSInteger i = 0; i < numberOfItems; i++) {
            [self.cachedData addObject:[NSMutableDictionary dictionary]];
        }
    }
    return [self.cachedData count];
}

- (PTContentType)contentTypeForItemAtIndex:(NSInteger)index
{
    NSNumber *contentType = [[self.cachedData objectAtIndex:index] objectForKey:@"contentType"];
    if (contentType == nil) {
        contentType = [NSNumber numberWithInteger:[self.showcaseDataSource showcaseView:self contentTypeForItemAtIndex:index]];
        [[self.cachedData objectAtIndex:index] setObject:contentType forKey:@"contentType"];
    }
    return [contentType integerValue];
}

- (PTItemOrientation)orientationForItemAtIndex:(NSInteger)index
{
    NSNumber *orientation = [[self.cachedData objectAtIndex:index] objectForKey:@"orientation"];
    if (orientation == nil) {
        if ([self.showcaseDelegate respondsToSelector:@selector(showcaseView:orientationForItemAtIndex:)]) {
            orientation = [NSNumber numberWithInteger:[self.showcaseDelegate showcaseView:self orientationForItemAtIndex:index]];
        }
        else {
            orientation = [NSNumber numberWithInteger:PTItemOrientationPortrait];
        }

        [[self.cachedData objectAtIndex:index] setObject:orientation forKey:@"orientation"];
    }

    return [orientation integerValue];
}

- (CGSize)sizeForThumbnailImageOfItemAtIndex:(NSInteger)index
{
    NSValue *thumbnailImageSize = [[self.cachedData objectAtIndex:index] objectForKey:@"thumbnailImageSize"];
    if (thumbnailImageSize == nil) {
        NSString *thumbnailImageSource = [self sourceForThumbnailImageOfItemAtIndex:index];

        // TODO remove duplicate
        // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        NSURL *url = nil;

        // Check for file URLs.
        if ([thumbnailImageSource hasPrefix:@"/"]) {
            // If the url starts with / then it's likely a file URL, so treat it accordingly.
            url = [NSURL fileURLWithPath:thumbnailImageSource];
        }
        else {
            // Otherwise we assume it's a regular URL.
            url = [NSURL URLWithString:thumbnailImageSource];
        }
        // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        // we will try to get image size from image source only if this is
        // an image file available on the file system
        if (url.isFileURL) {
            CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
            if (imageSource) {
                NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithBool:NO], (NSString *)kCGImageSourceShouldCache,
                                         nil];

                CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
                CFRelease(imageSource);

                if (imageProperties) {
                    NSNumber *width = (__bridge NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
                    NSNumber *height = (__bridge NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
                    CFRelease(imageProperties);

                    thumbnailImageSize = [NSValue valueWithCGSize:CGSizeMake([width floatValue], [height floatValue])];
                }
            }
        }
        else {
            thumbnailImageSize = [NSValue valueWithCGSize:CGSizeZero];
        }

        [[self.cachedData objectAtIndex:index] setObject:thumbnailImageSize forKey:@"thumbnailImageSize"];
    }

    return [thumbnailImageSize CGSizeValue];
}

- (NSString *)uniqueNameForItemAtIndex:(NSInteger)index
{
    id uniqueName = [[self.cachedData objectAtIndex:index] objectForKey:@"uniqueName"];
    if (uniqueName == nil) {
        uniqueName = [self.showcaseDataSource showcaseView:self uniqueNameForItemAtIndex:index];
        [[self.cachedData objectAtIndex:index] setObject:(uniqueName ? uniqueName : [NSNull null]) forKey:@"uniqueName"];
    }
    return uniqueName == [NSNull null] ? nil : uniqueName;
}

- (NSString *)pathForItemAtIndex:(NSInteger)index
{
    id path = [[self.cachedData objectAtIndex:index] objectForKey:@"path"];
    if (path == nil) {
        path = [self.showcaseDataSource showcaseView:self pathForItemAtIndex:index];
        NSAssert([path hasPrefix:@"/"], @"path should be a valid non-relative (absolute) system path.");
        [[self.cachedData objectAtIndex:index] setObject:(path ? path : [NSNull null]) forKey:@"path"];
    }
    return path == [NSNull null] ? nil : path;
}

- (NSString *)sourceForThumbnailImageOfItemAtIndex:(NSInteger)index
{
    id source = [[self.cachedData objectAtIndex:index] objectForKey:@"thumbnailImageSource"];
    if (source == nil) {
        // TODO if optional 'showcaseView:sourceForThumbnailImageOfItemAtIndex:' wasn't implemented in data source use original image path instead?
        source = [self.showcaseDataSource showcaseView:self sourceForThumbnailImageOfItemAtIndex:index];
        [[self.cachedData objectAtIndex:index] setObject:(source ? source : [NSNull null]) forKey:@"thumbnailImageSource"];
    }
    return source == [NSNull null] ? nil : source;
}

- (NSString *)textForItemAtIndex:(NSInteger)index
{
    id text = [[self.cachedData objectAtIndex:index] objectForKey:@"text"];
    if (text == nil) {
        text = [self.showcaseDataSource showcaseView:self textForItemAtIndex:index];
        [[self.cachedData objectAtIndex:index] setObject:(text ? text : [NSNull null]) forKey:@"text"];
    }
    return text == [NSNull null] ? nil : text;
}

- (NSString *)detailTextForItemAtIndex:(NSInteger)index
{
    id text = [[self.cachedData objectAtIndex:index] objectForKey:@"detailText"];
    if (text == nil) {
        text = [self.showcaseDataSource showcaseView:self detailTextForItemAtIndex:index];
        [[self.cachedData objectAtIndex:index] setObject:(text ? text : [NSNull null]) forKey:@"detailText"];
    }
    return text == [NSNull null] ? nil : text;
}

- (NSInteger)indexForItemAtRelativeIndex:(NSInteger)relativeIndex withContentType:(PTContentType)contentType
{
    for (NSInteger i = 0; i < [self.cachedData count]; i++) {
        if ([[[self.cachedData objectAtIndex:i] objectForKey:@"contentType"] integerValue] == contentType && --relativeIndex < 0) {
            return i;
        }
    }
    // TODO use NSNotFound instead?
    return -1;
}

- (NSInteger)relativeIndexForItemAtIndex:(NSInteger)index withContentType:(PTContentType)contentType
{
    // TODO use NSNotFound instead?
    NSInteger relativeIndex = -1;
    for (NSInteger i = 0; i <= index; i++) {
        if ([[[self.cachedData objectAtIndex:i] objectForKey:@"contentType"] integerValue] == contentType) {
            relativeIndex++;
        }
    }
    return relativeIndex;
}

- (void)reloadData
{
    self.cachedData = nil;
    self.imageItems = nil;
    [super reloadData];
}

/* =============================================================================
 * Supported cells for content types
 * =============================================================================
 */
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView reusableCellForContentType:(PTContentType)contentType withOrientation:(PTItemOrientation)orientation
{
    GMGridViewCell *cell;

    switch (contentType)
    {
        case PTContentTypeGroup:
        {
            NSString *cellIdentifier = orientation == PTItemOrientationPortrait ? @"GroupPortraitCell" : @"GroupLandscapeCell";
            cell = [gridView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [self reusableGroupCellWithReuseIdentifier:cellIdentifier forOrientation:orientation];
                break;
            }
            return cell;
        }

        case PTContentTypeImage:
        {
            NSString *cellIdentifier = orientation == PTItemOrientationPortrait ? @"ImagePortraitCell" : @"ImageLandscapeCell";
            cell = [gridView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [self reusableImageCellWithReuseIdentifier:cellIdentifier forOrientation:orientation];
                break;
            }
            return cell;
        }

        case PTContentTypeVideo:
        {
            NSString *cellIdentifier = @"VideoCell";
            cell = [gridView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [self reusableVideoCellWithReuseIdentifier:cellIdentifier forOrientation:orientation];
                break;
            }
            return cell;
        }

        case PTContentTypePdf:
        {
            NSString *cellIdentifier = orientation == PTItemOrientationPortrait ? @"PdfPortraitCell" : @"PdfLandscapeCell";
            cell = [gridView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [self reusablePdfCellWithReuseIdentifier:cellIdentifier forOrientation:orientation];
                break;
            }
            return cell;
        }

        default: NSAssert(NO, @"Unknown content-type.");
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 80.0, 80.0, 20.0)];
        textLabel.tag = PTShowcaseTagText;
        textLabel.font = [UIFont boldSystemFontOfSize:12.0];
        textLabel.textAlignment = UITextAlignmentCenter;
        textLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        textLabel.textColor = [UIColor whiteColor];
        textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        textLabel.shadowColor = [UIColor blackColor];
        textLabel.backgroundColor = [UIColor clearColor];

        [cell.contentView addSubview:textLabel];
    }
    else {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 256.0, 256.0, 20.0)];
        textLabel.tag = PTShowcaseTagText;
        textLabel.font = [UIFont boldSystemFontOfSize:12.0];
        textLabel.textAlignment = UITextAlignmentCenter;
        textLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        textLabel.textColor = [UIColor whiteColor];
        textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        textLabel.shadowColor = [UIColor blackColor];
        textLabel.backgroundColor = [UIColor clearColor];

        [cell.contentView addSubview:textLabel];

        UILabel *detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 256.0+20.0, 256.0, 40.0)];
        detailTextLabel.tag = PTShowcaseTagDetailText;
        detailTextLabel.numberOfLines = 2;
        detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        detailTextLabel.textAlignment = UITextAlignmentCenter;
        detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
        detailTextLabel.textColor = [UIColor whiteColor];
        detailTextLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        detailTextLabel.shadowColor = [UIColor blackColor];
        detailTextLabel.backgroundColor = [UIColor clearColor];

        [cell.contentView addSubview:detailTextLabel];
    }

    if ([self.showcaseDelegate respondsToSelector:@selector(showcaseView:didPrepareReusableThumbnailView:forContentType:andOrientation:)]) {
        [self.showcaseDelegate showcaseView:self didPrepareReusableThumbnailView:cell.contentView forContentType:contentType andOrientation:orientation];
    }

    return cell;
}

- (GMGridViewCell *)reusableGroupCellWithReuseIdentifier:(NSString *)identifier forOrientation:(PTItemOrientation)orientation
{
    GMGridViewCell *cell = [[GMGridViewCell alloc] init];
    cell.reuseIdentifier = identifier;

    CGSize size = [self GMGridView:self sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    cell.contentView = view;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // Placeholder

        NSString *placeholderImageName = @"PTShowcase.bundle/group.png";
        CGRect placeholderImageNameImageViewFrame = CGRectMake(2.5, 2.5, 75.0, 75.0);

        UIImageView *placeholderImageView = [[UIImageView alloc] initWithFrame:placeholderImageNameImageViewFrame];
        placeholderImageView.image = [UIImage imageNamed:placeholderImageName];
        [cell.contentView addSubview:placeholderImageView];
    }
    else {
        // Back Image

        NSString *backImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"group",
                                   orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
        CGRect backImageViewFrame = CGRectMake(0.0, 0.0, 256.0, 256.0);

        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewFrame];
        backImageView.image = [UIImage imageNamed:backImageName];
        [cell.contentView addSubview:backImageView];

        // Thumbnail

        NSString *loadingImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"thumbnail-loading",
                                      orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
        CGRect loadingImageViewFrame = orientation == PTItemOrientationPortrait
        ? CGRectMake(60.0, 28.0, 135.0, 180.0)
        : CGRectMake(40.0, 50.0, 180.0, 135.0);

        NINetworkImageView *thumbnailView = [[NINetworkImageView alloc] initWithFrame:loadingImageViewFrame];
        thumbnailView.tag = PTShowcaseTagThumbnail;
        thumbnailView.initialImage = [UIImage imageNamed:loadingImageName];
        [cell.contentView addSubview:thumbnailView];
    }

    return cell;
}

- (GMGridViewCell *)reusableImageCellWithReuseIdentifier:(NSString *)identifier forOrientation:(PTItemOrientation)orientation
{
    GMGridViewCell *cell = [[GMGridViewCell alloc] init];
    cell.reuseIdentifier = identifier;

    CGSize size = [self GMGridView:self sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    cell.contentView = view;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // Back Image

        CGRect backImageViewFrame = CGRectMake(2.5, 2.5, 75.0, 75.0);

        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewFrame];
        backImageView.image = [UIImage imageNamed:@"PTShowcase.bundle/image.png"];
        [cell.contentView addSubview:backImageView];

        // Thumbnail

        NSString *loadingImageName = @"PTShowcase.bundle/image-loading.png";

        NINetworkImageView *thumbnailView = [[NINetworkImageView alloc] initWithFrame:backImageViewFrame];
        thumbnailView.tag = PTShowcaseTagThumbnail;
        thumbnailView.initialImage = [UIImage imageNamed:loadingImageName];
        [cell.contentView addSubview:thumbnailView];

        // Overlap

        UIImageView *overlapView = [[UIImageView alloc] initWithFrame:backImageViewFrame];
        overlapView.image = [UIImage imageNamed:@"PTShowcase.bundle/image-overlap.png"];
        [cell.contentView addSubview:overlapView];
    }
    else {
        // Back Image

        NSString *backImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"image",
                                   orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
        CGRect backImageViewFrame = orientation == PTItemOrientationPortrait
        ? CGRectMake(38.0, 8.0, 180.0, 240.0)
        : CGRectMake(8.0, 28.0, 240.0, 180.0);

        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewFrame];
        backImageView.image = [UIImage imageNamed:backImageName];
        [cell.contentView addSubview:backImageView];

        // Thumbnail

        NSString *loadingImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"thumbnail-loading",
                                      orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];

        NINetworkImageView *thumbnailView = [[NINetworkImageView alloc] initWithFrame:backImageViewFrame];
        thumbnailView.tag = PTShowcaseTagThumbnail;
        thumbnailView.initialImage = [UIImage imageNamed:loadingImageName];
        [cell.contentView addSubview:thumbnailView];

        // Overlap

        NSString *overlapImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"image-overlap",
                                      orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
        UIImageView *overlapView = [[UIImageView alloc] initWithFrame:backImageViewFrame];
        overlapView.image = [UIImage imageNamed:overlapImageName];
        [cell.contentView addSubview:overlapView];
    }

    return cell;
}

- (GMGridViewCell *)reusableVideoCellWithReuseIdentifier:(NSString *)identifier forOrientation:(PTItemOrientation)orientation
{
    GMGridViewCell *cell = [[GMGridViewCell alloc] init];
    cell.reuseIdentifier = identifier;

    CGSize size = [self GMGridView:self sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    cell.contentView = view;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // Thumbnail

        NSString *loadingImageName = @"PTShowcase.bundle/video-loading.png";
        CGRect loadingImageViewFrame = CGRectMake(2.5, 2.5, 75.0, 75.0);
        UIImage *maskedImage = [PTVideoThumbnailImageView applyMask:[UIImage imageNamed:loadingImageName] forOrientation:orientation];

        PTVideoThumbnailImageView *thumbnailView = [[PTVideoThumbnailImageView alloc] initWithFrame:loadingImageViewFrame];
        thumbnailView.tag = PTShowcaseTagThumbnail;
        thumbnailView.initialImage = maskedImage;
        [cell.contentView addSubview:thumbnailView];

        // Overlap

        UIImageView *overlapView = [[UIImageView alloc] initWithFrame:loadingImageViewFrame];
        overlapView.image = [UIImage imageNamed:@"PTShowcase.bundle/video-overlap.png"];
        [cell.contentView addSubview:overlapView];
    }
    else {
        // Thumbnail

        NSString *loadingImageName = @"PTShowcase.bundle/video-loading.png";
        CGRect loadingImageViewFrame = CGRectMake(8.0, 30.0, 240.0, 180.0);
        UIImage *maskedImage = [PTVideoThumbnailImageView applyMask:[UIImage imageNamed:loadingImageName] forOrientation:orientation];

        PTVideoThumbnailImageView *thumbnailView = [[PTVideoThumbnailImageView alloc] initWithFrame:loadingImageViewFrame];
        thumbnailView.tag = PTShowcaseTagThumbnail;
        thumbnailView.initialImage = maskedImage;
        [cell.contentView addSubview:thumbnailView];

        // Overlap

        UIImageView *overlapView = [[UIImageView alloc] initWithFrame:loadingImageViewFrame];
        overlapView.image = [UIImage imageNamed:@"PTShowcase.bundle/video-overlap.png"];
        [cell.contentView addSubview:overlapView];
    }

    return cell;
}

- (GMGridViewCell *)reusablePdfCellWithReuseIdentifier:(NSString *)identifier forOrientation:(PTItemOrientation)orientation
{
    GMGridViewCell *cell = [[GMGridViewCell alloc] init];
    cell.reuseIdentifier = identifier;

    CGSize size = [self GMGridView:self sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    cell.contentView = view;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // Thumbnail

        NSString *loadingImageName = @"PTShowcase.bundle/document-loading.png";
        CGRect loadingImageViewFrame = CGRectMake(2.5, 2.5, 75.0, 75.0);
        UIImage *maskedImage = [PTPdfThumbnailImageView applyMask:[UIImage imageNamed:loadingImageName] forOrientation:orientation];

        PTPdfThumbnailImageView *thumbnailView = [[PTPdfThumbnailImageView alloc] initWithFrame:loadingImageViewFrame];
        thumbnailView.tag = PTShowcaseTagThumbnail;
        thumbnailView.initialImage = maskedImage;
        [cell.contentView addSubview:thumbnailView];

        // Overlap

        UIImageView *overlapView = [[UIImageView alloc] initWithFrame:loadingImageViewFrame];
        overlapView.image = [UIImage imageNamed:@"PTShowcase.bundle/document-overlap.png"];
        [cell.contentView addSubview:overlapView];
    }
    else {
        // Back Image

        NSString *backImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"document-pages",
                                   orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
        CGRect backImageViewFrame = CGRectMake(0.0, 0.0, 256.0, 256.0);

        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewFrame];
        backImageView.image = [UIImage imageNamed:backImageName];
        [cell.contentView addSubview:backImageView];

        // Thumbnail

        NSString *loadingImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"thumbnail-loading",
                                      orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
        CGRect loadingImageViewFrame = orientation == PTItemOrientationPortrait
        ? CGRectMake(60.0, 38.0, 135.0, 180.0)
        : CGRectMake(38.0, 61.0, 180.0, 135.0);

        NINetworkImageView *thumbnailView = [[NINetworkImageView alloc] initWithFrame:loadingImageViewFrame];
        thumbnailView.tag = PTShowcaseTagThumbnail;
        thumbnailView.initialImage = [UIImage imageNamed:loadingImageName];
        [cell.contentView addSubview:thumbnailView];
    }

    return cell;
}

#pragma mark GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [self numberOfItems];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return CGSizeMake(80.0, 80.0+20.0);
    }

    return CGSizeMake(256.0, 256.0+20.0+40.0);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    PTContentType contentType = [self contentTypeForItemAtIndex:index];
    PTItemOrientation orientation = [self orientationForItemAtIndex:index];
    NSString *thumbnailImageSource = [self sourceForThumbnailImageOfItemAtIndex:index];
    CGSize size = [self sizeForThumbnailImageOfItemAtIndex:index];
    NSString *text = [self textForItemAtIndex:index];
    NSString *detailText = [self detailTextForItemAtIndex:index];

    GMGridViewCell *cell = [self GMGridView:gridView reusableCellForContentType:contentType withOrientation:orientation];

    NINetworkImageView *thumbnailView = (NINetworkImageView *)[cell.contentView viewWithTag:PTShowcaseTagThumbnail];
    [thumbnailView setPathToNetworkImage:thumbnailImageSource];

    thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        NSArray *minSize = self.itemUIProperties[contentType][[[UIDevice currentDevice] userInterfaceIdiom]][orientation];
        if (size.width < [minSize[0] floatValue] || size.height < [minSize[1] floatValue]) {
            thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }

    UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:PTShowcaseTagText];
    textLabel.text = text;

    UILabel *detailTextLabel = (UILabel *)[cell.contentView viewWithTag:PTShowcaseTagDetailText];
    detailTextLabel.text = detailText;

    if ([self.showcaseDelegate respondsToSelector:@selector(showcaseView:willDisplayThumbnailView:forItemAtIndex:)]) {
        [self.showcaseDelegate showcaseView:self willDisplayThumbnailView:cell.contentView forItemAtIndex:index];
    }

//    [cell.contentView setBackgroundColor:((index % 2 == 0) ? [UIColor greenColor] : [UIColor magentaColor])];
//    [thumbnailView setBackgroundColor:[UIColor cyanColor]];
//    [textLabel setBackgroundColor:((index % 2 == 0) ? [UIColor redColor] : [UIColor blueColor])];
//    [detailTextLabel setBackgroundColor:((index % 2 == 0) ? [UIColor brownColor] : [UIColor yellowColor])];

    return cell;
}

@end
