//
//  LVDateSource.h
//  越战数据请求
//
//  Created by LV on 15/3/24.
//  Copyright (c) 2015年 LV. All rights reserved.
//

//lv - 接口
#define getToken @"app/user/getToken"

#define getIndexPics @"app/indexPic/getIndexPic"

/**
 * @brief 【获取赛事列表】
 * @param sportsType  赛事类型(18种运动类型ID)
 * @param matchStutus 赛事状态（null，全部；0，即将开赛；1，正在比赛；2，比赛结束）
 * @param page  查询时的当前页面
 * @param rows  当前每页显示的条数
 * @param String sort (0综合排序 1离我最近)
 **/
#define getMatchList @"app/match/getMatchs"
/**
 * 获取滚动赛事
 */
#define selectBanner @"app/match/selectBanner"
/**
 * @brief 【进入赛事详情】
 * @param id 赛事id(例如：203)必传
 */
#define getMatchDetail @"app/match/getMatchDetails"
#define readMatch @"app/match/readMatch"
#define MatchAdmire @"app/admire/admire"//打赏
/**
 * @brief 【赛事报名】
 * @param uid 用户ID 必传
 * @param matchId 赛事ID 必传
 */
#define toSignUp  @"app/match/toSignUp"

/**
 * @brief 【获取越战列表】
 * @param sportsType 运动类型
 * @param sort 排序方式
 * @param introduce 关键字搜索
 * @param longitude 经度
 * @param latitude 纬度
 * @param page 查询时的当前页数
 * @param rows 当前每页显示条数
 */
#define getApplies @"app/play/getApplies"

/**
 * @brief 【获取越战详情】
 * @param id 越战id
 * @param uid 用户ID 必传
 */
#define getApplyDetail @"app/play/getApplyDetail"

/**
 * @brief 【越战加好友】
 * @param uid
 * @param fuid 
 * @param fusername 
 * @param status 
 * @param num
 */
#define addFrirend @"app/friend/addFrined"

/**
 *  搜索好友
 */
#define getFriendByUsername @"app/personal/findUser"
/*【附近好友】
 CFriendParam{
 uid;//用户ID
 longitude;//经度
 latitude;//纬度
 }
 */
#define getNearFriendList @"app/friend/getNearFriendList"

/**
 * @brief 【评论，点赞，恢复越战(insert)】
 CPlayInteractParam{
 Integer playId;//约战id
 Integer userId;//评论人id
 Integer parentId;//回复的评论的id，回复留言时填充
 String type;//类型 HDLX_0001=点赞,HDLX_0002=留言，HDLX_0003=回复
 String message;//评论内容
 Date interactTime;//评论时间
 Date createtime;//创建时间
 String createuser;//创建人
 Date lmodifytime;//修改时间
 String lmodifyuser;//修改人
 }
 */
#define addInteract @"app/play/addInteract"

/**
 * @brief 【发起约战insert】
 CPlayApplyParam{
 Integer id;
 Integer uid;//uid
 String sportsType;//运动类型代码
 String sportsTypeMeaning;//运动类型
 String username;//用户名
 String mobile;//手机号
 String remarksType;//约战赛制
 String remarksFee;//约战费用
 String remarksTime;//约战时长
 String playTime;//约战时间
 String province;//省份代码
 String provinceMeaning;//省份
 String city;//市区代码
 String cityMeaning;//市区
 String area;//区域代码
 String areaMeaning;//区域
 String venuesName;//详细地址
 String longitude;//经度
 String latitude;//纬度
 String playType;//默认：YZFS_0001约战方式
 Date createtime;
 String createuser;
 Date lmodifytime;
 String lmodifyuser;
 String url;//约战图片
 String path;//图片完整路径
 String introduce;//约战介绍
 String friendIdStr;//获取好友ID用逗号为分隔符，如：22,23,24
 }
 */
#define addPlayApply @"app/play/addPlayApply"

/**
 * @brief 【应战insert】
 CPlayReplyParam{
 "sportsType":"运动类型",
 "uid":"uid",
 "username":"username",
 "mobile":"手机号",
 "applyId":"约战id"
 }
 */
#define addPlayReply @"app/play/addPlayReply"
/**
 CPlayReplyParam{
 Integer id;//应战id
 }
 */
