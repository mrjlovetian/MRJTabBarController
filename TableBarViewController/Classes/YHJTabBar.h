//
//  YHJTabBar.h
//  YHJTabBarController
//
//  Created by 余洪江 on 17/8/11.
//  Copyright (c) 2017年 YHJTabBarController. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHJTabItem.h"

@class YHJTabBar;

@protocol YHJTabBarDelegate <NSObject>

@optional

/**
 *  是否能切换到指定index
 */
- (BOOL)tabBar:(YHJTabBar *)tabBar shouldSelectItemAtIndex:(NSUInteger)index;

/**
 *  将要切换到指定index
 */
- (void)tabBar:(YHJTabBar *)tabBar willSelectItemAtIndex:(NSUInteger)index;

/**
 *  已经切换到指定index
 */
- (void)yhj_tabBar:(YHJTabBar *)tabBar didSelectedItemAtIndex:(NSUInteger)index;

@end

@interface YHJTabBar : UIView

/**
 *  TabItems，提供给YHJTabBarController使用，一般不手动设置此属性
 */
@property (nonatomic, copy) NSArray <YHJTabItem *> *items;

@property (nonatomic, strong) UIColor *itemSelectedBgColor;         // item选中背景颜色
@property (nonatomic, strong) UIImage *itemSelectedBgImage;         // item选中背景图像
@property (nonatomic, assign) CGFloat itemSelectedBgCornerRadius;   // item选中背景圆角

@property (nonatomic, strong) UIColor *itemTitleColor;              // 标题颜色
@property (nonatomic, strong) UIColor *itemTitleSelectedColor;      // 选中时标题的颜色
@property (nonatomic, strong) UIFont  *itemTitleFont;               // 标题字体
@property (nonatomic, strong) UIFont  *itemTitleSelectedFont;       // 选中时标题的字体

@property (nonatomic, strong) UIColor *badgeBackgroundColor;        // Badge背景颜色
@property (nonatomic, strong) UIImage *badgeBackgroundImage;        // Badge背景图像
@property (nonatomic, strong) UIColor *badgeTitleColor;             // Badge标题颜色
@property (nonatomic, strong) UIFont  *badgeTitleFont;              // Badge标题字体

@property (nonatomic, assign) CGFloat leftAndRightSpacing;          // TabBar边缘与第一个和最后一个item的距离

@property (nonatomic, assign) NSUInteger selectedItemIndex;          // 选中某一个item


/**
 *  拖动内容视图时，item的颜色是否根据拖动位置显示渐变效果，默认为YES
 */
@property (nonatomic, assign, getter = isItemColorChangeFollowContentScroll) BOOL itemColorChangeFollowContentScroll;

/**
 *  拖动内容视图时，item的字体是否根据拖动位置显示渐变效果，默认为NO
 */
@property (nonatomic, assign, getter = isItemFontChangeFollowContentScroll) BOOL itemFontChangeFollowContentScroll;

/**
 *  TabItem的选中背景是否随contentView滑动而移动
 */
@property (nonatomic, assign, getter = isItemSelectedBgScrollFollowContent) BOOL itemSelectedBgScrollFollowContent;

/**
 *  将Image和Title设置为水平居中，默认为YES
 */
@property (nonatomic, assign, getter = isItemContentHorizontalCenter) BOOL itemContentHorizontalCenter;

@property (nonatomic, weak) id<YHJTabBarDelegate> delegate;

/**
 *  返回已选中的item
 */
- (YHJTabItem *)selectedItem;

/**
 *  根据titles创建item
 */
- (void)setTitles:(NSArray <NSString *> *)titles;

/**
 *  设置tabItem的选中背景，这个背景可以是一个横条
 *
 *  @param insets       选中背景的insets
 *  @param animated     点击item进行背景切换的时候，是否支持动画
 */
- (void)setItemSelectedBgInsets:(UIEdgeInsets)insets tapSwitchAnimated:(BOOL)animated;

