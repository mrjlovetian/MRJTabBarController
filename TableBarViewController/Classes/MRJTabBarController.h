//
//  MRJTabBarController.h
//  MRJTabBarController
//
//  Created by 余洪江 on 17/8/11.
//  Copyright (c) 2017年 MRJTabBarController. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRJTabBar.h"
#import "MRJTabItem.h"

@interface MRJTabBarController : UIViewController <MRJTabBarDelegate>

@property (nonatomic, strong, readonly) MRJTabBar *tabBar;

@property (nonatomic, copy) NSArray <UIViewController *> *viewControllers;

/// 内容视图的Frame
@property (nonatomic, assign) CGRect contentViewFrame;

/// 第一次显示时，默认被选中的ViewController的Index，在viewWillAppear方法被调用前设置有效
@property (nonatomic, assign) NSUInteger defaultSelectedControllerIndex;

/// 设置被选中的ViewController的Index，界面会自动切换
@property (nonatomic, assign) NSUInteger selectedControllerIndex;

/// 此属性仅在内容视图支持滑动时有效，它控制child view controller调用viewDidLoad方法的时机
/// 值为YES时，拖动内容视图，一旦拖动到该child view controller所在的位置，立即加载其view
/// 值为NO时，拖动内容视图，拖动到该child view controller所在的位置，不会立即其view，而是要等到手势结束，scrollView停止滚动后，再加载其view
/// 默认值为NO
@property (nonatomic, assign) BOOL loadViewOfChildContollerWhileAppear;

/// 鉴于有些项目集成了左侧或者右侧侧边栏，当内容视图支持滑动切换时，不能实现在第一页向右滑动和最后一页向左滑动呼出侧边栏的功能，
/// 此2个属性则可以拦截第一页向右滑动和最后一页向左滑动的手势，实现呼出侧边栏的功能
@property (nonatomic, assign) BOOL interceptRightSlideGuetureInFirstPage;
@property (nonatomic, assign) BOOL interceptLeftSlideGuetureInLastPage;

/// 设置tabBar和contentView的frame，默认是tabBar在底部，contentView填充其余空间
- (void)setTabBarFrame:(CGRect)tabBarFrame contentViewFrame:(CGRect)contentViewFrame;

/// 设置内容视图支持滑动切换，以及点击item切换时是否有动画
- (void)setContentScrollEnabledAndTapSwitchAnimated:(BOOL)animated;

/// 获取被选中的ViewController
- (UIViewController *)selectedController;

/// ViewController被选中时调用此方法，此方法为回调方法
- (void)didSelectViewControllerAtIndex:(NSUInteger)index;

@end

@interface UIViewController (MRJTabBarController)

/// tabItem的标题
@property (nonatomic, copy) NSString *tabItemTitle;
/// tabItem的图像
@property (nonatomic, strong) UIImage *tabItemImage;
/// tabItem的选中图像
@property (nonatomic, strong) UIImage *tabItemSelectedImage;

- (MRJTabItem *)tabItem;
- (MRJTabBarController *)tabBarController;

/// ViewController对应的Tab被Select后，执行此方法，此方法为回调方法
/// @param isFirstTime  是否为第一次被选中
- (void)tabItemDidSelected:(BOOL)isFirstTime;

/// ViewController对应的Tab被Deselect后，执行此方法，此方法为回调方法
- (void)tabItemDidDeselected;

@end
