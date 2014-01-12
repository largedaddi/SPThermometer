//
//  PLKTemperatureBar.m
//  Dress
//
//  Created by Sean Pilkenton on 6/24/13.
//  Copyright (c) 2013 Patricio Enterprises. All rights reserved.
//

#import "SPThermometer.h"
#import "SPThermometerTopLayer.h"
#import "SPThermometerBottomLayer.h"
#import "UIColor+RGBString.h"
#import "PEDressUtil.h"
#import <QuartzCore/QuartzCore.h>

#define ANIMATION_DURATION 0.15
#define LAYER_SPACING 1.0

#define TOP_LAYER_MINIMUM_HEIGHT 47.0
#define BOTTOM_LAYER_MINIMUM_HEIGHT 52.0
#define ADJUSTABLE_HEIGHT 396.0

#define SELECTED_LAYER_EXTENDED_WIDTH 30.0
#define BOTTOM_LAYER_WIDTH 40.0
#define BOTTOM_LAYER_RADIUS 20.0
#define THERMOMETER_WIDTH 20.0

#define SELECTED_LAYER_HEIGHT 20.0

@interface SPThermometer ()

@property (strong, nonatomic) NSArray *ranges;
@property (assign, nonatomic) NSRange overallTemperatureRange;

- (void)commonInit;
- (void)setUpThermometerLayers;
- (void)initLayer:(CALayer *)l background:(UIColor *)bg;
- (void)setUpTemperatureGuides;

@end

@implementation SPThermometer {
  NSRange _defaultRange;
  
  SPThermometerTopLayer *_topLayer;
  CALayer *_adjustableTopLayer;
  CALayer *_selectedLayer;
  CALayer *_adjustableBottomLayer;
  SPThermometerBottomLayer *_bottomLayer;
  
  CATextLayer *_fahrenheightTextLayer;
  CATextLayer *_lowerBoundTextLayer;
  CATextLayer *_middleLowerTextLayer;
  CATextLayer *_middleMiddleTextLayer;
  CATextLayer *_middleUpperTextLayer;
  CATextLayer *_upperBoundTextLayer;
  
  CATextLayer *_temperatureRangeSelectedBottomTextLayer;
  CATextLayer *_temperatureRangeSelectedTopTextLayer;
  CATextLayer *_temperatureSelectedTextLayer;
  
  CGPoint _previousTouchPoint;
}

#pragma mark - Touch Overrides

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    BOOL isTouchPointValid = [self validateTouchPoint:touchPoint];
    if (isTouchPointValid) {
        _previousTouchPoint = touchPoint;
        [self hideSelectedTemperatureRangeText];
        [self resizeTemperatureRangeLayersWithTouch:NO];
        [self showSelectedTemperatureText:touchPoint disableActions:NO];
    }
    
    return isTouchPointValid;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    BOOL isTouchPointValid = [self validateTouchPoint:touchPoint];
    if (isTouchPointValid) {
        _previousTouchPoint = touchPoint;
        [self resizeTemperatureRangeLayersWithTouch:YES];
        [self updateSelectedTemperatureText:touchPoint disableActions:YES];
    }
    
    //  return isTouchPointValid;
    //  return [super continueTrackingWithTouch:touch withEvent:event];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
  int temperature = [_temperatureSelectedTextLayer.string intValue];
  [self selectRangeFromTemperature:temperature];
}

#pragma mark - Non-Touch Overrides

- (CGSize)intrinsicContentSize
{
    //  return CGSizeMake(92.0, 495.0);
    return CGSizeMake(40.0, 495.0);
}

#pragma mark - Init

- (id)initWithSize:(CGSize)s ranges:(NSArray *)ranges
{
  self = [super init];
  if (self) {
    self.ranges = ranges;
    [self commonInit];
  }
  return self;
}

- (void)commonInit
{
  _defaultRange = NSMakeRange(0, 166.0);
  
  [self setUpThermometerLayers];
  [self setUpTemperatureGuides];
//  [self setUpUserInteraction];
}

