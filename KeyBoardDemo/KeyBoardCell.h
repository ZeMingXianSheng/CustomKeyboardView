//
//  KeyBoardCell.h
//  KeyBoardDemo
//
//  Created by Rain on 2018/8/1.
//  Copyright © 2018年 Rain. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomKeyBoardView.h"
typedef NS_ENUM(NSInteger, KeyboardInputType){
    KeyboardInputTypeNumber,            //输入数字
    KeyboardInputTypePoint,             //输入小数点
    KeyboardInputTypePositiveNegative,  //输入正负
    KeyboardInputTypePlus,              //输入加号
    KeyboardInputTypeMinus,             //输入减号
    KeyboardInputTypeMultiply,          //输入相乘
    KeyboardInputTypeDivide,            //输入相除
    KeyboardInputTypeEqual,             //输入等于
    KeyboardInputTypeDelete,            //输入删除
    KeyboardInputTypeClear,             //输入清除
    KeyboardInputTypeSure,              //输入确定
    KeyboardInputTypeClose              //输入关闭键盘
};
@class KeyModel;

typedef void(^InputTextBlock)(KeyboardInputType inputTextType, KeyModel *keyModel, NSString *value);//返回键盘输入内容, 以及类型
@interface KeyBoardCell : UICollectionViewCell

@property (nonatomic, strong) KeyModel *keyModel;

@property (nonatomic, copy) InputTextBlock inputTextBlock;

@end
