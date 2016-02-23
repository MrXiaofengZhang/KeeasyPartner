//
//  ZHCommentController.m
//  yuezhan123
//
//  Created by zhangxiaofeng on 15/6/11.
//  Copyright (c) 2015年 LV. All rights reserved.
//

#import "ZHCommentController.h"
#import "MessagePhotoView.h"
#import "ZHupdateImage.h"
#define imgWith (BOUNDS.size.width-2*mygap-2*mygap)/4.0
@interface ZHCommentController ()<UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,MessagePhotoViewDelegate>{
    NSMutableArray *imgArray;
    UILabel *holderLb;
    int level;
    MessagePhotoView *_imagePickView;
}
@property (nonatomic,strong) UITextView *comentView;
@property (nonatomic,strong) UIScrollView *imgScrol;//自己写的用系统添加照片的视图
//@property (nonatomic,strong) MessagePhotoView *imagePickView;
@property (nonatomic,strong) UIView *starView;
@property (nonatomic,strong) NSMutableDictionary *postInfoDic;
@property (nonatomic,strong) NSArray *tempArray;

@end

@implementation ZHCommentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = BackGray_dan;
    [self navgationBarLeftReturn];
    level = 0;
    if (self.fromStyle == StyleResultComment || self.fromStyle == StyelResultVenueComment||self.fromStyle == StyelResultTimeMachine) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(faSong)];
    } else if (self.fromStyle == StyleResultImg) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(faSong)];
    } else if (self.fromStyle == StyleResultTeam){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(faSong)];
    } else if (self.fromStyle == StyleResultMatch){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(faSong)];
    }
    
    
    imgArray = [[NSMutableArray alloc] initWithCapacity:0];
    UIImage *addimage = [UIImage imageNamed:@"addImg"];
    [imgArray addObject:addimage];
    [self creatUI];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (void)setImageArray{
    for (NSInteger i=0; i<imgArray.count; i++) {
        UIButton *imageV  =(UIButton*)[_imgScrol viewWithTag:100+i];
        if (imageV==nil) {
           imageV = [[UIButton alloc] initWithFrame:CGRectMake(mygap+imgWith*i, mygap, imgWith-mygap, imgWith-mygap)];
            UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(imageV.width-20, 0, 20, 20)];
            imageV.contentMode = UIViewContentModeScaleAspectFit;
            [deleteBtn setBackgroundImage:[UIImage imageNamed:@"deleteImg"] forState:UIControlStateNormal];
            [deleteBtn addTarget:self action:@selector(deleteOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [imageV addSubview:deleteBtn];
            imageV.tag = 100+i;
            //[imageV addTarget:self action:@selector(imgOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_imgScrol addSubview:imageV];
        }
        if (i==imgArray.count-1) {
            UIButton *btn =(UIButton*)[imageV.subviews lastObject];
            btn.hidden = YES;
        }
        else{
            UIButton *btn =(UIButton*)[imageV.subviews lastObject];
            btn.hidden = NO;
        }
        [imageV setBackgroundImage:[imgArray objectAtIndex:i] forState:UIControlStateNormal];
    }
}
//- (void)imgOnClick:(UIButton*)btn{
//    [self.view endEditing:YES];
//    if (btn.tag-100 == imgArray.count-1) {
//        //添加按钮
//        if(imgArray.count==4){
//            [self showHint:@"最多发表三张图片"];
//        }
//        else{
//            UIActionSheet *action=[[UIActionSheet alloc]initWithTitle:@"请选择需要的操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"从相册选取" otherButtonTitles:@"拍照", nil];
//            [action showInView:self.view];
//        }
//    }
//    else{
//        //图片
//        
//    }
//}
- (void)deleteOnClick:(UIButton*)btn{
    UIView *lastView = [_imgScrol viewWithTag:[imgArray count]-1+100];
    [lastView removeFromSuperview];
    
    NSInteger selectIndex = btn.superview.tag-100;
    [imgArray removeObjectAtIndex:selectIndex];
    [self setImageArray];
}
//发表时光机
- (void)commitMessageWithDic:(NSDictionary*)dic{
     NSLog(@"----%@",dic);
    [DataService requestWeixinAPI:maddMessage parsms:@{@"param":[LVTools configDicToDES: dic]} method:@"POST" completion:^(id result) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self hideHud];
        NSLog(@"%@",result);
        if([result[@"statusCodeInfo"] isEqualToString:@"成功"]){
            [self showHint:@"发表成功"];
          
            self.chuanComment(dic);
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [self showHint:ErrorWord];
        }
    }];
}
//上传战队晒图
- (void)updateTeamImg{
   
    NSMutableArray *imgPathInfos = [NSMutableArray array];
    __block int times = 0;
    if (_imagePickView.photoMenuItems.count > 0) {
        ZHupdateImage *upload = [[ZHupdateImage alloc] init];
        [self showHudInView:self.view hint:@"图片上传中"];
        for (int i = 0; i < [_imagePickView.photoMenuItems count]; i ++) {
            UIImage *tempImg=nil;
            if ([[_imagePickView.photoMenuItems objectAtIndex:i] isKindOfClass:[UIImage class]]) {
                tempImg=[_imagePickView.photoMenuItems objectAtIndex:i];
            }
            else{
                ALAsset *asset=[_imagePickView.photoMenuItems objectAtIndex:i];
                tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            }

            NSDictionary *dic = [LVTools getTokenApp];
            NSData *imageData=UIImageJPEGRepresentation(tempImg, kCompressqulitaty);
            if (imageData==nil) {
                imageData=UIImagePNGRepresentation(tempImg);
            }
            [upload requestWithURL:imageupdata WithParams:@{@"param":dic,@"type":@"TEAMLIST_SHOW"} WithType:nil WithData:imageData With:^(id result) {
                times ++;
                if ([[result objectForKey:@"statusCodeInfo"] isEqualToString:@"成功"])
                {
                    NSLog(@"result ==== %@",result);
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                    [dictionary setValue:[LVTools mToString:result[@"url"]] forKey:@"filenameExt"];
                    [dictionary setValue:@"" forKey:@"filename"];
                    [dictionary setValue:[LVTools mToString:result[@"path"]] forKey:@"path"];
                    [dictionary setValue:[LVTools mToString:result[@"url"]] forKey:@"url"];
                    [imgPathInfos addObject:dictionary];
                    NSLog(@"temptime == %d      i = %d",times,i);
                    if (times == _imagePickView.photoMenuItems.count) {
                        //此时隐藏圈圈
                        [self hideHud];
                        if (imgPathInfos.count == _imagePickView.photoMenuItems.count) {
                            NSDictionary *dic = [LVTools getTokenApp];
                            [dic setValue:self.idstring forKey:@"typeId"];
                            [dic setValue:@"TEAMLIST_SHOW" forKey:@"type"];
                            [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"uid"];
                            [dic setValue:imgPathInfos forKey:@"pics"];
                            [DataService requestWeixinAPI:insertPlayShows parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                                NSLog(@"%@",result);
                                if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
                                    [self showHint:@"上传成功"];
                                    self.chuanBlock(dic[@"pics"]);
                                    [self.navigationController popViewControllerAnimated:YES];
                                }
                            }];
                        } else {
                            [self showHint:@"上传失败"];
                        }
                    }
                }
            }];
        }
    } else {
        [self showHint:@"请选择图片上传"];
    }
}
//发表约战评论
- (void)publishTheComment:(NSDictionary *)dic {
    NSLog(@"----%@",dic);
    [self hideHud];
    [DataService requestWeixinAPI:addInteract parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSLog(@"final result === %@",result);
        if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
            _postInfoDic = [NSMutableDictionary dictionaryWithDictionary:result[@"list"]];
            [_postInfoDic setValue:[kUserDefault valueForKey:KUserIcon] forKey:@"iconPath"];
            [_postInfoDic setValue:_tempArray forKey:@"commentShowList"];
            [_postInfoDic setValue:[kUserDefault valueForKey:kUserName] forKey:@"userName"];
            NSLog(@"postdic ==== %@",_postInfoDic);
            self.chuanComment(_postInfoDic);
            [self.navigationController popViewControllerAnimated:YES];
           //发表成功，然后返回
        } else {
            [self showHint:@"发表失败，请重试"];
        }
    }];
}

