//
//  WSQCameraViewController.m
//  WSQCamera
//
//  Created by 翁胜琼 on 2018/9/4.
//  Copyright © 2018年 Dev John. All rights reserved.
//  拍债

#import "WSQCameraViewController.h"
#import <GPUImage.h>
#import "Macros.h"
#import "UIView+FrameChanged.h"
#import "WSQCameraFiltersCollectionView.h"
#import "WSQCameraFiltersCollectionViewCellModel.h"
#import "WSQImageEditiViewController.h"


static CGFloat const kResultBottomViewHeight = 120.0;   // 展示结果的底部按钮视图高度
static NSInteger const kResultBottomBtnBaseTag = 5000;  // 展示结果的底部按钮的基础 tag

@interface WSQCameraViewController ()<WSQImageEditiViewControllerDelegate>
{
    float _brightnessValue;   // 亮度
    float _contrastValue;   // 对比度
    float _saturationValue;   // 饱和度
    float _whiteBalanceValue;    // 白平衡
    NSInteger _regulateFilterType;  // 调节滤镜类型 1亮度 2对比度 3饱和度 4白平衡
}

// 相机
@property (nonatomic,strong) GPUImageStillCamera *stillCamera;
@property (strong,nonatomic) GPUImageFilter *filter;
@property (strong,nonatomic) GPUImageView *filterImageView;
// 首页底部视图
@property (strong,nonatomic) UIView *mainBottomView;    // 首页底部视图
@property (strong,nonatomic) UIButton *photoBtn;    // 拍照按钮
@property (strong,nonatomic) UIButton *showRegulateBtn; // 显示调节按钮
@property (strong,nonatomic) UIButton *showFiltersBtn;  // 显示滤镜按钮
// 首页顶部视图
@property (strong,nonatomic) UIView *mainTopView;   // 首页顶部视图
@property (strong,nonatomic) UIButton *mainCloseBtn;    // 首页关闭按钮
// 滤镜视图
@property (strong,nonatomic) WSQCameraFiltersCollectionView *filtersCollectionView; // 滤镜视图
@property (strong,nonatomic) UIView *filtersContainerView;  // 滤镜显示时，底部容器视图
@property (strong,nonatomic) UIButton *filterBackBtn;   // 滤镜页面退回按钮
// 调节视图
@property (strong,nonatomic) UIView *regulateContainerView; // 调节页面的包装视图
@property (strong,nonatomic) UIView *regulateTypeView;  // 调节页面选择类型视图
@property (strong,nonatomic) UIView *sliderContainerView;   // slider 的包装视图
@property (strong,nonatomic) UISlider *regulateSlider;  // 调节 slider

// 调节滤镜
@property (strong,nonatomic) GPUImageBrightnessFilter *birghtnessFilter;    // 亮度滤镜
@property (strong,nonatomic) GPUImageContrastFilter *contrastFilter;    // 对比度滤镜
@property (strong,nonatomic) GPUImageSaturationFilter *staturationFilter;   // 对比度滤镜
@property (strong,nonatomic) GPUImageWhiteBalanceFilter *whiteBalanceFilter;    // 白平衡滤镜
@property (strong,nonatomic) GPUImageFilterGroup *filterGroup;  // 滤镜组合

// 拍完照显示视图
@property (strong,nonatomic) UIView *resultContainerView; // 拍照的包装视图结果
@property (strong,nonatomic) UIView *resultBottomView;  // 拍照结果的底部按钮包装视图
@property (strong,nonatomic) UIImageView *resultImageView;  // 展示结果的imageView
@property (strong,nonatomic) UIImage *resultImage;  // 处理之后的图片


// 辅助
@property (strong,nonatomic) NSArray<WSQCameraFiltersCollectionViewCellModel *> *regulateTypesArray;  // 调节类型
@property (strong,nonatomic) UIButton *preRegulateTypeBtn;  // 上一个选择的调节类型按钮
@end

@implementation WSQCameraViewController

- (instancetype)init
{
    if (self = [super init])
    {
        // 设置自动保存图片至相册
        self.autoSaveToLibray = true;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupHelper];
    [self setupUI];
    
}

