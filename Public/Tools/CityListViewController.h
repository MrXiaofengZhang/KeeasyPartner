//
//  CityListViewController.h
//  CityList
//
//  Created by Chen Yaoqiang on 14-3-6.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol CityDelegate <ZHRefreshDelegate>

@optional
- (void)sendCityAreas:(NSDictionary *)dic;
- (void)wholeContryClick;
- (void)collectionClickAtCode:(NSString *)code andName:(NSString *)name andInfo:(NSDictionary *)dic;

@end

@interface CityListViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UICollectionViewDataSource,UICollectionViewDelegate>{
    NSMutableArray *dataArray;
    UISearchBar *mySearchBar;
    UISearchDisplayController *searchDisplayController;
}

@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic,assign) BOOL isUniversityList;//YES表示大学
@property (nonatomic, strong) NSMutableDictionary *cities;
@property (nonatomic, strong) NSMutableArray *keys; //城市首字母
@property (nonatomic, strong) NSMutableArray *arrayCitys;   //城市数据
@property (nonatomic, strong) NSMutableArray *arrayHotCity;
@property (nonatomic, assign) id <CityDelegate> citydelegate;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UICollectionView *collectView;
@property (nonatomic, strong)UIView *headerview;
@property (nonatomic, strong)NSDictionary *areaDictionary;
@property (nonatomic, strong)NSMutableArray *searchInfoArray;//查询后返回的数组（每条都是详细信息）
@property (nonatomic, strong)NSMutableArray *tempArray;
@property (nonatomic, strong) NSDictionary *citiesDictionary;
@property (nonatomic, assign) BOOL hasAllCountry;


@end
