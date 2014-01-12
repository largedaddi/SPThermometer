//
//  PLKThermometerTopLayer.m
//  Dress
//
//  Created by Sean Pilkenton on 7/22/13.
//  Copyright (c) 2013 Patricio Enterprises. All rights reserved.
//

#import "SPThermometerTopLayer.h"

@interface SPThermometerTopLayer ()
@property(strong, nonatomic) UIColor *color;
@end

@implementation SPThermometerTopLayer

- (id)initWithColor:(UIColor *)color
{
  self = [super init];
  if (self) {
    self.color = color;
  }
  return self;
}

+ (id)layerWithColor:(UIColor *)color
{
  return [[SPThermometerTopLayer alloc] initWithColor:color];
}

- (void)drawInContext:(CGContextRef)ctx
{
  CGContextSetFillColorWithColor(ctx, self.color.CGColor);
  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                             byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                   cornerRadii:CGSizeMake(10.0, 10.0)];
  CGContextAddPath(ctx, path.CGPath);
  CGContextFillPath(ctx);
}

@end
