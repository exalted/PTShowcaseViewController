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

#import "GMGridView.h"

#import "PTShowcase.h"

#import "PTShowcaseViewDelegate.h"
#import "PTShowcaseViewDataSource.h"

@interface PTShowcaseView : GMGridView

@property (nonatomic, assign) id<PTShowcaseViewDelegate> showcaseDelegate;
@property (nonatomic, assign) id<PTShowcaseViewDataSource> showcaseDataSource;

@property (nonatomic, retain, readonly) NSString *uniqueName;

@property (nonatomic, readonly) NSArray *imageItems;

- (id)initWithUniqueName:(NSString *)uniqueName;

- (NSInteger)numberOfItems;

- (PTContentType)contentTypeForItemAtIndex:(NSInteger)index;
- (PTItemOrientation)orientationForItemAtIndex:(NSInteger)index;

- (NSString *)pathForItemAtIndex:(NSInteger)index;

- (NSString *)uniqueNameForItemAtIndex:(NSInteger)index;
- (NSString *)sourceForThumbnailImageOfItemAtIndex:(NSInteger)index;
- (NSString *)textForItemAtIndex:(NSInteger)index;

- (NSInteger)indexForItemAtRelativeIndex:(NSInteger)relativeIndex withContentType:(PTContentType)contentType;
- (NSInteger)relativeIndexForItemAtIndex:(NSInteger)index withContentType:(PTContentType)contentType;

- (void)reloadData;

@end
