//
//  SHLabelPageView.m
//  SHLabelPageView
//
//  Created by CSH on 2018/7/10.
//  Copyright © 2018年 CSH. All rights reserved.
//

#import "SHLabelPageView.h"

@interface SHLabelPageView ()

//标签滚动视图
@property (nonatomic, strong) UIScrollView *pageScroll;
//选中线
@property (nonatomic, strong) UIImageView *currentLine;

@end

@implementation SHLabelPageView

//标签tag
static NSInteger labTag = 1000000;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tagColor = nil;
        self.fontSize = nil;
        self.unFontSize = nil;
        self.checkColor = nil;
        self.uncheckColor = nil;
        self.currentLineColor = nil;
        self.labelH = 40;
    }
    return self;
}

#pragma mark - 私有方法
#pragma mark SET
- (void)setIndex:(NSInteger)index {
    if (_index == index) {
        return;
    }

    _index = index;
    //刷新界面
    [self reloadPage];
    //回调
    if (self.pageViewBlock) {
        self.pageViewBlock(self);
    }
}

- (void)setContentOffsetX:(CGFloat)contentOffsetX {
    _contentOffsetX = contentOffsetX;

    //竖直布局不生效
    if (self.directione == SHLabelPageDirectione_hor) {
        return;
    }
    
    if (contentOffsetX == self.index) { //已经设置完毕 -> 界面滚动 -> 触发本方法
        return;
    }

    if (contentOffsetX < 0) { //最左边
        return;
    }

    if (contentOffsetX > self.pageList.count - 1) { //最右边
        return;
    }

    //左右位置
    NSInteger leftIndex = (NSInteger)contentOffsetX;
    NSInteger rightIndex = leftIndex + 1;

    //取出左右的视图
    UIButton *leftBtn = [self.pageScroll viewWithTag:(leftIndex + labTag)];
    UIButton *rightBtn = [self.pageScroll viewWithTag:(rightIndex + labTag)];
    UIButton *currentBtn;
    //增加下划线动画
    CGFloat scale = 0;

    //当前 X
    CGFloat currentX;
    //目标 X
    CGFloat targetX = 0.0;
    //当前 W
    CGFloat currentW;
    //目标 W
    CGFloat targetW = 0.0;
    //最大 W
    CGFloat maxW;

    //设置 X 变化
    if (self.index > leftIndex) { //往右滑
        currentBtn = rightBtn;
        currentW = rightBtn.width + self.currentLineMargin;
        targetW = leftBtn.width + self.currentLineMargin;
        currentX = rightBtn.centerX - (currentW / 2);
        targetX = leftBtn.centerX - (targetW / 2);

        //设置了Size 则不进行标签适配
        if (self.currentLineSize.width) {
            CGFloat lineW = self.currentLineSize.width;
            currentX = rightBtn.centerX - (lineW / 2);
            targetX = leftBtn.centerX - (lineW / 2);
            currentW = targetW = lineW;
        }

        maxW = currentX - targetX + currentW;

        if (contentOffsetX - leftIndex > 0.5) { //首先
            //0 ~ 1
            scale = (1 - (contentOffsetX - leftIndex)) * 2;
            //X 减小
            self.currentLine.x = currentX - scale * (currentX - targetX);
            //W 变大
            self.currentLine.width = currentW + (currentX - self.currentLine.x);
        } else { //然后

            //1 ~ 0
            scale = ((contentOffsetX - leftIndex)) * 2;
            //X 不变
            self.currentLine.x = targetX;
            //W 减小
            self.currentLine.width = maxW - (1 - scale) * (maxW - targetW);
        }
    }

    if (self.index < rightIndex) { //往左滑
        currentBtn = leftBtn;
        currentW = leftBtn.width + self.currentLineMargin;
        targetW = rightBtn.width + self.currentLineMargin;
        currentX = leftBtn.centerX - (currentW / 2);
        targetX = rightBtn.centerX - (targetW / 2);

        //设置了Size 则不进行标签适配
        if (self.currentLineSize.width) {
            CGFloat lineW = self.currentLineSize.width;
            currentX = leftBtn.centerX - (lineW / 2);
            targetX = rightBtn.centerX - (lineW / 2);
            currentW = targetW = lineW;
        }

        maxW = targetX - currentX + targetW;

        if (rightIndex - contentOffsetX > 0.5) { //首先

            //0 ~ 1
            scale = (1 - (rightIndex - contentOffsetX)) * 2;
            //X 不变
            self.currentLine.x = currentX;
            //W 变大
            self.currentLine.width = currentW + scale * (maxW - currentW);
        } else { //然后

            //1 ~ 0
            scale = (rightIndex - contentOffsetX) * 2;
            //X 变大
            self.currentLine.x = currentX + (1 - scale) * (targetX - currentX);
            //W 减小
            self.currentLine.width = maxW - (self.currentLine.x - currentX);
        }
    }

    //文字颜色
    CGFloat scaleLeft = (rightIndex - contentOffsetX);

    //设置左右视图颜色变化
    [leftBtn setTitleColor:[self getColorWithScale:scaleLeft] forState:0];
    [rightBtn setTitleColor:[self getColorWithScale:1 - scaleLeft] forState:0];

    if (leftIndex == contentOffsetX) {
        self.index = leftIndex;
    }
}

