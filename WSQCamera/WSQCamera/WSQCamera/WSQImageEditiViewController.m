//
//  WSQImageEditiViewController.m
//  WSQCamera
//
//  Created by 翁胜琼 on 2018/9/5.
//  Copyright © 2018年 Dev John. All rights reserved.
//  编辑图片

#import "WSQImageEditiViewController.h"
#import "Macros.h"
#import <Photos/Photos.h>
#import "GPUImage.h"
#import "WSQCameraFiltersCollectionViewCellModel.h"
#import "WSQCameraFiltersCollectionView.h"
#import "PhotoTweaksViewController.h"
#import "SmearImageEdit/CTImageSmearViewController.h"







static CGFloat const kMainBottomViewHeight = 180.0; // 首页底部视图高度
static CGFloat const kEditBtnHeight = 30; // 编辑按钮高度
static CGFloat const kEditBtnTopSpace = 8; // 编辑按钮顶部距离
static NSInteger const kBottomBtnBaseTag = 2333;    // 编辑按钮基础 tag


@interface WSQImageEditiViewController ()<PhotoTweaksViewControllerDelegate,CTImageSmearViewControllerDelegate>
{
    float _brightnessValue;   // 亮度
    float _contrastValue;   // 对比度
    float _saturationValue;   // 饱和度
    float _whiteBalanceValue;    // 白平衡
    NSInteger _regulateFilterType;  // 调节滤镜类型 0亮度 1对比度 2饱和度 3白平衡 4裁剪 5马赛克 6滤镜
}

@property (nonatomic , strong) UIImage *image;
@property (strong,nonatomic) GPUImageView *imageView;
@property (strong,nonatomic) GPUImagePicture *gpuImagePicture;

// 首页顶部视图
@property (strong,nonatomic) UIView *mainTopView;   // 首页顶部视图
@property (strong,nonatomic) UIButton *mainCloseBtn;    // 首页关闭按钮
@property (strong,nonatomic) UIButton *mainSaveBtn;  // 首页保存按钮

// 首页底部视图
@property (strong,nonatomic) UIView *mainBottomView;    // 首页底部视图
@property (strong,nonatomic) UIView *editBtnContainerView;  // 编辑按钮包装视图
//@property (strong,nonatomic) UIButton *birghtnessBtn;   // 亮度
//@property (strong,nonatomic) UIButton *contrastBtn;    // 对比度
//@property (strong,nonatomic) UIButton *staturationBtn;   // 对比度
//@property (strong,nonatomic) UIButton *whiteBalanceBtn;    // 白平衡
//@property (strong,nonatomic) UIButton *cropBtn; // 裁剪
//@property (strong,nonatomic) UIButton *mosaicBtn;   // 马赛克
@property (strong,nonatomic) NSArray<NSDictionary *> *bottomBtnsTitleArray;
// 图片裁剪
@property (strong,nonatomic) PhotoTweaksViewController *cropViewController;

// 调节滤镜
@property (strong,nonatomic) GPUImageBrightnessFilter *birghtnessFilter;    // 亮度滤镜
@property (strong,nonatomic) GPUImageContrastFilter *contrastFilter;    // 对比度滤镜
@property (strong,nonatomic) GPUImageSaturationFilter *staturationFilter;   // 对比度滤镜
@property (strong,nonatomic) GPUImageWhiteBalanceFilter *whiteBalanceFilter;    // 白平衡滤镜
@property (strong,nonatomic) GPUImageFilterGroup *filterGroup;  // 滤镜组合
@property (strong,nonatomic) UISlider *regulateSlider;  // 调节滤镜值的 slider
@property (strong,nonatomic) GPUImageFilter *filter;    // 由选择滤镜选择到的滤镜
@property (strong,nonatomic) WSQCameraFiltersCollectionView *filtersCollectionView; // 滤镜选择视图

@end

@implementation WSQImageEditiViewController

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init])
    {
        self.image = image;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupHelpers];
    [self setupUI];
}

// 设置 UI
- (void)setupUI
{
    [self setupImageView];
    
    [self.view addSubview:self.mainTopView];
    [self.view addSubview:self.mainBottomView];
}