#define deletePlayReply @"app/play/deletePlayReply"
/**
 
 */
#define validateAccount @"app/user/isRegister"
/**
 * @brief 【我的战友】
 * @param uid 用户id
 sportsType
 coachName
 gender
 level
 type
 page:"查询时的当前页数",
 rows:"当前每页显示条数"
 sort:"排序方式"

 */
#define getFriendList @"app/personal/getFriendList"
/**
 *  获取一组用户信息
 */
#define getUsersByIds @"app/personal/getUsersByIds"
/**
 *  新的好友
 */
#define informAndInvite @"app/personal/informAndInvite"
/**
 CFriendDBParam{
 uid;//用户ID
 fuid;//对象ID
 }
 */
#define deleteFriend @"app/friend/delFriend"
/**
 *  @brief 【发送验证码】
 *  @param mobile 手机号
 */
#define PostCode @"app/user/getSMSVerificationCode"

/**
 *  @brief 【下一步，缺人信息，填写用户名密码】
 */
#define confrimCode @"app/user/verifySMSVerificationCode"

/**
 *  @brief 【最后一步，填写手机号和密码】
 */
#define confrimOwnInfo @"app/passport/mobileReg"
/**
 *  更换手机绑定
 */
#define saveBindMobile @"app/passport/saveBindMobile"
/**
 * @brief 【登陆】
 * CLoginParam{
 String username;//账号
 String password;//密码
 Double longitude;//经度
 Double latitude;//纬度
 }
 */
#define yuezhanlogin @"app/user/login"
#define xiaodongRegister @"app/user/register"
//zhang

/**
 *  @brief [获取教练首页列表]
 * @param sportType 运动类型
 oachName
 gender
 level
 type
 page:"查询时的当前页数",
 rows:"当前每页显示条数"
 sort:"排序方式"
 */
#define getCoachs @"app/coach/getCoachList"
//zhang
/**
 * @brief [获取某个教练详情]
 * @param id
 */
#define getCoachDetail @"app/coach/getCoachDetail"
/**
 * @brief [获取俱乐部列表]
 * @param sportsType
 name
 page:"查询时的当前页数",
 rows:"当前每页显示条数"
 sort:"排序方式"
 */
#define getClubs @"app/club/getClubList"
/**
 * @brief [获取某个俱乐部详情]
 * @param id
 */
#define getClubDetail @"app/club/getClubDetail"
/**
 * @brief [获取俱乐部列表]
 * @param sportsType
 name
 page:"查询时的当前页数",
 rows:"当前每页显示条数"
 sort:"排序方式"
 */
#define getTrains @"app/train/getTrainList"
/**
 * @brief [获取某个俱乐部详情]
 * @param id
 */
#define getTrainDetail @"app/train/getTrainDetail"
/**
 @brief [获取场地列表]
 * @param
 sportsType:"运动类型",
 venuesName:"场馆名称",
 longitude:"经度",
 latitude:"维度",
 promote:"推荐场馆",
 page:"查询时的当前页数",
 rows:"当前每页显示条数"
 sort:"排序方式"，0=综合排序 1=离我最近
 
 */
#define getVenues @"app/venues/getVenues"
/**
 @brief [获取场地详情]
 * @param id
 */
#define getVenuesDetail @"app/venues/getVenuesDetail"
/**
 @brief [获取场地图片列表]
 * @param id
 */
#define getVenuesPics @"app/venues/getVenuesDetail"
/**
 @brief [获取场地套餐列表]
 * @param id
 */
#define getVenuesPackages @"app/venues/getVenuesPackages"
/**
 @brief [获取场地套餐列表]
 * @param packageId
 */
#define getVenuesPackageById @"app/venues/getVenuesPackageById"

/**
 * @brief 【个人中心的首页】
 CPsersonalParam{
 uid
 }
 */
#define selfcenterhome @"app/personal/UserInfo"
/**
 *  获取消息中心列表
 */
#define selfmessagecenter @"app/message/getMyMessages"
/**
 *  获取未读消息条数
 */
