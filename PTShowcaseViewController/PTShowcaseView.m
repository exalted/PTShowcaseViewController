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

@interface PTShowcaseView ()

@property (nonatomic, retain) NSMutableArray *data;

@end

@implementation PTShowcaseView

@synthesize showcaseDelegate = _showcaseDelegate;
@synthesize showcaseDataSource = _showcaseDataSource;

@synthesize uniqueName = _uniqueName;

// private
@synthesize data = _data;

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

- (NSArray *)imageItems
{
    return [self.data filteredArrayUsingPredicate:
            [NSPredicate predicateWithFormat:@"contentType = %d", PTContentTypeImage]];
}

#pragma mark - Instance methods

- (NSInteger)numberOfItems
{
    return [self.data count];
}

- (PTContentType)contentTypeForItemAtIndex:(NSInteger)index
{
    return [[[self.data objectAtIndex:index] objectForKey:@"contentType"] integerValue];
}

- (PTItemOrientation)orientationForItemAtIndex:(NSInteger)index
{
    return [[[self.data objectAtIndex:index] objectForKey:@"orientation"] integerValue];
}

- (NSString *)uniqueNameForItemAtIndex:(NSInteger)index
{
    id object = [[self.data objectAtIndex:index] objectForKey:@"uniqueName"];
    return object == [NSNull null] ? nil : object;
}

- (NSString *)pathForItemAtIndex:(NSInteger)index
{
    id object = [[self.data objectAtIndex:index] objectForKey:@"path"];
    return object == [NSNull null] ? nil : object;
}

- (NSString *)sourceForThumbnailImageOfItemAtIndex:(NSInteger)index
{
    id object = [[self.data objectAtIndex:index] objectForKey:@"thumbnailImageSource"];
    return object == [NSNull null] ? nil : object;
}

- (NSString *)textForItemAtIndex:(NSInteger)index
{
    id object = [[self.data objectAtIndex:index] objectForKey:@"text"];
    return object == [NSNull null] ? nil : object;
}

- (NSInteger)relativeIndexForItemAtIndex:(NSInteger)index withContentType:(PTContentType)contentType
{
    NSInteger relativeIndex = -1;
    for (NSInteger i = 0; i < index+1; i++) {
        if ([[[self.data objectAtIndex:i] objectForKey:@"contentType"] integerValue] == contentType) {
            relativeIndex++;
        }
    }
    
    return relativeIndex;
}

- (void)reloadData
{
    // Ask data source for number of items
    NSInteger numberOfItems = [self.showcaseDataSource numberOfItemsInShowcaseView:self];
    
    // Create an items' info array for reusing
    self.data = [NSMutableArray arrayWithCapacity:numberOfItems];
    for (NSInteger i = 0; i < numberOfItems; i++) {
        // Ask data source and delegate for various data
        PTContentType contentType = [self.showcaseDataSource showcaseView:self contentTypeForItemAtIndex:i];
        PTItemOrientation orientation = [self.showcaseDelegate showcaseView:self orientationForItemAtIndex:i];

        NSString *path = [self.showcaseDataSource showcaseView:self pathForItemAtIndex:i];
        if (path) {
            NSAssert([path hasPrefix:@"/"], @"path should be a valid non-relative (absolute) system path.");
        }
        NSString *uniqueName = [self.showcaseDataSource showcaseView:self uniqueNameForItemAtIndex:i];
        NSString *thumbnailImageSource = [self.showcaseDataSource showcaseView:self sourceForThumbnailImageOfItemAtIndex:i];
        NSString *text = [self.showcaseDataSource showcaseView:self textForItemAtIndex:i];
        
        [self.data addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInteger:contentType], @"contentType",
                              [NSNumber numberWithInteger:orientation], @"orientation",
                              path ? path : [NSNull null], @"path",
                              uniqueName ? uniqueName : [NSNull null], @"uniqueName",
                              thumbnailImageSource ? thumbnailImageSource : [NSNull null], @"thumbnailImageSource",
                              text ? text : [NSNull null], @"text",
                              nil]];
    }
    
    [super reloadData];
}

@end
