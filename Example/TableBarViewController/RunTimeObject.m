//
//  RunTimeObject.m
//  TableBarViewController
//
//  Created by MRJ on 2017/9/3.
//  Copyright © 2017年 mrjyuhongjiang. All rights reserved.
//

#import "RunTimeObject.h"

#import <objc/runtime.h>

@implementation RunTimeObject

///此方法只会执行一次
+ (void)load
{
    
    ///获得类方法
//    Method desMethod = class_getClassMethod(self, @selector(description));
//    
//    Method mrj_desMethod = class_getClassMethod(self, @selector(MRJ_description));
    
    ///获得实例方法, 两个方法的交换
    Method desMethod = class_getInstanceMethod(self, @selector(description));
    
    Method mrj_desMethod = class_getInstanceMethod(self, @selector(MRJ_description));
    
    method_exchangeImplementations(desMethod, mrj_desMethod);
}



///实例方法
- (void)methodName
{
    NSLog(@"我的名字是小江江!");
}

///私有方法
- (void)nameMethod
{
    NSLog(@"这是个私有方法");
}

///动态添加类方法
+ (BOOL)resolveClassMethod:(SEL)sel
{
    if (![super resolveClassMethod:sel]) {
        class_addMethod(self, sel, (IMP)temMethod, "v");
    }
    return YES;
}

///动态添加实例方法
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    if (![super resolveInstanceMethod:sel]) {
        class_addMethod(self, sel, (IMP)temMethod, "v");
    }
    return YES;
}

///临时加载的方法，防止系统找不到要找的方法是，调用此方法
void temMethod(){
    NSLog(@"我是替换方法，哇咔咔");
}

///系统自带方法
- (NSString *)description
{
    return @"我是原生系统方法";
}

///替换的方法
- (NSString *)MRJ_description
{
    return @"现在原生系统已经被我取代，哇咔咔咔";
}

@end