// 辅助方法
- (void)setupHelper
{
    
    // 设置滤镜默认值
    _brightnessValue = 0.0;
    _contrastValue = 1.0;
    _saturationValue = 1.0;
    _whiteBalanceValue = 5000;
}

- (void)setupUI
{
    self.view.backgroundColor = black_color;
    
    // 设置相机
    [self setupCamera];
    // 设置首页底部视图
    [self setupMainBottomView];
    // 设置首页顶部视图
    [self setupMainTopView];
    // 添加组合滤镜
    [self addGPUImageGroup];
    
}

// 创建各个调节滤镜
- (void)setupRegulateFilters
{
    WSQCameraFiltersCollectionViewCellModel *model0 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"返回" filterType:@"GPUImageBrightnessFilter"];
    WSQCameraFiltersCollectionViewCellModel *model1 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"亮度" filterType:@"GPUImageBrightnessFilter"];
    WSQCameraFiltersCollectionViewCellModel *model2 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"对比度" filterType:@"GPUImageSepiaFilter"];
    WSQCameraFiltersCollectionViewCellModel *model3 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"饱和度" filterType:@"GPUImageBilateralFilter"];
    WSQCameraFiltersCollectionViewCellModel *model4 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"白平衡" filterType:@"GPUImageSketchFilter"];
    
    self.regulateTypesArray = @[model0,model1,model2,model3,model4];
    
    // 添加调节滤镜
    // 亮度
    self.birghtnessFilter = [[GPUImageBrightnessFilter alloc] init];
    // 对比度
    self.contrastFilter = [[GPUImageContrastFilter alloc] init];
    // 饱和度
    self.staturationFilter = [[GPUImageSaturationFilter alloc] init];
    // 白平衡
    self.whiteBalanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
}

// 隐藏状态栏
- (BOOL)prefersStatusBarHidden
{
    return true;
}

// 创建相机
- (void)setupCamera
{
    // 设置码率，开启后置摄像头
    self.stillCamera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    // 输出图像横竖屏方式
    self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    // 设置灰度滤镜
    self.filter = [[GPUImageGammaFilter alloc] init];
    // 设置滤镜上下文
    [self.filter forceProcessingAtSize:self.filterImageView.bounds.size];
    // 创建承载图像的视图
    self.filterImageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    // 为相机添加滤镜
    [self.stillCamera addTarget:self.filter];
    // 将滤镜显示在 filterImageView 上
    [self.filter addTarget:self.filterImageView];
    
    // 开启子线程开始捕获图像
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.stillCamera startCameraCapture];
    });
    
    // 将承载图像的视图添加到 view 上
    [self.view addSubview:self.filterImageView];
}

