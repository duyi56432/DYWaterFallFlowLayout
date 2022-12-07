//
//  Const.h
//  DYWaterFlowLayoutDemo
//
//  Created by VolcanoStudio on 2022/12/6.
//

#ifndef Const_h
#define Const_h

#define iPhoneX \
    ({BOOL isPhoneX = NO;\
    if (@available(iOS 11.0, *)) {\
        isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
    }\
    (isPhoneX);})

#define ISIPAD [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

#define  kStatusBarHeight     ({CGFloat statusBarHeight = 0;\
    if (@available(iOS 13.0, *)) {\
        statusBarHeight = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarFrame.size.height;\
    }\
    ( statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height);})

#define  kNavBarHeight  (ISIPAD ? 60.f : 44.f)

#define  kNavigation_height  (kNavBarHeight+kStatusBarHeight)


#define  Screen_Width [UIScreen mainScreen].bounds.size.width
#define  Screen_Hieght [UIScreen mainScreen].bounds.size.height
#endif /* Const_h */
