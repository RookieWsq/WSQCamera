//
//  WSQCameraFiltersCollectionViewCellModel.m
//  WSQCamera
//
//  Created by 翁胜琼 on 2018/9/4.
//  Copyright © 2018年 Dev John. All rights reserved.
//

#import "WSQCameraFiltersCollectionViewCellModel.h"

@interface WSQCameraFiltersCollectionViewCellModel()

@property (nonatomic,copy,readwrite) NSString *title;
@property (nonatomic,copy,readwrite) NSString *filterType;

@end

@implementation WSQCameraFiltersCollectionViewCellModel


- (instancetype)initWithTitle:(NSString *)title filterType:(NSString *)filterType
{
    if (self = [super init])
    {
        self.title = title;
        self.filterType = filterType;
    }
    return self;
}


@end