// 辅助函数
- (void)setupHelpers
{
    // 设置滤镜默认值
    _brightnessValue = 0.0;
    _contrastValue = 1.0;
    _saturationValue = 1.0;
    _whiteBalanceValue = 5000;
    
    self.bottomBtnsTitleArray = @[
                                  @{
                                      @"title" : @"亮度",
                                      @"image" : @"亮度"
                                      },
                                  @{
                                      @"title" : @"对比度",
                                      @"image" : @"对比度"
                                      },
                                  @{
                                      @"title" : @"饱和度",
                                      @"image" : @"饱和度"
                                      },
                                  @{
                                      @"title" : @"白平衡",
                                      @"image" : @"黑白平衡"
                                      },
                                  @{
                                      @"title" : @"裁剪",
                                      @"image" : @"裁剪"
                                      },
                                  @{
                                      @"title" : @"马赛克",
                                      @"image" : @"马赛克"
                                      },
                                  @{
                                      @"title" : @"滤镜",
                                      @"image" : @"滤镜黑白"
                                      },
                                  ];
}

// 设置状态栏
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

// 设置 imageView
- (void)setupImageView
{
    self.imageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    self.gpuImagePicture = [[GPUImagePicture alloc] initWithImage:self.image];
    [self.gpuImagePicture forceProcessingAtSize:self.imageView.bounds.size];
    
    [self.view addSubview:self.imageView];
    
    // 创建各个调节滤镜
    [self setupRegulateFilters];
    
    // 在gpuImagePicture 添加返回手势
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToMainView)];
    [self.imageView addGestureRecognizer:tapGes];
}

// 返回到首页
- (void)backToMainView
{
    [UIView animateWithDuration:0.3 animations:^{
       
        self.mainSaveBtn.hidden = false;
        self.mainBottomView.transform = CGAffineTransformIdentity;
        self.filtersCollectionView.transform = CGAffineTransformIdentity;
    }];
    
    // 删除原有滤镜,重新设置组合滤镜此次添加上预定滤镜
    [self.gpuImagePicture removeTarget:self.filterGroup];
    [self.gpuImagePicture removeTarget:self.filter];
    [self.gpuImagePicture removeTarget:self.imageView];
    [self.filterGroup removeTarget:self.imageView];
    [self.filter removeTarget:self.imageView];
    
    // 重置滤镜默认值
    // 设置滤镜默认值
    _brightnessValue = 0.0;
    _contrastValue = 1.0;
    _saturationValue = 1.0;
    _whiteBalanceValue = 5000;
    
    [self setupRegulateFilters];
}

// 退出页面
- (void)mainCloseBtnAction
{
//    [self dismissViewControllerAnimated:false completion:nil];
    [self.delegate imageEditViewControllerDidCancel:self];
}

// 创建各个调节滤镜
- (void)setupRegulateFilters
{
    // 添加调节滤镜
    // 亮度
    self.birghtnessFilter = [[GPUImageBrightnessFilter alloc] init];
    // 对比度
    self.contrastFilter = [[GPUImageContrastFilter alloc] init];
    // 饱和度
    self.staturationFilter = [[GPUImageSaturationFilter alloc] init];
    // 白平衡
    self.whiteBalanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
    
    // 设置组合滤镜
    _filterGroup = [[GPUImageFilterGroup alloc] init];
    
    GPUImageFilter *filter1 = self.birghtnessFilter;
    GPUImageFilter *filter2 = self.contrastFilter;
    GPUImageFilter *filter3 = self.staturationFilter;
    GPUImageFilter *filter4 = self.whiteBalanceFilter;
    
    [self.birghtnessFilter setBrightness:_brightnessValue];
    [self.contrastFilter setContrast:_contrastValue];
    [self.staturationFilter setSaturation:_saturationValue];
    [self.whiteBalanceFilter setTemperature:_whiteBalanceValue];
    
    if (self.filter != nil)
    {
        [self addGPUImageFilter:self.filter];
    }
    
    [self addGPUImageFilter:filter1];
    [self addGPUImageFilter:filter2];
    [self addGPUImageFilter:filter3];
    [self addGPUImageFilter:filter4];
    
    [_filterGroup addTarget:_imageView];
    [self.gpuImagePicture addTarget:_filterGroup];
    [self.gpuImagePicture processImage];
}