/**
 *  设置tabBar可以左右滑动
 *  此方法与setScrollEnabledAndItemFitTextWidthWithSpacing这个方法是两种模式，哪个后调用哪个生效
 *
 *  @param width 每个tabItem的宽度
 */
- (void)setScrollEnabledAndItemWidth:(CGFloat)width;

/**
 *  设置tabBar可以左右滑动，并且item的宽度根据标题的宽度来匹配
 *  此方法与setScrollEnabledAndItemWidth这个方法是两种模式，哪个后调用哪个生效
 *
 *  @param spacing  item的宽度 = 文字宽度 + spacing 
 */
- (void)setScrollEnabledAndItemFitTextWidthWithSpacing:(CGFloat)spacing;

/**
 *  将tabItem的image和title设置为居中，并且调整其在竖直方向的位置
 *
 *  @param verticalOffset  竖直方向的偏移量
 *  @param spacing         image和title的距离
 */
- (void)setItemContentHorizontalCenterWithVerticalOffset:(CGFloat)verticalOffset
                                                 spacing:(CGFloat)spacing;

/**
 *  设置数字Badge的位置与大小。
 *  默认marginTop = 2，centerMarginRight = 30，titleHorizonalSpace = 8，titleVerticalSpace = 2。
 *
 *  @param marginTop            与TabItem顶部的距离，默认为：2
 *  @param centerMarginRight    中心与TabItem右侧的距离，默认为：30
 *  @param titleHorizonalSpace  标题水平方向的空间，默认为：8
 *  @param titleVerticalSpace   标题竖直方向的空间，默认为：2
 */
- (void)setNumberBadgeMarginTop:(CGFloat)marginTop
              centerMarginRight:(CGFloat)centerMarginRight
            titleHorizonalSpace:(CGFloat)titleHorizonalSpace
             titleVerticalSpace:(CGFloat)titleVerticalSpace;
/**
 *  设置小圆点Badge的位置与大小。
 *  默认marginTop = 5，centerMarginRight = 25，sideLength = 10。
 *
 *  @param marginTop            与TabItem顶部的距离，默认为：5
 *  @param centerMarginRight    中心与TabItem右侧的距离，默认为：25
 *  @param sideLength           小圆点的边长，默认为：10
 */
- (void)setDotBadgeMarginTop:(CGFloat)marginTop
           centerMarginRight:(CGFloat)centerMarginRight
                  sideLength:(CGFloat)sideLength;

/**
 *  设置分割线
 *
 *  @param itemSeparatorColor 分割线颜色
 *  @param width              宽度
 *  @param marginTop          与tabBar顶部距离
 *  @param marginBottom       与tabBar底部距离
 */
- (void)setItemSeparatorColor:(UIColor *)itemSeparatorColor
                        width:(CGFloat)width
                    marginTop:(CGFloat)marginTop
                 marginBottom:(CGFloat)marginBottom;

- (void)setItemSeparatorColor:(UIColor *)itemSeparatorColor
                    marginTop:(CGFloat)marginTop
                 marginBottom:(CGFloat)marginBottom;

/**
 *  添加一个特殊的YHJTabItem到tabBar上，此TabItem不包含在tabBar的items数组里
 *  主要用于有的项目需要在tabBar的中间放置一个单独的按钮，类似于新浪微博等。
 *  此方法仅适用于不可滚动类型的tabBar
 *
 *  @param item    YHJTabItem对象
 *  @param index   将其放在此index的item后面
 *  @param handler 点击事件回调
 */
- (void)setSpecialItem:(YHJTabItem *)item
    afterItemWithIndex:(NSUInteger)index
            tapHandler:(void (^)(YHJTabItem *item))handler;

/**
 *  当YHJTabBar所属的YHJTabBarController内容视图支持拖动切换时，
 *  此方法用于同步内容视图scrollView拖动的偏移量，以此来改变YHJTabBar内控件的状态
 */
- (void)updateSubViewsWhenParentScrollViewScroll:(UIScrollView *)scrollView;

@end
