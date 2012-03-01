//
//  PTShowcaseView.m
//  ShowcaseDemo
//
//  Created by Ali Servet Donmez on 10.2.12.
//  Copyright (c) 2012 Apex-net srl. All rights reserved.
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

- (NSString *)uniqueNameForItemAtIndex:(NSInteger)index;
{
    id object = [[self.data objectAtIndex:index] objectForKey:@"uniqueName"];
    return object == [NSNull null] ? nil : object;
}

- (PTContentType)contentTypeForItemAtIndex:(NSInteger)index;
{
    return [[[self.data objectAtIndex:index] objectForKey:@"contentType"] integerValue];
}

- (PTItemOrientation)orientationForItemAtIndex:(NSInteger)index;
{
    return [[[self.data objectAtIndex:index] objectForKey:@"orientation"] integerValue];
}

- (NSString *)sourceForItemAtIndex:(NSInteger)index;
{
    id object = [[self.data objectAtIndex:index] objectForKey:@"source"];
    return object == [NSNull null] ? nil : object;
}

- (NSString *)textForItemAtIndex:(NSInteger)index;
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
        NSString *text = [self.showcaseDataSource showcaseView:self textForItemAtIndex:i];
        
        [self.data addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              uniqueName ? uniqueName : [NSNull null], @"uniqueName",
                              [NSNumber numberWithInteger:contentType], @"contentType",
                              [NSNumber numberWithInteger:orientation], @"orientation",
                              source ? source : [NSNull null], @"source",
                              text ? text : [NSNull null], @"text",
                              nil]];
    }
    
    [super reloadData];
}

@end
