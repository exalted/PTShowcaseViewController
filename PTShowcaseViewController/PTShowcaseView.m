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

#import "GMGridView.h"

// Thumbnail
#import "PTVideoThumbnailImageView.h"
#import "PTPdfThumbnailImageView.h"

typedef enum {
    PTShowcaseTagThumbnail  = 10,
    PTShowcaseTagText       = 20,
    PTShowcaseTagDetailText = 30,
} PTShowcaseTag;

@interface PTShowcaseView () <GMGridViewDataSource> {
    NSMutableArray *_cachedData;
    NSArray *_imageItems;
}

// Supported cells for content types
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForContentType:(PTContentType)contentType withOrientation:(PTItemOrientation)orientation;
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView groupCellWithOrientation:(PTItemOrientation)orientation;
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView imageCellWithOrientation:(PTItemOrientation)orientation;
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView videoCellWithOrientation:(PTItemOrientation)orientation;
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView pdfCellWithOrientation:(PTItemOrientation)orientation;

@end

@implementation PTShowcaseView

@synthesize showcaseDelegate = _showcaseDelegate;
@synthesize showcaseDataSource = _showcaseDataSource;

@synthesize uniqueName = _uniqueName;

- (id)initWithUniqueName:(NSString *)uniqueName
{
    self = [super init];
    if (self) {
        // Custom initialization
        _uniqueName = uniqueName;
    }
    return self;
}

#pragma mark - Instance properties

// TODO replace with much better 'imageItemsForContentType:'
- (NSArray *)imageItems
{
    if (_imageItems == nil) {
        _imageItems = [_cachedData filteredArrayUsingPredicate:
                       [NSPredicate predicateWithFormat:@"contentType = %d", PTContentTypeImage]];
    }
    return _imageItems;
}

#pragma mark - Instance methods

- (NSInteger)numberOfItems
{
    if (_cachedData == nil) {
        NSInteger numberOfItems = [self.showcaseDataSource numberOfItemsInShowcaseView:self];
        _cachedData = [[NSMutableArray alloc] initWithCapacity:numberOfItems];
        for (NSInteger i = 0; i < numberOfItems; i++) {
            [_cachedData addObject:[NSMutableDictionary dictionary]];
        }
    }
    return [_cachedData count];
}

- (PTContentType)contentTypeForItemAtIndex:(NSInteger)index
{
    NSNumber *contentType = [[_cachedData objectAtIndex:index] objectForKey:@"contentType"];
    if (contentType == nil) {
        contentType = [NSNumber numberWithInteger:[self.showcaseDataSource showcaseView:self contentTypeForItemAtIndex:index]];
        [[_cachedData objectAtIndex:index] setObject:contentType forKey:@"contentType"];
    }
    return [contentType integerValue];
}

- (PTItemOrientation)orientationForItemAtIndex:(NSInteger)index
{
    NSNumber *orientation = [[_cachedData objectAtIndex:index] objectForKey:@"orientation"];
    if (orientation == nil) {
        if ([self.showcaseDelegate respondsToSelector:@selector(showcaseView:orientationForItemAtIndex:)]) {
            orientation = [NSNumber numberWithInteger:[self.showcaseDelegate showcaseView:self orientationForItemAtIndex:index]];
        }
        else {
            orientation = [NSNumber numberWithInteger:PTItemOrientationPortrait];
        }

        [[_cachedData objectAtIndex:index] setObject:orientation forKey:@"orientation"];
    }

    return [orientation integerValue];
}

- (NSString *)uniqueNameForItemAtIndex:(NSInteger)index
{
    NSString *uniqueName = [[_cachedData objectAtIndex:index] objectForKey:@"uniqueName"];
    if (uniqueName == nil) {
        uniqueName = [self.showcaseDataSource showcaseView:self uniqueNameForItemAtIndex:index];
        [[_cachedData objectAtIndex:index] setObject:uniqueName forKey:@"uniqueName"];
    }
    return uniqueName;
}

- (NSString *)pathForItemAtIndex:(NSInteger)index
{
    NSString *path = [[_cachedData objectAtIndex:index] objectForKey:@"path"];
    if (path == nil) {
        path = [self.showcaseDataSource showcaseView:self pathForItemAtIndex:index];
        NSAssert([path hasPrefix:@"/"], @"path should be a valid non-relative (absolute) system path.");
        [[_cachedData objectAtIndex:index] setObject:path forKey:@"path"];
    }
    return path;
}

