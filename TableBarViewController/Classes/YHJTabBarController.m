//
//  YHJTabBarController.m
//  YHJTabBarController
//
//  Created by 余洪江 on 17/8/11.
//  Copyright (c) 2017年 YHJTabBarController. All rights reserved.
//

#import "YHJTabBarController.h"
#import <objc/runtime.h>

#define TAB_BAR_HEIGHT 50

#pragma mark - YHJTabContentScrollView

/**
 *  自定义UIScrollView，在需要时可以拦截其滑动手势
 */

@class YHJTabContentScrollView;

@protocol YHJTabContentScrollViewDelegate <NSObject>

@optional

- (BOOL)scrollView:(YHJTabContentScrollView *)scrollView shouldScrollToPageIndex:(NSUInteger)index;

@end

@interface YHJTabContentScrollView : UIScrollView

@property (nonatomic, weak) id<YHJTabContentScrollViewDelegate> yhj_delegate;

@property (nonatomic, assign) BOOL interceptLeftSlideGuetureInLastPage;
@property (nonatomic, assign) BOOL interceptRightSlideGuetureInFirstPage;

@end


#pragma mark - UIViewController (YHJTabBarController)

@implementation UIViewController (YHJTabBarController)

- (NSString *)yhj_tabItemTitle {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYhj_tabItemTitle:(NSString *)yhj_tabItemTitle {
    self.yhj_tabItem.title = yhj_tabItemTitle;
    objc_setAssociatedObject(self, @selector(yhj_tabItemTitle), yhj_tabItemTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIImage *)yhj_tabItemImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYhj_tabItemImage:(UIImage *)yhj_tabItemImage {
    self.yhj_tabItem.image = yhj_tabItemImage;
    objc_setAssociatedObject(self, @selector(yhj_tabItemImage), yhj_tabItemImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)yhj_tabItemSelectedImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYhj_tabItemSelectedImage:(UIImage *)yhj_tabItemSelectedImage {
    self.yhj_tabItem.selectedImage = yhj_tabItemSelectedImage;
    objc_setAssociatedObject(self, @selector(yhj_tabItemSelectedImage), yhj_tabItemSelectedImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (YHJTabItem *)yhj_tabItem {
    YHJTabBar *tabBar = self.yhj_tabBarController.tabBar;
    if (!tabBar) {
        return nil;
    }
    if (![self.yhj_tabBarController.viewControllers containsObject:self]) {
        return nil;
    }
    
    NSUInteger index = [self.yhj_tabBarController.viewControllers indexOfObject:self];
    return tabBar.items[index];
}

- (YHJTabBarController *)yhj_tabBarController {
    return (YHJTabBarController *)self.parentViewController;
}

- (void)yhj_tabItemDidSelected:(BOOL)isFirstTime {}

- (void)tabItemDidSelected {}

- (void)yhj_tabItemDidDeselected {}

- (void)tabItemDidDeselected {}

- (BOOL)yhj_isTabItemSelectedFirstTime {
    id selected = objc_getAssociatedObject(self, _cmd);
    if (!selected) {
        return YES;
    }
    return [selected boolValue];
}

@end


#pragma mark - YHJTabBarController

@interface YHJTabBarController () <UIScrollViewDelegate, YHJTabContentScrollViewDelegate> {
    BOOL _didViewAppeared;
    CGFloat _lastContentScrollViewOffsetX;
}

@property (nonatomic, strong) YHJTabContentScrollView *contentScrollView;

@property (nonatomic, assign) BOOL contentScrollEnabled;
@property (nonatomic, assign) BOOL contentSwitchAnimated;

@end

@implementation YHJTabBarController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _setup];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    _selectedControllerIndex = NSNotFound;
    _tabBar = [[YHJTabBar alloc] init];
    _tabBar.delegate = self;
    
    _loadViewOfChildContollerWhileAppear = NO;
    _defaultSelectedControllerIndex = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupFrameOfTabBarAndContentView];
    
    [self.view addSubview:self.tabBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 在第一次调用viewWillAppear方法时，初始化选中的item
    if (!_didViewAppeared) {
        self.tabBar.selectedItemIndex = self.defaultSelectedControllerIndex;
        _didViewAppeared = YES;
    }
}

- (void)setupFrameOfTabBarAndContentView {
    // 设置默认的tabBar的frame和contentViewFrame
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGFloat contentViewY = 0;
    CGFloat tabBarY = screenSize.height - TAB_BAR_HEIGHT;
    CGFloat contentViewHeight = tabBarY;
    // 如果parentViewController为UINavigationController及其子类
    if ([self.parentViewController isKindOfClass:[UINavigationController class]] &&
        !self.navigationController.navigationBarHidden &&
        !self.navigationController.navigationBar.hidden) {
        
        CGFloat navMaxY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        if (!self.navigationController.navigationBar.translucent ||
            self.edgesForExtendedLayout == UIRectEdgeNone ||
            self.edgesForExtendedLayout == UIRectEdgeTop) {
            tabBarY = screenSize.height - TAB_BAR_HEIGHT - navMaxY;
            contentViewHeight = tabBarY;
        } else {
            contentViewY = navMaxY;
            contentViewHeight = screenSize.height - TAB_BAR_HEIGHT - contentViewY;
        }
    }
    
    [self setTabBarFrame:CGRectMake(0, tabBarY, screenSize.width, TAB_BAR_HEIGHT)
        contentViewFrame:CGRectMake(0, contentViewY, screenSize.width, contentViewHeight)];
}

- (void)setContentViewFrame:(CGRect)contentViewFrame {
    _contentViewFrame = contentViewFrame;
    [self updateContentViewsFrame];
}

- (void)setTabBarFrame:(CGRect)tabBarFrame contentViewFrame:(CGRect)contentViewFrame {
    self.tabBar.frame = tabBarFrame;
    self.contentViewFrame = contentViewFrame;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    for (UIViewController *controller in _viewControllers) {
        [controller removeFromParentViewController];
        if (controller.isViewLoaded) {
            [controller.view removeFromSuperview];
        }
    }
    
    _viewControllers = [viewControllers copy];
    
    NSMutableArray *items = [NSMutableArray array];
    for (UIViewController *controller in _viewControllers) {
        [self addChildViewController:controller];
        
        YHJTabItem *item = [YHJTabItem buttonWithType:UIButtonTypeCustom];
        item.image = controller.yhj_tabItemImage;
        item.selectedImage = controller.yhj_tabItemSelectedImage;
        item.title = controller.yhj_tabItemTitle;
        [items addObject:item];
    }
    self.tabBar.items = items;
    
    if (_didViewAppeared) {
        _selectedControllerIndex = NSNotFound;
        self.tabBar.selectedItemIndex = 0;
    }
    
    // 更新scrollView的content size
    if (self.contentScrollView) {
        self.contentScrollView.contentSize = CGSizeMake(self.contentViewFrame.size.width * _viewControllers.count,
                                                 self.contentViewFrame.size.height);
    }
}

- (void)setContentScrollEnabledAndTapSwitchAnimated:(BOOL)switchAnimated {
    if (!self.contentScrollView) {
        self.contentScrollView = [[YHJTabContentScrollView alloc] initWithFrame:self.contentViewFrame];
#if TARGET_OS_IOS
        self.contentScrollView.pagingEnabled = YES;
        self.contentScrollView.scrollsToTop = NO;
#elif TARGET_OS_TV
        
#endif
        
        self.contentScrollView.showsHorizontalScrollIndicator = NO;
        self.contentScrollView.showsVerticalScrollIndicator = NO;
        self.contentScrollView.delegate = self;
        self.contentScrollView.yhj_delegate = self;
        [self.view insertSubview:self.contentScrollView belowSubview:self.tabBar];
        self.contentScrollView.contentSize = CGSizeMake(self.contentViewFrame.size.width * self.viewControllers.count, self.contentViewFrame.size.height);
    }
    [self updateContentViewsFrame];
    self.contentSwitchAnimated = switchAnimated;
}

- (void)updateContentViewsFrame {
    if (self.contentScrollView) {
        self.contentScrollView.frame = self.contentViewFrame;
        self.contentScrollView.contentSize = CGSizeMake(self.contentViewFrame.size.width * self.viewControllers.count,
                                                 self.contentViewFrame.size.height);
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull controller,
                                                           NSUInteger idx, BOOL * _Nonnull stop) {
            if (controller.isViewLoaded) {
                controller.view.frame = [self frameForControllerAtIndex:idx];
            }
        }];
        [self.contentScrollView scrollRectToVisible:self.selectedController.view.frame animated:NO];
    } else {
        self.selectedController.view.frame = self.contentViewFrame;
    }
}

- (CGRect)frameForControllerAtIndex:(NSUInteger)index {
    return CGRectMake(index * self.contentViewFrame.size.width,
                      0,
                      self.contentViewFrame.size.width,
                      self.contentViewFrame.size.height);
}

- (void)setInterceptRightSlideGuetureInFirstPage:(BOOL)interceptRightSlideGuetureInFirstPage {
    _interceptRightSlideGuetureInFirstPage = interceptRightSlideGuetureInFirstPage;
    self.contentScrollView.interceptRightSlideGuetureInFirstPage = interceptRightSlideGuetureInFirstPage;
}

- (void)setInterceptLeftSlideGuetureInLastPage:(BOOL)interceptLeftSlideGuetureInLastPage {
    _interceptLeftSlideGuetureInLastPage = interceptLeftSlideGuetureInLastPage;
    self.contentScrollView.interceptLeftSlideGuetureInLastPage = interceptLeftSlideGuetureInLastPage;
}

- (void)setSelectedControllerIndex:(NSUInteger)selectedControllerIndex {
    self.tabBar.selectedItemIndex = selectedControllerIndex;
}

- (UIViewController *)selectedController {
    if (self.selectedControllerIndex != NSNotFound) {
        return self.viewControllers[self.selectedControllerIndex];
    }
    return nil;
}

- (void)didSelectViewControllerAtIndex:(NSUInteger)index {}

#pragma mark - YHJTabBarDelegate

- (void)yhj_tabBar:(YHJTabBar *)tabBar didSelectedItemAtIndex:(NSUInteger)index {
    if (index == self.selectedControllerIndex) {
        return;
    }
    UIViewController *oldController = nil;
    if (self.selectedControllerIndex != NSNotFound) {
        oldController = self.viewControllers[self.selectedControllerIndex];
        [oldController yhj_tabItemDidDeselected];
        if ([oldController respondsToSelector:@selector(tabItemDidDeselected)]) {
            [oldController performSelector:@selector(tabItemDidDeselected)];
        }
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull controller, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx != index && controller.isViewLoaded && controller.view.superview) {
                [controller.view removeFromSuperview];
            }
        }];
    }
    UIViewController *curController = self.viewControllers[index];
    if (self.contentScrollView) {
        // contentView支持滚动
        if (!curController.isViewLoaded) {
            curController.view.frame = [self frameForControllerAtIndex:index];
        }
        
        [self.contentScrollView addSubview:curController.view];
        // 切换到curController
        [self.contentScrollView scrollRectToVisible:curController.view.frame animated:self.contentSwitchAnimated];
    } else {
        // contentView不支持滚动
        
        [self.view insertSubview:curController.view belowSubview:self.tabBar];
        // 设置curController.view的frame
        if (!CGRectEqualToRect(curController.view.frame, self.contentViewFrame)) {
            curController.view.frame = self.contentViewFrame;
        }
    }
    
    BOOL isSelectedFirstTime = [curController yhj_isTabItemSelectedFirstTime];
    if (isSelectedFirstTime) {
        objc_setAssociatedObject(curController, @selector(yhj_isTabItemSelectedFirstTime), @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [curController yhj_tabItemDidSelected:isSelectedFirstTime];
    if ([curController respondsToSelector:@selector(tabItemDidSelected)]) {
        [curController performSelector:@selector(tabItemDidSelected)];
    }
    
    // 当contentView为scrollView及其子类时，设置它支持点击状态栏回到顶部
    if (oldController && [oldController.view isKindOfClass:[UIScrollView class]]) {
#if TARGET_OS_IOS
        [(UIScrollView *)oldController.view setScrollsToTop:NO];
#elif TARGET_OS_TV
        
#endif
        
    }
    if ([curController.view isKindOfClass:[UIScrollView class]]) {
#if TARGET_OS_IOS
        [(UIScrollView *)curController.view setScrollsToTop:YES];
#elif TARGET_OS_TV
        
#endif
        
    }

    _selectedControllerIndex = index;
    
    [self didSelectViewControllerAtIndex:_selectedControllerIndex];
}

#pragma mark - YHJTabContentScrollViewDelegate

- (BOOL)scrollView:(YHJTabContentScrollView *)scrollView shouldScrollToPageIndex:(NSUInteger)index {
    if ([self respondsToSelector:@selector(tabBar:shouldSelectItemAtIndex:)]) {
        return [self tabBar:self.tabBar shouldSelectItemAtIndex:index];
    }
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.tabBar.selectedItemIndex = page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 如果不是手势拖动导致的此方法被调用，不处理
    if (!(scrollView.isDragging || scrollView.isDecelerating)) {
        return;
    }
    
    // 滑动越界不处理
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat scrollViewWidth = scrollView.frame.size.width;
    
    if (offsetX < 0) {
        return;
    }
    if (offsetX > scrollView.contentSize.width - scrollViewWidth) {
        return;
    }

    NSUInteger leftIndex = offsetX / scrollViewWidth;
    NSUInteger rightIndex = leftIndex + 1;
    
    // 这里处理shouldSelectItemAtIndex方法
    if ([self respondsToSelector:@selector(tabBar:shouldSelectItemAtIndex:)] && !scrollView.isDecelerating) {
        NSUInteger targetIndex;
        if (_lastContentScrollViewOffsetX < (CGFloat)offsetX) {
            // 向左
            targetIndex = rightIndex;
        } else {
            // 向右
            targetIndex = leftIndex;
        }
        if (targetIndex != self.selectedControllerIndex) {
            if (![self tabBar:self.tabBar shouldSelectItemAtIndex:targetIndex]) {
                [scrollView setContentOffset:CGPointMake(self.selectedControllerIndex * scrollViewWidth, 0) animated:NO];
            }
        }
    }
    _lastContentScrollViewOffsetX = offsetX;
    
    // 刚好处于能完整显示一个child view的位置
    if (leftIndex == offsetX / scrollViewWidth) {
        rightIndex = leftIndex;
    }
    // 将需要显示的child view放到scrollView上
    for (NSUInteger index = leftIndex; index <= rightIndex; index++) {
        UIViewController *controller = self.viewControllers[index];
        
        if (!controller.isViewLoaded && self.loadViewOfChildContollerWhileAppear) {
            controller.view.frame = [self frameForControllerAtIndex:index];
        }
        if (controller.isViewLoaded && !controller.view.superview) {
            [self.contentScrollView addSubview:controller.view];
        }
    }
    
    // 同步修改tarBar的子视图状态
    [self.tabBar updateSubViewsWhenParentScrollViewScroll:self.contentScrollView];
}

@end


@implementation YHJTabContentScrollView

/**
 *  重写此方法，在需要的时候，拦截UIPanGestureRecognizer
 */
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    if (![gestureRecognizer respondsToSelector:@selector(translationInView:)]) {
        return YES;
    }
    // 计算可能切换到的index
    NSInteger currentIndex = self.contentOffset.x / self.frame.size.width;
    NSInteger targetIndex = currentIndex;
    
    CGPoint translation = [gestureRecognizer translationInView:self];
    if (translation.x > 0) {
        targetIndex = currentIndex - 1;
    } else {
        targetIndex = currentIndex + 1;
    }
    
    // 第一页往右滑动
    if (self.interceptRightSlideGuetureInFirstPage && targetIndex < 0) {
        return NO;
    }
    
    // 最后一页往左滑动
    if (self.interceptLeftSlideGuetureInLastPage) {
        NSUInteger numberOfPage = self.contentSize.width / self.frame.size.width;
        if (targetIndex >= numberOfPage) {
            return NO;
        }
    }
    
    // 其他情况
    if (self.yhj_delegate && [self.yhj_delegate respondsToSelector:@selector(scrollView:shouldScrollToPageIndex:)]) {
        return [self.yhj_delegate scrollView:self shouldScrollToPageIndex:targetIndex];
    }
    
    return YES;
}

@end
