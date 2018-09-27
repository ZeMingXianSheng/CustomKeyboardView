//
//  CustomKeyBoardView.m
//  KeyBoardDemo
//
//  Created by Rain on 2018/8/1.
//  Copyright © 2018年 Rain. All rights reserved.
//

#ifdef DEBUG
#define debugLog(format, ...) NSLog(@"[%s] %s [第%d行] \n %@", __TIME__, __FUNCTION__, __LINE__, [NSString stringWithFormat:format, ##__VA_ARGS__]);
#define debugMethod() NSLog(@"%s", __func__)
#else
#define debugLog(...)
#define debugMethod()
#endif


#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone5s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define  symbolWidth     ((WindowWidth - 0.5 * 4) / (82 * 3 / 64 + 2))

#define symbolHeight (iPhone5s ? 51 :  (51 * ( [UIScreen mainScreen].bounds.size.height / 667)))


#import "CustomKeyBoardView.h"
#import "KeyBoardCell.h"
#import "KeyModel.h"
#import "WaterFallLayout.h"
#import "KeyboardModeHandler.h"
#import "MacroConfig.h"
@interface CustomKeyBoardView () <UICollectionViewDelegate, UICollectionViewDataSource, WaterFallLayoutDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableString *contentString;//存储计算过程中的输入的内容

@property (nonatomic, strong) NSMutableString *valueString;//记录显示到UITextFiled内容的值

@property (nonatomic, assign) double num1, num2, num3;//计算时，作为数组取出来的数值，便于计算。

@property (nonatomic, strong) NSMutableArray *numArr;//存储操作数的数组

@property (nonatomic, strong) NSMutableArray *operatorArr;//存储操作符的数组

@property (nonatomic, assign) BOOL finishCalculation;//是否完成计算
@end

@implementation CustomKeyBoardView

- (instancetype)initWithFrame:(CGRect)frame keyBoardType:(KeyBoardType)keyBoradType {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        self.keyboardType = keyBoradType;
        self.dataSource = [[KeyboardModeHandler shareKeyboardInstance] getKeyboardDataWithKeyboardType:keyBoradType];
        self.num1 = 0;
        self.num2 = 0;
        self.num3 = 0;
        self.finishCalculation = NO;
    }
    return self;
}
- (instancetype)initWithKeyboardType:(KeyBoardType)keyBoradType {
    self = [self initWithFrame:CGRectMake(0, 0, WindowWidth, symbolHeight * 4 + 0.6 * 3 + BottomHomeBarHeight) keyBoardType:keyBoradType];
    return self;
}

- (instancetype)initWithKeyboardType:(KeyBoardType)keyBoradType inputSource:(UIView *)inputSource {
    self = [self initWithKeyboardType:keyBoradType];
    if (self) {
        self.inputSource = inputSource;
    }
    return self;
}