- (void)dealloc {
    NSLog(@"img ===== %@",_imagePickView);
    _imagePickView = nil;
}

//发表赛事评论
- (void)publishMatchComment:(NSDictionary *)dic {
    [DataService requestWeixinAPI:addMatchInteract parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"final result === %@",result);
        [self hideHud];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if ([result[@"status"] boolValue]) {
//            result[@"data"][@"id"];
//            _postInfoDic = [NSMutableDictionary dictionaryWithDictionary:result[@"list"]];
//            [_postInfoDic setValue:[kUserDefault valueForKey:KUserIcon] forKey:@"iconPath"];
//            [_postInfoDic setValue:_tempArray forKey:@"commentShowList"];
//            [_postInfoDic setValue:[kUserDefault valueForKey:kUserName] forKey:@"userName"];
            self.chuanComment(_postInfoDic);
            [self.navigationController popViewControllerAnimated:YES];
            //发表成功，然后返回
        } else {
            [self showHint:@"发表失败，请重试"];
        }
    }];
}
//发表场馆评论
- (void)publishVenueComment:(NSDictionary *)dic {
    [DataService requestWeixinAPI:addVenuesComment parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        NSLog(@"final result === %@",result);
        [self hideHud];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
            _postInfoDic = [NSMutableDictionary dictionaryWithDictionary:result[@"list"]];
            [_postInfoDic setValue:[kUserDefault valueForKey:KUserIcon] forKey:@"iconPath"];
            [_postInfoDic setValue:_tempArray forKey:@"commentShowList"];
            [_postInfoDic setValue:[kUserDefault valueForKey:kUserName] forKey:@"userName"];
            self.chuanComment(_postInfoDic);
            [self showHint:@"评论成功"];
            [self.navigationController popViewControllerAnimated:YES];
            //发表成功，然后返回
        } else {
            [self showHint:@"发表失败，请重试"];
        }
    }];
}