- (void)setUpThermometerLayers
{
  //  CGRect frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.intrinsicContentSize.width , self.intrinsicContentSize.height);
  
  CGFloat adjustableHeight = ADJUSTABLE_HEIGHT / 3.0;
  CGFloat selectedHeight = adjustableHeight - (LAYER_SPACING * 2);
  
  CGFloat originX = (self.intrinsicContentSize.width / 2) + (THERMOMETER_WIDTH / 2);
  CGFloat originY = 0.0;
  CGRect frame = CGRectMake(originX, originY, THERMOMETER_WIDTH, TOP_LAYER_MINIMUM_HEIGHT);
  _topLayer = [SPThermometerTopLayer layerWithColor:[UIColor colorWithRGBString:@"103 125 178"]];
//  _topLayer.backgroundColor = [UIColor colorWithRGBString:@"13 125 18"].CGColor;
  _topLayer.frame = frame;
  _topLayer.contentsScale = [UIScreen mainScreen].scale;
  //  [_topLayer setNeedsDisplay];
  [self.layer addSublayer:_topLayer];
  [_topLayer setNeedsDisplay];
  
  originY += frame.size.height;
  frame = CGRectMake(originX, originY, THERMOMETER_WIDTH, adjustableHeight);
  _adjustableTopLayer = [CALayer layer];
  _adjustableTopLayer.backgroundColor = [UIColor colorWithRGBString:@"103 125 178"].CGColor;
  _adjustableTopLayer.frame = frame;
  //  [_adjustableTopLayer setNeedsDisplay];
  [self.layer addSublayer:_adjustableTopLayer];
  
  originY += frame.size.height + LAYER_SPACING;
  frame = CGRectMake(originX, originY, THERMOMETER_WIDTH, selectedHeight);
  _selectedLayer = [CALayer layer];
  _selectedLayer.backgroundColor = [UIColor colorWithRGBString:@"246 245 118"].CGColor;
  _selectedLayer.frame = frame;
  //  [_selectedLayer setNeedsDisplay];
  [self.layer addSublayer:_selectedLayer];
  
  originY += frame.size.height + LAYER_SPACING;
  frame = CGRectMake(originX, originY, THERMOMETER_WIDTH, adjustableHeight);
  _adjustableBottomLayer = [CALayer layer];
  _adjustableBottomLayer.backgroundColor = [UIColor colorWithRGBString:@"235 53 74"].CGColor;
  _adjustableBottomLayer.frame = frame;
  //  [_adjustableBottomLayer setNeedsDisplay];
  [self.layer addSublayer:_adjustableBottomLayer];
  
  originX = (self.layer.bounds.size.width / 2) + (BOTTOM_LAYER_WIDTH / 2);
  originY += frame.size.height;
  frame = CGRectMake(originX, originY, BOTTOM_LAYER_WIDTH, BOTTOM_LAYER_MINIMUM_HEIGHT);
  _bottomLayer = [SPThermometerBottomLayer layerWithRadius:BOTTOM_LAYER_RADIUS color:[UIColor colorWithRGBString:@"235 53 74"]];
//  _bottomLayer.backgroundColor = [UIColor colorWithRGBString:@"13 125 18"].CGColor;
  _bottomLayer.frame = frame;
  _bottomLayer.contentsScale = [UIScreen mainScreen].scale;
  [self.layer addSublayer:_bottomLayer];
  [_bottomLayer setNeedsDisplay];
}

