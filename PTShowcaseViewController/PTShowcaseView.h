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
- (NSString *)sourceForItemThumbnailAtIndex:(NSInteger)index;
- (NSString *)textForItemAtIndex:(NSInteger)index;
- (NSInteger)relativeIndexForItemAtIndex:(NSInteger)index withContentType:(PTContentType)contentType;

- (void)reloadData;

@end