- (void)faSong{
    [self.view endEditing:YES];
    if ([LVTools stringContainsEmoji:_comentView.text]) {
        [self showHint:@"后台暂不支持表情符号"];
        return;
    }
    if (self.fromStyle == StyleResultComment) {
        //写评论发表
        if (_comentView.text.length == 0) {
            [self showHint:@"评论内容不能为空"];
            return;
        } else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            NSMutableDictionary *dic = [LVTools getTokenApp];
            [dic setValue:self.idstring forKey:@"playId"];
            [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"userId"];
            [dic setValue:@"HDLX_0002" forKey:@"type"];
            [dic setValue:_comentView.text forKey:@"message"];
            if ([_imagePickView.photoMenuItems count] == 0) {
                //直接上传回复信息
                [self publishTheComment:dic];
            } else {
                //先上传图片
                NSMutableArray *imgPathInfos = [NSMutableArray array];
                __block int counttimes = 0;
                ZHupdateImage *upload = [[ZHupdateImage alloc] init];
                [self showHudInView:self.view hint:@"图片上传中"];
                for (int i = 0; i < [_imagePickView.photoMenuItems count]; i ++) {
                    UIImage *tempImg=nil;
                    if ([[_imagePickView.photoMenuItems objectAtIndex:i] isKindOfClass:[UIImage class]]) {
                        tempImg=[_imagePickView.photoMenuItems objectAtIndex:i];
                    }
                    else{
                        ALAsset *asset=[_imagePickView.photoMenuItems objectAtIndex:i];
                        tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                    }
                    NSDictionary *everydic = [LVTools getTokenApp];
                    NSData *imageData=UIImageJPEGRepresentation(tempImg, kCompressqulitaty);
                    if (imageData==nil) {
                        imageData=UIImagePNGRepresentation(tempImg);
                    }
                    [upload requestWithURL:imageupdata WithParams:@{@"param":everydic,@"type":@"PLAY_COMMENT_SHOW"} WithType:nil WithData:imageData With:^(id result) {
                        counttimes ++;
                        NSLog(@"%@",result[@"message"]);
                        NSLog(@"%@",result[@"statusCodeInfo"]);
                        if ([[result objectForKey:@"statusCodeInfo"] isEqualToString:@"成功"])
                        {
                            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                            [dictionary setValue:[LVTools mToString:result[@"url"]] forKey:@"filenameExt"];
                            [dictionary setValue:@"" forKey:@"filename"];
                            [dictionary setValue:[LVTools mToString:result[@"path"]] forKey:@"path"];
                            [dictionary setValue:[LVTools mToString:result[@"url"]] forKey:@"url"];
                            [imgPathInfos addObject:dictionary];
                            NSLog(@"items == %@",_imagePickView.photoMenuItems);
                            NSLog(@"imgpathinfo ==== %@",imgPathInfos);
                            if (counttimes == _imagePickView.photoMenuItems.count) {
                                if (imgPathInfos.count == _imagePickView.photoMenuItems.count) {
                                    _tempArray = [NSArray arrayWithArray:imgPathInfos];
                                    NSDictionary *littledic = @{@"type":@"PLAY_COMMENT_SHOW",@"pics":imgPathInfos};
                                    [dic setValue:littledic forKey:@"file"];
                                    [self publishTheComment:dic];
                                } else {
                                    [self hideHud];
                                    [self showHint:@"上传失败"];
                                    self.navigationItem.rightBarButtonItem.enabled = YES;
                                }
                            }
                        }
                    }];
                }
            }
        }
    } else if (self.fromStyle == StyleResultImg) {
        //赛果图片上传
        NSMutableArray *imgPathInfos = [NSMutableArray array];
        __block int times = 0;
        if (_imagePickView.photoMenuItems.count > 0) {
            ZHupdateImage *upload = [[ZHupdateImage alloc] init];
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [self showHudInView:self.view hint:@"图片上传中"];
            for (int i = 0; i < [_imagePickView.photoMenuItems count]; i ++) {
                UIImage *tempImg=nil;
                if ([[_imagePickView.photoMenuItems objectAtIndex:i] isKindOfClass:[UIImage class]]) {
                    tempImg=[_imagePickView.photoMenuItems objectAtIndex:i];
                }
                else{
                    ALAsset *asset=[_imagePickView.photoMenuItems objectAtIndex:i];
                    tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                }
                NSDictionary *dic = [LVTools getTokenApp];
                NSData *imageData=UIImageJPEGRepresentation(tempImg, kCompressqulitaty);
                if (imageData==nil) {
                    imageData=UIImagePNGRepresentation(tempImg);
                }
                [upload requestWithURL:imageupdata WithParams:@{@"param":dic,@"type":@"PLAY"} WithType:nil WithData:imageData With:^(id result) {
                    times ++;
                    NSLog(@"resutl                             ================= %@",result);
                    if ([[result objectForKey:@"statusCodeInfo"] isEqualToString:@"成功"])
                    {
                        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                        [dictionary setValue:[LVTools mToString:result[@"url"]] forKey:@"filenameExt"];
                        [dictionary setValue:@"" forKey:@"filename"];
                        [dictionary setValue:[LVTools mToString:result[@"path"]] forKey:@"path"];
                        [dictionary setValue:[LVTools mToString:result[@"url"]] forKey:@"url"];
                        [imgPathInfos addObject:dictionary];
                        NSLog(@"temptime == %d      i = %d",times,i);
                        if (times == _imagePickView.photoMenuItems.count) {
                            //此时隐藏圈圈
                            [self hideHud];
                            if (imgPathInfos.count == _imagePickView.photoMenuItems.count) {
                                NSDictionary *dic = [LVTools getTokenApp];
                                [dic setValue:self.idstring forKey:@"typeId"];
                                [dic setValue:@"PLAY_SHOW" forKey:@"type"];
                                [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"uid"];
                                [dic setValue:imgPathInfos forKey:@"pics"];
                                [DataService requestWeixinAPI:insertPlayShows parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
                                    NSLog(@"%@",result);
                                    if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
                                        self.navigationItem.rightBarButtonItem.enabled = YES;
                                        [self showHint:@"上传成功"];
                                        self.chuanBlock(result[@"playShowList"]);
                                        [self.navigationController popViewControllerAnimated:YES];
                                    }
                                }];
                            } else {
                                self.navigationItem.rightBarButtonItem.enabled = YES;
                                [self showHint:@"上传失败"];
                            }
                        }
                    }
                }];
            }
        } else {
            [self showHint:@"请选择图片上传"];
        }
    }
    else if (self.fromStyle == StyelResultTimeMachine){
        //发布时光机,时光机不能为空。
        
        NSMutableDictionary *dic = [LVTools getTokenApp];
        
        [dic setValue:[kUserDefault objectForKey:kUserId] forKey:@"uid"];
        [dic setValue:@"1" forKey:@"type"];
        [dic setValue:_comentView.text forKey:@"info"];

        if ([_imagePickView.photoMenuItems count] == 0) {
            //直接上传回复信息
            if (_comentView.text.length==0) {
                [self showHint:@"至少说点什么吧"];
                return;
            }
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [self commitMessageWithDic:dic];
        } else {
            //先上传图片
            NSMutableArray *imgPathInfos = [NSMutableArray array];
            __block int counttimes = 0;
            ZHupdateImage *upload = [[ZHupdateImage alloc] init];
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [self showHudInView:self.view hint:@"图片上传中"];
            for (int i = 0; i < [_imagePickView.photoMenuItems count]; i ++) {
                UIImage *tempImg=nil;
                if ([[_imagePickView.photoMenuItems objectAtIndex:i] isKindOfClass:[UIImage class]]) {
                   tempImg=[_imagePickView.photoMenuItems objectAtIndex:i];
                }
                else{
                    ALAsset *asset=[_imagePickView.photoMenuItems objectAtIndex:i];
                    tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                }
               
                NSDictionary *everydic = [LVTools getTokenApp];
                NSData *imageData=UIImageJPEGRepresentation(tempImg, kCompressqulitaty);
                if (imageData==nil) {
                    imageData=UIImagePNGRepresentation(tempImg);
                }
                [upload requestWithURL:imageupdata WithParams:@{@"param":everydic,@"type":@"TIMEMACHINE_SHOW"} WithType:nil WithData:imageData With:^(id result) {
                    counttimes ++;
                    NSLog(@"%@",result[@"message"]);
                    NSLog(@"%@",result[@"statusCodeInfo"]);
                    if ([[result objectForKey:@"statusCodeInfo"] isEqualToString:@"成功"])
                    {
                        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                        [dictionary setValue:[LVTools mToString:result[@"url"]] forKey:@"filenameExt"];
                        [dictionary setValue:@"" forKey:@"filename"];
                        [dictionary setValue:[LVTools mToString:result[@"path"]] forKey:@"path"];
                        [dictionary setValue:[LVTools mToString:result[@"url"]] forKey:@"url"];
                        [imgPathInfos addObject:dictionary];
                        NSLog(@"items == %@",_imagePickView.photoMenuItems);
                        NSLog(@"imgpathinfo ==== %@",imgPathInfos);
                        if (counttimes == _imagePickView.photoMenuItems.count) {
                            if (imgPathInfos.count == _imagePickView.photoMenuItems.count) {
                                _tempArray = [NSArray arrayWithArray:imgPathInfos];
                                NSDictionary *littledic = @{@"type":@"TIMEMACHINE_SHOW",@"pics":imgPathInfos,@"uid":[LVTools mToString:[kUserDefault objectForKey:kUserId]]};
                                [dic setValue:littledic forKey:@"file"];
                                [self commitMessageWithDic:dic];
                            } else {
                                [self hideHud];
                                [self showHint:@"上传失败"];
                                self.navigationItem.rightBarButtonItem.enabled = YES;
                            }
                        }
                    }
                }];
            }
        }
    } else if (self.fromStyle == StyleResultMatch) {
        //写评论发表
        if (_comentView.text.length == 0) {
            [self showHint:@"评论内容不能为空"];
            return;
        } else {
            NSMutableDictionary *dic = [LVTools getTokenApp];
            [dic setValue:self.idstring forKey:@"matchId"];
            [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"userId"];
            [dic setValue:@"2" forKey:@"type"];
            [dic setValue:@[] forKey:@"ids"];
            [dic setValue:_comentView.text forKey:@"message"];
            if ([_imagePickView.photoMenuItems count] == 0) {
                //直接上传回复信息
                self.navigationItem.rightBarButtonItem.enabled = NO;
                [self publishMatchComment:dic];
            } else {
                //先上传图片
                NSMutableArray *imgPathInfos = [NSMutableArray array];
                __block int counttimes = 0;
                ZHupdateImage *upload = [[ZHupdateImage alloc] init];
                self.navigationItem.rightBarButtonItem.enabled = NO;
                [self showHudInView:self.view hint:@"图片上传中"];
                for (int i = 0; i < [_imagePickView.photoMenuItems count]; i ++) {
                    UIImage *tempImg=nil;
                    if ([[_imagePickView.photoMenuItems objectAtIndex:i] isKindOfClass:[UIImage class]]) {
                        tempImg=[_imagePickView.photoMenuItems objectAtIndex:i];
                    }
                    else{
                        ALAsset *asset=[_imagePickView.photoMenuItems objectAtIndex:i];
                        tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                    }
                    NSDictionary *everydic = [LVTools getTokenApp];
                    NSData *imageData=UIImageJPEGRepresentation(tempImg, kCompressqulitaty);
                    if (imageData==nil) {
                        imageData=UIImagePNGRepresentation(tempImg);
                    }
                    [upload requestWithURL:imageupdata WithParams:@{@"param":everydic,@"type":@"MATCH_COMMENT_SHOW"} WithType:nil WithData:imageData With:^(id result) {
                        counttimes ++;
                        NSLog(@"%@",result);
                        if ([[result objectForKey:@"status"] boolValue])
                        {
                            [imgPathInfos addObject:result[@"data"][@"id"]];
                        if (counttimes == _imagePickView.photoMenuItems.count) {
                                if (imgPathInfos.count == _imagePickView.photoMenuItems.count) {
                                    [dic setValue:imgPathInfos forKey:@"ids"];
                                    [self publishMatchComment:dic];
                                } else {
                                    [self hideHud];
                                    [self showHint:@"上传失败"];
                                    self.navigationItem.rightBarButtonItem.enabled = YES;
                                }
                            }
                        }
                    }];
                }
            }
        }
    } else if (self.fromStyle == StyleResultTeam){
        [self updateTeamImg];
    } else if (self.fromStyle == StyelResultVenueComment) {
        //写评论发表
        if (_comentView.text.length == 0) {
            [self showHint:@"评论内容不能为空"];
            return;
        } else {
            NSMutableDictionary *dic = [LVTools getTokenApp];
            [dic setValue:self.idstring forKey:@"oid"];
            [dic setValue:[kUserDefault valueForKey:kUserId] forKey:@"uid"];
            [dic setValue:@"" forKey:@"type"];
            [dic setValue:_comentView.text forKey:@"content"];
            [dic setValue:[NSString stringWithFormat:@"%d",level] forKey:@"level"];
            [dic setValue:[kUserDefault valueForKey:kUserName] forKey:@"createuser"];
            if ([_imagePickView.photoMenuItems count] == 0) {
                //直接上传回复信息
                self.navigationItem.rightBarButtonItem.enabled = NO;
                [self publishVenueComment:dic];
            } else {
                //先上传图片
                NSMutableArray *imgPathInfos = [NSMutableArray array];
                self.navigationItem.rightBarButtonItem.enabled = NO;
                __block int counttimes = 0;
                ZHupdateImage *upload = [[ZHupdateImage alloc] init];
                [self showHudInView:self.view hint:@"图片上传中"];
                for (int i = 0; i < [_imagePickView.photoMenuItems count]; i ++) {
                    UIImage *tempImg=nil;
                    if ([[_imagePickView.photoMenuItems objectAtIndex:i] isKindOfClass:[UIImage class]]) {
                        tempImg=[_imagePickView.photoMenuItems objectAtIndex:i];
                    }
                    else{
                        ALAsset *asset=[_imagePickView.photoMenuItems objectAtIndex:i];
                        tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                    }
                    NSDictionary *everydic = [LVTools getTokenApp];
                    NSData *imageData=UIImageJPEGRepresentation(tempImg, kCompressqulitaty);
                    if (imageData==nil) {
                        imageData=UIImagePNGRepresentation(tempImg);
                    }
                    [upload requestWithURL:imageupdata WithParams:@{@"param":everydic,@"type":@"UPLOAD_TYPE_PERSONAL_LOGO"} WithType:nil WithData:imageData With:^(id result) {
                        counttimes ++;
                        NSLog(@"%@",result[@"message"]);
                        NSLog(@"%@",result[@"statusCodeInfo"]);
                        if ([[result objectForKey:@"statusCodeInfo"] isEqualToString:@"成功"])
                        {
                            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                            [dictionary setValue:[LVTools mToString:result[@"url"]] forKey:@"filenameExt"];
                            [dictionary setValue:@"" forKey:@"filename"];
                            [dictionary setValue:[LVTools mToString:result[@"path"]] forKey:@"path"];
                            [dictionary setValue:[LVTools mToString:result[@"url"]] forKey:@"url"];
                            [imgPathInfos addObject:dictionary];
                            NSLog(@"items == %@",_imagePickView.photoMenuItems);
                            NSLog(@"imgpathinfo ==== %@",imgPathInfos);
                            if (counttimes == _imagePickView.photoMenuItems.count) {
                                if (imgPathInfos.count == _imagePickView.photoMenuItems.count) {
                                    _tempArray = [NSArray arrayWithArray:imgPathInfos];
                                    NSDictionary *littledic = @{@"type":@"VENUES_COMMENT_SHOW",@"pics":imgPathInfos};
                                    [dic setValue:littledic forKey:@"file"];
                                    [self publishVenueComment:dic];
                                } else {
                                    [self hideHud];
                                    [self showHint:@"上传失败"];
                                    self.navigationItem.rightBarButtonItem.enabled = YES;
                                }
                            }
                        }
                    }];
                }
            }
        }
    }
}
- (void)creatUI{
    
    if (self.fromStyle == StyleResultComment) {
        [self.view addSubview:self.comentView];
        [self.view addSubview:[self imagePickView]];//这里用第三方的照片浏览器
    } else if (self.fromStyle == StyleResultImg||self.fromStyle == StyleResultTeam) {
        _imagePickView.frame = CGRectMake(0, mygap, UISCREENWIDTH, 114);
        [self.view addSubview:[self imagePickView]];
    } else if (self.fromStyle == StyleResultInfo) {
        [self.view addSubview:self.comentView];
    } else {
        [self.view addSubview:self.starView];
        [self.view addSubview:self.comentView];
        [self.view addSubview:[self imagePickView]];
    }
}
- (void)uploadResult
{
    [self.view endEditing:YES];
    if ([LVTools stringContainsEmoji:_comentView.text]) {
        [self showHint:@"后台暂不支持表情符号"];
        return;
    }
    NSMutableDictionary *dic = [LVTools getTokenApp];
    NSLog(@"%@",self.idstring);
    [dic setObject:self.idstring forKey:@"id"];
    [dic setObject:self.comentView.text forKey:@"results"];
    [self showHudInView:self.view hint:@"提交中"];
    [DataService requestWeixinAPI:updatePlayApply parsms:@{@"param":[LVTools configDicToDES:dic]} method:@"post" completion:^(id result) {
        [self hideHud];
        NSLog(@"--%@",result);
        if ([[LVTools mToString:result[@"statusCode"]] isEqualToString:@"success"]) {
            
            [self showHint:@"提交成功"];
            [self.delegate sendMsg:self.comentView.text];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self showHint:@"提交失败，请重试"];
        }
    }];
}