- (void)setUpTemperatureGuides
{
  _fahrenheightTextLayer = [self staticTextLayerInitWithString:@"˚F" anchorPoint:CGPointZero];
  _fahrenheightTextLayer.position = CGPointZero;
  [self.layer addSublayer:_fahrenheightTextLayer];
  
  CGFloat adjustableHeightSegment = ADJUSTABLE_HEIGHT / 4.0;
  CGFloat x = _fahrenheightTextLayer.bounds.size.width;
  CGPoint anchorPoint = CGPointMake(1.0, 0.0);
  CGPoint position = CGPointMake(x, _adjustableTopLayer.frame.origin.y - _upperBoundTextLayer.bounds.size.height / 2);
  
  _upperBoundTextLayer = [self staticTextLayerInitWithString:@"40" anchorPoint:anchorPoint];
  _upperBoundTextLayer.position = position;
  [self.layer addSublayer:_upperBoundTextLayer];
  
  position.y += adjustableHeightSegment;
  _middleUpperTextLayer = [self staticTextLayerInitWithString:@"30" anchorPoint:anchorPoint];
  _middleUpperTextLayer.position = position;
  [self.layer addSublayer:_middleUpperTextLayer];
  
  position.y += adjustableHeightSegment;
  _middleMiddleTextLayer = [self staticTextLayerInitWithString:@"20" anchorPoint:anchorPoint];
  _middleMiddleTextLayer.position = position;
  [self.layer addSublayer:_middleMiddleTextLayer];
  
  position.y += adjustableHeightSegment;
  _middleLowerTextLayer = [self staticTextLayerInitWithString:@"10" anchorPoint:anchorPoint];
  _middleLowerTextLayer.position = position;
  [self.layer addSublayer:_middleLowerTextLayer];
  
  _lowerBoundTextLayer = [self staticTextLayerInitWithString:@"0" anchorPoint:anchorPoint];
  _lowerBoundTextLayer.position = CGPointMake(x, _bottomLayer.frame.origin.y - _lowerBoundTextLayer.bounds.size.height / 2);
  [self.layer addSublayer:_lowerBoundTextLayer];
  
  anchorPoint = CGPointZero;
  position = _selectedLayer.frame.origin;
  position.x += _selectedLayer.bounds.size.width + 10.0;
  
//  
  _temperatureRangeSelectedTopTextLayer = [self staticTextLayerInitWithString:@"T" anchorPoint:anchorPoint];
  position.y -= _temperatureRangeSelectedTopTextLayer.bounds.size.height / 2;
  _temperatureRangeSelectedTopTextLayer.position = position;
  [self.layer addSublayer:_temperatureRangeSelectedTopTextLayer];

//  nothing until selected
  _temperatureSelectedTextLayer = [self staticTextLayerInitWithString:@"S" anchorPoint:anchorPoint];
  position.y += _selectedLayer.bounds.size.height / 2;
  _temperatureSelectedTextLayer.position = position;
  [self.layer addSublayer:_temperatureSelectedTextLayer];
  
//  
  _temperatureRangeSelectedBottomTextLayer = [self staticTextLayerInitWithString:@"B" anchorPoint:anchorPoint];
  position.y += _selectedLayer.bounds.size.height / 2;
  _temperatureRangeSelectedBottomTextLayer.position = position;
  [self.layer addSublayer:_temperatureRangeSelectedBottomTextLayer];
}

#pragma mark - API

//TODO: implement high-level (handles all the small tasks) range selection
- (void)selectRangeFromTemperature:(int)temperature
{
//  find range
  NSRange selectedRange = [self rangeForTemperature:temperature];
//  animate selected temperature block to fill selectedRange
  [self resizeTemperatureRangeLayersWithSelectedRange:selectedRange];
}

//TODO: implement reset
- (void)reset
{
  
}

#pragma mark - Temperature Range Layers

- (void)resizeTemperatureRangeLayersWithSelectedRange:(NSRange)range
{
  //  adjust all temperature ranges appropriately
    //  expand selected temperature block
      //  show selected temperature bounds (text)
}

