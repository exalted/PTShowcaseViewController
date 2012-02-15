//
//  PTShowcaseView.h
//  ShowcaseDemo
//
//  Created by Ali Servet Donmez on 10.2.12.
//  Copyright (c) 2012 Apex-net srl. All rights reserved.
//

#import "GMGridView.h"

@protocol PTShowcaseViewDelegate;
@protocol PTShowcaseViewDataSource;

@interface PTShowcaseView : GMGridView

@property(nonatomic, assign) id<PTShowcaseViewDelegate> showcaseDelegate;
@property(nonatomic, assign) id<PTShowcaseViewDataSource> showcaseDataSource;

@end
