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

- (NSString *)uniqueNameForItemAtIndex:(NSInteger)index
{
    id object = [[self.data objectAtIndex:index] objectForKey:@"uniqueName"];
    return object == [NSNull null] ? nil : object;
}

- (PTContentType)contentTypeForItemAtIndex:(NSInteger)index
{
    return [[[self.data objectAtIndex:index] objectForKey:@"contentType"] integerValue];
}

- (PTItemOrientation)orientationForItemAtIndex:(NSInteger)index
{
    return [[[self.data objectAtIndex:index] objectForKey:@"orientation"] integerValue];
}

- (NSString *)sourceForItemAtIndex:(NSInteger)index
{
    id object = [[self.data objectAtIndex:index] objectForKey:@"source"];
    return object == [NSNull null] ? nil : object;
}

- (NSString *)sourceForItemThumbnailAtIndex:(NSInteger)index
{
    id object = [[self.data objectAtIndex:index] objectForKey:@"thumbnailSource"];
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
        // Ask datasource and delegate for various data
        NSString *uniqueName = [self.showcaseDataSource showcaseView:self uniqueNameForItemAtIndex:i];
        PTContentType contentType = [self.showcaseDataSource showcaseView:self contentTypeForItemAtIndex:i];
        PTItemOrientation orientation = [self.showcaseDelegate showcaseView:self orientationForItemAtIndex:i];
        NSString *source = [self.showcaseDataSource showcaseView:self sourceForItemAtIndex:i];
        NSString *thumbnailSource = [self.showcaseDataSource showcaseView:self sourceForItemThumbnailAtIndex:i];
        NSString *text = [self.showcaseDataSource showcaseView:self textForItemAtIndex:i];
        
        [self.data addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              uniqueName ? uniqueName : [NSNull null], @"uniqueName",
                              [NSNumber numberWithInteger:contentType], @"contentType",
                              [NSNumber numberWithInteger:orientation], @"orientation",
                              source ? source : [NSNull null], @"source",
                              thumbnailSource ? thumbnailSource : [NSNull null], @"thumbnailSource",
                              text ? text : [NSNull null], @"text",
                              nil]];
    }
    
    [super reloadData];
}

@end