#define selfmessagecenterNum  @"app/personal/index" 
/**
 * @brief 【个人中心的我的信息】
 CPersonalDBParam":{
 Integer id;//ID
 Integer uid;//uid
 String userName;//用户名
 String icon;//icon
 String iconPath;//iconPath
 String gender;//性别
 String height;//身高
 String weight;//体重
 Date birthday;//生日
 String mobile;//手机号（需要绑定，此处不赋值）
 String email;//邮件 （需要绑定，此处不赋值）
 String loveSports;//喜爱的运动
 String loveClub;//喜欢的俱乐部
 String loveStar;//喜欢的体育明星
 String addr;//所在地
 String province;//省份代码
 String provinceMeaning;//省份
 String city;//市区代码
 String cityMeaning;//市区
 String area;//区域代码
 String areaMeaning;//区域
 Integer integral;//积分不赋值
 Date lmodifytime;
 String lmodifyuser;}
 }
 */
#define selfcenterinformation @"app/personal/editPersonalData"


/**
 * @brief 【获取地区】
 CPsersonalParam{
 uid
 }
 */
#define getarea @"app/common/getRegions"

/**
 *@brief 【图片上传】
 CBaseParam{
 type:"图片归属类型",
 file:"文件"
 }
 type:{
 PERSONAL_LOGO:"个人信息LOGO",
 PERSONAL_TEAM:"队伍图标",
 COACH:"教练",
 PLAY:"约战"}
 */
#define imageupdata @"upload/file/imgUpload"
/**
 *多张图片上传
 */
#define imgsUpload @"app/upload/file/imgsUpload"
/**
 @brief 【个人中心约战列表】
 CPsersonalParam{
 uid
 }
 */
#define getPlayList @"app/personal/getPlayList"
/**
 *  删除应战
*/
#define delReply @"app/personal/delReply"
/**
 *  删除约战
 */
#define delApply @"app/personal/delApply"
/**
 @brief 【个人中心赛事信息】
 CPsersonalParam{
 uid
 }
 */
#define getpersonalMatchList @"app/personal/getMatchList"
/**
 *  获取不用付钱的我的赛事
 */
#define getNotOrderSigup @"app/personal/getNotOrderSigup"
/**
 @brief 【个人中心订单管理】
 CPsersonalParam{
 uid
 }
 */
#define getOrderList @"app/personal/getOrderList"
/**
 *  获取赛事订单详情
 */
#define getMatchOrderDetail @"app/order/getMatchOrderDetail"
/*
 支付宝获取sign的接口
 */
#define toAliPay @"app/order/toAlipay"
/**
 @brief 银联支付
 CPersonalOrderParam{
 Integer id;//订单ID
 String orderNum//订单号
 }
 */
#define toPay @"app/order/toPay"
/**
 *  微信支付
 */
#define toWXPay @"app/order/toWeiPay"
/**
 @brief 定场馆
 COrderParam{id:"",
 Integer uid;//用户ID
 String username;//用户名
 Integer quantity;//数量
 String orderType;//类型 DDLX_0001=定场馆, DDLX_0002=团体赛事报名费,DDLX_0003=个人赛事报名费
 String orderName;//订单名称
 String orderNum;（传null）
 Double unitPrice;（传null）
 Double amount;（传null）
 
 CMatchSignupInfoDBParam matchSignupInfo;//报名信息
 CVenuesPackageParam packageParam;//场馆套餐信息}
 */
#define payVenuesPackage @"app/order/payVenuesPackage"
/**
 [赛事报名]
 */
#define matchSignup @"app/order/matchSignup"

/**
 【判断是否绑定QQ用户信息】
 CPassportParam{
 String qqId;//qq登录返回的id
 Double longitude;//经度
 Double latitude;//纬度
 }
 */
#define isBindQQAccount @"app/passport/isBindQQAccount"
/**
 *  【使用qq快速注册】
 CPassportParam{
 String qqId
 String userName
 String qqResGender
 Double longitude;//经度
 Double latitude;//纬度
 }
 **/
#define qqRegister @"app/passport/qqRegister"

/**
 *【账号绑定】
 CPassportParam{
 Integer uid;
 String mobile;
 String password;//密码
 String qqId;//qq登录返回的id
 Double longitude;//经度
 Double latitude;//纬度
 }
 **/

