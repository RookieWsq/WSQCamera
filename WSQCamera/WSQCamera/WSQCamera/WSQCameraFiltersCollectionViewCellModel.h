//
//  WSQCameraFiltersCollectionViewCellModel.h
//  WSQCamera
//
//  Created by 翁胜琼 on 2018/9/4.
//  Copyright © 2018年 Dev John. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSQCameraFiltersCollectionViewCellModel : NSObject

@property (nonatomic,copy,readonly) NSString *title;
@property (nonatomic,copy,readonly) NSString *filterType;

- (instancetype)initWithTitle:(NSString *)title filterType:(NSString *)filterType;

@end
