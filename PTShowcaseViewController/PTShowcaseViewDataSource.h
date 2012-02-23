//
//  PTShowcaseViewDataSource.h
//  ShowcaseDemo
//
//  Created by Ali Servet Donmez on 10.2.12.
//  Copyright (c) 2012 Apex-net srl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PTShowcase.h"

@class PTShowcaseView;

@protocol PTShowcaseViewDataSource <NSObject>

@required
- (NSInteger)numberOfItemsInShowcaseView:(PTShowcaseView *)showcaseView;
- (PTContentType)showcaseView:(PTShowcaseView *)showcaseView contentTypeForItemAtIndex:(NSInteger)index;
- (NSString *)showcaseView:(PTShowcaseView *)showcaseView sourceForItemAtIndex:(NSInteger)index;

@optional
- (NSString *)showcaseView:(PTShowcaseView *)showcaseView uniqueNameForItemAtIndex:(NSInteger)index;

@end
