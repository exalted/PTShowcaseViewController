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

@class PTShowcaseView;

typedef enum {
    PTItemOrientationPortrait,
    PTItemOrientationLandscape,
} PTItemOrientation;

typedef enum {
    PTContentTypeGroup,
    PTContentTypeImage,
    PTContentTypeVideo,
    PTContentTypePdf,
} PTContentType;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegate protocol definition
////////////////////////////////////////////////////////////////////////////////
@protocol PTShowcaseViewDelegate <NSObject>

@optional
- (PTItemOrientation)showcaseView:(PTShowcaseView *)showcaseView orientationForItemAtIndex:(NSInteger)index;

- (void)showcaseView:(PTShowcaseView *)showcaseView didPrepareReusableThumbnailView:(UIView *)view forContentType:(PTContentType)contentType andOrientation:(PTItemOrientation)orientation;
- (void)showcaseView:(PTShowcaseView *)showcaseView willDisplayThumbnailView:(UIView *)view forItemAtIndex:(NSInteger)index;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Data source protocol definition
////////////////////////////////////////////////////////////////////////////////
@protocol PTShowcaseViewDataSource <NSObject>

@required
- (NSInteger)numberOfItemsInShowcaseView:(PTShowcaseView *)showcaseView;
- (PTContentType)showcaseView:(PTShowcaseView *)showcaseView contentTypeForItemAtIndex:(NSInteger)index;
- (NSString *)showcaseView:(PTShowcaseView *)showcaseView pathForItemAtIndex:(NSInteger)index;

@optional
- (NSString *)showcaseView:(PTShowcaseView *)showcaseView uniqueNameForItemAtIndex:(NSInteger)index;
- (NSString *)showcaseView:(PTShowcaseView *)showcaseView sourceForThumbnailImageOfItemAtIndex:(NSInteger)index;
- (NSString *)showcaseView:(PTShowcaseView *)showcaseView textForItemAtIndex:(NSInteger)index;
- (NSString *)showcaseView:(PTShowcaseView *)showcaseView detailTextForItemAtIndex:(NSInteger)index;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class interface
////////////////////////////////////////////////////////////////////////////////
@interface PTShowcaseView : GMGridView

@property (assign, nonatomic) id<PTShowcaseViewDelegate> showcaseDelegate;
@property (assign, nonatomic) id<PTShowcaseViewDataSource> showcaseDataSource;

@property (retain, nonatomic, readonly) NSString *uniqueName;

@property (retain, nonatomic, readonly) NSArray *imageItems;

- (id)initWithUniqueName:(NSString *)uniqueName;

- (NSInteger)numberOfItems;

- (PTContentType)contentTypeForItemAtIndex:(NSInteger)index;
- (PTItemOrientation)orientationForItemAtIndex:(NSInteger)index;

- (CGSize)sizeForThumbnailImageOfItemAtIndex:(NSInteger)index;

- (NSString *)pathForItemAtIndex:(NSInteger)index;

- (NSString *)uniqueNameForItemAtIndex:(NSInteger)index;
- (NSString *)sourceForThumbnailImageOfItemAtIndex:(NSInteger)index;
- (NSString *)textForItemAtIndex:(NSInteger)index;
- (NSString *)detailTextForItemAtIndex:(NSInteger)index;

- (NSInteger)indexForItemAtRelativeIndex:(NSInteger)relativeIndex withContentType:(PTContentType)contentType;
- (NSInteger)relativeIndexForItemAtIndex:(NSInteger)index withContentType:(PTContentType)contentType;

- (void)reloadData;

@end