// 创建首页底部视图
- (void)setupMainBottomView
{
    // 首页底部视图
    UIView *mainBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, Screen_Height - 180, Screen_Width, 180)];
    self.mainBottomView = mainBottomView;
    mainBottomView.backgroundColor = clear_color;
    [self.view addSubview: mainBottomView];
    
    // 拍照按钮
    CGRect photoBtnFrame = CGRectMake((mainBottomView.width - 64)/2, (mainBottomView.height - 64)/2, 64, 64);
    UIButton *photoBtn = [[UIButton alloc]initWithFrame:photoBtnFrame];
    self.photoBtn = photoBtn;
    photoBtn.imageView.tintColor = UICOLORFROMHEX(0xFFCCCC);
    [photoBtn setImage:[[UIImage imageNamed:@"拍照"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
    
    [mainBottomView addSubview:photoBtn];
    [photoBtn addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    // 调节按钮
    UIButton *regulateBtn = [[UIButton alloc] initWithFrame:CGRectMake(32, photoBtnFrame.origin.y, 40, 40)];
    self.showRegulateBtn = regulateBtn;
    regulateBtn.center = CGPointMake(regulateBtn.center.x, photoBtn.center.y);
    [regulateBtn setImage:[[UIImage imageNamed:@"调节"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    regulateBtn.imageView.tintColor = white_color;
    [regulateBtn addTarget:self action:@selector(regulateBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [mainBottomView addSubview:regulateBtn];
    
    // 滤镜按钮
    UIButton *showFiltersBtn = [[UIButton alloc] initWithFrame:CGRectMake(Screen_Width - 40 - 32, photoBtnFrame.origin.y, 40, 40)];
    self.showFiltersBtn = showFiltersBtn;
    showFiltersBtn.center = CGPointMake(showFiltersBtn.center.x, photoBtn.center.y);
    [showFiltersBtn setImage:[[UIImage imageNamed:@"滤镜"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [showFiltersBtn addTarget:self action:@selector(showFilterBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [mainBottomView addSubview:showFiltersBtn];
}

// 创建首页顶部视图
- (void)setupMainTopView
{
    // 创建顶部容器视图
    UIView *mainTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 100)];
    self.mainTopView = mainTopView;
    [self.view addSubview:mainTopView];
    
    // 创建关闭按钮
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(16, 24, 18, 18)];
    [closeBtn setImage:[UIImage imageNamed:@"关  闭"] forState:UIControlStateNormal];
    self.mainCloseBtn = closeBtn;
    [mainTopView addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(mainCloseBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
}

// 拍照动作
- (void)takePhoto
{
    [self setupResultView];
}

// 创建展示拍摄的结果
- (void)setupResultView
{
    __weak typeof(self) weakSelf = self;
    [self.stillCamera capturePhotoAsJPEGProcessedUpToFilter:self.filterGroup withCompletionHandler:^(NSData *processedJPEG, NSError *error){
        __strong typeof(weakSelf) self = weakSelf;
        
        UIImage *image = [UIImage imageWithData:processedJPEG];
        
        // 容器视图
        self.resultContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.resultContainerView.backgroundColor = black_color;
        [self.view addSubview:self.resultContainerView];
        
        // 结果展示视图
        self.resultImageView = [[UIImageView alloc] initWithFrame:self.resultContainerView.bounds];
        self.resultImageView.image = image;
        self.resultImage = image;
        self.resultImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.resultContainerView addSubview:self.resultImageView];
        
        // 按钮视图
        self.resultBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, Screen_Height - kResultBottomViewHeight, Screen_Width, kResultBottomViewHeight)];
        [self.resultContainerView addSubview:self.resultBottomView];
        
        NSArray<NSString *> *imageTitleArray = @[@"重置",@"编辑",@"同意"];
        CGFloat btnWidth = Screen_Width / imageTitleArray.count;
        
        [imageTitleArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self createResultBottomBtnWithImage:obj index:idx btnWidth:btnWidth];
        }];
        
        
        NSLog(@"拍照成功%@",image);
    }];
    
}

// 创建展示结果的底部按钮视图
- (void)createResultBottomBtnWithImage:(NSString *)obj index:(NSInteger)idx btnWidth:(CGFloat)btnWidth
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(idx * btnWidth, 0, btnWidth, kResultBottomViewHeight)];
    [btn setImage:[[UIImage imageNamed:obj] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    btn.imageView.tintColor = white_color;
    btn.tag = idx + kResultBottomBtnBaseTag;
    [btn addTarget:self action:@selector(resultViewBottomBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.resultBottomView addSubview:btn];
}

// 结果展示视图底部按钮的动作
- (void)resultViewBottomBtnAction:(UIButton *)sender
{
    NSInteger tag = sender.tag - kResultBottomBtnBaseTag;
    switch (tag) {
        case 0: // 重拍
        {
            [self.resultContainerView removeFromSuperview];
        }
            break;
        case 1: // 编辑
        {
            WSQImageEditiViewController *editImageVC = [[WSQImageEditiViewController alloc] initWithImage:self.resultImage];
            editImageVC.delegate = self;
            [self presentViewController:editImageVC animated:false completion:nil];
        }
            break;
        case 2: // 确定使用
        {
            if (self.autoSaveToLibray) {
                UIImageWriteToSavedPhotosAlbum(self.resultImage, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
            }
            [self.delegate imageEditViewController:self didFinishWithEditImage:self.resultImage];
        }
            break;
    }
}

// 保存最终图片
- (void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(error != nil) {
        NSLog(@"ERROR: %@",[error localizedDescription]);
    }
}

// 选择调节类型
- (void)regulateTypesBtnAction:(UIButton *)sender
{
    if (sender == self.preRegulateTypeBtn)
    {
        return;
    }
    
    NSInteger tag = sender.tag - 8888;
    
    if (tag != 0)
    {
        // 设置按钮选中状态
        sender.selected = !sender.isSelected;
        self.preRegulateTypeBtn.selected = false;
    }
    
    
    switch (tag) {
        case 0: // 退回
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.regulateContainerView.transform = CGAffineTransformMakeTranslation(0, Screen_Height);
                self.mainBottomView.transform = CGAffineTransformIdentity;
            }];
            return ;
        }
            break;
        case 1: // 亮度
        {
            // 设置 slider
            [self.regulateSlider setMinimumValue:-1.0];
            [self.regulateSlider setMaximumValue:1.0];
            [self.regulateSlider setValue:_brightnessValue];
        }
            break;
        case 2: // 对比度
        {
            [self.regulateSlider setMinimumValue:0.0];
            [self.regulateSlider setMaximumValue:4.0];
            [self.regulateSlider setValue:_contrastValue];
        }
            break;
        case 3: // 饱和度
        {
            [self.regulateSlider setMinimumValue:0.0];
            [self.regulateSlider setMaximumValue:2.0];
            [self.regulateSlider setValue:_saturationValue];
        }
            break;
        case 4: // 白平衡
        {
            [self.regulateSlider setMinimumValue:2500.0];
            [self.regulateSlider setMaximumValue:7500.0];
            [self.regulateSlider setValue:_whiteBalanceValue];
        }
            break;
            
        default:
            break;
    }
    
    // 设置当前调节滤镜类型
    _regulateFilterType = tag;
    self.preRegulateTypeBtn = sender;
}

// 更新调节滤镜的值
- (void)updateFilterFrom:(UISlider *)sender
{
    switch (_regulateFilterType) {
        case 1: // 亮度
        {
            [self.birghtnessFilter setBrightness:sender.value];
            _brightnessValue = sender.value;
        }
            break;
        case 2: // 对比度
        {
            [self.contrastFilter setContrast:sender.value];
            _contrastValue = sender.value;
        }
            break;
        case 3: // 饱和度
        {
            [self.staturationFilter setSaturation:sender.value];
            _saturationValue = sender.value;
        }
            break;
        case 4: // 白平衡
        {
            [self.whiteBalanceFilter setTemperature:sender.value];
            _whiteBalanceValue = sender.value;
        }
            break;
            
        default:
            break;
    }
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

// 添加组合滤镜
- (void)addGPUImageGroup
{
    // 移除原滤镜
    [self.filter removeAllTargets];
    [self.stillCamera removeTarget:self.filter];
    
    // 创建各个调节滤镜
    [self setupRegulateFilters];
    
    // 设置组合滤镜
    _filterGroup = [[GPUImageFilterGroup alloc] init];
    [self.stillCamera addTarget:_filterGroup];
    
    GPUImageFilter *filter0 = self.filter;
    GPUImageFilter *filter1 = self.birghtnessFilter;
    GPUImageFilter *filter2 = self.contrastFilter;
    GPUImageFilter *filter3 = self.staturationFilter;
    GPUImageFilter *filter4 = self.whiteBalanceFilter;
    
    [self.birghtnessFilter setBrightness:_brightnessValue];
    [self.contrastFilter setContrast:_contrastValue];
    [self.staturationFilter setSaturation:_saturationValue];
    [self.whiteBalanceFilter setTemperature:_whiteBalanceValue];
    
    [self addGPUImageFilter:filter0];
    [self addGPUImageFilter:filter1];
    [self addGPUImageFilter:filter2];
    [self addGPUImageFilter:filter3];
    [self addGPUImageFilter:filter4];
    
    [_filterGroup addTarget:_filterImageView];
}

// 显示调节页面
- (void)regulateBtnAction
{
    [self.view addSubview:self.regulateContainerView];
    self.regulateContainerView.transform = CGAffineTransformMakeTranslation(0, Screen_Height);
    [UIView animateWithDuration:0.3 animations:^{
        self.regulateContainerView.transform = CGAffineTransformIdentity;
        self.mainBottomView.transform = CGAffineTransformMakeTranslation(0, Screen_Height);
    }];
    
    // 删除原组合滤镜
    [self.stillCamera removeTarget:self.filterGroup];
    [self.filterGroup removeTarget:self.filterImageView];
    
    // 重新添加组合滤镜
    [self addGPUImageGroup];
    
}

// 显示选择滤镜页面
- (void)showFilterBtnAction
{
    [self.filtersContainerView addSubview:self.filtersCollectionView];
    self.filtersContainerView.transform = CGAffineTransformMakeTranslation(0, Screen_Height);
    self.showFiltersBtn.hidden = true;
    self.showRegulateBtn.hidden = true;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.filtersContainerView.transform = CGAffineTransformIdentity;
        self.mainBottomView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(0.6, 0.6), 0, 80);
    } completion:^(BOOL finished) {
        
    }];
}

// 退出页面
- (void)mainCloseBtnAction
{
    [self.delegate imageEditViewControllerDidCancel:self];
}

// 滤镜页面返回
- (void)filterBackBtnAction
{
    self.showFiltersBtn.hidden = false;
    self.showRegulateBtn.hidden = false;
    [UIView animateWithDuration:0.3 animations:^{
        self.filtersContainerView.transform = CGAffineTransformMakeTranslation(0, Screen_Height);
        self.mainBottomView.transform = CGAffineTransformIdentity;
    }];
}

// MARK: - lazy loading
- (WSQCameraFiltersCollectionView *)filtersCollectionView
{
    if (!_filtersCollectionView)
    {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(45, 100);
        flowLayout.minimumLineSpacing = 8;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 32, 0, 0);
        
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        WSQCameraFiltersCollectionView *collectionView = [[WSQCameraFiltersCollectionView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 110) collectionViewLayout:flowLayout];
        collectionView.stillCamera = self.stillCamera;
        collectionView.showsHorizontalScrollIndicator = false;
        collectionView.backgroundColor = clear_color;
        
        WSQCameraFiltersCollectionViewCellModel *model0 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"原始" filterType:@"GPUImageBrightnessFilter"];
        WSQCameraFiltersCollectionViewCellModel *model1 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"棕色滤镜" filterType:@"GPUImageSepiaFilter"];
        WSQCameraFiltersCollectionViewCellModel *model2 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"素描滤镜" filterType:@"GPUImageSketchFilter"];
        WSQCameraFiltersCollectionViewCellModel *model3 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"双边滤镜" filterType:@"GPUImageBilateralFilter"];
        WSQCameraFiltersCollectionViewCellModel *model4 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"模糊滤镜" filterType:@"GPUImageGaussianBlurFilter"];
        WSQCameraFiltersCollectionViewCellModel *model5 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"sobel滤镜" filterType:@"GPUImageToonFilter"];
        WSQCameraFiltersCollectionViewCellModel *model6 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"浮雕滤镜" filterType:@"GPUImageEmbossFilter"];
        //        WSQCameraFiltersCollectionViewCellModel *model7 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"涡扭滤镜" filterType:@"GPUImageSwirlFilter"];
        //        WSQCameraFiltersCollectionViewCellModel *model8 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"捏扭滤镜" filterType:@"GPUImagePinchDistortionFilter"];
        //        WSQCameraFiltersCollectionViewCellModel *model9 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"球体折射" filterType:@"GPUImageSphereRefractionFilter"];
        //        WSQCameraFiltersCollectionViewCellModel *model10 = [[WSQCameraFiltersCollectionViewCellModel alloc] initWithTitle:@"渐晕滤镜" filterType:@"GPUImageVignetteFilter"];
        
        collectionView.dataArray = @[model0,model1,model2,model3,model4,model5,model6];
        _filtersCollectionView = collectionView;
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(collectionView) weakCollectionView = collectionView;
        collectionView.didSelectedItemBlock = ^(NSInteger index) {
            __strong typeof(weakSelf) self = weakSelf;
            __strong typeof(weakCollectionView) collectionView = weakCollectionView;
            
            [self.stillCamera removeTarget:self.filterGroup];
            [self.filterGroup removeTarget:self.filterImageView];
            
            [self.stillCamera removeTarget:self.filter];
            
            WSQCameraFiltersCollectionViewCellModel *model = collectionView.dataArray[index];
            Class filterClass = NSClassFromString(model.filterType);
            GPUImageFilter *filter = [[filterClass alloc] init];
            self.filter = filter;
            [filter forceProcessingAtSize:self.filterImageView.bounds.size];
            
            [self.stillCamera addTarget:filter];
            [filter addTarget:self.filterImageView];
        };
    }
    return _filtersCollectionView;
}