#define bindQQAccount @"app/passport/bindQQAccount"
/**
 [重设密码]
 CPassportParam{
 mobile
 password
 }
 */
#define resetPassword @"app/user/editUserInfo"
/**
 获取全国城市列表
 */
#define getCity @"app/other/getCitys"
/**
 获取全国城市大学
 */
#define getCityUniversities @"app/other/getCitySchools"
/**
 获取全国大学
 */
#define getUniversities @"app/other/getSchools"
/**
 *  获取所有战队、按条件筛选
 CPsersonalParam{
 String sportsType; //运动类型
 String university;//所属大学
 Double longitude;//"经度",
 Double latitude;//"维度",
 }
 */
#define getTeamList @"app/team/getTeamList"
/**
 获取我的球队
 */
//#define getMyTeam @"app/team/getMyTeam"
/**
 获取附近球队列表
 */
#define nearTeamList @"app/team/nearTeamList"
/**
 *  查看队伍详情
 id 队伍id
 */
#define getTeamDetail @"app/team/teamDetail"
/**
 * 球队粉丝
 */
#define TeamFansList @"app/follow/TeamFansList"
/**
 *  获取所有大学列表
 */
#define getUniversity @"app/team/getUniversity"
/**
 *  上传战队图
 */
#define insertTeamShow @"app/team/insertTeamShow"
/**
 *  创建队伍
*/
#define addTeam @"app/team/createTeam"
/**
 *  申请/批准加入队伍
*/
#define applyJoinTeam @"app/team/applyJoinTeam"
/**
 *  查询队伍下队员
 */
#define getPlayerList @"app/team/getTeamMembers"
/**
 *  删除队员或是退出队伍
 */
#define delPlayer @"app/team/removeTeamUser"
/**
 *  删除队伍
 */
#define delTeam @"app/team/delTeam"
/**
 *  修改战队信息
 */
#define modifyTeam @"app/team/editTeam"
/**
 *  获取我的队伍/申请队伍列表
*/
#define getMyTeamList @"app/team/getMyTeam"
/**
 *申请明星球队
 */
#define starTeamApply @"app/team/starTeamApply"
/**
 * 获取我创建的球队
 */
#define myTeams @"app/personal/myTeams"
/**
 *  传uid 查询创建的战队
 */
#define getCreateTeam @"app/team/getCreateTeam"
/**
 *  上传战队图片列表
 */
#define insertTeamListShows @"app/team/insertTeamListShows"
/**
 *  删除发起的约战
 */
#define deletePlayApply @"app/play/deletePlayApply"
/**
 *  添加／更新约战赛果
 */
#define updatePlayApply @"app/play/updatePlayApply"
/**
 *  删除一个越战赛图
 */
#define deletePlayShow @"app/play/deletePlayShow"
/**
 *  新增多个约战赛图
 */
#define insertPlayShows @"app/play/insertPlayShows"
/**
 *  取消赞或者
 */
#define delInteract @"app/play/delInteract"
/**
 *  查看关于我的评论
 */
#define aboutMe @"app/play/aboutMe"
/**
 赛事报名
 */
#define MatchSignUp @"app/match/signUp"
/**
 *赛事报名信息
 */
#define MatchSignUpInfo @"app/match/signUpInfo"
/*-------------------------时光机接口-------------------------*/
/**
 *  发布添加消息
 */
#define maddMessage @"app/TimeMachine/addMessage"
/**
 *  获取动态详情
 */
#define getMessages @"app/TimeMachine/getMessages"
/**
 *  点赞，评论
 */
#define addComment @"app/TimeMachine/addComment"
/**
 *  获取我的消息
 */
#define getMyMessages @"app/TimeMachine/getMyMessages"
/**
 *  删除消息
 */
#define delMessages @"app/TimeMachine/delMessages"
/**
 *  删除赞
 */
#define delZan @"app/TimeMachine/delCommentByUM"
/**
 *  删除评论，
 */
#define delComment @"app/TimeMachine/delComment"
/**
 *  查看详细消息
 */
#define getMessageDetail @"app/TimeMachine/getMessageDetail"
/**
 *  获取未读与我相关消息
 */
#define getMessageAbout @"app/TimeMachine/aboutMe"
/**
 *  将未读消息设置为已读
 */
