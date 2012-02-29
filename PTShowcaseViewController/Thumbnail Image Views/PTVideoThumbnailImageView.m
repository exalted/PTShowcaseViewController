//
//  PTVideoThumbnailImageView.m
//  ShowcaseDemo
//
//  Created by Ali Servet Donmez on 28.2.12.
//  Copyright (c) 2012 Apex-net srl. All rights reserved.
//

#import "PTVideoThumbnailImageView.h"

@implementation PTVideoThumbnailImageView

+ (UIImage *)applyMask:(UIImage *)image
{
    CGImageRef maskImageRef = [[UIImage imageNamed:@"PTShowcase.bundle/video-mask.png"] CGImage];
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
    self.image = [PTVideoThumbnailImageView applyMask:image];
}

@end
