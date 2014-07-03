//
//  UIImage+BlurEffects.h
//  Expo
//
//  Created by Ben Gotow on 10/23/13.
//  Copyright (c) 2013 Expo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BlurEffects)

+ (UIImage *)imageWithColor:(UIColor*)color;

- (UIImage *)imageScaledAspectFill:(CGSize)targetSize;

// from http://stackoverflow.com/questions/17041669/creating-a-blurring-overlay-view
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end