// 设置组合滤镜
- (void)addGPUImageFilter:(GPUImageOutput<GPUImageInput> *)filter
{
    [_filterGroup addFilter:filter];
    
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    
    NSInteger count = _filterGroup.filterCount;
    
    if (count == 1)
    {
        _filterGroup.initialFilters = @[newTerminalFilter];
        _filterGroup.terminalFilter = newTerminalFilter;
        
    } else
    {
        GPUImageOutput<GPUImageInput> *terminalFilter    = _filterGroup.terminalFilter;
        NSArray *initialFilters                          = _filterGroup.initialFilters;
        
        [terminalFilter addTarget:newTerminalFilter];
        
        _filterGroup.initialFilters = @[initialFilters[0]];
        _filterGroup.terminalFilter = newTerminalFilter;
    }
}

// 更新调节滤镜的值
- (void)updateFilterFrom:(UISlider *)sender
{
    switch (_regulateFilterType) {
        case 0: // 亮度
        {
            [self.birghtnessFilter setBrightness:sender.value];
            _brightnessValue = sender.value;
        }
            break;
        case 1: // 对比度
        {
            [self.contrastFilter setContrast:sender.value];
            _contrastValue = sender.value;
        }
            break;
        case 2: // 饱和度
        {
            [self.staturationFilter setSaturation:sender.value];
            _saturationValue = sender.value;
        }
            break;
        case 3: // 白平衡
        {
            [self.whiteBalanceFilter setTemperature:sender.value];
            _whiteBalanceValue = sender.value;
        }
            break;
            
        default:
            break;
    }
    [self.gpuImagePicture processImage];
}

// 保存按钮动作
- (void)saveBtnAction
{
//    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//         __unused PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:self.image];
//    } completionHandler:^(BOOL success, NSError * _Nullable error) {
//        NSLog(@"success = %d, error = %@", success, error);
//    }];
    [self.gpuImagePicture processImage];
    [self.regulateSlider setHidden:true];
    [self.gpuImagePicture useNextFrameForImageCapture];
    [self.filterGroup useNextFrameForImageCapture];
    UIImage *image = [self.filterGroup imageFromCurrentFramebuffer];
    NSLog(@"after edit image = %@",image);
    [self.delegate imageEditViewController:self didFinishWithEditImage:image];
    
}

// 选择编辑按钮
- (void)bottomBtnAction:(UIButton *)sender
{
    NSInteger tag = sender.tag - kBottomBtnBaseTag;
    _regulateFilterType = tag;
    
    switch (tag) {
        case 0: // 亮度
        {
            // 设置 slider
            [self.regulateSlider setMinimumValue:-1.0];
            [self.regulateSlider setMaximumValue:1.0];
            [self.regulateSlider setValue:_brightnessValue];
            [self.regulateSlider setHidden:false];
        }
            break;
        case 1: // 对比度
        {
            [self.regulateSlider setMinimumValue:0.0];
            [self.regulateSlider setMaximumValue:4.0];
            [self.regulateSlider setValue:_contrastValue];
            [self.regulateSlider setHidden:false];
        }
            break;
        case 2: // 饱和度
        {
            [self.regulateSlider setMinimumValue:0.0];
            [self.regulateSlider setMaximumValue:2.0];
            [self.regulateSlider setValue:_saturationValue];
            [self.regulateSlider setHidden:false];
        }
            break;
        case 3: // 白平衡
        {
            [self.regulateSlider setMinimumValue:2500.0];
            [self.regulateSlider setMaximumValue:7500.0];
            [self.regulateSlider setValue:_whiteBalanceValue];
            [self.regulateSlider setHidden:false];
        }
            break;
        case 4: // 裁剪
        {
            // 跳转到裁剪页面
            [self presentCropViewController];
        }
            break;
        case 5: // 马赛克
        {
            // 跳转到涂抹页面
            [self presentSmearViewController];
        }
            break;
        case 6: // 滤镜
        {
            [self.regulateSlider setHidden:true];
            [self.view addSubview:self.filtersCollectionView];
            [UIView animateWithDuration:0.3 animations:^{
                
                self.mainSaveBtn.hidden = true;
                self.mainBottomView.transform = CGAffineTransformMakeTranslation(0, Screen_Height);
                self.filtersCollectionView.transform = CGAffineTransformMakeTranslation(0, -110);
                
            }];
            
            
        }
            break;
        default:
            break;
    }
}

