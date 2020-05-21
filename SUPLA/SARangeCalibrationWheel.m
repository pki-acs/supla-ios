/*
Copyright (C) AC SOFTWARE SP. Z O.O.
This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

#import "SARangeCalibrationWheel.h"

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180.0)
#define RADIANS_TO_DEGREES(angrad)(angrad * 180.0 / M_PI)

#define TOUCHED_NONE 0
#define TOUCHED_LEFT 1
#define TOUCHED_RIGHT 2

@implementation SARangeCalibrationWheel {
    UIColor *_wheelColor;
    UIColor *_borderColor;
    UIColor *_btnColor;
    UIColor *_rangeColor;
    UIColor *_insideBtnColor;
    UIColor *_boostLineColor;
    CGFloat _borderLineWidth;
    double _maximumValue;
    double _minimumRange;
    double _numerOfTurns;
    double _minimum;
    double _maximum;
    double _leftEdge;
    double _rightEdge;
    double _boostLevel;
    BOOL _boostHidden;
    BOOL initialized;
    Byte touched;
    double lastTouchedDegree;
    CGFloat wheelRadius;
    CGFloat wheelWidth;
    CGFloat halfBtnSize;
    CGFloat btnRad;
    CGPoint btnRightCenter;
    CGPoint btnLeftCenter;
}

@synthesize delegate;

-(void)wheelInit {
    if ( initialized ) {
     return;
    }
   
    _maximumValue = 1000;
    _minimumRange = _maximumValue * 0.1;
    _numerOfTurns = 5;
    _minimum = 0;
    _maximum = _maximumValue;
    _leftEdge = 0;
    _rightEdge = _maximumValue;
    _boostLevel = 0;
    _boostHidden = YES;
    
    touched = TOUCHED_NONE;
    _borderLineWidth = 1.5;

    initialized = YES;
}

-(id)init {
    self = [super init];
    
    if ( self != nil ) {
        [self wheelInit];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if ( self != nil ) {
        [self wheelInit];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if ( self != nil ) {
        [self wheelInit];
    }

    return self;
}

- (void)setWheelColor:(UIColor *)wheelColor {
    _wheelColor = wheelColor == nil ? nil : [wheelColor copy];
    [self setNeedsDisplay];
}

- (UIColor*)wheelColor {
    if (_wheelColor == nil) {
        _wheelColor = [UIColor colorWithRed: 0.78 green: 0.84 blue: 0.94 alpha: 1.00];
    }
    return _wheelColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor == nil ? nil : [borderColor copy];
    [self setNeedsDisplay];
}

- (UIColor*)borderColor {
    if (_borderColor == nil) {
        _borderColor = [UIColor colorWithRed: 0.27 green: 0.52 blue: 0.91 alpha: 1.00];
    }
    return _borderColor;
}

- (void)setBtnColor:(UIColor *)btnColor {
    _btnColor = btnColor == nil ? nil : [btnColor copy];
    [self setNeedsDisplay];
}

- (UIColor*)btnColor {
    if (_btnColor == nil) {
        _btnColor = [UIColor colorWithRed: 0.27 green: 0.52 blue: 0.91 alpha: 1.00];
    }
    return _btnColor;
}

- (void)setRangeColor:(UIColor *)rangeColor {
    _rangeColor = rangeColor == nil ? nil : [rangeColor copy];
    [self setNeedsDisplay];
}

- (UIColor*)rangeColor {
    if (_rangeColor == nil) {
        _rangeColor = [UIColor colorWithRed: 1.00 green: 0.90 blue: 0.09 alpha: 1.00];
    }
    return _rangeColor;
}

- (void)setInsideBtnColor:(UIColor *)insideBtnColor {
    _insideBtnColor = insideBtnColor == nil ? nil : [insideBtnColor copy];
    [self setNeedsDisplay];
}

- (UIColor*)insideBtnColor {
    if (_insideBtnColor == nil) {
        _insideBtnColor = [UIColor whiteColor];
    }
    return _insideBtnColor;
}

- (void)setBoostLineColor:(UIColor *)boostLineColor {
    _boostLineColor = boostLineColor == nil ? nil : [boostLineColor copy];
    [self setNeedsDisplay];
}

-(UIColor*)boostLineColor {
    if (_boostLineColor == nil) {
        _boostLineColor = [UIColor redColor];
    }

    return _boostLineColor;
}

-(CGFloat)borderLineWidth {
    return _borderLineWidth;
}

-(void)setBorderLineWidth:(CGFloat)borderLineWidth {
    if (borderLineWidth < 0.1) {
        borderLineWidth = 0.1;
    }
    
    _borderLineWidth = borderLineWidth;
}

-(double) maximumValue {
    return _maximumValue;
}

-(void) setMaximumValue:(double)maximumValue {
    
    if (maximumValue < self.minimumRange) {
        maximumValue = self.minimumRange;
    }
    
    _maximumValue = maximumValue;
    
    if (_rightEdge > maximumValue) {
        self.rightEdge = maximumValue;
    }
    
    [self setNeedsDisplay];
}

-(double) minimumRange {
    return _minimumRange;
}

-(void) setMinimumRange:(double)minimumRange {
    if (minimumRange < 0) {
        minimumRange = 0;
    }
    if (minimumRange > self.maximumValue) {
        minimumRange = self.maximumValue;
    }
    
    _minimumRange = minimumRange;
    
    if (_minimumRange > self.rightEdge-self.leftEdge) {
        double diff = (_minimumRange - (self.rightEdge-self.leftEdge)) / 2;
        if (diff > self.leftEdge) {
            self.leftEdge = 0;
            self.rightEdge = _minimumRange;
        } else if (diff + self.rightEdge > self.maximumValue) {
            self.rightEdge = self.maximumValue;
            self.leftEdge = self.rightEdge - _minimumRange;
        } else {
            self.leftEdge -= diff;
            self.rightEdge += diff;
        }
    }
    
    if (_minimumRange > self.maximum - self.minimum) {
        double diff = (_minimumRange - (self.maximum-self.minimum)) / 2;
        if (self.minimum-diff < self.leftEdge) {
            self.minimum = self.leftEdge;
            self.maximum = self.minimum + _minimumRange;
        } else if (self.maximum + diff > self.rightEdge) {
            self.maximum = self.rightEdge;
            self.minimum = self.maximum - _minimumRange;
        } else {
            self.minimum -= diff;
            self.maximum += diff;
        }
    }
}

-(double)numerOfTurns {
    return _numerOfTurns;
}

-(void) setNumerOfTurns:(double)numerOfTurns {
    if (numerOfTurns < 1) {
        numerOfTurns = 1;
    }
    _numerOfTurns = numerOfTurns;
}

-(double)minimum {
    return _minimum;
}

-(void)setMinimum:(double)minimum needsDisplay:(BOOL)needsDisplay {
  
    if (minimum < self.leftEdge) {
        minimum = self.leftEdge;
    }
    
    if (minimum+self.minimumRange > self.maximum) {
        minimum = self.maximum - self.minimumRange;
    }
    
    _minimum = minimum;

    if (minimum > self.boostLevel) {
        _boostLevel = minimum;
    }
    
    if (needsDisplay) {
        [self setNeedsDisplay];
    }
}

-(void)setMinimum:(double)minimum {
    [self setMinimum:minimum needsDisplay:YES];
}

-(double)maximum {
    return _maximum;
}

-(void)setMaximum:(double)maximum needsDisplay:(BOOL)needsDisplay {
    
    if (maximum > self.rightEdge) {
        maximum = self.rightEdge;
    }
    
    if (self.minimum+self.minimumRange > maximum) {
        maximum = self.minimum+self.minimumRange;
    }
    
    _maximum = maximum;

    if (maximum < self.boostLevel) {
        _boostLevel = maximum;
    }

    if (needsDisplay) {
        [self setNeedsDisplay];
    }
}

-(void)setMaximum:(double)maximum {
    [self setMaximum:maximum needsDisplay:YES];
}

-(double)leftEdge {
    return _leftEdge;
}

-(void)setLeftEdge:(double)leftEdge {
    if (leftEdge < 0) {
        leftEdge = 0;
    }
    
    _leftEdge = leftEdge;

    if (leftEdge+self.minimumRange > self.rightEdge) {
        self.rightEdge = leftEdge + self.minimumRange;
    }
    
    double max = self.maximum;
    [self setMaximum:self.maximumValue needsDisplay:NO];
    [self setMinimum:self.minimum needsDisplay:NO];
    self.maximum = max;
}

-(double)rightEdge {
    return _rightEdge;
}

-(void)setRightEdge:(double)rightEdge {
    if (rightEdge < self.minimumRange) {
        rightEdge = self.minimumRange;
    }
    
    if (self.rightEdge > self.maximumValue) {
         rightEdge = self.maximumValue;
     }

    _rightEdge = rightEdge;
    
    if (self.leftEdge+self.minimumRange > rightEdge) {
        self.leftEdge = _rightEdge - self.minimumRange;
    }

    double min = self.minimum;
    [self setMinimum:0 needsDisplay:NO];
    [self setMaximum:self.maximum needsDisplay:NO];
    self.minimum = min;
}

-(double)boostLevel {
    return _boostLevel;
}

-(void)setBoostLevel:(double)boostLevel {
    if (boostLevel < self.minimum) {
        boostLevel = self.minimum;
    }

    if (boostLevel > self.maximum) {
        boostLevel = self.maximum;
    }

    _boostLevel = boostLevel;
    
    if (!self.boostHidden) {
        [self setNeedsDisplay];
    }
}

-(void)setBoostHidden:(BOOL)boostHidden {
    _boostHidden = boostHidden;
    [self setNeedsDisplay];
}

-(BOOL)boostHidden {
    return _boostHidden;
}

-(CGPoint)drawButtonWithCtx:(CGContextRef)cfx radius:(CGFloat)rad hidden:(BOOL)hidden {
    CGFloat btnSize = wheelWidth+self.borderLineWidth*4;
    halfBtnSize = btnSize / 2;
    CGFloat x = wheelRadius - self.borderLineWidth;
    CGPoint result = CGPointMake(cosf(rad)*wheelRadius, sinf(rad)*wheelRadius);
        
    if (hidden) {
        return result;
    }
    
    CGRect rect = CGRectMake(x-halfBtnSize, halfBtnSize * -1, halfBtnSize*2, halfBtnSize*2);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:3];

    [path applyTransform:CGAffineTransformMakeRotation(rad)];
    
    [self.btnColor setFill];
    [self.btnColor setStroke];
    
    [path fill];
    
    CGFloat hMargin = rect.size.height * 0.35;
    CGFloat wMargin = rect.size.width * 0.2;
    
    rect.origin.x += wMargin;
    rect.origin.y += hMargin;
    rect.size.height -= hMargin * 2;
    rect.size.width -= wMargin * 2;
    
    const Byte lc = 3;
    CGFloat step = rect.size.height / (lc-1);
    CGFloat lineWidth = self.borderLineWidth;
    
    [self.insideBtnColor setFill];
    
    for(float a=0;a<3;a++) {
        CGRect lineRect = CGRectMake(rect.origin.x,
                                     rect.origin.y+step*a-lineWidth/2.0,
                                     rect.size.width,
                                     lineWidth);
        
         path = [UIBezierPath bezierPathWithRoundedRect:lineRect cornerRadius:3];
         [path applyTransform:CGAffineTransformMakeRotation(rad)];
         [path fill];
    }
    
    return result;
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
   
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, YES);
    CGContextTranslateCTM(ctx, rect.size.width / 2, rect.size.height / 2);
    
    wheelRadius = (rect.size.width > rect.size.height
                  ? rect.size.height : rect.size.width) / 2;
    
    wheelRadius *= 0.8;
    wheelWidth = wheelRadius * 0.25;
    
    CGRect r;
    
    r.origin.x = wheelRadius * -1;
    r.origin.y = wheelRadius * -1;
    r.size.height = wheelRadius * 2;
    r.size.width = wheelRadius * 2;
   
    CGContextSetLineWidth(ctx, wheelWidth);
    CGContextSetStrokeColorWithColor(ctx, self.borderColor.CGColor);
    CGContextAddEllipseInRect(ctx, r);
    CGContextStrokePath(ctx);
    
    CGContextSetLineWidth(ctx, wheelWidth-self.borderLineWidth*2);
    CGContextSetStrokeColorWithColor(ctx, self.wheelColor.CGColor);
    CGContextAddEllipseInRect(ctx, r);
    CGContextStrokePath(ctx);
    
    if (touched == TOUCHED_NONE) {
        btnRightCenter = [self drawButtonWithCtx:ctx radius:DEGREES_TO_RADIANS(0) hidden:NO];
        btnLeftCenter = [self drawButtonWithCtx:ctx radius:DEGREES_TO_RADIANS(180) hidden:!_boostHidden];
    } else {
        if (touched == TOUCHED_RIGHT) {
             [self drawButtonWithCtx:ctx radius:btnRad hidden:NO];
        } else if (touched == TOUCHED_LEFT) {
             [self drawButtonWithCtx:ctx radius:btnRad hidden:!_boostHidden];
        }
    }
   
    CGFloat distanceToEdge = halfBtnSize + self.borderLineWidth * 2;
    CGRect valueFrame = CGRectMake(btnLeftCenter.x+distanceToEdge,
                                   btnLeftCenter.y-halfBtnSize,
                                   btnRightCenter.x -btnLeftCenter.x - distanceToEdge * 2,
                                   halfBtnSize * 2);
    
    [self.rangeColor setFill];
    
    CGFloat vmin = (valueFrame.size.width * self.minimum / self.maximumValue);
    
    r.origin.x = valueFrame.origin.x + vmin;
    r.origin.y = valueFrame.origin.y;
    r.size.height = valueFrame.size.height;
    r.size.width = valueFrame.size.width * self.maximum / self.maximumValue - vmin;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:r cornerRadius:3];
    [path fill];
    
    path = [UIBezierPath bezierPathWithRoundedRect:valueFrame cornerRadius:3];
    [path stroke];

    if (!self.boostHidden) {
        CGFloat vleft = valueFrame.origin.x + valueFrame.size.width * self.boostLevel/self.maximumValue;
        
        if (self.boostLevel >= (self.maximum-self.minimum) / 2) {
            vleft-=self.borderLineWidth;
        } else {
            vleft+=self.borderLineWidth;
        }
        
        [self.boostLineColor setStroke];
        

        CGContextSetLineWidth(ctx, self.borderLineWidth);
        CGContextMoveToPoint(ctx, vleft, valueFrame.origin.y);
        CGContextAddLineToPoint(ctx, vleft, valueFrame.origin.y+valueFrame.size.height);
        CGContextStrokePath(ctx);
    }
}

-(BOOL) isBtnTouchedWithCenterPointAt:(CGPoint)btnCenter touchPoint:(CGPoint)touchPoint {
    btnCenter.x += self.bounds.size.width / 2;
    btnCenter.y += self.bounds.size.height / 2;
    
    float touchRadius = sqrtf(pow(touchPoint.x - btnCenter.x, 2) + pow(touchPoint.y -btnCenter.y, 2));
    return touchRadius <= halfBtnSize*1.1;
}

-(void) onRangeChanged {
    if (self.delegate != nil) {
        [self.delegate calibrationWheelRangeChanged:self];
    }
}

-(void) onBoostChanged {
  if (self.delegate != nil) {
        [self.delegate calibrationWheelBoostChanged:self];
    }
}

-(UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    Byte _touched = TOUCHED_NONE;
    
    if (self.boostHidden && [self isBtnTouchedWithCenterPointAt:btnLeftCenter touchPoint:point]) {
        _touched = TOUCHED_LEFT;
        btnRad = DEGREES_TO_RADIANS(180);
        [self onRangeChanged];
    } else if ([self isBtnTouchedWithCenterPointAt:btnRightCenter touchPoint:point]) {
        _touched = TOUCHED_RIGHT;
        btnRad = 0;
        if (self.boostHidden) {
          [self onRangeChanged];
        } else {
          [self onBoostChanged];
        }
    }
    
    if (touched != _touched) {
        lastTouchedDegree = RADIANS_TO_DEGREES([self touchPointToRadian:point]);
        touched = _touched;
        [self setNeedsDisplay];
    }

    return touched == TOUCHED_NONE ? nil : self;
}

-(double) touchPointToRadian:(CGPoint)touchPoint {
    return atan2(touchPoint.y-self.bounds.size.height/2,
            touchPoint.x-self.bounds.size.width/2);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    if (touch == nil || touched == TOUCHED_NONE) {
        return;
    }
    
    CGPoint touchLocation = [touch locationInView:touch.view];

    btnRad = [self touchPointToRadian:touchLocation];
    double touchedDegree = RADIANS_TO_DEGREES(btnRad);
    
    double diff = touchedDegree-lastTouchedDegree;
    if (fabs(diff) > 100) {
        diff = 360 - fabs(lastTouchedDegree) - fabs(touchedDegree);
        if (touchedDegree > 0) {
            diff*=-1;
        }
    }
  
    if (fabs(diff) <= 20) {
        diff = (diff*100.0/360.0)*self.maximumValue/100/self.numerOfTurns;
        if (touched==TOUCHED_LEFT) {
            [self setMinimum:self.minimum+diff needsDisplay:NO];
            [self onRangeChanged];
        } else {
            if (_boostHidden) {
                [self setMaximum:self.maximum+diff needsDisplay:NO];
                [self onRangeChanged];
            } else {
                self.boostLevel += diff;
                [self onBoostChanged];
            }
        }
    }

    lastTouchedDegree = touchedDegree;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    touched = TOUCHED_NONE;
    btnRad = 0;
    [self setNeedsDisplay];
}

-(void) setMinimum:(double)minimum andMaximum:(double)maximum {
    [self setMinimum:0 needsDisplay:NO];
    [self setMaximum:self.maximumValue needsDisplay:NO];
    
    [self setMinimum:minimum needsDisplay:NO];
    [self setMaximum:maximum];
}

@end