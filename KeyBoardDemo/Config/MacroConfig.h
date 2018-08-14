//
//  MacroConfig.h
//  KeyBoardDemo
//
//  Created by Rain on 2018/8/14.
//  Copyright © 2018年 Rain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//****************************贺贺同学所写******************************
/**
 判断是不是iPhone X
 
 @return Bool值
 */
BOOL isIphoneX(void);

/**
 适配iPhone X NavBar高度
 
 @return NavBar高度
 */
CGFloat adjustNavBarHeight(void);


//当前Window宽高 //

#define   WindowWidth       [UIScreen mainScreen].bounds.size.width

#define   WindowHeight      [UIScreen mainScreen].bounds.size.height

//判断是不是iPhoneX
#define IS_IPHONEX isIphoneX()

//iPhone X顶部StatusBar = 44,而其他的皆为StatusBar = 20
#define StatusBarH [UIApplication sharedApplication].statusBarFrame.size.height

#define StatusBarHeight ((IS_IPHONEX) ? (44) : (20))

//iPhone X顶部StatusBar + navigationBar = 88,而其他的皆为StatusBar + navigationBar = 64
#define SafeAreaTopHeight (IS_IPHONEX ? adjustNavBarHeight() : 64)
// iPhone X 底部HomeBar高度
#define BottomHomeBarHeight (IS_IPHONEX ? 34 : 0)



@interface MacroConfig : NSObject
+ (NSString *)iPhoneType;
@end