- (void)resizeTemperatureRangeLayersWithTouch:(BOOL)disableActions
{
  float touchY = _previousTouchPoint.y;
  float touchYWithSelectedLayerTop = touchY - (SELECTED_LAYER_HEIGHT / 2);
  float touchYWithSelectedLayerBottom = touchY + (SELECTED_LAYER_HEIGHT / 2);
  
  if ([self belowUpperBound:touchYWithSelectedLayerTop] &&
      [self aboveLowerBound:touchYWithSelectedLayerBottom])
  {
    CGRect selectedLayerFrame = _selectedLayer.frame;
    selectedLayerFrame.origin.y = touchY - (SELECTED_LAYER_HEIGHT / 2);
    selectedLayerFrame.size.height = SELECTED_LAYER_HEIGHT;
    
    CGRect topLayerFrame = _adjustableTopLayer.frame;
    topLayerFrame.size.height = selectedLayerFrame.origin.y - topLayerFrame.origin.y - 1;
    
    CGRect bottomLayerFrame = _adjustableBottomLayer.frame;
    bottomLayerFrame.origin.y = selectedLayerFrame.origin.y + selectedLayerFrame.size.height + 1;
    bottomLayerFrame.size.height = _bottomLayer.frame.origin.y - bottomLayerFrame.origin.y;
    
    [CATransaction begin];
    [CATransaction setDisableActions:disableActions];
    _adjustableTopLayer.frame = topLayerFrame;
    _selectedLayer.frame = selectedLayerFrame;
    _adjustableBottomLayer.frame = bottomLayerFrame;
    [CATransaction commit];
  }
}

//TODO: implement selected temperature range (yellow block) expansion
- (void)expandSelectedRangeLayer
{
    
}

//TODO: implement selected temperature range contraction
- (void)contractSelectedRangeLayer
{
    
}

#pragma mark - Temperature Range Text Layers

- (void)showSelectedTemperatureText:(CGPoint)touchPoint disableActions:(BOOL)disableActions
{
  [self updateSelectedTemperatureText:touchPoint disableActions:disableActions];
//  _temperatureSelectedTextLayer.hidden = NO;
}

- (void)updateSelectedTemperatureText:(CGPoint)touchPoint
                         disableActions:(BOOL)disableActions
{
//  CGFloat temperature = [self convertTouchToTemperature:touchPoint];
  int temperature = [self convertTouchToTemperature:touchPoint];
//  NSString *string = [NSString stringWithFormat:@"%.f", roundf(temperature)];
  NSString *string = [NSString stringWithFormat:@"%d", temperature];
  CGRect frame = _selectedLayer.frame;
  UIFont *font = [UIFont fontWithName: @"Avenir-Book" size:14.0];
  CGSize s = [string sizeWithFont:font];
  
  _temperatureSelectedTextLayer.string = string;
  
  frame.origin.x = _temperatureSelectedTextLayer.frame.origin.x;
  frame.size = s;
  
  [CATransaction begin];
  [CATransaction setDisableActions:disableActions];
  _temperatureSelectedTextLayer.frame = frame;
  [CATransaction commit];
}

//TODO: implement animated hiding of selected temperature range text (bottom and top yellow bounds)
- (void)hideSelectedTemperatureRangeText
{
  //  _temperatureRangeSelectedTopTextLayer.hidden = YES;
  //  _temperatureRangeSelectedBottomTextLayer.hidden = YES;
}

//TODO: implement animated appearance of selected temperature range text
- (void)showSelectedTemperatureRangeText
{
  
}

#pragma mark - Setters

//- (void)setSelectedTemperatureRange:(NSRange)yellowTemperatureRange
//{
//  _yellowTemperatureRange = yellowTemperatureRange;
//
//  if (_extended) {
//    [CATransaction begin];
//    [CATransaction setAnimationDuration:ANIMATION_DURATION];
//    [CATransaction setCompletionBlock:^{
//      [CATransaction begin];
//      [CATransaction setAnimationDuration:ANIMATION_DURATION];
//      [CATransaction setCompletionBlock:^{
//        [self adjustYellowHeight:50.0];
//        [self showYellowTemperatureRangeText];
//      }];
//      [self adjustWidths];
//      [CATransaction commit];
//    }];
//    [self adjustYellowHeight:11.0];
//    [CATransaction commit];
//  } else {
//    [CATransaction begin];
//    [CATransaction setAnimationDuration:ANIMATION_DURATION];
//    [CATransaction setCompletionBlock:^{
//      [self adjustYellowHeight:50.0];
//      [self showYellowTemperatureRangeText];
//      _extended = !_extended;
//    }];
//    [self adjustWidths];
//    [CATransaction commit];
//  }
//}

