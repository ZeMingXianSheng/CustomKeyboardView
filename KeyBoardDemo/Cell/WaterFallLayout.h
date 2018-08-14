//
//  WaterFallLayout.h
//  KeyBoardDemo
//
//  Created by Rain on 2018/8/2.
//  Copyright © 2018年 Rain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WaterFallLayout;

@protocol WaterFallLayoutDelegate <NSObject>

@required

/**
 每个item的宽高度
 */
- (CGSize)waterFallLayout:(WaterFallLayout *)waterFallLayout sizeForItemAtIndexPath:(NSUInteger)indexPath;

@optional

/**
 有多少列
 */
- (NSUInteger)columnCountInWaterFallLayout:(WaterFallLayout *)waterFallLayout;
/**
 每列之间的间距
 */
- (CGFloat)columnMarginInWaterFallLayout:(WaterFallLayout *)waterFallLayout;
/**
 每行之间的间距
 */
- (CGFloat)rowMarginInWaterFallLayout:(WaterFallLayout *)waterFallLayout;

/**
 每个item的内边距
 */
- (UIEdgeInsets)edgeInsetInWaterFalllayout:(WaterFallLayout *)waterFallLayout;
@end



@interface WaterFallLayout : UICollectionViewLayout

@property (nonatomic, weak) id<WaterFallLayoutDelegate> delegate;

@end
