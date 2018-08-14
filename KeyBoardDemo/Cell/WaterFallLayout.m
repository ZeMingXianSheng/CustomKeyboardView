//
//  WaterFallLayout.m
//  KeyBoardDemo
//
//  Created by Rain on 2018/8/2.
//  Copyright © 2018年 Rain. All rights reserved.
//

#import "WaterFallLayout.h"

//默认的列数
static const CGFloat DefaultColumnCount = 4;
//每一列之间的间距
static const CGFloat DefaultColumnMargin = 0.5;
//每一行的间距
static const CGFloat DefaultRowMaigin = 0.5;
//内边距
static const UIEdgeInsets DefaultEdgeInsets = {0, 0, 0, 0};


@interface WaterFallLayout ()
/**
 存放所有的布局属性
 */
@property (nonatomic, strong) NSMutableArray *attrArr;
/**
 存放所有列的当前高度
 */
@property (nonatomic, strong) NSMutableArray *columnHieghts;
/**
 内容的高度
 */
@property (nonatomic, assign) CGFloat contentHeight;

/**
 记录上一次maxX
 */
@property (nonatomic, assign) CGFloat lastMaxX;

/**
 列数
 */
- (NSUInteger)columnCount;
/**
 * 列间距
 */
- (CGFloat)columnMargin;
/**
 * 行间距
 */
- (CGFloat)rowMargin;
/**
 * item的内边距
 */
- (UIEdgeInsets)edgeInsets;
@end


@implementation WaterFallLayout

/**
 初始化
 */
- (void)prepareLayout {
    [super prepareLayout];
    
    self.contentHeight = 0;
    //清空之前计算的所有高度
    [self.columnHieghts removeAllObjects];
    
    //设置每一列默认高度
    for (int i = 0; i < self.columnCount; i++) {
        [self.columnHieghts addObject:@(DefaultEdgeInsets.top)];
    }
    
    //清空之前的所有布局
    [self.attrArr removeAllObjects];
    
    //开始创建每一个cell对应的布局属性
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < count; i++) {
        
        //创建位置
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        //获取indexPath位置上cell对应的布局属性
        UICollectionViewLayoutAttributes *atts = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attrArr addObject:atts];
        
    }
}


/**
 返回indexPath位置cell对应的布局属性
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    //创建布局属性
    UICollectionViewLayoutAttributes *atts = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    //设置布局属性的frame
    CGSize itemSize = [self.delegate waterFallLayout:self sizeForItemAtIndexPath:indexPath.item];
    
    //找出最短的那一列
    NSInteger destColumn = 0;
    CGFloat minColumnHieght = [self.columnHieghts[0] doubleValue];
    
    for (int i = 0; i < self.columnCount; i++) {
        //取得第i列的高度
        CGFloat columnHieght = [self.columnHieghts[i] doubleValue];
        if (minColumnHieght > columnHieght) {
            minColumnHieght = columnHieght;
            destColumn = i;
        }
    }
    CGFloat maxX = (self.lastMaxX + itemSize.width) > [UIScreen mainScreen].bounds.size.width  ? 0 : self.lastMaxX + (_lastMaxX > 0 ? self.columnMargin : 0);
    CGFloat cellX = self.edgeInsets.left + maxX;
    CGFloat cellY = minColumnHieght;
    if (cellY != self.edgeInsets.top) {
        cellY += self.rowMargin;
    }
    
    atts.frame = CGRectMake(cellX, cellY, itemSize.width, itemSize.height);
    NSLog(@"atts.frame: %@", NSStringFromCGRect(atts.frame));
    //更新最短那一列的高度
    self.columnHieghts[destColumn] = @(CGRectGetMaxY(atts.frame));
    
    //记录内容的高度 = 即最长那一列的高度
    CGFloat maxColumnHeight = [self.columnHieghts[destColumn] doubleValue];
    if (self.contentHeight < maxColumnHeight) {
        self.contentHeight = maxColumnHeight;
    }
    self.lastMaxX = CGRectGetMaxX(atts.frame);
    return atts;
}


/**
 决定cell的高度
 */
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrArr;
}


/**
 内容的高度
 */
- (CGSize)collectionViewContentSize {
    return CGSizeMake(0, self.contentHeight + self.edgeInsets.bottom);
}



#pragma mark -- 数据处理

- (NSUInteger)columnCount {
    if ([self.delegate respondsToSelector:@selector(columnCountInWaterFallLayout:)]) {
        return [self.delegate columnCountInWaterFallLayout:self];
    } else {
        return DefaultColumnCount;
    }
}

- (CGFloat)columnMargin {
    if ([self.delegate respondsToSelector:@selector(columnMarginInWaterFallLayout:)]) {
        return [self.delegate columnMarginInWaterFallLayout:self];
    } else {
        return DefaultColumnMargin;
    }
}

- (CGFloat)rowMargin {
    if ([self.delegate respondsToSelector:@selector(rowMarginInWaterFallLayout:)]) {
        return [self.delegate rowMarginInWaterFallLayout:self];
    } else {
        return DefaultRowMaigin;
    }
}

- (UIEdgeInsets)edgeInsets {
    if ([self.delegate respondsToSelector:@selector(edgeInsetInWaterFalllayout:)]) {
        return [self.delegate edgeInsetInWaterFalllayout:self];
    } else {
        return DefaultEdgeInsets;
    }
}




#pragma mark -- lazy
- (NSMutableArray *)attrArr {
    if (!_attrArr) {
        _attrArr = [NSMutableArray array];
    }
    return _attrArr;
}
- (NSMutableArray *)columnHieghts {
    if (!_columnHieghts) {
        _columnHieghts = [NSMutableArray array];
    }
    return _columnHieghts;
}
@end