- (NSString *)sourceForThumbnailImageOfItemAtIndex:(NSInteger)index
{
    NSString *source = [[_cachedData objectAtIndex:index] objectForKey:@"thumbnailImageSource"];
    if (source == nil) {
        // TODO if optional 'showcaseView:sourceForThumbnailImageOfItemAtIndex:' wasn't implemented in data source use original image path instead?
        source = [self.showcaseDataSource showcaseView:self sourceForThumbnailImageOfItemAtIndex:index];
        [[_cachedData objectAtIndex:index] setObject:source forKey:@"thumbnailImageSource"];
    }
    return source;
}

- (NSString *)textForItemAtIndex:(NSInteger)index
{
    NSString *text = [[_cachedData objectAtIndex:index] objectForKey:@"text"];
    if (text == nil) {
        text = [self.showcaseDataSource showcaseView:self textForItemAtIndex:index];
        [[_cachedData objectAtIndex:index] setObject:text forKey:@"text"];
    }
    return text;
}

- (NSInteger)indexForItemAtRelativeIndex:(NSInteger)relativeIndex withContentType:(PTContentType)contentType
{
    for (NSInteger i = 0; i < [_cachedData count]; i++) {
        if ([[[_cachedData objectAtIndex:i] objectForKey:@"contentType"] integerValue] == contentType && --relativeIndex < 0) {
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
        if ([[[_cachedData objectAtIndex:i] objectForKey:@"contentType"] integerValue] == contentType) {
            relativeIndex++;
        }
    }
    return relativeIndex;
}

- (void)reloadData
{
    _cachedData = nil;
    _imageItems = nil;
    [super reloadData];
}

/* =============================================================================
 * Supported cells for content types
 * =============================================================================
 */
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForContentType:(PTContentType)contentType withOrientation:(PTItemOrientation)orientation
{
    GMGridViewCell *cell = nil;
    switch (contentType)
    {
        case PTContentTypeGroup:
        {
            cell = [self GMGridView:gridView groupCellWithOrientation:orientation];
            break;
        }
            
        case PTContentTypeImage:
        {
            cell = [self GMGridView:gridView imageCellWithOrientation:orientation];
            break;
        }
            
        case PTContentTypeVideo:
        {
            cell = [self GMGridView:gridView videoCellWithOrientation:orientation];
            break;
        }
            
        case PTContentTypePdf:
        {
            cell = [self GMGridView:gridView pdfCellWithOrientation:orientation];
            break;
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
        
        [cell addSubview:textLabel];
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
        
        [cell addSubview:textLabel];
    }
    
    return cell;
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
            CGRect placeholderImageNameImageViewFrame = CGRectMake(2.0, 2.0, 75.0, 75.0);
            
            UIImageView *placeholderImageView = [[UIImageView alloc] initWithFrame:placeholderImageNameImageViewFrame];
            placeholderImageView.image = [UIImage imageNamed:placeholderImageName];
            [cell addSubview:placeholderImageView];
        }
        else {
            // Back Image
            
            NSString *backImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"group",
                                       orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
            CGRect backImageViewFrame = CGRectMake(0.0, 0.0, 256.0, 256.0);
            
            UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewFrame];
            backImageView.image = [UIImage imageNamed:backImageName];
            [cell addSubview:backImageView];
            
            // Thumbnail
            
            NSString *loadingImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"thumbnail-loading",
                                          orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
            CGRect loadingImageViewFrame = orientation == PTItemOrientationPortrait
            ? CGRectMake(60.0, 28.0, 135.0, 180.0)
            : CGRectMake(40.0, 50.0, 180.0, 135.0);
            
            NINetworkImageView *thumbnailView = [[NINetworkImageView alloc] initWithFrame:loadingImageViewFrame];
            thumbnailView.tag = PTShowcaseTagThumbnail;
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
            CGRect loadingImageViewFrame = CGRectMake(2.0, 2.0, 75.0, 75.0);
            
            NINetworkImageView *thumbnailView = [[NINetworkImageView alloc] initWithFrame:loadingImageViewFrame];
            thumbnailView.tag = PTShowcaseTagThumbnail;
            thumbnailView.initialImage = [UIImage imageNamed:loadingImageName];
            [cell addSubview:thumbnailView];
            
            // Overlap
            
            UIImageView *overlapView = [[UIImageView alloc] initWithFrame:loadingImageViewFrame];
            overlapView.image = [UIImage imageNamed:@"PTShowcase.bundle/image-overlap.png"];
            [cell addSubview:overlapView];
        }
        else {
            // Thumbnail
            
            NSString *loadingImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"thumbnail-loading",
                                          orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
            CGRect loadingImageViewFrame = orientation == PTItemOrientationPortrait
            ? CGRectMake(38.0, 8.0, 180.0, 240.0)
            : CGRectMake(8.0, 28.0, 240.0, 180.0);
            
            NINetworkImageView *thumbnailView = [[NINetworkImageView alloc] initWithFrame:loadingImageViewFrame];
            thumbnailView.tag = PTShowcaseTagThumbnail;
            thumbnailView.initialImage = [UIImage imageNamed:loadingImageName];
            [cell addSubview:thumbnailView];
            
            // Overlap
            
            NSString *overlapImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"image-overlap",
                                          orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
            UIImageView *overlapView = [[UIImageView alloc] initWithFrame:loadingImageViewFrame];
            overlapView.image = [UIImage imageNamed:overlapImageName];
            [cell addSubview:overlapView];
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
            CGRect loadingImageViewFrame = CGRectMake(2.0, 2.0, 75.0, 75.0);
            UIImage *maskedImage = [PTVideoThumbnailImageView applyMask:[UIImage imageNamed:loadingImageName] forOrientation:orientation];
            
            PTVideoThumbnailImageView *thumbnailView = [[PTVideoThumbnailImageView alloc] initWithFrame:loadingImageViewFrame];
            thumbnailView.tag = PTShowcaseTagThumbnail;
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
            CGRect loadingImageViewFrame = CGRectMake(0.0, 30.0, 240.0, 180.0);
            UIImage *maskedImage = [PTVideoThumbnailImageView applyMask:[UIImage imageNamed:loadingImageName] forOrientation:orientation];
            
            PTVideoThumbnailImageView *thumbnailView = [[PTVideoThumbnailImageView alloc] initWithFrame:loadingImageViewFrame];
            thumbnailView.tag = PTShowcaseTagThumbnail;
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
            CGRect loadingImageViewFrame = CGRectMake(2.0, 2.0, 75.0, 75.0);
            UIImage *maskedImage = [PTPdfThumbnailImageView applyMask:[UIImage imageNamed:loadingImageName] forOrientation:orientation];
            
            PTPdfThumbnailImageView *thumbnailView = [[PTPdfThumbnailImageView alloc] initWithFrame:loadingImageViewFrame];
            thumbnailView.tag = PTShowcaseTagThumbnail;
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
            CGRect backImageViewFrame = CGRectMake(0.0, 0.0, 256.0, 256.0);
            
            UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewFrame];
            backImageView.image = [UIImage imageNamed:backImageName];
            [cell addSubview:backImageView];
            
            // Thumbnail
            
            NSString *loadingImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"thumbnail-loading",
                                          orientation == PTItemOrientationPortrait ? @"portrait" : @"landscape"];
            CGRect loadingImageViewFrame = orientation == PTItemOrientationPortrait
            ? CGRectMake(60.0, 38.0, 135.0, 180.0)
            : CGRectMake(38.0, 61.0, 180.0, 135.0);
            
            NINetworkImageView *thumbnailView = [[NINetworkImageView alloc] initWithFrame:loadingImageViewFrame];
            thumbnailView.tag = PTShowcaseTagThumbnail;
            thumbnailView.initialImage = [UIImage imageNamed:loadingImageName];
            [cell addSubview:thumbnailView];
        }
    }
    
    return cell;
}

#pragma mark - GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [self numberOfItems];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return CGSizeMake(80.0, 80.0+20.0);
    }
    
    return CGSizeMake(256.0, 256.0+20.0);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    PTContentType contentType = [self contentTypeForItemAtIndex:index];
    PTItemOrientation orientation = [self orientationForItemAtIndex:index];
    NSString *thumbnailImageSource = [self sourceForThumbnailImageOfItemAtIndex:index];
    NSString *text = [self textForItemAtIndex:index];
    
    GMGridViewCell *cell = [self GMGridView:gridView cellForContentType:contentType withOrientation:orientation];
    
    NINetworkImageView *thumbnailView = (NINetworkImageView *)[cell viewWithTag:PTShowcaseTagThumbnail];
    thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    [thumbnailView setPathToNetworkImage:thumbnailImageSource];
    
    UILabel *textLabel = (UILabel *)[cell viewWithTag:PTShowcaseTagText];
    textLabel.text = text;
    
    if ([self.showcaseDelegate respondsToSelector:@selector(showcaseView:willDisplayView:forItemAtIndex:)]) {
        [self.showcaseDelegate showcaseView:self willDisplayView:cell forItemAtIndex:index];
    }
    
    return cell;
}

@end