- (void)setCurrentLineY:(CGFloat)currentLineY {
    _currentLineY = currentLineY;
    //竖直布局不生效
    if (self.directione == SHLabelPageDirectione_hor)
    {
        return;
    }
    self.currentLine.y = currentLineY;
}

- (void)setCurrentImg:(UIImage *)currentImg{
    _currentImg = currentImg;
    self.currentLine.image = currentImg;
}

- (void)setCurrentLineSize:(CGSize)currentLineSize {
    _currentLineSize = currentLineSize;
    self.currentLine.size = currentLineSize;
}

- (void)setCurrentLineColor:(UIColor *)currentLineColor {
    if (!currentLineColor) {
        currentLineColor = [UIColor redColor];
    }
    _currentLineColor = currentLineColor;
    self.currentLine.backgroundColor = currentLineColor;
}

- (void)setCurrentLineRadius:(CGFloat)currentLineRadius {
    _currentLineRadius = currentLineRadius;
    self.currentLine.layer.cornerRadius = currentLineRadius;
}

- (void)setTagColor:(UIColor *)tagColor {
    if (!tagColor) {
        tagColor = [UIColor redColor];
    }
    _tagColor = tagColor;
}

- (void)setFontSize:(UIFont *)fontSize {
    if (!fontSize) {
        fontSize = [UIFont boldSystemFontOfSize:16];
    }
    _fontSize = fontSize;
}

- (void)setUnFontSize:(UIFont *)unFontSize {
    if (!unFontSize) {
        unFontSize = [UIFont systemFontOfSize:16];
    }
    _unFontSize = unFontSize;
}

- (void)setCheckColor:(UIColor *)checkColor {
    if (!checkColor) {
        checkColor = [UIColor blackColor];
    }
    _checkColor = checkColor;
}

- (void)setUncheckColor:(UIColor *)uncheckColor {
    if (!uncheckColor) {
        uncheckColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }
    _uncheckColor = uncheckColor;
}

#pragma mark 配置UI
- (void)configUI {
    
    //设置滚动大小
    self.pageScroll.size = self.size;
    
    
    [self.currentLine removeFromSuperview];
    [self.pageScroll addSubview:self.currentLine];

    //设置内容
    switch (self.directione)
    {
        case SHLabelPageDirectione_hor: //竖直布局
        {
            [self configUIhor];
        }
            break;
        default:
        {
            //默认水平布局
            [self configUIver];
        }
            break;
    }


    //刷新界面
    [self reloadPage];
}

