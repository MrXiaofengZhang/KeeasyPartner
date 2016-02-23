//
//  WPCFriendMsgTableViewCell.m
//  yuezhan123
//
//  Created by admin on 15/5/14.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "WPCFriendMsgTableViewCell.h"
#import "TeamCollectCell.h"
#import "TeamModel.h"
#define CELLHEIGHT self.bounds.size.height
#define infoHeight 53.0
@implementation WPCFriendMsgTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _prefixArr = @[@"身高:",@"体重:",@"所在地:",@"喜欢的体育明星:"];

        self.iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CELLHEIGHT-15, CELLHEIGHT-15)];
        self.iconImage.center = CGPointMake(35, CELLHEIGHT/2);
        self.iconImage.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.iconImage];
        
        self.nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, CELLHEIGHT-20)];
        self.nameLab.center = CGPointMake(140, CELLHEIGHT/2);
        self.nameLab.textAlignment = NSTextAlignmentLeft;
        self.nameLab.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:self.nameLab];
        if (UISCREENWIDTH == 320) {
            self.nameLab.font = [UIFont systemFontOfSize:15];
        } else if (UISCREENWIDTH == 375) {
            self.nameLab.font = [UIFont systemFontOfSize:16];
        } else {
            self.nameLab.font = [UIFont systemFontOfSize:17];
        }
        
        if (self.isMsged) {
            self.msgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CELLHEIGHT-10, CELLHEIGHT-10)];
            self.msgView.center = CGPointMake(self.bounds.size.width-60, CELLHEIGHT/2);
            self.msgView.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:self.msgView];
        } else {
            self.msgView = nil;
        }
    }
    return self;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andType:(NSInteger)type{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _prefixArr = @[@"身高:",@"体重:",@"所在地:",@"喜欢的体育明星:"];
        
        self.iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CELLHEIGHT-15, CELLHEIGHT-15)];
        self.iconImage.center = CGPointMake(35, CELLHEIGHT/2);
        self.iconImage.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.iconImage];
        
        
        self.nameLab = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImage.right+10, CELLHEIGHT/2-(CELLHEIGHT-20)/2, 140, CELLHEIGHT-20)];
        self.nameLab.textAlignment = NSTextAlignmentLeft;
        self.nameLab.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.nameLab];
        if (UISCREENWIDTH == 320) {
            self.nameLab.font = [UIFont systemFontOfSize:15];
        } else if (UISCREENWIDTH == 375) {
            self.nameLab.font = [UIFont systemFontOfSize:16];
        } else {
            self.nameLab.font = [UIFont systemFontOfSize:17];
        }
        
        if (self.isMsged) {
            self.msgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CELLHEIGHT-10, CELLHEIGHT-10)];
            self.msgView.center = CGPointMake(self.bounds.size.width-60, CELLHEIGHT/2);
            self.msgView.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:self.msgView];
        } else {
            self.msgView = nil;
        }
        if (type == 0) {
            //基本资料
            [self initialInterface];
        }
        else if (type == 11){
            //战队
            [self.contentView addSubview:self.teamCollection];
        }
        else if (type == 12){
            //群组
            [self.contentView addSubview:self.teamCollection];
        }
    }
    return self;
}
- (void)loadData
{
    //个性签名不知道是哪个键值对,暂用loveSportsMeaning代替
    NSLog(@"%@",self.infoDic);
    NSArray *tempArr = @[@"height",@"weight",@"addr",@"loveStar"];
    for (int i = 0; i < [tempArr count]; i ++) {
        NSString *str = [LVTools mToString:[self.infoDic valueForKey:tempArr[i]]];
        UILabel *label = (UILabel *)[self.contentView viewWithTag:555+i];
        if (str.length != 0) {
            if (i == 0) {
                label.text = [NSString stringWithFormat:@"%@ (cm)",str];
            } else if (i == 1) {
                label.text = [NSString stringWithFormat:@"%@ (kg)",str];
            } else {
                label.text = str;
            }
        } else {
            label.text = @"保密";
        }
    }
}
- (void)initialInterface
{
    for (int i = 0; i < _prefixArr.count; i ++) {
        UILabel *prefixLab = [[UILabel alloc] init];
        UILabel *detailLab = [[UILabel alloc] init];
        detailLab.tag = 555+i;
        UIView *grayline = [[UIView alloc] init];
        if (UISCREENWIDTH == 320) {
            prefixLab.frame = CGRectMake(0, infoHeight*i+HeightOfCell, 130, 37);
            detailLab.frame = CGRectMake(135, infoHeight*i+HeightOfCell, 170, 37);
            prefixLab.font = [UIFont systemFontOfSize:14];
            detailLab.font = [UIFont systemFontOfSize:14];
            grayline.frame = CGRectMake(135, CGRectGetMaxY(detailLab.frame)+0.5, UISCREENWIDTH-100, 0.5);
        } else if (UISCREENWIDTH == 375) {
            prefixLab.frame = CGRectMake(0, infoHeight*i+HeightOfCell, 140, 43);
            detailLab.frame = CGRectMake(145, infoHeight*i+HeightOfCell, 210, 43);
            grayline.frame = CGRectMake(145, CGRectGetMaxY(detailLab.frame)+0.5, UISCREENWIDTH-100, 0.5);
        } else {
            prefixLab.frame = CGRectMake(0, infoHeight*i+HeightOfCell, 150, 43);
            detailLab.frame = CGRectMake(155, infoHeight*i+HeightOfCell, 240, 43);
            grayline.frame = CGRectMake(145, CGRectGetMaxY(detailLab.frame)+0.5, UISCREENWIDTH-100, 0.5);
        }
        
        prefixLab.backgroundColor = [UIColor clearColor];
        prefixLab.textAlignment = NSTextAlignmentRight;
        prefixLab.textColor = [UIColor lightGrayColor];
        prefixLab.text = _prefixArr[i];
        [self.contentView addSubview:prefixLab];
        
        detailLab.textAlignment = NSTextAlignmentLeft;
        detailLab.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:detailLab];
        
        
        grayline.backgroundColor = RGBACOLOR(204, 204, 204, 1);
        [self.contentView addSubview:grayline];
    }
}

