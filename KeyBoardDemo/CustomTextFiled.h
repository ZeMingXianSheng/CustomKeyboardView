//
//  CustomTextFiled.h
//  KeyBoardDemo
//
//  Created by Rain on 2018/8/2.
//  Copyright © 2018年 Rain. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, CustomTextFiledType) {
    CustomTextFiledTypeNormal,             //普通数字键盘        不带小数点、不可以为负
    CustomTextFiledTypePoint,              //数字键盘           带小数点
    CustomTextFiledTypeNegavite,           //数字键盘           带正负
    CustomTextFiledTypeCalcuateNormal,     //普通计算数字键盘     不带小数点 、不可以为负
    CustomTextFiledTypeCalcuatePoint,      //计算数字键盘        带小数点
    CustomTextFiledTypeCalcuateNegavite,   //计算数字键盘        带正负
};

@interface CustomTextFiled : UITextField

@end
