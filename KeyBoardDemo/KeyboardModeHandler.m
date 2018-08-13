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
            tempArr = @[dataArr[0], dataArr[1],dataArr[2],dataArr[13],dataArr[3],dataArr[4],dataArr[5],dataArr[14],dataArr[6],dataArr[7],dataArr[8],dataArr[15],dataArr[9],dataArr[11]];
            break;
        case 1://带小数
            tempArr = @[dataArr[0], dataArr[1],dataArr[2],dataArr[13],dataArr[3],dataArr[4],dataArr[5],dataArr[14],dataArr[6],dataArr[7],dataArr[8],dataArr[15],dataArr[10],dataArr[9],dataArr[11]];
            break;
        case 2://带正负
            tempArr = @[dataArr[0], dataArr[1],dataArr[2],dataArr[13],dataArr[3],dataArr[4],dataArr[5],dataArr[14],dataArr[6],dataArr[7],dataArr[8],dataArr[15],dataArr[12],dataArr[9],dataArr[11]];
            break;
        case 3://普通计算
            tempArr = @[dataArr[16],dataArr[0], dataArr[1],dataArr[2],dataArr[13],dataArr[17],dataArr[3],dataArr[4],dataArr[5],dataArr[14],dataArr[18],dataArr[6],dataArr[7],dataArr[8],dataArr[15],dataArr[19],dataArr[9],dataArr[11]];
            break;
        case 4://计算带小数
            tempArr = @[dataArr[16],dataArr[0], dataArr[1],dataArr[2],dataArr[13],dataArr[17],dataArr[3],dataArr[4],dataArr[5],dataArr[14],dataArr[18],dataArr[6],dataArr[7],dataArr[8],dataArr[15],dataArr[19],dataArr[10],dataArr[9],dataArr[11]];
            break;
        case 5://计算带正负
            tempArr = @[dataArr[16],dataArr[0], dataArr[1],dataArr[2],dataArr[13],dataArr[17],dataArr[3],dataArr[4],dataArr[5],dataArr[14],dataArr[18],dataArr[6],dataArr[7],dataArr[8],dataArr[15],dataArr[19],dataArr[12],dataArr[9],dataArr[11]];
            break;
        default:
            break;
    }
    
    return tempArr;
}
@end