#pragma mark -- inputText setting方法解析数据
- (void)setInputText:(NSString *)inputText {
    if (!inputText.length||
        _keyboardType == KeyBoardTypeNormal
        || _keyboardType == KeyBoardTypePoint
        || _keyboardType == KeyBoardTypeNegavite
        ) {
        return;
    }
    self.valueString.string = inputText;
    if (![inputText containsString:@"+"]
        && ![inputText containsString:@"-"]
        && ![inputText containsString:@"×"]
        && ![inputText containsString:@"/"]) {
        self.contentString.string = inputText;
    } else {
        //分割操作数
        NSCharacterSet *numCharacter = [NSCharacterSet characterSetWithCharactersInString:@"+-×/"];
        NSArray *numArr =  [inputText componentsSeparatedByCharactersInSet:numCharacter];
        self.numArr = numArr.mutableCopy;
        //分割运算符
        NSCharacterSet *operatorCha = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        NSArray *operatorArr = [inputText componentsSeparatedByCharactersInSet:operatorCha];
        if (operatorArr.count) {
            for (NSString *operator in operatorArr) {
                if (operator.length) {//删除多余的空字符串
                    [self.operatorArr addObject:operator];
                }
            }
        }
    }
    if (_operatorArr.count) {//当有运算符时，最后一个操作数是需要赋值给 contentString。 因为下面输入运算符或者等于运算符时，会把contentString添加到numArr数组里面参与运算。 这样操作是为了方便处理删除运算符的结果。
        self.contentString.string = _numArr.lastObject;
        [_numArr removeLastObject];
    }
    NSLog(@"inputText = %@ \n numArr = %@\n operator = %@", inputText, _numArr, _operatorArr);
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KeyBoardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KeyBoardCell" forIndexPath:indexPath];
    KeyModel *model = self.dataSource[indexPath.item];
    cell.keyModel = model;
    //处理键盘输入的事件
    cell.inputTextBlock = ^(KeyboardInputType inputTextType, KeyModel *keyModel, NSString *value) {
        switch (inputTextType) {
            case KeyboardInputTypeNumber://点击数字
                [self clickNumber:value];
                break;
            case KeyboardInputTypePoint://点击小数点
                [self clickPoint];
                break;
            case KeyboardInputTypePositiveNegative://点击正负
                if (keyModel.status == YES) {
                    self.valueString = [NSMutableString stringWithFormat:@"%@",[_valueString substringFromIndex:1]];
                } else {
                    self.valueString = [NSMutableString stringWithFormat:@"-%@", _valueString.length ? _valueString : @"0"];
                }
                [self clearInputSource];
                [self inputString:_valueString close:NO];
                
                break;
            case KeyboardInputTypePlus:
            case KeyboardInputTypeMinus:
            case KeyboardInputTypeMultiply:
            case KeyboardInputTypeDivide:
                [self clickOperator:value];//点击操作符
                break;
            case KeyboardInputTypeEqual:
                [self clickCalculate];//点击计算
                break;
            case KeyboardInputTypeDelete://删除
                [self clickDelete];
                
                break;
            case KeyboardInputTypeClear://清空
                [self clickClear];
                break;
            case KeyboardInputTypeSure://点击确定
                
                if (_keyboardType == KeyBoardTypeCalcuateNormal
                    || _keyboardType == KeyBoardTypeCalcuatePoint
                    || _keyboardType == KeyBoardTypeCalcuateNegavite) {
                    [self clickCalculate];//计算
                } else {//关闭键盘
                    if (self.confirmBlock) {
                        self.confirmBlock();
                    }
                }
                break;
            case KeyboardInputTypeClose://关闭
                if (self.closeKeyboardBlock) {
                    self.closeKeyboardBlock();
                }
                break;
                
            default:
                break;
        }
        
        
    };
    
    
    return cell;
}

#pragma mark -- WaterFallLayoutDelegate
-  (CGSize)waterFallLayout:(WaterFallLayout *)waterFallLayout sizeForItemAtIndexPath:(NSUInteger)indexPath {
    KeyModel *model = self.dataSource[indexPath];
    switch (_keyboardType) {
        case KeyBoardTypeNormal://普通键盘 不带小数点和正负
            if (model.keyNumberType == KeyNumberTypeSure) {//确定按钮
                return CGSizeMake((WindowWidth - 0.5 * 3) / 4, symbolHeight * 2 + 0.5);
            } else if (model.keyNumberType == KeyNumberTypeZero)  {//0 按钮
                return CGSizeMake((WindowWidth - 0.5 * 3) / 4 * 2 + 0.5,symbolHeight);
            }
            return CGSizeMake((WindowWidth - 0.5 * 3) / 4, symbolHeight);
            break;
        case KeyBoardTypePoint://有小数点
        case KeyBoardTypeNegavite://无小数点、有正负
            if (model.keyNumberType == KeyNumberTypeSure) {//确定按钮
                return CGSizeMake((WindowWidth - 0.5 * 3) / 4, symbolHeight * 2 + 0.5);
            }
            return CGSizeMake((WindowWidth - 0.5 * 3) / 4, symbolHeight);
            break;
        case KeyBoardTypeCalcuateNormal: //计算 不带小数点、不带正负
            if (model.keyNumberType == KeyNumberTypePlus
                || model.keyNumberType == KeyNumberTypeMinus
                || model.keyNumberType == KeyNumberTypeMultiply
                || model.keyNumberType == KeyNumberTypeEqual
                || model.keyNumberType == KeyNumberTypeDelete
                || model.keyNumberType == KeyNumberTypeClear) {
                return CGSizeMake(symbolWidth, symbolHeight);
            } else if (model.keyNumberType == KeyNumberTypeSure) {//确定按钮
                return CGSizeMake(symbolWidth, symbolHeight * 2 + 0.5);
            } else if (model.keyNumberType == KeyNumberTypeZero)  {//0 按钮
                return CGSizeMake((WindowWidth - 0.5 * 4 - symbolWidth * 2) / 3 * 2 + 0.5, symbolHeight);
            }
            return CGSizeMake((WindowWidth - 0.5 * 4 - symbolWidth * 2) / 3, symbolHeight);
            break;
        case KeyBoardTypeCalcuatePoint: //计算 带小数点
        case KeyBoardTypeCalcuateNegavite: //计算 带正负
            if (model.keyNumberType == KeyNumberTypePlus
                || model.keyNumberType == KeyNumberTypeMinus
                || model.keyNumberType == KeyNumberTypeMultiply
                || model.keyNumberType == KeyNumberTypeEqual
                || model.keyNumberType == KeyNumberTypeDelete
                || model.keyNumberType == KeyNumberTypeClear) {
                return CGSizeMake(symbolWidth, symbolHeight);
            } else if (model.keyNumberType == KeyNumberTypeSure) {//确定按钮
                return CGSizeMake(symbolWidth, symbolHeight * 2 + 0.5);
            }
            return CGSizeMake((WindowWidth - 0.5 * 4 - symbolWidth * 2) / 3, symbolHeight);
            break;
        default:
            break;
    }
    
    return CGSizeZero;
}
- (CGFloat)columnMarginInWaterFallLayout:(WaterFallLayout *)waterFallLayout {
    return 0.5;
}
- (CGFloat)rowMarginInWaterFallLayout:(WaterFallLayout *)waterFallLayout {
    return 0.5;
}

