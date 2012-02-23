//
//  PTShowcaseViewController.h
//  ShowcaseDemo
//
//  Created by Ali Servet Donmez on 10.2.12.
//  Copyright (c) 2012 Apex-net srl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PTShowcaseViewDelegate.h"
#import "PTShowcaseViewDataSource.h"

#import "PTShowcaseView.h"

@interface PTShowcaseViewController : UIViewController <PTShowcaseViewDelegate, PTShowcaseViewDataSource>

@property (nonatomic, retain) PTShowcaseView *showcaseView;

- (id)initWithUniqueName:(NSString *)uniqueName;

@end