//- (void)showYellowTemperatureRangeText
//{
//  _middleLowerTextLayer.string = [NSString stringWithFormat:@"%d - %d", _yellowTemperatureRange.location, _yellowTemperatureRange.location + _yellowTemperatureRange.length];
//
//  [CATransaction begin];
//  [CATransaction setCompletionBlock:^{
//    _middleLowerTextLayer.opacity = 1.0;
//  }];
//
//  _middleLowerTextLayer.hidden = NO;
//
//  if (CGRectIntersectsRect(_selectedLayer.frame, _lowerBoundTextLayer.frame)) {
//    _lowerBoundTextLayer.opacity = 0.0;
//    _lowerBoundTextLayer.hidden = YES;
//  } else if (CGRectIntersectsRect(_selectedLayer.frame, _upperBoundTextLayer.frame)) {
//    _middleLowerTextLayer.string = [_middleLowerTextLayer.string stringByAppendingString:@"˚F"];
//    _upperBoundTextLayer.opacity = 0.0;
//    _upperBoundTextLayer.hidden = YES;
//  } else {
//    _lowerBoundTextLayer.opacity = 1.0;
//    _lowerBoundTextLayer.hidden = NO;
//    _upperBoundTextLayer.opacity = 1.0;
//    _upperBoundTextLayer.hidden = NO;
//  }
//
//  CGSize s = [_middleLowerTextLayer.string sizeWithFont:[UIFont fontWithName:@"Avenir-Book" size:14.0]];
//  _middleLowerTextLayer.bounds = CGRectMake(0, 0, s.width, s.height);
//  _middleLowerTextLayer.position = CGPointMake(CGRectGetMidX(_selectedLayer.frame), CGRectGetMaxY(_selectedLayer.frame));
//
//  [CATransaction commit];
//}

- (void)hideYellowTemperatureRangeText
{
  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    _middleLowerTextLayer.hidden = YES;
  }];
  _middleLowerTextLayer.opacity = 0.0;
  [CATransaction commit];
}

#pragma mark - Temperature Ranges

- (NSArray *)parseTemperatureRanges:(NSArray *)ranges
{
  
//  @[@"0-15", @"16-28", @"29-40"];
  [ranges enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
    if (![self containsOnlyNumbers:obj]) {
      
      return;
    }
  }];
  return @[];
}

//- (void)adjustWidths
//{
//  int yellowTemperatureLowerBound = _yellowTemperatureRange.location;
//  int yellowTemperatureUpperBound = _yellowTemperatureRange.location + _yellowTemperatureRange.length;
//
//  int firstBound = [PEDressUtil mapValue:yellowTemperatureLowerBound
//                               fromRange:_temperatureRange
//                                 toRange:_defaultRange];
//  CGRect frame = _topLayer.frame;
//  NSLog(@"frame: %@", NSStringFromCGRect(frame));
//  frame.size.width = (CGFloat)firstBound;
//  _topLayer.frame = frame;
//
//  int yellowBound = [PEDressUtil mapValue:yellowTemperatureUpperBound
//                                fromRange:_temperatureRange
//                                  toRange:_defaultRange];
//  frame = _selectedLayer.frame;
//  CGFloat boundWithPadding = firstBound + 1;
//  frame.size.width = yellowBound - boundWithPadding;
//  frame.origin.x = boundWithPadding;
//  _selectedLayer.frame = frame;
//
//  int thirdBound = self.bounds.size.width;
//  boundWithPadding = yellowBound + 1;
//
//  int defaultWidth = (_defaultRange.location + _defaultRange.length);
//  if (boundWithPadding > defaultWidth) {
//    boundWithPadding = 166.0;
//  }
//
//  CGFloat blueWidth = thirdBound - boundWithPadding;
//  frame = _bottomLayer.frame;
//  frame.size.width = blueWidth;
//  frame.origin.x = boundWithPadding;
//  _bottomLayer.frame = frame;
//}