- (NSUInteger)columnCountInWaterFallLayout:(WaterFallLayout *)waterFallLayout {
    if (self.keyboardType == KeyBoardTypeNormal
        || self.keyboardType == KeyBoardTypePoint
        || self.keyboardType == KeyBoardTypeNegavite) {
        return 4;
    } else if (self.keyboardType == KeyBoardTypeCalcuateNormal
               || self.keyboardType == KeyBoardTypeCalcuatePoint
               || self.keyboardType == KeyBoardTypeCalcuateNegavite) {
        return 5;
    }
    return 0;
}


#pragma mark -- 计算有关

/**
 点击清除
 */
- (void)clickClear {
    _finishCalculation = NO;
    [_valueString setString:@""];
    [_contentString setString:@""];
    _num3 = 0;
    [_numArr removeAllObjects];
    [_operatorArr removeAllObjects];
    [self clearInputSource];
}

/**
 点击删除
 */
- (void)clickDelete {
    if ([_valueString isEqualToString:@""]) {
        return;
    }
    if ([_valueString hasSuffix:@"+"]
        ||[_valueString hasSuffix:@"-"]
        ||[_valueString hasSuffix:@"×"]
        ||[_valueString hasSuffix:@"/"]) {//如果valueString以操作符结果
        [_operatorArr removeLastObject];
        [_numArr removeLastObject];
        [_valueString deleteCharactersInRange:NSMakeRange(_valueString.length - 1, 1)];//删除最后一个字符
    } else if ([_valueString hasSuffix:@"."]) {//如果valueString 是以.结尾
        if (_finishCalculation == YES) {
            [_numArr removeAllObjects];
        }
        if ([self.contentString isEqualToString:@"0."]) {
            [_contentString setString:@""];
            [_valueString setString:@""];
        } else {
            if (_contentString.length) {
                [_contentString deleteCharactersInRange:NSMakeRange(_contentString.length - 1, 1)];
            }
            [_valueString deleteCharactersInRange:NSMakeRange(_valueString.length - 1, 1)];
            if (_finishCalculation) {//计算完成
                _num3 = [_valueString doubleValue];
                [_numArr addObject:[NSString stringWithFormat:@"%@", _valueString]];
            }
            
        }
        
    } else {//以数字结尾
        if (_numArr.count && _finishCalculation) {
            NSMutableString *lastStr = [NSMutableString stringWithFormat:@"%g", [_numArr.lastObject doubleValue]];
            [lastStr deleteCharactersInRange:NSMakeRange(lastStr.length - 1, 1)];
            [_numArr removeLastObject];//删除原来的最后数字值
            if (lastStr.length) {
                [_numArr addObject:lastStr];//添加修改的数字值
            }
            _num3 = [lastStr doubleValue];
        }
        [_valueString deleteCharactersInRange:NSMakeRange(_valueString.length - 1, 1)];//删除最后一个字符
        if (_contentString.length) {
            [_contentString deleteCharactersInRange:NSMakeRange(_contentString.length - 1, 1)];
        }
    }
    if (!_valueString.length) {//删除完时，清空数据
        _finishCalculation = NO;
        [_contentString setString:@""];
        _num3 = 0;
        [_numArr removeAllObjects];
        [_operatorArr removeAllObjects];
    }
    [self deleteInputSource];
}

