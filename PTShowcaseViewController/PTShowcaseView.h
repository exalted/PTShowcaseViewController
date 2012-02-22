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

@property (nonatomic, readonly) NSArray *imageItems;

- (NSInteger)numberOfImages;
- (PTContentType)contentTypeForImageAtIndex:(NSInteger)index;
- (PTItemOrientation)orientationForImageAtIndex:(NSInteger)index;
- (NSString *)sourceForImageAtIndex:(NSInteger)index;

- (void)reloadData;

@end
