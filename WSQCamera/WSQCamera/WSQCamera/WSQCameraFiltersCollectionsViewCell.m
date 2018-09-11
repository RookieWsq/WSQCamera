//
//  WSQCameraFiltersCollectionsViewCell.m
//  WSQCamera
//
//  Created by 翁胜琼 on 2018/9/4.
//  Copyright © 2018年 Dev John. All rights reserved.
//

#import "WSQCameraFiltersCollectionsViewCell.h"
#import "GPUImage.h"
#import "WSQCameraFiltersCollectionViewCellModel.h"


@interface WSQCameraFiltersCollectionsViewCell()

@property (weak, nonatomic) IBOutlet GPUImageView *filterImageView;
@property (weak, nonatomic) IBOutlet UILabel *filterTitleLabel;

@end

@implementation WSQCameraFiltersCollectionsViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    
}

- (void)setModel:(WSQCameraFiltersCollectionViewCellModel *)model
{
    
    self.filterTitleLabel.text = model.title;
    Class filterClass = NSClassFromString(model.filterType);
    GPUImageFilter *filter = [[filterClass alloc] init];
    [filter forceProcessingAtSize:self.filterImageView.bounds.size];
    
    if (self.stillCamera != nil)
    {
        [self.stillCamera addTarget:filter];
        [filter addTarget:self.filterImageView];
    }else if (self.gpuImagePicture != nil)
    {
        [self.gpuImagePicture addTarget:filter];
        [filter addTarget:self.filterImageView];
//        [self.gpuImagePicture addTarget:self.filterImageView];
        [self.gpuImagePicture processImage];
    }
    
    
}

@end