- (UITextView*)comentView{
    if (_comentView == nil) {
        _comentView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 100)];
        if (self.fromStyle == StyleResultInfo) {
            _comentView.frame = CGRectMake(10, 10, UISCREENWIDTH-20, 160);
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(10, _comentView.bottom+10, UISCREENWIDTH-20, 45);
            btn.layer.cornerRadius = 3;
            btn.layer.masksToBounds = YES;
            [btn setTitle:@"确定" forState:UIControlStateNormal];
            btn.backgroundColor = NavgationColor;
            [btn addTarget:self action:@selector(uploadResult) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:btn];
        }
        if (self.fromStyle == StyelResultVenueComment) {
            _comentView.frame = CGRectMake(0, _starView.bottom, UISCREENWIDTH, 120);
        }
        _comentView.font = Btn_font;
        _comentView.backgroundColor = [UIColor whiteColor];
        _comentView.returnKeyType = UIReturnKeyDone;
        _comentView.delegate = self;
        holderLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 200, 20)];
        holderLb.backgroundColor = [UIColor clearColor];
        holderLb.text = @"  说点什么吧...";
        holderLb.textColor = [UIColor lightGrayColor];
        [_comentView addSubview:holderLb];
        if (_str.length > 0) {
            _comentView.text = _str;
            holderLb.hidden = YES;
        }
    }
    return _comentView;
}

