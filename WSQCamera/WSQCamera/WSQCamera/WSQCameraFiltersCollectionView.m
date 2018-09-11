//
//  WSQCameraFiltersCollectionView.m
//  WSQCamera
//
//  Created by 翁胜琼 on 2018/9/4.
//  Copyright © 2018年 Dev John. All rights reserved.
//

#import "WSQCameraFiltersCollectionView.h"
#import "WSQCameraFiltersCollectionsViewCell.h"
#import "WSQCameraFiltersCollectionViewCellModel.h"
#import "Macros.h"


static NSString* const kCollectionViewCellID = @"WSQCameraFiltersCollectionsViewCell";

@interface WSQCameraFiltersCollectionView()<UICollectionViewDelegate , UICollectionViewDataSource>


@end

@implementation WSQCameraFiltersCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if (self = [super initWithFrame:frame collectionViewLayout:layout])
    {
        self.delegate = self;
        self.dataSource = self;
        [self setupUI];

    }
    return self;
}

- (void)setDataArray:(NSArray<WSQCameraFiltersCollectionViewCellModel *> *)dataArray
{
    _dataArray = dataArray;
    [self reloadData];
}


- (void)setupUI
{
    [self registerNib:[UINib nibWithNibName:@"WSQCameraFiltersCollectionsViewCell" bundle:nil] forCellWithReuseIdentifier:kCollectionViewCellID];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WSQCameraFiltersCollectionsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellID forIndexPath:indexPath];
    cell.stillCamera = self.stillCamera;
    cell.gpuImagePicture = self.gpuImagePicture;
    [cell setModel:self.dataArray[indexPath.row]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.didSelectedItemBlock)
    {    
        self.didSelectedItemBlock(indexPath.row);
    }
}
@end
