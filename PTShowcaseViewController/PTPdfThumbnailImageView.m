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
