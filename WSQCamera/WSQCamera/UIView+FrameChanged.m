//
//  UIView+FrameChanged.m
//  自定义转场测试
//
//  Created by 翁胜琼 on 2018/3/14.
//  Copyright © 2018年 翁胜琼. All rights reserved.
//  快速改变视图的 frame

#import "UIView+FrameChanged.h"
//#import <objc/runtime.h>
//
//const NSString *maxXKey = @"maxX";
//const NSString *maxYKey = @"maxY";

@implementation UIView (FrameChanged)

-(void)setX:(CGFloat)x
{
    CGRect origionalFrame = self.frame;
    self.frame = CGRectMake(x, origionalFrame.origin.y, origionalFrame.size.width, origionalFrame.size.height);
}

-(CGFloat)x
{
    return self.frame.origin.x;
}

-(void)setY:(CGFloat)y
{
    CGRect origionalFrame = self.frame;
    self.frame = CGRectMake(origionalFrame.origin.x, y, origionalFrame.size.width, origionalFrame.size.height);
}
-(CGFloat)y
{
    return self.frame.origin.y;
}

-(void)setWidth:(CGFloat)width
{
    CGRect origionalFrame = self.frame;
    self.frame = CGRectMake(origionalFrame.origin.x, origionalFrame.origin.y, width, origionalFrame.size.height);
}

-(CGFloat)width
{
    return self.frame.size.width;
}

-(void)setHeight:(CGFloat)height
{
    CGRect origionalFrame = self.frame;
    self.frame = CGRectMake(origionalFrame.origin.x, origionalFrame.origin.y,  origionalFrame.size.width,height);
}

-(CGFloat)height
{
    return self.frame.size.height;
}

-(CGFloat)maxX
{
    return self.x + self.width;
}

-(CGFloat)maxY
{
    return self.y + self.height;
}


@end
