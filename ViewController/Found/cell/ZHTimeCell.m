//
//  ZHTimeCell.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/6/30.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHTimeCell.h"
#import "ZHImgCollectionCell.h"
 static NSString *imgCell = @"imgCell";
@implementation ZHTimeCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self customViews];
    }
    return self;
}
- (void)customViews{
    self.contentView.backgroundColor = BackGray_dan;
    whiteBg= [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 0)];
    whiteBg.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:whiteBg];
    [whiteBg addSubview:self.headImg];
    [whiteBg addSubview:self.nameLb];
    [whiteBg addSubview:self.contentLb];
    [whiteBg addSubview:self.imgCollection];
    [whiteBg addSubview:self.timeLb];
    [whiteBg addSubview:self.removeBtn];
    //分割线
    lineTop = [[UIView alloc] initWithFrame:CGRectMake(0, self.removeBtn.bottom+mygap*2, BOUNDS.size.width, 0.5)];
    lineTop.tag = 500;
    lineTop.backgroundColor = BackGray_dan;
    [whiteBg addSubview:lineTop];
    [whiteBg addSubview:self.visitCount];
    [whiteBg addSubview:self.commentBtn];
    [whiteBg addSubview:self.zanBtn];
    whiteBg.height = self.zanBtn.bottom;
    NSLog(@"%d",(int)(whiteBg.height));
}
- (void)reDrawViews{
    if (self.imgArray.count==0) {
        _imgCollection.frame = CGRectMake(_nameLb.left, _contentLb.bottom+mygap, 540*UISCREENWIDTH/750, 0);
    }
    else if (self.imgArray.count>0&&self.imgArray.count<4){
        _imgCollection.frame = CGRectMake(_nameLb.left, _contentLb.bottom+mygap, 540*UISCREENWIDTH/750, 370*UISCREENWIDTH/750/2.0);
    }
    else{
        _imgCollection.frame = CGRectMake(_nameLb.left, _contentLb.bottom+mygap, 540*UISCREENWIDTH/750, 370*UISCREENWIDTH/750);
    }
    _timeLb.frame = CGRectMake(_imgCollection.left, _imgCollection.bottom+mygap, 60, 20);
    [_removeBtn setFrame:CGRectMake(_timeLb.right+mygap, _timeLb.top, _timeLb.width, _timeLb.height)];
    lineTop.frame = CGRectMake(0, self.removeBtn.bottom+mygap*2, BOUNDS.size.width, 0.5);
    _visitCount.frame = CGRectMake(0,_removeBtn.bottom+mygap*2, BOUNDS.size.width/2.0, 45);
    [_commentBtn setFrame:CGRectMake(_visitCount.right, _visitCount.top, BOUNDS.size.width/4.0, _visitCount.height)];
    [_zanBtn setFrame:CGRectMake(_commentBtn.right, _visitCount.top, BOUNDS.size.width/4.0, _visitCount.height)];
    whiteBg.height = self.zanBtn.bottom;
    NSLog(@"计算得出高度%d",(int)(whiteBg.height));
}
#pragma  mark getter
- (UIButton*)headImg{
    if (_headImg == nil) {
        _headImg = [[UIButton alloc]initWithFrame:CGRectMake(mygap*2, mygap*2, 50, 50)];
        _headImg.layer.masksToBounds = YES;
        _headImg.layer.cornerRadius = 25.0;
    }
    return _headImg;
}
- (UILabel*)nameLb{
    if (_nameLb == nil) {
        _nameLb = [[UILabel alloc] initWithFrame:CGRectMake(_headImg.right+mygap*2, _headImg.top, BOUNDS.size.width-_headImg.right-mygap*4, 20)];
        _nameLb.text = @"seven";
        _nameLb.textColor = NavgationColor;
        _nameLb.textAlignment = NSTextAlignmentLeft;
        _nameLb.font = Content_lbfont;
    }
    return _nameLb;
}
- (UILabel*)contentLb{
    if (_contentLb == nil) {
        _contentLb = [[UILabel alloc] initWithFrame:CGRectMake(_nameLb.left, _nameLb.bottom+mygap, _nameLb.width,_nameLb.height)];
        _contentLb.text = @"今天很高兴";
        _contentLb.textColor = [UIColor blackColor];
        _contentLb.textAlignment = NSTextAlignmentLeft;
        _contentLb.font = Content_lbfont;
        
    }
    return _contentLb;
}
- (UICollectionView*)imgCollection{
    if (_imgCollection == nil) {
        //创建 collectionview
       
        CGFloat cellWidth = 170*UISCREENWIDTH/750;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.minimumInteritemSpacing = mygap;
        flowLayout.minimumLineSpacing = 2*mygap;
        flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);

        _imgCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(_nameLb.left, _contentLb.bottom+mygap, 540*UISCREENWIDTH/750, 370*UISCREENWIDTH/750) collectionViewLayout:flowLayout];
        _imgCollection.backgroundColor =[UIColor whiteColor];
        _imgCollection.dataSource = self;
        _imgCollection.delegate = self;
        [_imgCollection registerClass:[ZHImgCollectionCell class] forCellWithReuseIdentifier:imgCell];
    }
    return _imgCollection;
}
- (UILabel*)timeLb{
    if (_timeLb == nil) {
        _timeLb = [[UILabel alloc] initWithFrame:CGRectMake(_imgCollection.left, _imgCollection.bottom+mygap, 60, 20)];
        _timeLb.text = @"2小时前";
        _timeLb.textColor = [UIColor lightGrayColor];
        _timeLb.textAlignment = NSTextAlignmentLeft;
        _timeLb.font = Content_lbfont;
    }
    return _timeLb;
}
- (UIButton*)removeBtn{
    if (_removeBtn == nil) {
        _removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_removeBtn setFrame:CGRectMake(_timeLb.right+mygap, _timeLb.top, _timeLb.width, _timeLb.height)];
        _removeBtn.titleLabel.font = Content_lbfont;
        [_removeBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_removeBtn setTitleColor:NavgationColor forState:UIControlStateNormal];
    }
    return _removeBtn;
}
- (UIButton*)commentBtn{
    if (_commentBtn == nil) {
        _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentBtn setFrame:CGRectMake(_visitCount.right, _visitCount.top, BOUNDS.size.width/4.0, _visitCount.height)];
        _commentBtn.layer.borderColor = BackGray_dan.CGColor;
        _commentBtn.layer.borderWidth = 0.3;
        [_commentBtn setImage:[UIImage imageNamed:@"comment_wpc"] forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _commentBtn;
}
- (UIButton*)zanBtn{
    if (_zanBtn == nil) {
        _zanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_zanBtn setFrame:CGRectMake(_commentBtn.right, _visitCount.top, BOUNDS.size.width/4.0, _visitCount.height)];
        [_zanBtn setImage:[UIImage imageNamed:@"hasPraised_wpc"] forState:UIControlStateSelected];
        [_zanBtn setImage:[UIImage imageNamed:@"praise_wpc"] forState:UIControlStateNormal];
        [_zanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _zanBtn;
}
- (UILabel*)visitCount{
    if (_visitCount == nil) {
        _visitCount = [[UILabel alloc] initWithFrame:CGRectMake(0,_removeBtn.bottom+mygap*2, BOUNDS.size.width/2.0, 45)];
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"visite"]];
        icon.frame = CGRectMake(30, 15, 14, 14);
        //[_visitCount addSubview:icon];
        
        _visitCount.textColor = [UIColor lightGrayColor];
        _visitCount.textAlignment = NSTextAlignmentCenter;
        _visitCount.font = Content_lbfont;
        
    }
    return _visitCount;
}
#pragma mark UICollectionDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imgArray.count;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ZHImgCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:imgCell forIndexPath:indexPath];
    NSDictionary *dic = [self.imgArray objectAtIndex:indexPath.row];
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",preUrl,[dic objectForKey:@"path"]]] placeholderImage:[UIImage imageNamed:@"applies_plo"]];
        return cell;

}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(mcollectionView:didSelectItemAtIndexPath:)]) {
        [self.delegate mcollectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
