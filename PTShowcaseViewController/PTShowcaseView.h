//
//  PTShowcaseView.h
//  ShowcaseDemo
//
//  Created by Ali Servet Donmez on 10.2.12.
//  Copyright (c) 2012 Apex-net srl. All rights reserved.
//

#import "GMGridView.h"

#import "PTShowcase.h"

@protocol PTShowcaseViewDelegate;
@protocol PTShowcaseViewDataSource;

@interface PTShowcaseView : GMGridView

@property (nonatomic, assign) id<PTShowcaseViewDelegate> showcaseDelegate;
@property (nonatomic, assign) id<PTShowcaseViewDataSource> showcaseDataSource;

@property (nonatomic, retain, readonly) NSString *uniqueName;

@property (nonatomic, readonly) NSArray *imageItems;

- (id)initWithUniqueName:(NSString *)uniqueName;

- (NSInteger)numberOfItems;
- (NSString *)uniqueNameForItemAtIndex:(NSInteger)index;
- (PTContentType)contentTypeForItemAtIndex:(NSInteger)index;
- (PTItemOrientation)orientationForItemAtIndex:(NSInteger)index;
- (NSString *)sourceForItemAtIndex:(NSInteger)index;
- (NSString *)textForItemAtIndex:(NSInteger)index;
- (NSInteger)relativeIndexForItemAtIndex:(NSInteger)index withContentType:(PTContentType)contentType;

- (void)reloadData;

@end
