//
//  ViewController.m
//  WSQCamera
//
//  Created by 翁胜琼 on 2018/9/4.
//  Copyright © 2018年 Dev John. All rights reserved.
//

#import "WSQCameraViewController.h"
#import "ViewController.h"

@interface ViewController ()<WSQCameraViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)bnAction:(id)sender {
    WSQCameraViewController *cameraVC = [[WSQCameraViewController alloc] init];
    cameraVC.delegate = self;
    [self presentViewController:cameraVC animated:true completion:nil];
}


- (void)imageEditViewController:(WSQCameraViewController *)controller didFinishWithEditImage:(UIImage *)editedImage {
    [controller dismissViewControllerAnimated:true completion:nil];
}

- (void)imageEditViewControllerDidCancel:(WSQCameraViewController *)controller {
    [controller dismissViewControllerAnimated:true completion:nil];
}

@end