/**
 点击数字
 */
- (void)clickNumber:(NSString *)number {
    
    [self.valueString appendString:number];
    if (_finishCalculation == YES) {
        if (_numArr.count && !_operatorArr.count) {
            NSMutableString *lastStr = [NSMutableString stringWithFormat:@"%g", [_numArr.lastObject doubleValue]];
            if ([_valueString containsString:@"."]) {
                [lastStr appendString:@"."];
            }
            [lastStr appendString:number];
            [_numArr removeAllObjects];
            [_operatorArr removeAllObjects];
            [_numArr addObject:lastStr];
            _num3 = [lastStr doubleValue];
        }
    } else {
        [self.contentString appendString:number];
    }
    [self inputString:number close:NO];
    
    //    _finishCalculation = NO;
}

/**
 处理小数点
 */
- (void)clickPoint {
    NSString *tempStr = [NSString stringWithFormat:@"%g", _num3];
    if ([tempStr rangeOfString:@"."].length > 0) {//若结果中已经存在小数点则重新计算
        return;
    }
    if ([self.contentString rangeOfString:@"."].length > 0) {//若contentString中已经存在小数点则返回
        return;
    }
    if (_finishCalculation) {
        if (_valueString.length) {
            [_valueString appendString:@"."];
        } else {
            [_valueString setString:@"0."];
        }
    } else {
        if ([_contentString isEqualToString:@""]) {
            [_contentString setString:@"0."];
            [_valueString setString:@"0."];
            _finishCalculation = NO;
        } else {
            [_contentString appendString:@"."];
            [_valueString appendString:@"."];
            _finishCalculation = NO;
        }
    }
    
    [self inputString:@"." close:NO];
    
}

/**
 点击加减乘除操作符
 */
- (void)clickOperator:(NSString *)value {
    if (_finishCalculation == YES) {
        [_numArr removeAllObjects];
        [_operatorArr removeAllObjects];
        NSString *tempStr = [NSString stringWithFormat:@"%g", _num3];
        [_contentString setString:tempStr];
        [_valueString setString:tempStr];
        _finishCalculation = NO;
    }
    
    if (!_numArr.count && !_valueString.length) {
        NSString *tempStr = [NSString stringWithFormat:@"%g", _num3];
        [_contentString setString:tempStr];
        [_valueString setString:tempStr];
    }
    
    if (!_contentString.length && _operatorArr.count) {//限制输入多个连着的操作运算符
        [_valueString replaceCharactersInRange:NSMakeRange(_valueString.length - 1, 1) withString:value];
        [_operatorArr replaceObjectAtIndex:_operatorArr.count - 1 withObject:value];
        [self inputString:value close:NO];
        
        return;
    }
    
    self.num3 = 0;
    NSString *tempString = [NSString stringWithString:self.contentString];
    [self.numArr addObject:tempString];
    NSLog(@"numArr1: %@", _numArr);
    [_valueString appendString:value];
    [self.operatorArr addObject:value];//保存操作符
    [self.contentString setString:@""];//清空内容string
    [self inputString:value close:NO];
}

/**
 点击计算操作符， 即等于操作符
 */
