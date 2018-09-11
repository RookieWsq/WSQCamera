//
//  WSQCameraFiltersCollectionsViewCell.h
//  WSQCamera
//
//  Created by 翁胜琼 on 2018/9/4.
//  Copyright © 2018年 Dev John. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSQCameraFiltersCollectionViewCellModel,GPUImageStillCamera,GPUImagePicture;

@interface WSQCameraFiltersCollectionsViewCell : UICollectionViewCell

@property (nonatomic,strong) GPUImageStillCamera *stillCamera;
@property (strong,nonatomic) GPUImagePicture *gpuImagePicture;


- (void)setModel:(WSQCameraFiltersCollectionViewCellModel *)model;


@end
