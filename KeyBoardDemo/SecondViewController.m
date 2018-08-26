//
//  SecondViewController.m
//  KeyBoardDemo
//
//  Created by Rain on 2018/8/1.
//  Copyright © 2018年 Rain. All rights reserved.
//

#import "SecondViewController.h"
#import "KeyModel.h"
#import "CustomKeyBoardView.h"
#import "KeyboardModeHandler.h"
@interface SecondViewController () <UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) UITextField *tf;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
    self.title = @"自定义键盘";
    [self initUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
     [_tf resignFirstResponder];//关闭键盘
}
#pragma mark -- 初始化界面UI
- (void)initUI {
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
        [self.dataArr addObject:model];
    }
    NSArray *titleArr = @[@"普通不计算", @"带小数",@"带正负",@"普通计算",@"计算带小数",@"计算带正负"];
    
    for (int i = 0; i < 6; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, 84 + i * (51 + 10), 120, 41);
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor orangeColor];
        btn.tag = i;
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    self.tf = [[UITextField alloc] init];
    _tf.frame = CGRectMake(160, 100, 150, 41);
    _tf.delegate = self;
    _tf.backgroundColor = [UIColor orangeColor];
    _tf.placeholder = @"请输入";
    [self.view addSubview:_tf];
}


/**
 btn点击事件
 */
- (void)clickBtn:(UIButton *)sender {
    [_tf resignFirstResponder];
    
    CustomKeyBoardView *keyBoardView = [[CustomKeyBoardView alloc] initWithKeyboardType:sender.tag inputSource:_tf];
    keyBoardView.inputText = _tf.text;
    _tf.inputView = keyBoardView;
    keyBoardView.closeKeyboardBlock = ^{
        //TODO
        [_tf resignFirstResponder];
    };
    keyBoardView.confirmBlock = ^{
        //TODO
        [_tf resignFirstResponder];
    };
}

#pragma mark -- 回收键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_tf resignFirstResponder];
}

#pragma mark -- UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}


#pragma mark -- lazy
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
