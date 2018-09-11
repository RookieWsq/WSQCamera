//
//  WSQCameraViewController.h
//  WSQCamera
//
//  Created by 翁胜琼 on 2018/9/4.
//  Copyright © 2018年 Dev John. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WSQCameraViewControllerDelegate;

@interface WSQCameraViewController : UIViewController

// 代理
@property (nonatomic, weak) id<WSQCameraViewControllerDelegate> delegate;

/**
 是否拍照完成后点击完成按钮自动保存到相册，默认是 YES
 */
@property (nonatomic,assign) BOOL autoSaveToLibray;

@end

@protocol WSQCameraViewControllerDelegate <NSObject>

// 完成编辑回调
- (void)imageEditViewController:(WSQCameraViewController *)controller didFinishWithEditImage:(UIImage *)editedImage;

// 取消编辑回调
- (void)imageEditViewControllerDidCancel:(WSQCameraViewController *)controller;


@end
