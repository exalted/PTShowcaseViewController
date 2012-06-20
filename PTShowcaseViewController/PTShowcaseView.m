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

#import "PTShowcaseViewDelegate.h"
#import "PTShowcaseViewDataSource.h"

@interface PTShowcaseView () {
    NSMutableArray *_cachedData;
    NSArray *_imageItems;
}

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

@end