- (void)clickCalculate {
    if ([self.valueString isEqualToString:@""] || _finishCalculation == YES) {
        return;
    }
    NSString *tempStr = [NSString stringWithString:self.contentString];
    if (tempStr.length) {
        [self.numArr addObject:tempStr];
    }
    NSLog(@"numArr2: %@", _numArr);
    if (_numArr.count == 1) {//若操作数只有一个
        _num3 = [_numArr[0] doubleValue];
        [_valueString setString:[NSString stringWithFormat:@"%g", _num3]];
        return;
    }
    NSLog(@"opeatorArr: %@", _operatorArr);
    [_operatorArr addObject:@"#"];
    while (![_operatorArr[0] isEqualToString:@"#"]) {//当运算符只剩#时，终止
        switch ([self precede:_operatorArr[0] operator2:_operatorArr[1]]) {
            case 0://第一个符号优先级 小于 第二个符号的优先级
            {
                _num1 = [_numArr[1] doubleValue];
                _num2 = [_numArr[2] doubleValue];
                _num3 = [self calculateWithNumber1:_num1 number2:_num2 atOperatorIndex:1];
                [_numArr removeObjectAtIndex:1];
                [_numArr removeObjectAtIndex:1];
                [_operatorArr removeObjectAtIndex:1];//第二第三号位置数值出栈、第二个符号出栈。
                NSString *tempValue = [ NSString stringWithFormat:@"%f", self.num3];
                [_numArr insertObject:tempValue atIndex:1];//将计算结果插入 第二号位置中。
                NSLog(@"小于结果 = %f", self.num3);
                break;
            }
            case 1://第一个符号的优先级 大于  第二个符号的优先级
                [self dealSameCalculateWay];
                break;
            case 2://第一个符号的优先级  等于 第二个符号的优先级
                [self dealSameCalculateWay];
                break;
            case 3://最后一个运算
                //                _num1 = [_numArr[0] doubleValue];
                //                _num2 = [_numArr[1] doubleValue];
                //                _num3 = [self calculateWithNumber1:_num1 number2:_num2 atOperatorIndex:0];
                //                [_operatorArr removeObjectAtIndex:0];//删除最后一个符号
                [self dealSameCalculateWay];
                break;
            default:
                break;
        }
    }
    
    NSLog(@"num3: %f", _num3);
    
    [_valueString setString:[NSString stringWithFormat:@"%g", self.num3]];
    [_operatorArr removeObjectAtIndex:0];//计算完成后删除#
    //    [_contentString setString:[NSString stringWithFormat:@"%g", self.num3]];
    [_contentString setString:@""];
    _finishCalculation = YES;
    _num1 = 0;
    _num2 = 0;
    [self clearInputSource];
    [self inputString:_valueString close:NO];
    
}
#pragma mark -- private method
/**
 处理相同的结算方式
 */
- (void)dealSameCalculateWay {
    _num1 = [_numArr[0] doubleValue];
    _num2 = [_numArr[1] doubleValue];
    _num3 = [self calculateWithNumber1:_num1 number2:_num2 atOperatorIndex:0];
    [_numArr removeObjectAtIndex:0];
    [_numArr removeObjectAtIndex:0];
    [_operatorArr removeObjectAtIndex:0];//第一第二号位置数值出栈、第一个符号出栈。
    NSString *tempValue = [NSString stringWithFormat:@"%f", _num3];
    [_numArr insertObject:tempValue atIndex:0];//将计算结果插入第一号位置中
    NSLog(@"结果 = %f", _num3);
}

/**
 对比两个符号的优先级
 */
- (NSInteger)precede:(NSString *)operator1 operator2:(NSString *)operator2 {
    if (([operator1 isEqualToString:@"+"] || [operator1 isEqualToString:@"-"]) && ([operator2 isEqualToString:@"×"] || [operator2 isEqualToString:@"/"])) {
        return 0;//小于
    } else if (([operator1 isEqualToString:@"×"] || [operator1 isEqualToString:@"/"]) && ([operator2 isEqualToString:@"+"] || [operator2 isEqualToString:@"-"])) {
        return 1;//大于
    } else if (([operator1 isEqualToString:@"+"] || [operator1 isEqualToString:@"-"]) && ([operator2 isEqualToString:@"+"] || [operator2 isEqualToString:@"-"])) {
        return 2;//等于
    } else {//当只剩最后一个符号时
        return 3;
    }
}

/**
 计算
 */

- (double)calculateWithNumber1:(double)number1 number2:(double)number2 atOperatorIndex:(NSInteger)index {
    if ([_operatorArr[index] isEqualToString:@"+"]) {
        return number1 + number2;
    } else if ([_operatorArr[index] isEqualToString:@"-"]) {
        return number1 - number2;
    } else if ([_operatorArr[index] isEqualToString:@"×"]) {
        return number1 * number2;
    } else {
        return number1 / number2;
    }
}

/**
 删除字符操作
 */
