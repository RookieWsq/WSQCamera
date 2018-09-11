//
//  UIView+FrameChanged.h
//  自定义转场测试
//
//  Created by 翁胜琼 on 2018/3/14.
//  Copyright © 2018年 翁胜琼. All rights reserved.
//  快速改变视图的 frame

#import <UIKit/UIKit.h>

@interface UIView (FrameChanged)

@property (nonatomic,assign) CGFloat x;
@property (nonatomic,assign) CGFloat y;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign,readonly) CGFloat maxX;
@property (nonatomic,assign,readonly) CGFloat maxY;

@end