#pragma mark getter
- (UICollectionView*)teamCollection{
    if (_teamCollection == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake(60, 80);
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 5, 10, 5);
        flowLayout.minimumInteritemSpacing = 5;
        flowLayout.minimumLineSpacing = mygap*2;
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];

        _teamCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(mygap, mygap, BOUNDS.size.width-2*mygap, 90) collectionViewLayout:flowLayout];
        _teamCollection.pagingEnabled = YES;
        _teamCollection.scrollEnabled = NO;
        _teamCollection.dataSource = self;
        _teamCollection.delegate = self;
        _teamCollection.backgroundColor = [UIColor whiteColor];
        [_teamCollection registerClass:[TeamCollectCell class] forCellWithReuseIdentifier:@"TeamCollectCell"];
       
    }
    return _teamCollection;
}
#pragma mark setter
- (void)setDataArray:(NSMutableArray *)dataArray{
    _dataArray = dataArray;
    [self.teamCollection reloadData];
}
- (void)setInfoDic:(NSDictionary *)infoDic{
    _infoDic = infoDic;
    [self loadData];
}
#pragma mark UICollectionDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"TeamCollectCell";
    TeamCollectCell * cell = (TeamCollectCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    TeamModel *model = _dataArray[indexPath.row];
    [cell configTeamDict:model];
    [cell.ownerBtn addTarget:self action:@selector(ownerOnClick) forControlEvents:UIControlEventTouchUpInside];
    cell.levelBtn.tag = 100+indexPath.row;
    [cell.levelBtn addTarget:self action:@selector(levelOnCLick:) forControlEvents:UIControlEventTouchUpInside];
    if ([[LVTools mToString: model.creatorId] isEqualToString:[LVTools mToString:self.userId]]&&[LVTools mToString:self.userId].length>0) {
        cell.ownerBtn.hidden = NO;
    }
    else{
        cell.ownerBtn.hidden = YES;
    }

    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    self.selectBlock(collectionView,indexPath);
    
}
- (void)ownerOnClick{
    self.leaderBlock(nil);
}
- (void)levelOnCLick:(UIButton*)btn{
    self.levelBlock(_dataArray[btn.tag-100]);
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