#pragma mark 水平布局
- (void)configUIver{
    //设置标签
       CGFloat view_h = self.pageScroll.height;

       //间隔
       __block CGFloat view_x = self.startX;
       __block CGFloat view_start = 0;
       __block CGFloat contentSetX = 0;

       if (self.type == SHLabelPageType_one) {
           view_start = (self.width - 2 * self.startX) / (self.pageList.count + 1);
       }

       //设置内容
       [self.pageList enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *_Nonnull stop) {

           //设置标签
           UIButton *btn = [self getChannelLab];
           [btn setTitle:obj forState:0];
           btn.tag = labTag + idx;

           //设置了宽度就用、没设置用自适应
           if (self.labelW) {
               btn.frame = CGRectMake(view_x, 0, self.labelW, view_h);
           } else {
               btn.frame = CGRectMake(view_x, 0, [self getChannelWithText:obj], view_h);
           }

           //设置frame
           switch (self.type) {
               case SHLabelPageType_one: //一页
               {
                   //设置了间距
                   if (self.spaceW) {
                       if (idx == 0) { //第一个
                           btn.x = 0;
                       }
                       if (idx == self.pageList.count - 1) { //最后一个
                           //计算位置
                           contentSetX = (self.width - btn.maxX) / 2;
                       }
                   } else { //没有设置间距

                       btn.centerX = self.startX + ((idx + 1) * view_start);
                   }
               } break;
               default:
                   break;
           }

           view_x += btn.width + self.spaceW;

           [self.pageScroll addSubview:btn];

           NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)idx];
           CGRect frame = [self.labelTag[key] CGRectValue];
           //是否存在标记
           if (frame.size.height) {
               //添加标记
               CALayer *layer = [CALayer layer];
               layer.frame = frame;
               layer.cornerRadius = frame.size.height / 2;
               layer.backgroundColor = self.tagColor.CGColor;
               [btn.layer addSublayer:layer];
           }
       }];

       if (contentSetX) {
           self.pageScroll.contentSize = CGSizeMake(view_x - self.spaceW, 0);
           self.pageScroll.x = contentSetX;
       } else {
           self.pageScroll.contentSize = CGSizeMake(view_x, 0);
       }
}

#pragma mark 竖直布局
- (void)configUIhor{
    
    self.currentLine.origin = CGPointZero;
    __block CGFloat view_y = 0;
    //设置内容
    [self.pageList enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *_Nonnull stop) {

        //设置标签
        UIButton *btn = [self getChannelLab];
        [btn setTitle:obj forState:0];
        btn.tag = labTag + idx;
        btn.origin = CGPointMake(0, view_y);
        btn.size = CGSizeMake(self.pageScroll.width, self.labelH);
        view_y = btn.maxY;

        [self.pageScroll addSubview:btn];
    }];
    
    self.pageScroll.contentSize = CGSizeMake(0, view_y);
    self.pageScroll.clipsToBounds = YES;

}
    

#pragma mark 获取标签
- (UIButton *)getChannelLab {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = self.fontSize;
    btn.backgroundColor = [UIColor clearColor];

    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];

    return btn;
}

#pragma mark 获取宽度
- (CGFloat)getChannelWithText:(NSString *)text {
    CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.pageScroll.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName : self.fontSize } context:nil].size;

    return ceil(size.width);
}

#pragma mark 标签点击
- (void)btnAction:(UIButton *)btn {
    self.index = btn.tag - labTag;
}

#pragma mark 刷新视图
- (void)reloadPage {
    if (self.index >= self.pageList.count) {
        return;
    }

    //改变颜色
    for (UIButton *btn in self.pageScroll.subviews) {
        //找到标签
        if (btn.tag >= labTag && btn.tag < (self.pageList.count + labTag)) {
            //未选中颜色
            [btn setTitleColor:[self getColorWithScale:0] forState:0];
            btn.titleLabel.font = self.unFontSize;
        }
    }
    
    //处理布局
    switch (self.directione) {
        case SHLabelPageDirectione_hor://垂直
            [self handlePagehor];
            break;
        default:
            [self handlePagever];
            break;
    }
    
}

