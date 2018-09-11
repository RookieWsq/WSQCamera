//
//  Macros.h
//  WSQOCTools
//
//  Created by 翁胜琼 on 2018/8/28.
//  Copyright © 2018年 Dev John. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

/** 弱引用 */
#define WEAKSELF __weak typeof(self) weakSelf = self;

/** 获取UserDefaults */
#define DEFAULTS [NSUserDefaults standardUserDefaults]

/** appdelegate */
#define APPDELEGATE ((AppDelegate *)[UIApplication sharedApplication].delegate)

/** keywindow */
#define KEYWINDOW  [UIApplication sharedApplication].keyWindow

// MARK: - 视图相关
// View 圆角和加边框
#define ViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

// View 圆角
#define ViewRadius(View, Radius)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES]

// MARK: - 屏幕相关
#define Screen_Height      [[UIScreen mainScreen] bounds].size.height
#define Screen_Width       [[UIScreen mainScreen] bounds].size.width
#define Screen_Bounds      [UIScreen mainScreen] bounds]

#define Screen_TabBarHeight   ((StatusHeight==44)?83.0f:49.0f)
#define StatusHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define Screen_NavBarHeight   ((StatusHeight==44)?88:64)

// MARK:  屏幕适配
//#define iphone6p (ScreenH == 763)
//#define iphone6 (ScreenH == 667)
//#define iphone5 (ScreenH == 568)
//#define iphone4 (ScreenH == 480)

// MARK: -  颜色相关
// 快速设置颜色
#define UICOLORFROMHEXA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define UICOLORFROMHEX(r,g,b) UICOLORFROMHEXA(r,g,b,1.0f)

// 传入0x123233 十六位参数
#define UICOLORFROMHEX(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:1]

// 主题色
#define  WSQThemeColor UICOLORFROMHEX(245,245,245)

// 常用颜色
#define black_color     [UIColor blackColor]
#define blue_color      [UIColor blueColor]
#define brown_color     [UIColor brownColor]
#define clear_color     [UIColor clearColor]
#define darkGray_color  [UIColor darkGrayColor]
#define darkText_color  [UIColor darkTextColor]
#define white_color     [UIColor whiteColor]
#define yellow_color    [UIColor yellowColor]
#define red_color       [UIColor redColor]
#define orange_color    [UIColor orangeColor]
#define purple_color    [UIColor purpleColor]
#define lightText_color [UIColor lightTextColor]
#define lightGray_color [UIColor lightGrayColor]
#define green_color     [UIColor greenColor]
#define gray_color      [UIColor grayColor]
#define magenta_color   [UIColor magentaColor]
#define line_color      RGB_Color(236, 236, 236)


// MARK: -  文字相关
#define WSQFont20 [UIFont fontWithName:PFR size:20];
#define WSQFont18 [UIFont fontWithName:PFR size:18];
#define WSQFont16 [UIFont fontWithName:PFR size:16];
#define WSQFont15 [UIFont fontWithName:PFR size:15];
#define WSQFont14 [UIFont fontWithName:PFR size:14];
#define WSQFont13 [UIFont fontWithName:PFR size:13];
#define WSQFont12 [UIFont fontWithName:PFR size:12];
#define WSQFont11 [UIFont fontWithName:PFR size:11];
#define WSQFont10 [UIFont fontWithName:PFR size:10];
#define WSQFont9 [UIFont fontWithName:PFR size:9];
#define WSQFont8 [UIFont fontWithName:PFR size:8];


#endif /* Macros_h */
