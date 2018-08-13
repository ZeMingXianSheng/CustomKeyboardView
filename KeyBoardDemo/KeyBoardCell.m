//
//  KeyBoardCell.m
//  KeyBoardDemo
//
//  Created by Rain on 2018/8/1.
//  Copyright © 2018年 Rain. All rights reserved.
//

#import "KeyBoardCell.h"
#import "KeyModel.h"
#define RGBCOLOR(r,g,b)         [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a)      [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
@interface KeyBoardCell ()
@property (nonatomic, strong) UIButton *keyBtn;//键盘上btn按钮

@end

@implementation KeyBoardCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.keyBtn];
    }
    return self;
}
- (void)setKeyModel:(KeyModel *)keyModel {
    _keyModel = keyModel;
    _keyBtn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _keyBtn.tag = keyModel.keyNumberType;
    if (keyModel.keyImage.length) {
        [_keyBtn setImage:[UIImage imageNamed:keyModel.keyImage] forState:UIControlStateNormal];
    } else {
        [_keyBtn setTitle:keyModel.keyName forState:UIControlStateNormal];
    }
    //设置btn默认颜色
    if (keyModel.keyNumberType == KeyNumberTypeDelete
        || keyModel.keyNumberType == KeyNumberTypeClear
        || keyModel.keyNumberType == KeyNumberTypePlus
        || keyModel.keyNumberType == KeyNumberTypeMinus
        || keyModel.keyNumberType == KeyNumberTypeMultiply
        || keyModel.keyNumberType == KeyNumberTypeEqual) {//加减乘等 删除、清空按钮点击和默认背景颜色
        _keyBtn.backgroundColor = RGBCOLOR(209, 213, 219);
    } else if (keyModel.keyNumberType == KeyNumberTypeSure) {//确定按钮点击和默认颜色
        _keyBtn.backgroundColor = RGBCOLOR(4, 126, 255);
    } else {//常规按钮点击颜色
        _keyBtn.backgroundColor = [UIColor whiteColor];
    }
}


#pragma mark -- btn点击事件
- (void)clickBtn:(UIButton *)sender {
    NSLog(@"%@", self.keyModel.keyName.length ? self.keyModel.keyName : self.keyModel.keyImage);
    if (sender.tag == KeyNumberTypeDelete
        || _keyModel.keyNumberType == KeyNumberTypeClear
        || _keyModel.keyNumberType == KeyNumberTypePlus
        || _keyModel.keyNumberType == KeyNumberTypeMinus
        || _keyModel.keyNumberType == KeyNumberTypeMultiply
        || _keyModel.keyNumberType == KeyNumberTypeEqual) {//加减乘等 删除、清空按钮点击和默认背景颜色
        sender.backgroundColor = RGBCOLOR(182, 188, 196);
    } else if (sender.tag == KeyNumberTypeSure) {//确定按钮点击和默认颜色
         sender.backgroundColor = RGBCOLOR(0, 110, 226);
    } else {//常规按钮点击颜色
        sender.backgroundColor = RGBCOLOR(222, 222, 222);
    }
    
    KeyboardInputType inputTextType;
    switch (sender.tag) {
        case KeyNumberTypeOne:
        case KeyNumberTypeTwo:
        case KeyNumberTypeThree:
        case KeyNumberTypeFour:
        case KeyNumberTypeFive:
        case KeyNumberTypeSix:
        case KeyNumberTypeSeven:
        case KeyNumberTypeEight:
        case KeyNumberTypeNine:
        case KeyNumberTypeZero:
            inputTextType = KeyboardInputTypeNumber;
            if (self.inputTextBlock) {
                self.inputTextBlock(inputTextType, _keyModel, _keyModel.keyName);
            }
            break;
        case KeyNumberTypePositiveNegative://正负
            inputTextType = KeyboardInputTypePositiveNegative;
            if (self.inputTextBlock) {
                if (_keyModel.status == YES) {
                    _keyModel.status = NO;
                } else {
                    _keyModel.status = YES;
                }
                 self.inputTextBlock(inputTextType, _keyModel, @"");
            }
            break;
        case KeyNumberTypePoint://小数点
            inputTextType = KeyboardInputTypePoint;
            if (self.inputTextBlock) {
                self.inputTextBlock(inputTextType, _keyModel, @".");
            }
            break;
        case KeyNumberTypePlus://加
            inputTextType = KeyboardInputTypePlus;
            if (self.inputTextBlock) {
                self.inputTextBlock(inputTextType, _keyModel, @"+");
            }
            break;
        case KeyNumberTypeMinus://减
            inputTextType = KeyboardInputTypeMinus;
            if (self.inputTextBlock) {
                self.inputTextBlock(inputTextType, _keyModel, @"-");
            }
            break;
        case KeyNumberTypeMultiply://乘
            inputTextType = KeyboardInputTypeMultiply;
            if (self.inputTextBlock) {
                self.inputTextBlock(inputTextType, _keyModel, @"×");
            }
            break;
        case KeyNumberTypeEqual://等于
            inputTextType = KeyboardInputTypeEqual;
            if (self.inputTextBlock) {
                 self.inputTextBlock(inputTextType, _keyModel, @"");
            }
            break;
        case KeyNumberTypeDelete://删除
            inputTextType = KeyboardInputTypeDelete;
            if (self.inputTextBlock) {
                self.inputTextBlock(inputTextType, _keyModel, @"");
            }
            break;
        case KeyNumberTypeClear://清空
            inputTextType = KeyboardInputTypeClear;
            if (self.inputTextBlock) {
                self.inputTextBlock(inputTextType, _keyModel, @"");
            }
            break;
        case KeyNumberTypeSure://确定
            inputTextType = KeyboardInputTypeSure;
            if (self.inputTextBlock) {
                self.inputTextBlock(inputTextType, _keyModel, @"");
            }
            break;
        case KeyNumberTypeClose://关闭
            inputTextType = KeyboardInputTypeClose;
            if (self.inputTextBlock) {
                self.inputTextBlock(inputTextType, _keyModel, @"");
            }
            break;
        default:
            break;
    }

}
- (void)cancelBtn:(UIButton *)sender {
    if (sender.tag == KeyNumberTypeDelete
        || _keyModel.keyNumberType == KeyNumberTypeClear
        || _keyModel.keyNumberType == KeyNumberTypePlus
        || _keyModel.keyNumberType == KeyNumberTypeMinus
        || _keyModel.keyNumberType == KeyNumberTypeMultiply
        || _keyModel.keyNumberType == KeyNumberTypeEqual) {//加减乘等 删除、清空按钮点击和默认背景颜色
        _keyBtn.backgroundColor = RGBCOLOR(209, 213, 219);
    } else if (sender.tag == KeyNumberTypeSure) {//确定按钮点击和默认颜色
        _keyBtn.backgroundColor = RGBCOLOR(4, 126, 255);
    } else {//常规按钮点击颜色
        _keyBtn.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark -- lazy
- (UIButton *)keyBtn {
    if (!_keyBtn) {
        _keyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _keyBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_keyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _keyBtn.backgroundColor = [UIColor whiteColor];
        [_keyBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchDown];

        [_keyBtn addTarget:self action:@selector(cancelBtn:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDragExit];
    }
    return _keyBtn;
}

@end