// 跳转到裁剪页面
- (void)presentCropViewController
{
    // 获取处理之后的图片必须要 processImage 和 useNextFrameForImageCapture
    [self.gpuImagePicture processImage];
    [self.regulateSlider setHidden:true];
    [self.gpuImagePicture useNextFrameForImageCapture];
    [self.filterGroup useNextFrameForImageCapture];
    UIImage *image = [self.filterGroup imageFromCurrentFramebuffer];
    PhotoTweaksViewController *cropVC = [[PhotoTweaksViewController alloc] initWithImage:image];
    cropVC.maxRotationAngle = M_PI_4;
    cropVC.delegate = self;
    cropVC.autoSaveToLibray = false;
    [self presentViewController:cropVC animated:false completion:nil];
}

// 跳转到涂抹页面
- (void)presentSmearViewController
{
    [self.regulateSlider setHidden:true];
    
    [self.gpuImagePicture processImage];
    [self.regulateSlider setHidden:true];
    [self.gpuImagePicture useNextFrameForImageCapture];
    [self.filterGroup useNextFrameForImageCapture];
    UIImage *image = [self.filterGroup imageFromCurrentFramebuffer];
    CTImageSmearViewController *ctr = [[CTImageSmearViewController alloc]init];
    ctr.delegate = self;
    [ctr packageWithImage:image];
    [self presentViewController:ctr animated:NO completion:nil];
}

// 创建编辑按钮
- (UIButton *)setupEditBtnWithDic:(NSDictionary *)obj index:(NSInteger)idx
{
    CGFloat btnWidth = (Screen_Width - 16) / self.bottomBtnsTitleArray.count;

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(idx * btnWidth + 8, 8, kEditBtnHeight, kEditBtnHeight)];
    UIImage *btnImage = [[UIImage imageNamed:obj[@"image"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [btn setImage:btnImage forState:UIControlStateNormal];
    btn.imageView.tintColor = white_color;
    btn.tag = kBottomBtnBaseTag + idx;
    [btn addTarget:self action:@selector(bottomBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (idx == 0)
    {
        [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    return btn;
}

// MARK: - lazy loading
// 首页顶部视图
- (UIView *)mainTopView
{
    if (!_mainTopView)
    {
        _mainTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 80)];
        
        UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(16, 24, 18, 18)];
        [closeBtn setImage:[UIImage imageNamed:@"关  闭"] forState:UIControlStateNormal];
        self.mainCloseBtn = closeBtn;
        [_mainTopView addSubview:closeBtn];
        [closeBtn addTarget:self action:@selector(mainCloseBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(Screen_Width - 64, 24, 42, 24)];
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn setTitleColor:white_color forState:UIControlStateNormal];
        self.mainSaveBtn = saveBtn;
        [_mainTopView addSubview:saveBtn];
        [saveBtn addTarget:self action:@selector(saveBtnAction) forControlEvents:UIControlEventTouchUpInside];

    }
    return _mainTopView;
}

// 首页底部视图
- (UIView *)mainBottomView
{
    if (!_mainBottomView)
    {
        _mainBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, Screen_Height - kMainBottomViewHeight, Screen_Width, kMainBottomViewHeight)];
        [_mainBottomView addSubview:self.editBtnContainerView];
        [_mainBottomView addSubview:self.regulateSlider];
        
        
    }
    return _mainBottomView;
}

// 编辑按钮包装视图
- (UIView *)editBtnContainerView
{
    if (!_editBtnContainerView)
    {
        _editBtnContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, kMainBottomViewHeight - kEditBtnHeight - 2 * kEditBtnTopSpace, Screen_Width, kEditBtnHeight + 2 * kEditBtnTopSpace)];
        _editBtnContainerView.backgroundColor = [black_color colorWithAlphaComponent:0.3];
        
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(_editBtnContainerView) weakEditBtnContainerView = _editBtnContainerView;
        [self.bottomBtnsTitleArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            __strong typeof(weakSelf) self = weakSelf;
            __strong typeof(weakEditBtnContainerView) _editBtnContainerView = weakEditBtnContainerView;
            
            // 创建按钮
            UIButton *btn = [self setupEditBtnWithDic:obj index:idx];
            [_editBtnContainerView addSubview:btn];
            
        }];

    }
    return _editBtnContainerView;
}

// 调节 slider
- (UISlider *)regulateSlider
{
    if (!_regulateSlider)
    {
        _regulateSlider = [[UISlider alloc] initWithFrame:CGRectMake(32,0, Screen_Width - 64, kMainBottomViewHeight - kEditBtnHeight - 2 * kEditBtnTopSpace)];
        _regulateSlider.tintColor = UICOLORFROMHEX(0xFFCCCC);
        [_regulateSlider addTarget:self action:@selector(updateFilterFrom:) forControlEvents:UIControlEventValueChanged];
        
    }
    return _regulateSlider;
}

