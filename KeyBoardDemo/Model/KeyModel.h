//
//  KeyModel.h
//  KeyBoardDemo
//
//  Created by Rain on 2018/8/1.
//  Copyright © 2018年 Rain. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KeyNumberType) {
    KeyNumberTypeOne,       //数字 1                      0
    KeyNumberTypeTwo,       //数字 2                      1
    KeyNumberTypeThree,     //数字 3                      2
    KeyNumberTypeFour,      //数字 4                      3
    KeyNumberTypeFive,      //数字 5                      4
    KeyNumberTypeSix,       //数字 6                      5
    KeyNumberTypeSeven,     //数字 7                      6
    KeyNumberTypeEight,     //数字 8                      7
    KeyNumberTypeNine,      //数字 9                      8
    KeyNumberTypeZero,      //数字 0                      9
    KeyNumberTypePoint,     //小数点                      10
    KeyNumberTypeClose,     //隐藏键盘                    11
    KeyNumberTypePositiveNegative,    //输入正负数        12
    KeyNumberTypeDelete,    //删除                       13
    KeyNumberTypeClear,     //清空                       14
    KeyNumberTypeSure,      //确定                       15
    KeyNumberTypePlus,       //相加                      16
    KeyNumberTypeMinus,       //相减                     17
    KeyNumberTypeMultiply,  //相乘                       18
    KeyNumberTypeEqual      //等于                       19
    
};


@interface KeyModel : NSObject
@property (nonatomic, assign) NSInteger keyId;//字母id
@property (nonatomic, copy) NSString *keyName;//字母名称  0-9 .  +-*=  清空  确定
@property (nonatomic, copy) NSString *keyImage;//字母图片  有图片情况下, 显示图片
@property (nonatomic, assign) KeyNumberType  keyNumberType;//字母类型
@property (nonatomic, assign) BOOL status;//正负数状态  0:是默认正数, 1:是负数

@end
