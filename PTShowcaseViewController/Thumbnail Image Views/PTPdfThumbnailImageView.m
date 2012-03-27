//
//  PTPdfThumbnailImageView.m
//  ShowcaseDemo
//
//  Created by Ali Servet Donmez on 28.2.12.
//  Copyright (c) 2012 Apex-net srl. All rights reserved.
//

#import "PTPdfThumbnailImageView.h"

@implementation PTPdfThumbnailImageView

@synthesize orientation = _orientation;

+ (UIImage *)applyMask:(UIImage *)image forOrientation:(PTItemOrientation)orientation
{
    CGImageRef maskImageRef = [[UIImage imageNamed:@"PTShowcase.bundle/document-mask.png"] CGImage];
    CGImageRef maskRef = CGImageMaskCreate(CGImageGetWidth(maskImageRef),
                                           CGImageGetHeight(maskImageRef),
                                           CGImageGetBitsPerComponent(maskImageRef),
                                           CGImageGetBitsPerPixel(maskImageRef),
                                           CGImageGetBytesPerRow(maskImageRef),
                                           CGImageGetDataProvider(maskImageRef),
                                           NULL,
                                           NO);
    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], maskRef);
    CGImageRelease(maskRef);
    
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    CGImageRelease(maskedImageRef);
    
    return maskedImage;
}

- (void)networkImageViewDidLoadImage:(UIImage *)image {
    self.image = [PTPdfThumbnailImageView applyMask:image forOrientation:self.orientation];
}

@end
