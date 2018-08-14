//
//  CustomKeyBoardView.m
//  KeyBoardDemo
//
//  Created by Rain on 2018/8/1.
//  Copyright © 2018年 Rain. All rights reserved.
//

#define  symbolWidth     ((WindowWidth - 0.5 * 4) / (82 * 3 / 64 + 2))

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

@property (nonatomic, assign) BOOL finishCalculation;//完成计算

@end

@implementation CustomKeyBoardView

- (instancetype)initWithFrame:(CGRect)frame keyBoardType:(KeyBoardType)keyBoradType{
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
    self = [super initWithFrame:CGRectMake(0, WindowHeight - SafeAreaTopHeight - BottomHomeBarHeight - 51 * 4 - 0.6 * 3, WindowWidth, 51 * 4 + 0.6 * 3)];
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
- (void)setInputText:(NSString *)inputText {
    if (!inputText.length) {
        return;
    }
    self.valueString.string = inputText;
    if (![inputText containsString:@"+"]
        && ![inputText containsString:@"-"]
        && ![inputText containsString:@"×"]
        && ![inputText containsString:@"/"]) {
        self.contentString.string = inputText;
    } else {
        NSString *tempStr = nil;
        //倒序遍历字符串
        NSInteger i = inputText.length - 1;
        NSMutableString *mStr = [NSMutableString stringWithFormat:@"%@", inputText];
        while (i > 0) {
            tempStr = [mStr substringWithRange:NSMakeRange(i, 1)];
            if ([tempStr isEqualToString:@"+"]
                || [tempStr isEqualToString:@"-"]
                || [tempStr isEqualToString:@"×"]
                || [tempStr isEqualToString:@"/"]) {
                if (!self.numArr.count) {
                    if ([mStr substringWithRange:NSMakeRange(i + 1, mStr.length - i - 1)].length) {
                        [_numArr addObject:[mStr substringWithRange:NSMakeRange(i + 1, mStr.length - i - 1)]];
                    }
                } else {
                    [_numArr insertObject:[mStr substringWithRange:NSMakeRange(i + 1, mStr.length - i - 1)] atIndex:0];//插入计算数值
                }
                if (!self.operatorArr.count) {
                    [_operatorArr addObject:tempStr];
                } else {
                    [_operatorArr insertObject:tempStr atIndex:0];//插入运算符
                }
                [mStr deleteCharactersInRange:NSMakeRange(i, mStr.length - i)];//移除已经遍历过的字符串
            }
            i--;
        }
        if (mStr.length) {//插入第一个计算数值
            [_numArr insertObject:mStr atIndex:0];
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
                    self.valueString = [NSMutableString stringWithFormat:@"-%@", _valueString];
                }
                if ([self.delegate respondsToSelector:@selector(senderTextFieldContent:close:)]) {
                    [self.delegate senderTextFieldContent:_valueString close:NO];
                }
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
            case KeyboardInputTypeDelete:
                [self clickDelete];
                
                break;
            case KeyboardInputTypeClear://清空
                [self clickClear];
                break;
            case KeyboardInputTypeSure://点击确定
//                if ([self.delegate respondsToSelector:@selector(clickSureAction)]) {
//                    [self.delegate clickSureAction];
//                }
                //暂时关闭键盘, 可根据具体情况回调。
                if ([self.delegate respondsToSelector:@selector(senderTextFieldContent:close:)]) {
                    [self.delegate senderTextFieldContent:_valueString close:YES];
                }
                break;
            case KeyboardInputTypeClose:
                if ([self.delegate respondsToSelector:@selector(senderTextFieldContent:close:)]) {
                    [self.delegate senderTextFieldContent:_valueString close:YES];
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
                return CGSizeMake((WindowWidth - 0.5 * 3) / 4, 51 * 2 + 0.5);
            } else if (model.keyNumberType == KeyNumberTypeZero)  {//0 按钮
                return CGSizeMake((WindowWidth - 0.5 * 3) / 4 * 2 + 0.5, 51);
            }
            return CGSizeMake((WindowWidth - 0.5 * 3) / 4, 51);
            break;
        case KeyBoardTypePoint://有小数点
        case KeyBoardTypeNegavite://无小数点、有正负
            if (model.keyNumberType == KeyNumberTypeSure) {//确定按钮
                return CGSizeMake((WindowWidth - 0.5 * 3) / 4, 51 * 2 + 0.5);
            }
            return CGSizeMake((WindowWidth - 0.5 * 3) / 4, 51);
            break;
        case KeyBoardTypeCalcuateNormal: //计算 不带小数点、不带正负
            if (model.keyNumberType == KeyNumberTypePlus
                || model.keyNumberType == KeyNumberTypeMinus
                || model.keyNumberType == KeyNumberTypeMultiply
                || model.keyNumberType == KeyNumberTypeEqual
                || model.keyNumberType == KeyNumberTypeDelete
                || model.keyNumberType == KeyNumberTypeClear) {
                return CGSizeMake(symbolWidth, 51);
            } else if (model.keyNumberType == KeyNumberTypeSure) {//确定按钮
                return CGSizeMake(symbolWidth, 51 * 2 + 0.5);
            } else if (model.keyNumberType == KeyNumberTypeZero)  {//0 按钮
                return CGSizeMake((WindowWidth - 0.5 * 4 - symbolWidth * 2) / 3 * 2 + 0.5, 51);
            }
            return CGSizeMake((WindowWidth - 0.5 * 4 - symbolWidth * 2) / 3, 51);
            break;
        case KeyBoardTypeCalcuatePoint: //计算 带小数点
        case KeyBoardTypeCalcuateNegavite: //计算 带正负
            if (model.keyNumberType == KeyNumberTypePlus
                || model.keyNumberType == KeyNumberTypeMinus
                || model.keyNumberType == KeyNumberTypeMultiply
                || model.keyNumberType == KeyNumberTypeEqual
                || model.keyNumberType == KeyNumberTypeDelete
                || model.keyNumberType == KeyNumberTypeClear) {
                return CGSizeMake(symbolWidth, 51);
            } else if (model.keyNumberType == KeyNumberTypeSure) {//确定按钮
                return CGSizeMake(symbolWidth, 51 * 2 + 0.5);
            }
            return CGSizeMake((WindowWidth - 0.5 * 4 - symbolWidth * 2) / 3, 51);
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

#pragma mark -- private method
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
    if ([self.delegate respondsToSelector:@selector(senderTextFieldContent:close:)]) {
        [self.delegate senderTextFieldContent:_valueString close:NO];
    }
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
                _num3 = [lastStr doubleValue];
            }
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
    
    if ([self.delegate respondsToSelector:@selector(senderTextFieldContent:close:)]) {
        [self.delegate senderTextFieldContent:_valueString close:NO];
    }
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
    if ([self.delegate respondsToSelector:@selector(senderTextFieldContent:close:)]) {
        [self.delegate senderTextFieldContent:_valueString close:NO];
    }
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
    
    if ([self.delegate respondsToSelector:@selector(senderTextFieldContent:close:)]) {
        [self.delegate senderTextFieldContent:_valueString close:NO];
    }
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
    
    self.num3 = 0;
    NSString *tempString = [NSString stringWithString:self.contentString];
    [self.numArr addObject:tempString];
    NSLog(@"numArr1: %@", _numArr);
    [_valueString appendString:value];
    [self.operatorArr addObject:value];//保存操作符
    [self.contentString setString:@""];//清空内容string
    if ([self.delegate respondsToSelector:@selector(senderTextFieldContent:close:)]) {
        [self.delegate senderTextFieldContent:_valueString close:NO];
    }
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
    if ([self.delegate respondsToSelector:@selector(senderTextFieldContent:close:)]) {
        [self.delegate senderTextFieldContent:_valueString close:NO];
    }
}

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

#pragma mark -- lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        //创建布局
        WaterFallLayout *flowLayout = [[WaterFallLayout alloc] init];
        flowLayout.delegate = self;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, WindowWidth, self.frame.size.height) collectionViewLayout:flowLayout];
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
