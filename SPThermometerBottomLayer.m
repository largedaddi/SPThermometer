//
//  PLKThermometerBottomLayer.m
//  Dress
//
//  Created by Sean Pilkenton on 7/22/13.
//  Copyright (c) 2013 Patricio Enterprises. All rights reserved.
//

#import "SPThermometerBottomLayer.h"
#import "UIColor+RGBString.h"

@interface SPThermometerBottomLayer ()
@property (assign, nonatomic) CGFloat radius;
@property (strong, nonatomic) UIColor *color;
@end

@implementation SPThermometerBottomLayer

+ (id)layerWithRadius:(CGFloat)radius color:(UIColor *)color
{
  return [[SPThermometerBottomLayer alloc] initWithRadius:radius color:color];
}

- (id)initWithRadius:(CGFloat)radius color:(UIColor *)color
{
  self = [super  init];
  if (self) {
    self.radius = radius;
    self.color = color;
  }
  return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
  CGContextSetFillColorWithColor(ctx, self.color.CGColor);
  
  CGFloat radius = self.radius;
  CGFloat x = CGRectGetMidX(self.bounds);
  CGFloat y = self.bounds.size.height - radius;
  CGContextAddArc(ctx, x, y, radius, 0.0, 2 * M_PI, 0);
  CGContextDrawPath(ctx, kCGPathFill);
  
  CGContextFillRect(ctx, CGRectMake(10.0, 0.0, 20.0, x));
}

@end
