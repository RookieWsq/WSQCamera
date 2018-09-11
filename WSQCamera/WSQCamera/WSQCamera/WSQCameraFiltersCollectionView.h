//
//  WSQCameraFiltersCollectionView.h
//  WSQCamera
//
//  Created by 翁胜琼 on 2018/9/4.
//  Copyright © 2018年 Dev John. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSQCameraFiltersCollectionViewCellModel,GPUImageStillCamera,GPUImagePicture;

typedef void(^didSelectedItemBlock)(NSInteger index);

@interface WSQCameraFiltersCollectionView : UICollectionView

@property (strong,nonatomic) NSArray<WSQCameraFiltersCollectionViewCellModel *> *dataArray;
@property (nonatomic,strong) GPUImageStillCamera *stillCamera;
@property (strong,nonatomic) GPUImagePicture *gpuImagePicture;
@property (copy,nonatomic) didSelectedItemBlock didSelectedItemBlock;

@end
