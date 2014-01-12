//
//  PLKTemperatureBar.h
//  Dress
//
//  Created by Sean Pilkenton on 6/24/13.
//  Copyright (c) 2013 Patricio Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPThermometer : UIControl

@property (assign, nonatomic) NSRange temperatureRange;
@property (assign, nonatomic) NSRange selectedTemperatureRange;

- (void)reset;
- (id)initWithSize:(CGSize)s ranges:(NSArray *)ranges;

@end
