//
//  KeyboardModeHandler.h
//  KeyBoardDemo
//
//  Created by Rain on 2018/8/13.
//  Copyright © 2018年 Rain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomKeyBoardView.h"
/**
 键盘viewModel层
 */
@interface KeyboardModeHandler : NSObject

+ (instancetype)shareKeyboardInstance;
/**
 返回不同键盘类型数据
 */
- (NSArray *)getKeyboardDataWithKeyboardType:(KeyBoardType)keyboradType;
@end