//- (void)adjustYellowHeight:(CGFloat)h
//{
//  _intrinsicHeight = h;
//  [self invalidateIntrinsicContentSize];
//  CGRect frame = _selectedLayer.frame;
//  frame.size.height = _intrinsicHeight;
//  _selectedLayer.frame = frame;
//}

#pragma mark - App Specific Utils

- (CATextLayer *)staticTextLayerInitWithString:(NSString *)text anchorPoint:(CGPoint)anchorPoint
{
    UIFont *font = [UIFont fontWithName: @"Avenir-Book" size:14.0];
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIColor *textColor = [UIColor whiteColor];
    
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = text;
    textLayer.foregroundColor = textColor.CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.font = (__bridge void*)(font.fontName);
    textLayer.fontSize = 14.0;
    CGSize s = [text sizeWithFont:font];
    textLayer.bounds = CGRectMake(0.0, 0.0, s.width, s.height);
    textLayer.contentsScale = scale;
    textLayer.anchorPoint = anchorPoint;
    
    return textLayer;
}

- (BOOL)belowUpperBound:(CGFloat)y
{
  return y > TOP_LAYER_MINIMUM_HEIGHT + 1;
}

- (BOOL)aboveLowerBound:(CGFloat)y
{
  return y < self.bounds.size.height - BOTTOM_LAYER_MINIMUM_HEIGHT - 1;
}

- (BOOL)withinBounds:(CGFloat)y
{
//  return (y > TOP_LAYER_MINIMUM_HEIGHT &&
//          y < self.bounds.size.height - BOTTOM_LAYER_MINIMUM_HEIGHT);
  return ([self belowUpperBound:y] && [self aboveLowerBound:y]);
}

- (BOOL)validateTouchPoint:(CGPoint)tp
{
//  return (tp.y > TOP_LAYER_MINIMUM_HEIGHT &&
//          tp.y < self.bounds.size.height - BOTTOM_LAYER_MINIMUM_HEIGHT);
  return [self withinBounds:tp.y];
}

- (BOOL)validateSelectedLayerPosition
{
  CGFloat selectedLayerHeight = _selectedLayer.bounds.size.height;
  CGFloat selectedLayerTopY = _selectedLayer.position.y - selectedLayerHeight / 2;
  CGFloat selectedLayerBottomY = selectedLayerTopY + selectedLayerHeight;
  return ([self withinBounds:selectedLayerTopY] && [self withinBounds:selectedLayerBottomY]);
}

//- (CGFloat)convertTouchToTemperature:(CGPoint)touch
- (int)convertTouchToTemperature:(CGPoint)touch
{
  CGSize s = [self intrinsicContentSize];
  CGFloat height = s.height - TOP_LAYER_MINIMUM_HEIGHT - BOTTOM_LAYER_MINIMUM_HEIGHT;
  CGFloat temperature = (touch.y - TOP_LAYER_MINIMUM_HEIGHT) / height;
  temperature = 1.0 - temperature;
  temperature *= 40.0;
  temperature += 0.5;
  return (int)temperature;
}

- (NSRange)rangeForTemperature:(int)temperature
{
  for (NSValue *range in self.ranges) {
    NSRange raw = [range rangeValue];
    if (NSLocationInRange(temperature, raw)) {
      return raw;
    }
  }
  
  return NSMakeRange(NSNotFound, 0);
}

#pragma mark - Utils

- (BOOL)containsOnlyNumbers:(NSString *)string
{
  NSCharacterSet *numericCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
  NSCharacterSet *stringCharacterSet = [NSCharacterSet characterSetWithCharactersInString:string];
  return [numericCharacterSet isSupersetOfSet:stringCharacterSet];
}

#pragma mark - Public

//- (void)reset
//{
//  //  [self hideYellowTemperatureRangeText];
//  [self adjustYellowHeight:11.0];
//
//  _extended = NO;
//  //  self.temperatureRange = NSMakeRange(17, 16);
//}

@end