- (UIView *)starView {
    if (_starView == nil) {
        _starView = [[UIView alloc] initWithFrame:CGRectMake(-0.5, 0, UISCREENWIDTH+1, 90)];
        _starView.layer.borderWidth = 0.5;
        _starView.backgroundColor = [UIColor whiteColor];
        _starView.layer.borderColor = [lightColor CGColor];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 40, 20)];
        lab.text = @"总体";
        lab.font = [UIFont systemFontOfSize:18];
        lab.textColor = [UIColor blackColor];
        [_starView addSubview:lab];
        
        for (int i = 0; i < 5; i ++) {
            UIButton *starBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            starBtn.frame = CGRectMake(lab.right+10+35*i, 35, 25, 25);
            starBtn.tag = 450+i;
            [starBtn setBackgroundImage:[UIImage imageNamed:@"unstar"] forState:UIControlStateNormal];
            [starBtn addTarget:self action:@selector(starclick:) forControlEvents:UIControlEventTouchUpInside];
            [_starView addSubview:starBtn];
        }
    }
    return _starView;
}

- (void)starclick:(UIButton *)btn {
    level = (int)btn.tag-450+1;
    for (int i = 450; i <= btn.tag; i ++) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i];
        [btn setBackgroundImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
    }
    for (NSInteger i = btn.tag+1; i < 455; i ++) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i];
        [btn setBackgroundImage:[UIImage imageNamed:@"unstar"] forState:UIControlStateNormal];
    }
}

