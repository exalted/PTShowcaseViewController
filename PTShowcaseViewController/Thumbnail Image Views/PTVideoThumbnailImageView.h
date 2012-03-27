//
//  PTVideoThumbnailImageView.h
//  ShowcaseDemo
//
//  Created by Ali Servet Donmez on 28.2.12.
//  Copyright (c) 2012 Apex-net srl. All rights reserved.
//

#import "NINetworkImageView.h"

#import "PTShowcase.h"

@interface PTVideoThumbnailImageView : NINetworkImageView

@property (nonatomic, assign) PTItemOrientation orientation;

+ (UIImage *)applyMask:(UIImage *)image forOrientation:(PTItemOrientation)orientation;

@end