- (void)deleteInputSource {
    if (self.deleteBlock) {
        self.deleteBlock();
    }
    if ([self.inputSource isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)self.inputSource;
        textField.text = textField.text.length ? [textField.text substringToIndex:textField.text.length - 1] : @"";
    } else if ([self.inputSource isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)self.inputSource;
        textView.text = textView.text.length ? [textView.text substringToIndex:textView.text.length - 1] : @"";
    }
//    else if ([self.inputSource isKindOfClass:[UISearchBar class]]) {
//        UISearchBar *searchBar = (UISearchBar *)self.inputSource;
//        NSMutableString *seartText = [NSMutableString stringWithString:searchBar.text];
//        if (seartText.length > 0) {
//            NSString *tempStr = [seartText substringToIndex:seartText.length - 1];
//            [searchBar setText:tempStr];
//        }
//    }
    [self inputString:@"" close:NO];
}

/**
 清空当前输入框内容
 */
- (void)clearInputSource {
    if (self.clearBlock) {
        self.clearBlock();
    }
    if ([self.inputSource isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)self.inputSource;
        textField.text =@"";
    } else if ([self.inputSource isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)self.inputSource;
        textView.text = @"";
    }
//    else if ([self.inputSource isKindOfClass:[UISearchBar class]]) {
//        UISearchBar *searchBar = (UISearchBar *)self.inputSource;
//        searchBar.text = @"";
//    }
    [self inputString:nil close:NO];
}

#pragma mark -- 输入文字
/*
 触发 textField:shouldChangeCharactersInRange:replacementString: 代理方法
 触发 textView:shouldChangeTextInRange:replacementText: 代理方法
 触发 searchBar:shouldChangeTextInRange:replacementText: 代理方法
 */
- (void)inputString:(NSString *)string close:(BOOL)close {
    if (!string.length) {
        return;
    }
    if ([_inputSource isKindOfClass:[UITextField class]]) {//UITextField 类型
        UITextField *textField = (UITextField *)self.inputSource;
        if (textField.delegate && [textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            NSRange range = NSMakeRange(textField.text.length, 1);
            BOOL ret = [textField.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
            if (ret) {
                [textField insertText:string];
            }
        } else {
            [textField insertText:string];
        }
    } else if ([self.inputSource isKindOfClass:[UITextView class]]) {//UITextView 类型
        UITextView *textView = (UITextView *)self.inputSource;
        if (textView.delegate && [textView.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
            NSRange range = NSMakeRange(textView.text.length, 1);
            BOOL ret = [textView.delegate textView:textView shouldChangeTextInRange:range replacementText:string];
            if (ret) {
                [textView insertText:string];
            }
        } else {
            [textView insertText:string];
        }
    }
//    else if ([self.inputSource isKindOfClass:[UISearchBar class]]) {//UISearchBar 类型
//        UISearchBar *searchBar = (UISearchBar *)self.inputSource;
//        NSMutableString *searchText = [NSMutableString stringWithString:searchBar.text];
//        [searchText appendString:string];
//        if (searchBar.delegate && [searchBar.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
//            NSRange range = NSMakeRange(searchBar.text.length, 1);
//            BOOL ret = [searchBar.delegate searchBar:searchBar shouldChangeTextInRange:range replacementText:string];
//            if (ret) {
//                [searchBar setText:[searchText copy]];
//            }
//        } else {
//            [searchBar setText:[searchText copy]];
//        }
//    }
    
}

#pragma mark -- lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        //        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        //创建布局
        WaterFallLayout *flowLayout = [[WaterFallLayout alloc] init];
        flowLayout.delegate = self;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, WindowWidth, symbolHeight * 4 + 0.5 * 3) collectionViewLayout:flowLayout];
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        _collectionView.backgroundColor = [UIColor colorWithRed:182 / 255.0 green:188 / 255.0 blue:196 / 255.0 alpha:1.0];
        [_collectionView registerClass:[KeyBoardCell class] forCellWithReuseIdentifier:@"KeyBoardCell"];
    }
    return _collectionView;
}

- (NSMutableString *)valueString {
    if (!_valueString) {
        _valueString = [NSMutableString string];
    }
    return _valueString;
}
- (NSMutableString *)contentString {
    if (!_contentString) {
        _contentString = [NSMutableString string];
    }
    return _contentString;
}
- (NSMutableArray *)numArr {
    if (!_numArr) {
        _numArr = [NSMutableArray array];
    }
    return _numArr;
}
- (NSMutableArray *)operatorArr {
    if (!_operatorArr) {
        _operatorArr = [NSMutableArray array];
    }
    return _operatorArr;
}
@end