// 选择滤镜
- (WSQCameraFiltersCollectionView *)filtersCollectionView
{
    if (!_filtersCollectionView)
    {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(45, 100);
        flowLayout.minimumLineSpacing = 8;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 32, 0, 0);
        
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        WSQCameraFiltersCollectionView *collectionView = [[WSQCameraFiltersCollectionView alloc] initWithFrame:CGRectMake(0, Screen_Height, Screen_Width, 110) collectionViewLayout:flowLayout];
        collectionView.gpuImagePicture = self.gpuImagePicture;
        collectionView.showsHorizontalScrollIndicator = false;
        collectionView.backgroundColor = clear_color;
        
        WSQCameraFiltersCollectionViewCellModel *model0 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"原始" filterType:@"GPUImageBrightnessFilter"];
        WSQCameraFiltersCollectionViewCellModel *model1 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"棕色滤镜" filterType:@"GPUImageSepiaFilter"];
        WSQCameraFiltersCollectionViewCellModel *model2 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"素描滤镜" filterType:@"GPUImageSketchFilter"];
        WSQCameraFiltersCollectionViewCellModel *model3 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"双边滤镜" filterType:@"GPUImageBilateralFilter"];
        WSQCameraFiltersCollectionViewCellModel *model4 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"模糊滤镜" filterType:@"GPUImageGaussianBlurFilter"];
        WSQCameraFiltersCollectionViewCellModel *model5 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"sobel滤镜" filterType:@"GPUImageToonFilter"];
        WSQCameraFiltersCollectionViewCellModel *model6 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"浮雕滤镜" filterType:@"GPUImageEmbossFilter"];

        
        collectionView.dataArray = @[model0,model1,model2,model3,model4,model5,model6];
        _filtersCollectionView = collectionView;
        _filtersCollectionView.backgroundColor = [black_color colorWithAlphaComponent:0.4];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(collectionView) weakCollectionView = collectionView;
        collectionView.didSelectedItemBlock = ^(NSInteger index) {
            __strong typeof(weakSelf) self = weakSelf;
            __strong typeof(weakCollectionView) collectionView = weakCollectionView;
            
            [self.filterGroup removeTarget:self.imageView];
            [self.filter removeTarget:self.imageView];
            
            [self.gpuImagePicture removeTarget:self.filterGroup];
            [self.gpuImagePicture removeTarget:self.filter];
            
            if (index == 0)
            {
                [self.gpuImagePicture removeTarget:self.imageView];
                [self.gpuImagePicture addTarget:self.imageView];
                self.filter = nil;
                
//                [self.gpuImagePicture forceProcessingAtSize:self.imageView.bounds.size];
                [self.gpuImagePicture processImage];
                return ;
            }
            
            
            WSQCameraFiltersCollectionViewCellModel *model = collectionView.dataArray[index];
            Class filterClass = NSClassFromString(model.filterType);
            GPUImageFilter *filter = [[filterClass alloc] init];
            self.filter = filter;
//            [filter forceProcessingAtSize:self.imageView.bounds.size];
            self.imageView.fillMode = kGPUImageFillModePreserveAspectRatio;
            
            [self.gpuImagePicture addTarget:filter];
            [filter addTarget:self.imageView];
            [self.gpuImagePicture processImage];
        };
    }
    return _filtersCollectionView;
}

// MARK: - 裁剪代理 PhotoTweaksViewControllerDelegate
- (void)photoTweaksController:(PhotoTweaksViewController *)controller didFinishWithCroppedImage:(UIImage *)croppedImage {
    [controller dismissViewControllerAnimated:false completion:nil];
    self.image  = croppedImage;
    [self setupHelpers];
    [self setupUI];
}

- (void)photoTweaksControllerDidCancel:(PhotoTweaksViewController *)controller {
    [controller dismissViewControllerAnimated:false completion:nil];
}

// MARK: - 涂抹代理 CTImageSmearViewControllerDelegate
- (void)didSmearPhotoWithResultImage:(UIImage *)image{
    self.image = image;
    [self setupHelpers];
    [self setupUI];
}

- (void)dealloc
{
    NSLog(@"editImageVC 被销毁");
}

@end