- (UIView *)filtersContainerView
{
    if (!_filtersContainerView)
    {
        _filtersContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, Screen_Height - 180, Screen_Width, 180)];
        _filtersContainerView.backgroundColor = [black_color colorWithAlphaComponent:0.5];
        
        self.filterBackBtn = [[UIButton alloc] initWithFrame:CGRectMake(16, 180 - 40, 40, 30)];
        self.filterBackBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [self.filterBackBtn setTitle:@"返回" forState:UIControlStateNormal];
        [self.filterBackBtn setTitleColor:white_color forState:UIControlStateNormal];
        [self.filterBackBtn addTarget:self action:@selector(filterBackBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_filtersContainerView addSubview:self.filterBackBtn];
        
        [self.view insertSubview:_filtersContainerView belowSubview:self.mainBottomView];
    }
    return _filtersContainerView;
}

// 调节类型视图
- (UIView *)regulateTypeView
{
    if (!_regulateTypeView)
    {
        _regulateTypeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 36)];
        
        
        
        CGFloat btnWidth = Screen_Width / self.regulateTypesArray.count;
        
        __weak typeof(self) weakSelf = self;
        [self.regulateTypesArray enumerateObjectsUsingBlock:^(WSQCameraFiltersCollectionViewCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            __strong typeof(weakSelf) self = weakSelf;
            
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(idx * btnWidth, 0, btnWidth, self->_regulateTypeView.height)];
            [btn setTitleColor:UICOLORFROMHEX(0xFFCCCC) forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            [btn setTitle:obj.title forState:normal];
            [self->_regulateTypeView addSubview:btn];
            btn.tag = 8888 + idx;
            [btn addTarget:self action:@selector(regulateTypesBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            
            if (idx == 1)
            {
                [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            
        }];
        
    }
    return _regulateTypeView;
}

// 调节总视图的包装视图
- (UIView *)regulateContainerView
{
    if (!_regulateContainerView)
    {
        _regulateContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, Screen_Height - 180, Screen_Width, 180)];
        _regulateContainerView.backgroundColor = [black_color colorWithAlphaComponent:0.5];
        [_regulateContainerView addSubview:self.regulateTypeView];
        [_regulateContainerView addSubview:self.sliderContainerView];
    }
    return _regulateContainerView;
}

