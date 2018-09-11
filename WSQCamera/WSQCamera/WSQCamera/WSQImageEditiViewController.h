//
//  WSQImageEditiViewController.h
//  WSQCamera
//
//  Created by 翁胜琼 on 2018/9/5.
//  Copyright © 2018年 Dev John. All rights reserved.
//  编辑图片

#import <UIKit/UIKit.h>

@protocol WSQImageEditiViewControllerDelegate;

@interface WSQImageEditiViewController : UIViewController

// 代理
@property (nonatomic, weak) id<WSQImageEditiViewControllerDelegate> delegate;


/**
 初始化

 @param image 需要被编辑的图片
 @return 初始化
 */
- (instancetype)initWithImage:(UIImage *)image;

@end

@protocol WSQImageEditiViewControllerDelegate <NSObject>

// 完成编辑回调
- (void)imageEditViewController:(WSQImageEditiViewController *)controller didFinishWithEditImage:(UIImage *)editedImage;

// 取消编辑回调
- (void)imageEditViewControllerDidCancel:(WSQImageEditiViewController *)controller;


@end
