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

#import <Foundation/Foundation.h>

#import "PTShowcase.h"

@class PTShowcaseView;

@protocol PTShowcaseViewDataSource <NSObject>

@required
- (NSInteger)numberOfItemsInShowcaseView:(PTShowcaseView *)showcaseView;
- (PTContentType)showcaseView:(PTShowcaseView *)showcaseView contentTypeForItemAtIndex:(NSInteger)index;
- (NSString *)showcaseView:(PTShowcaseView *)showcaseView pathForItemAtIndex:(NSInteger)index;

@optional
- (NSString *)showcaseView:(PTShowcaseView *)showcaseView uniqueNameForItemAtIndex:(NSInteger)index;
- (NSString *)showcaseView:(PTShowcaseView *)showcaseView sourceForThumbnailImageOfItemAtIndex:(NSInteger)index;
- (NSString *)showcaseView:(PTShowcaseView *)showcaseView textForItemAtIndex:(NSInteger)index;

@end