- (UIScrollView*)imgScrol{
    if (_imgScrol == nil) {
        _imgScrol = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _comentView.bottom, BOUNDS.size.width, 100)];
        _imgScrol.backgroundColor = [UIColor whiteColor];
        _imgScrol.layer.borderColor = BackGray_dan.CGColor;
        _imgScrol.layer.borderWidth = 0.5;
        _imgScrol.scrollEnabled = NO;
    }
    return _imgScrol;
}
- (MessagePhotoView*)imagePickView{
    if (_imagePickView == nil) {
        _imagePickView = [[MessagePhotoView alloc] initWithFrame:CGRectMake(0, _comentView.bottom, BOUNDS.size.width, 114) andCount:_count andStyle:self.fromStyle];
        _imagePickView.backgroundColor = [UIColor whiteColor];
        _imagePickView.delegate = self;
    }
    return _imagePickView;
}
#pragma mark MessagePhotoViewDelegate
//实现代理方法
-(void)addPicker:(UIImagePickerController *)picker{
    
    [self presentViewController:picker animated:YES completion:nil];
}
//以下为自己用系统的相册浏览器
#pragma mark UIactionsheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=2) {
        [self presentImagePickerControllerWithIndex:buttonIndex];
    }
}
#pragma mark [选择图片]
-(void)presentImagePickerControllerWithIndex:(NSInteger)index
{
    UIImagePickerControllerSourceType sourceType;
    if (index==0) {
        sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else
    {
        sourceType =UIImagePickerControllerSourceTypeCamera;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *pickerController=[[UIImagePickerController alloc]init];
        pickerController.delegate=self;
        pickerController.sourceType=sourceType;
        pickerController.allowsEditing=YES;
        [self presentViewController:pickerController animated:YES completion:nil];
    }
    
}

#pragma mark-UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    CGSize imageSize=image.size;
    imageSize.height=150;
    imageSize.width=150;
    [imgArray insertObject:image atIndex:0];
    [self setImageArray];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([@"\n" isEqualToString:text] == YES) {
        [textView resignFirstResponder];
        
        return NO;
    }
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (textView.text.length == 0) {
        holderLb.hidden = YES;
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length == 0) {
        holderLb.hidden = NO;
    }
}

-(void)addUIImagePicker:(UIImagePickerController *)picker {
    //todo
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
