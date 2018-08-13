//
//  KeyModel.h
//  KeyBoardDemo
//
//  Created by Rain on 2018/8/1.
//  Copyright © 2018年 Rain. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KeyNumberType) {
    KeyNumberTypeOne = 1,       //数字 1
    KeyNumberTypeTwo,       //数字 2
    KeyNumberTypeThree,     //数字 3
    KeyNumberTypeFour,      //数字 4
    KeyNumberTypeFive,      //数字 5
    KeyNumberTypeSix,       //数字 6
    KeyNumberTypeSeven,     //数字 7
    KeyNumberTypeEight,     //数字 8
    KeyNumberTypeNine,      //数字 9
    KeyNumberTypeZero,      //数字 0
    KeyNumberTypePoint,     //小数点
    KeyNumberTypeClose,    //隐藏键盘
    KeyNumberTypePositiveNegative,    //输入正负数
    KeyNumberTypeDelete,    //删除
    KeyNumberTypeClear,     //清空
    KeyNumberTypeSure,      //确定
    KeyNumberTypePlus,       //相加
    KeyNumberTypeMinus,       //相减
    KeyNumberTypeMultiply,  //相乘
    KeyNumberTypeEqual      //等于
    
};


@interface KeyModel : NSObject
@property (nonatomic, assign) NSInteger keyId;//字母id
@property (nonatomic, copy) NSString *keyName;//字母名称  0-9 .  +-*=  清空  确定
@property (nonatomic, copy) NSString *keyImage;//字母图片  有图片情况下, 显示图片
@property (nonatomic, assign) KeyNumberType  keyNumberType;//字母类型
@property (nonatomic, assign) BOOL status;//正负数状态  0:是默认正数, 1:是负数

@end
