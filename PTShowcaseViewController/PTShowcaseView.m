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
    return [[self.data objectAtIndex:index] objectForKey:@"uniqueName"];
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
    return [[self.data objectAtIndex:index] objectForKey:@"source"];
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
        
        // TODO checks below are the ugliest stuff ever!
        uniqueName = uniqueName == nil ? @"" : uniqueName;
        source = source == nil ? @"" : source;

        [self.data addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              uniqueName, @"uniqueName",
                              [NSNumber numberWithInteger:contentType], @"contentType",
                              [NSNumber numberWithInteger:orientation], @"orientation",
                              source, @"source",
                              nil]];
    }
    
    [super reloadData];
}

@end
