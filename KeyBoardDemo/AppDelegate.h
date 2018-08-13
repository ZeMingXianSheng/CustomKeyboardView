//
//  AppDelegate.h
//  KeyBoardDemo
//
//  Created by Rain on 2018/7/31.
//  Copyright © 2018年 Rain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

/*
 一、显示不全的问题，提醒自己用小屏开发。
 三、原来存储数据库是一条一条存储，现在改为遍历完数据后提交一个事务更新所有需要存储的数据。
 四、布料挂单
 销售单
 1.开单列表:
    当前简易购物车: - (SaleShoppingCartBriefState *)currentFabricShoppingCartBriefState {} （SaleShoppingCartStateStore类中）
        获取当前数据库有数据真正的购物车数据cart: - (NSDictionary *)currentSaleOrderShoppingCart {}    (SaleShoppingCartState类中)
        没有调用- (SalesorderShoppingCart *)getSaleShoppingCart的原因，他在数据库没有购物车shoppingCart时，自动创建一个。
        没有购车数据时按照以前模式，创建一个没有购物车数据的SaleShoppingCartBriefState。
    获取所有挂单列表的时间：- (NSArray *)allFabricSalePendingOrderState  返回的是cart.updatedAt数组。 为了显示在开单列表的挂单日期。
 
 2.挂单列表
    获取所有已挂单列表数据：docType = 2，按ctime降序排列
        - (NSArray <SaleShoppingCartBriefState *> *)allFabricSalePendingOrderBriefState  （SaleShoppingCartStateStore类中）
        注意：在构建SaleShoppingCartBriefState数据时返回的citme为cart.updateAt时间，即挂单时间，非创建购物车时间。
 
 3.添加挂单
    更新数据库购物车docType = 2  （该方法用户选择挂单为购物车时也会调用）
    - (void)updateSalesorderShoppingCartDocType:(NSDictionary *)dic （SaleShoppingCartService类中）

 4.删除挂单
    删除数据库中docType = 2且 cart.Id = 当前选中挂单cart的Id
    - (void)deletePendOrderDataByShoppingCartId:(NSString *)Id  （SaleShoppingCartService类中）
 5.选择一个挂单为购物车
    先清空现有购物车：购物车存在 且 点击的cart.Id != 当前购物车cart.Id 时
    - (void)clearShoppingCart  （SaleShoppingCartState）
    注意点：清空时，必须把docType = 1全部删除掉。因为有临时购物车的存在。
    更新数据库购物车docType = 1
    - (void)updateSalesorderShoppingCartDocType:(NSDictionary *)dic （SaleShoppingCartService类中）
 */

