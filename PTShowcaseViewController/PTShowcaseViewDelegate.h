//
//  PTShowcaseViewDelegate.h
//  ShowcaseDemo
//
//  Created by Ali Servet Donmez on 10.2.12.
//  Copyright (c) 2012 Apex-net srl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PTShowcase.h"

@class PTShowcaseView;

@protocol PTShowcaseViewDelegate <NSObject>

@optional
- (PTItemOrientation)showcaseView:(PTShowcaseView *)showcaseView orientationForItemAtIndex:(NSInteger)index;

@end