#pragma mark 处理水平
- (void)handlePagever{
    //取出当前的标签
    UIButton *currentBtn = [self.pageScroll viewWithTag:self.index + labTag];
    CGFloat lineW = self.currentLineSize.width ?: (currentBtn.width + self.currentLineMargin);

    if (self.type == SHLabelPageType_more) { //多个标签情况
        //设置scroll居中
        CGFloat offsetX = currentBtn.centerX - self.pageScroll.width * 0.5;
        CGFloat offsetMaxX = self.pageScroll.contentSize.width - self.pageScroll.width;

        if (offsetMaxX < 0) { //不足一屏幕则不进行处理
            return;
        }
        
        offsetX= MAX(0, MIN(offsetX, offsetMaxX));

        //滚动
        [self.pageScroll setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }

    //设置选中下划线
    [UIView animateWithDuration:0.25
                     animations:^{

                         self.currentLine.width = lineW;
                         self.currentLine.centerX = currentBtn.centerX;

                         //选中颜色
                         [currentBtn setTitleColor:[self getColorWithScale:1] forState:0];
                         //选中字体
                         currentBtn.titleLabel.font = self.fontSize;

                     }];
}

#pragma mark 处理竖直
- (void)handlePagehor{
    //取出当前的标签
    UIButton *currentBtn = [self.pageScroll viewWithTag:self.index + labTag];
    //选中颜色
    [currentBtn setTitleColor:[self getColorWithScale:1] forState:0];
    //选中字体
    currentBtn.titleLabel.font = self.fontSize;
    
    self.currentLine.centerY = currentBtn.centerY;

    //设置scroll居中
    CGFloat offsetY = currentBtn.centerY - self.pageScroll.height * 0.5;
    CGFloat offsetMaxY = self.pageScroll.contentSize.height - self.pageScroll.height;
    
    if (offsetMaxY < 0)
    {
        return;
    }
    
    offsetY = MAX(0, MIN(offsetY, offsetMaxY));

    //滚动
    [self.pageScroll setContentOffset:CGPointMake(0, offsetY) animated:YES];
}

#pragma mark 获取颜色RGB
- (UIColor *)getColorWithScale:(CGFloat)scale {
    //0 ~ 1
    NSArray *uncheckColorArr = [self getRGBWithColor:self.uncheckColor];

    NSArray *checkColorArr = [self getRGBWithColor:self.checkColor];
    //(x + (y-x)*k)
    CGFloat red = [uncheckColorArr[0] floatValue] + ([checkColorArr[0] floatValue] - [uncheckColorArr[0] floatValue]) * scale;
    CGFloat green = [uncheckColorArr[1] floatValue] + ([checkColorArr[1] floatValue] - [uncheckColorArr[1] floatValue]) * scale;
    CGFloat blue = [uncheckColorArr[2] floatValue] + ([checkColorArr[2] floatValue] - [uncheckColorArr[2] floatValue]) * scale;
    CGFloat alpha = [uncheckColorArr[3] floatValue] + ([checkColorArr[3] floatValue] - [uncheckColorArr[3] floatValue]) * scale;

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark 获取颜色RGB集合
- (NSArray *)getRGBWithColor:(UIColor *)color {
    //获得RGB值描述
    NSString *RGBValue = [NSString stringWithFormat:@"%@", color];
    //将RGB值描述分隔成字符串
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];

    if (RGBArr.count == 3) {
        RGBArr = @[ RGBArr[1], RGBArr[1], RGBArr[1], RGBArr[2] ];
    } else {
        RGBArr = @[ RGBArr[1], RGBArr[2], RGBArr[3], RGBArr[4] ];
    }

    NSString *RGBStr;
    //获取 R
    float red = [RGBArr[0] floatValue];
    RGBStr = [NSString stringWithFormat:@"%f", red];
    //获取 G
    float green = [RGBArr[1] floatValue];
    RGBStr = [NSString stringWithFormat:@"%f", green];
    //获取 B
    float blue = [RGBArr[2] floatValue];
    RGBStr = [NSString stringWithFormat:@"%f", blue];
    //获取 alpha
    CGFloat alpha = [RGBArr[3] floatValue];

    //返回保存RGB值的数组
    return @[ [NSString stringWithFormat:@"%f", red], [NSString stringWithFormat:@"%f", green], [NSString stringWithFormat:@"%f", blue], [NSString stringWithFormat:@"%f", alpha] ];
}

#pragma mark - 懒加载
//滚动视图
- (UIScrollView *)pageScroll {
    if (!_pageScroll) {
        _pageScroll = [[UIScrollView alloc] init];
        _pageScroll.origin = CGPointMake(0, 0);
        _pageScroll.backgroundColor = [UIColor clearColor];
        _pageScroll.showsHorizontalScrollIndicator = NO;
        _pageScroll.opaque = NO;
        _pageScroll.clipsToBounds = NO;
        // 设置下划线
        [self addSubview:_pageScroll];
    }
    return _pageScroll;
}

//当前点击的线
- (UIImageView *)currentLine{
    if (!_currentLine) {
        _currentLine = [[UIImageView alloc]init];
        _currentLine.height = 4;
        _currentLine.layer.cornerRadius = _currentLine.height/2;
        _currentLine.layer.masksToBounds = YES;
        _currentLine.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _currentLine;
}

#pragma mark - 公共方法
#pragma mark - 刷新
- (void)reloadView{
    
    //移除以前的标签
    [self.pageScroll.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.pageScroll.x = 0;
    
    if (!self.pageList.count) {
        return;
    }
    
    //配置UI
    [self configUI];
    
}

@end
