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

// private
@synthesize data = _data;

#pragma mark - Instance properties

- (NSArray *)imageItems
{
    return [self.data filteredArrayUsingPredicate:
            [NSPredicate predicateWithFormat:@"contentType = %d", PTContentTypeImage]];
}

#pragma mark - Instance methods

- (NSInteger)numberOfImages
{
    return [self.data count];
}

- (PTContentType)contentTypeForImageAtIndex:(NSInteger)index;
{
    return [[[self.data objectAtIndex:index] objectForKey:@"contentType"] integerValue];
}

- (PTItemOrientation)orientationForImageAtIndex:(NSInteger)index;
{
    return [[[self.data objectAtIndex:index] objectForKey:@"orientation"] integerValue];
}

- (NSString *)sourceForImageAtIndex:(NSInteger)index;
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
        PTContentType contentType = [self.showcaseDataSource showcaseView:self contentTypeForItemAtIndex:i];
        PTItemOrientation orientation = [self.showcaseDelegate showcaseView:self orientationForItemAtIndex:i];
        NSString *source = [self.showcaseDataSource showcaseView:self sourceForItemAtIndex:i];
        
        [self.data addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInteger:contentType], @"contentType",
                              [NSNumber numberWithInteger:orientation], @"orientation",
                              source, @"source",
                              nil]];
    }
    
    [super reloadData];
}

@end
