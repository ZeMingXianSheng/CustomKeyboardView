//
//  KeyboardModeHandler.m
//  KeyBoardDemo
//
//  Created by Rain on 2018/8/13.
//  Copyright © 2018年 Rain. All rights reserved.
//

#import "KeyboardModeHandler.h"
#import "KeyModel.h"

static KeyboardModeHandler *keyBoardModelHandler = nil;
@implementation KeyboardModeHandler

+ (instancetype)shareKeyboardInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyBoardModelHandler = [[KeyboardModeHandler alloc] init];
    });
    return keyBoardModelHandler;
}

- (NSArray *)getKeyboardDataWithKeyboardType:(KeyBoardType)keyboradType {
    NSMutableArray *dataArr = @[].mutableCopy;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"keyboard" ofType:@"json"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingAllowFragments error:nil];
    
    for (NSDictionary *dic in dataDic[@"data"]) {
        KeyModel *model = [[KeyModel alloc] init];
        model.keyId = [dic[@"keyId"] integerValue];
        model.keyName = dic[@"keyName"];
        model.keyNumberType = [dic[@"type"] integerValue];
        model.keyImage = dic[@"keyImage"];
        model.status = [dic[@"status"] boolValue];
        [dataArr addObject:model];
    }
    NSArray *tempArr = [[NSArray alloc] init];
    switch (keyboradType) {
        case 0://普通不计算
            tempArr = @[dataArr[KeyNumberTypeOne],
                        dataArr[KeyNumberTypeTwo],
                        dataArr[KeyNumberTypeThree],
                        dataArr[KeyNumberTypeDelete],
                        dataArr[KeyNumberTypeFour],
                        dataArr[KeyNumberTypeFive],
                        dataArr[KeyNumberTypeSix],
                        dataArr[KeyNumberTypeClear],
                        dataArr[KeyNumberTypeSeven],
                        dataArr[KeyNumberTypeEight],
                        dataArr[KeyNumberTypeNine],
                        dataArr[KeyNumberTypeSure],
                        dataArr[KeyNumberTypeZero],
                        dataArr[KeyNumberTypeClose]];
            break;
        case 1://带小数
            tempArr = @[dataArr[KeyNumberTypeOne],
                        dataArr[KeyNumberTypeTwo],
                        dataArr[KeyNumberTypeThree],
                        dataArr[KeyNumberTypeDelete],
                        dataArr[KeyNumberTypeFour],
                        dataArr[KeyNumberTypeFive],
                        dataArr[KeyNumberTypeSix],
                        dataArr[KeyNumberTypeClear],
                        dataArr[KeyNumberTypeSeven],
                        dataArr[KeyNumberTypeEight],
                        dataArr[KeyNumberTypeNine],
                        dataArr[KeyNumberTypeSure],
                        dataArr[KeyNumberTypePoint],
                        dataArr[KeyNumberTypeZero],
                        dataArr[KeyNumberTypeClose]];
            break;
        case 2://带正负
            tempArr = @[dataArr[KeyNumberTypeOne],
                        dataArr[KeyNumberTypeTwo],
                        dataArr[KeyNumberTypeThree],
                        dataArr[KeyNumberTypeDelete],
                        dataArr[KeyNumberTypeFour],
                        dataArr[KeyNumberTypeFive],
                        dataArr[KeyNumberTypeSix],
                        dataArr[KeyNumberTypeClear],
                        dataArr[KeyNumberTypeSeven],
                        dataArr[KeyNumberTypeEight],
                        dataArr[KeyNumberTypeNine],
                        dataArr[KeyNumberTypeSure],
                        dataArr[KeyNumberTypePositiveNegative],
                        dataArr[KeyNumberTypeNine],
                        dataArr[KeyNumberTypeClose]];
            break;
        case 3://普通计算
            tempArr = @[dataArr[KeyNumberTypePlus],
                        dataArr[KeyNumberTypeOne],
                        dataArr[KeyNumberTypeTwo],
                        dataArr[KeyNumberTypeThree],
                        dataArr[KeyNumberTypeDelete],
                        dataArr[KeyNumberTypeMinus],
                        dataArr[KeyNumberTypeFour],
                        dataArr[KeyNumberTypeFive],
                        dataArr[KeyNumberTypeSix],
                        dataArr[KeyNumberTypeClear],
                        dataArr[KeyNumberTypeMultiply],
                        dataArr[KeyNumberTypeSeven],
                        dataArr[KeyNumberTypeEight],
                        dataArr[KeyNumberTypeNine],
                        dataArr[KeyNumberTypeSure],
                        dataArr[KeyNumberTypeEqual],
                        dataArr[KeyNumberTypeZero],
                        dataArr[KeyNumberTypeClose]];
            break;
        case 4://计算带小数
            tempArr = @[dataArr[KeyNumberTypePlus],
                        dataArr[KeyNumberTypeOne],
                        dataArr[KeyNumberTypeTwo],
                        dataArr[KeyNumberTypeThree],
                        dataArr[KeyNumberTypeDelete],
                        dataArr[KeyNumberTypeMinus],
                        dataArr[KeyNumberTypeFour],
                        dataArr[KeyNumberTypeFive],
                        dataArr[KeyNumberTypeSix],
                        dataArr[KeyNumberTypeClear],
                        dataArr[KeyNumberTypeMultiply],
                        dataArr[KeyNumberTypeSeven],
                        dataArr[KeyNumberTypeEight],
                        dataArr[KeyNumberTypeNine],
                        dataArr[KeyNumberTypeSure],
                        dataArr[KeyNumberTypeEqual],
                        dataArr[KeyNumberTypePoint],
                        dataArr[KeyNumberTypeZero],
                        dataArr[KeyNumberTypeClose]];
            break;
        case 5://计算带正负
            tempArr = @[dataArr[KeyNumberTypePlus],
                        dataArr[KeyNumberTypeOne],
                        dataArr[KeyNumberTypeTwo],
                        dataArr[KeyNumberTypeThree],
                        dataArr[KeyNumberTypeDelete],
                        dataArr[KeyNumberTypeMinus],
                        dataArr[KeyNumberTypeFour],
                        dataArr[KeyNumberTypeFive],
                        dataArr[KeyNumberTypeSix],
                        dataArr[KeyNumberTypeClear],
                        dataArr[KeyNumberTypeMultiply],
                        dataArr[KeyNumberTypeSeven],
                        dataArr[KeyNumberTypeEight],
                        dataArr[KeyNumberTypeNine],
                        dataArr[KeyNumberTypeSure],
                        dataArr[KeyNumberTypeEqual],
                        dataArr[KeyNumberTypePositiveNegative],
                        dataArr[KeyNumberTypeZero],
                        dataArr[KeyNumberTypeClose]];
            break;
        default:
            break;
    }
    
    return tempArr;
}
@end