// slider 容器视图
- (UIView *)sliderContainerView
{
    if (!_sliderContainerView)
    {
        _sliderContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.regulateTypeView.height, Screen_Width, self.regulateContainerView.height - self.regulateTypeView.height)];
        [_sliderContainerView addSubview:self.regulateSlider];
    }
    return _sliderContainerView;
}

- (UISlider *)regulateSlider
{
    if (!_regulateSlider)
    {
        _regulateSlider = [[UISlider alloc] initWithFrame:CGRectMake(32,0, Screen_Width - 64, self.regulateContainerView.height - self.regulateTypeView.height)];
        _regulateSlider.tintColor = UICOLORFROMHEX(0xFFCCCC);
        [_regulateSlider addTarget:self action:@selector(updateFilterFrom:) forControlEvents:UIControlEventValueChanged];
        
    }
    return _regulateSlider;
}

// MARK: - 图片编辑代理
- (void)imageEditViewController:(WSQImageEditiViewController *)controller didFinishWithEditImage:(UIImage *)editedImage
{
    // 多个控制器以 modal 转场之后若是要一次 dismiss 回调第一个控制器，则需要取到第一个控制器然后 dismiss
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    // 保存图片至相册
    UIImageWriteToSavedPhotosAlbum(editedImage, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
}

- (void)imageEditViewControllerDidCancel:(WSQImageEditiViewController *)controller
{
    [controller dismissViewControllerAnimated:true completion:nil];
}


- (void)dealloc
{
    NSLog(@"cameraVC 被销毁");
}
@end