#define setMessageAbout @"app/TimeMachine/readAboutMe"
/**
 *  获取未读消息个数
 */
#define aboutMeNum @"app/TimeMachine/aboutMeNum"
/*-------------------------赛事交互性接口-------------------------*/
/**
 *赛事评论,点赞，回复
 */
#define addMatchInteract @"app/match/Interact"
/**
 * 我的赛事列表
 */
#define myMatches @"app/personal/myMatches"
/**
 取消赞
 */
#define deleteZan @"app/match/cancelAgree"
/**
 收藏
 */
#define addMatchCollect @"app/personal/collect"
/**
 取消收藏
 */
#define deleteMatchCollect @"app/personal/DeleteCollection"
/**
 我的收藏
 */
#define myCollections @"app/personal/myCollections"
/**
 战绩详情
 */
#define getTeamMatchRecord @"app/match/getTeamMatchRecord"
/**
 * 删除我的赛事
 */
#define hideMatch @"app/personal/hideMatch"
/**
 添加关注
 */
#define addFollow @"app/follow/addFollow"
/**
 取消关注
 */
#define cancleFollow @"app/follow/cancleFollow"
/**
我的粉丝
 */
#define followMeList @"app/follow/followMeList"
/**
我关注的人
 */
#define followPersonList @"app/follow/followPersonList"
/**
我关注的球队
 */
#define followTeamList @"app/follow/followTeamList"
/**
 *关于我的评论
 */
#define aboutMacthMe @"app/match/aboutMe"
/**
 * 我的评论
 */
#define myComment @"app/personal/myComment"
/**
 * 回复我的
 */
#define ReplyMe @"app/personal/ReplyMe"
/**
 * 评论详情
 */
#define commentDetails @"app/personal/commentDetails"
/**
 *删除评论，赞，回复
 */
#define delMatchInteract @"app/match/delInteract"
/**
 */
#define countShare @"app/match/share"
/**
 *赛事详情里，顶上的6个标签内容
 */
#define getMatchInfo @"app/match/getMatchBLOBsData"
/**
 *取消报名
 */
#define delMatchSignUp @"app/personal/delMatchSignuUp"
/**
 *赛事报名修改信息接口
 */
#define toModifySignUp @"app/match/toModifySignUp"
/**
 *赛事报名修改提交接口
 */
#define modifySignUp @"app/match/modifySignUp"

/*-------------------------场馆接口-------------------------*/
#define getVenuesPrices @"app/venues/getVenuesPrices"

#define addPlaceOrders @"app/order/addPlaceOrders"

#define getVenuesOrderDetail @"app/order/getVenuesOrderDetail"

#define addVenuesComment @"app/venues/addVenuesComment"

#define getPaywordList @"app/order/getPaywordList"

#define delOrder @"app/order/delOrder"
/*----------------------上传群聊头像------------------------*/
#define insertGroupShow @"app/group/insertGroup"

#define getGroupShow @"app/group/getGroupShow"

#define getGroupShowByGroupIds @"app/group/getGroupShowByGroupIds"

#define getGroupUserInfo @"app/group/getUserInfo"

#define orderRefund @"app/order/refund"

#define delMsgCenter @"app/personal/delMessage"//删除消息中心信息


#define delAllMessage @"app/message/deleteMyMessages"//删除消息中心信息
/*----------------------消息中心------------------------*/
#define xdgetMyMessage @"app/message/getMyMessages"
#define xdsendMessage @"app/message/sendMessage"
#define xdreadMessages @"app/message/readMessages"
#define xdMessageOperation @"app/message/MessageOperation"
/**
 *private Integer userId;		//举报人ID
	private Integer reportId;	//被举报ID
	private String content;		//举报内容
	private Integer reportType;	//举报类型(1：用户，2：球队，3：评论)
 */
#define xdAddReport @"app/report/addReport"

#define agreeJoin @"app/team/getAgreeJoin"//同意加入战队

//统计（场馆电话统计）
#define callStatic @"app/dialphone/addRecord"
//学校信息
#define getSchoolList @"app/other/school"
#ifndef _______LVDateSource_h
#define _______LVDateSource_h
#endif
