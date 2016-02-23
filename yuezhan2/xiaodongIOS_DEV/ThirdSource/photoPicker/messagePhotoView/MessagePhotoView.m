//
//  ZBShareMenuView.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-13.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "MessagePhotoView.h"
#import "ZYQAssetPickerController.h"
// 每行有4个
#define kZBMessageShareMenuPerRowItemCount 4
#define kZBMessageShareMenuPerColum 2

#define kZBShareMenuItemIconSize 60
#define KZBShareMenuItemHeight 80

#define ItemWidth 94
#define ItemHeight 94


@interface MessagePhotoView (){
    UILabel *lblNum;
}


/**
 *  这是背景滚动视图
 */

//@property (nonatomic, weak) UIScrollView *shareMenuScrollView;
//@property (nonatomic, weak) UIPageControl *shareMenuPageControl;
//@property(nonatomic,weak)UIButton *btnviewphoto;
@end

@implementation MessagePhotoView
//@synthesize photoMenuItems;
- (void)setlblNumHidden:(BOOL)hidden{
    lblNum.hidden = hidden;
}
- (id)initWithFrame:(CGRect)frame andCount:(NSInteger)count andStyle:(CommentFromStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        self.maxImgCount = count;
        self.fromstyle = style;
        [self setup];
    }
    return self;
}
- (void)setup{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(BOUNDS.size.width*0.1, 0, BOUNDS.size.width*0.9, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    
    self.photoScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, BOUNDS.size.width, 124)];
    self.photoScrollView.contentSize = CGSizeMake(1024, 124);
    self.photoScrollView.backgroundColor = [UIColor clearColor];
    self.photoScrollView.delegate = self;
    [self.photoScrollView addSubview:line];
    

    [self addSubview:self.photoScrollView];
    lblNum = [[UILabel alloc]initWithFrame:CGRectMake(50, self.photoScrollView.bottom, 230, 30)];
//    lblNum = [[UILabel alloc]initWithFrame:CGRectMake(50, 100, 230, 30)];
    lblNum.backgroundColor = [UIColor redColor];
    lblNum.textColor = [UIColor lightGrayColor];
    [self addSubview:lblNum];
    self.itemArray = [[NSMutableArray alloc]init];
    self.photoMenuItems = [[NSMutableArray alloc]init];
    [self initlizerScrollView:self.photoMenuItems];

}

-(void)reloadDataWithImage:(UIImage *)image{
    [self.photoMenuItems addObject:image];
    
    [self initlizerScrollView:self.photoMenuItems];
}

-(void)initlizerScrollView:(NSArray *)imgList{
    [self.photoScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSLog(@"imgList  =====  %@",imgList);
    ALAsset *asset = nil;
    UIImage *tempImg = nil;
    for(int i=0;i<imgList.count;i++){
        if ([imgList[i] isKindOfClass:[UIImage class]]) {
            tempImg = (UIImage *)imgList[i];
        } else {
            asset=imgList[i];
            tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        }
        
        
        
      //  UIImage *image = [imgList objectAtIndex:i];
        
        
        MessagePhotoMenuItem *photoItem = [[MessagePhotoMenuItem alloc]init];
        photoItem.backgroundColor = [UIColor redColor];
        if (self.fromstyle == StyleResultComment || self.fromstyle == StyelResultVenueComment) {
            photoItem.frame = CGRectMake(10+ i * (ItemWidth + 5 ), 0, ItemWidth, ItemHeight);
        } else {
            if (UISCREENWIDTH == 320) {
                photoItem.frame = CGRectMake(64*i+2, 20, 60, 60);
            } else if (UISCREENWIDTH == 375) {
                photoItem.frame = CGRectMake(80*i+2, 15, 70, 70);
            } else {
                photoItem.frame = CGRectMake(2+83*i, 8, 80, 80);
            }
        }
        
        photoItem.delegate = self;
        photoItem.index = i;
        photoItem.contentImage = tempImg;
        [self.photoScrollView addSubview:photoItem];
        [self.itemArray addObject:photoItem];
    }
    
    if(imgList.count<self.maxImgCount){
        UIButton *btnphoto=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnphoto setFrame:CGRectMake(20 + (ItemWidth + 5) * imgList.count, 0, 94, 94)];//
        if (self.fromstyle == StyleResultComment || self.fromstyle == StyelResultVenueComment) {
            [btnphoto setFrame:CGRectMake(20 + (ItemWidth + 5) * imgList.count, 0, 94, 94)];//
        } else {
            if (UISCREENWIDTH == 320) {
                btnphoto.frame = CGRectMake(64*(imgList.count)+2, 20, 60, 60);
            } else if (UISCREENWIDTH == 375) {
                btnphoto.frame = CGRectMake(80*(imgList.count)+2, 15, 70, 70);
            } else {
                btnphoto.frame = CGRectMake(2+83*imgList.count, 8, 80, 80);
            }
        }
        [btnphoto setImage:[UIImage imageNamed:@"addImg"] forState:UIControlStateNormal];
        [btnphoto setImage:[UIImage imageNamed:@"addImg"] forState:UIControlStateSelected];
        //给添加按钮加点击事件
        [btnphoto addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
        [self.photoScrollView addSubview:btnphoto];
    }
    
    NSInteger count = MIN(imgList.count +1, self.maxImgCount);
     lblNum.text = [NSString stringWithFormat:@"已选%lu张，共可选%d张",(unsigned long)self.photoMenuItems.count,(int)self.maxImgCount];
    lblNum.backgroundColor = [UIColor clearColor];
    [self.photoScrollView setContentSize:CGSizeMake(20 + (ItemWidth + 5)*count, 0)];
}
-(void)openMenu{
    //在这里呼出下方菜单按钮项
    myActionSheet = [[UIActionSheet alloc]
                     initWithTitle:nil
                     delegate:self
                     cancelButtonTitle:@"取消"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"打开照相机",@"从手机相册获取", nil];
    //刚才少写了这一句
    [myActionSheet showInView:self.window];
    [self.window endEditing:YES];
    
}
//下拉菜单的点击响应事件
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == myActionSheet.cancelButtonIndex){
        NSLog(@"取消");
    }
    switch (buttonIndex) {
        case 0:
            [self takePhoto];
            break;
        case 1:
            [self localPhoto];
            break;
        default:
            break;
    }
}

//开始拍照
-(void)takePhoto{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self.delegate addUIImagePicker:picker];
    
        
    }else{
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

/*
    新加的另外的方法
 */
////////////////////////////////////////////////////////////
//打开相册，可以多选
-(void)localPhoto{
    ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc]init];
    //设置最大可选照片
    
    picker.maximumNumberOfSelection = _maxImgCount;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showEmptyGroups = NO;
    picker.delegate = self;
    picker.maximumNumberOfSelection = self.maxImgCount;
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject,NSDictionary *bindings){
        if ([[(ALAsset *)evaluatedObject valueForProperty:ALAssetPropertyType]isEqual:ALAssetTypeVideo]) {
            NSTimeInterval duration = [[(ALAsset *)evaluatedObject valueForProperty:ALAssetPropertyDuration]doubleValue];
            return duration >= 5;
        }else{
            return  YES;
        }
    }];
    
    [self.delegate addPicker:picker];
}

#pragma  mark   -ZYQAssetPickerController Delegate

/*
 得到选中的图片
 */
#pragma mark - ZYQAssetPickerController Delegate

-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    
    [self.scrollview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
   
   // NSLog(@"self.itemArray is %@",self.photoMenuItems);
        NSLog(@"assets is %@",assets);
        //跳转到显示大图的页面
        ShowBigViewController *big = [[ShowBigViewController alloc]init];
      
        big.arrayOK = [NSMutableArray arrayWithArray:assets];
    
    self.photoMenuItems = [NSMutableArray arrayWithArray:assets];
    [self initlizerScrollView:self.photoMenuItems];
        NSLog(@"arraryOk is %lu",(unsigned long)big.arrayOK.count);
        [picker pushViewController:big animated:YES];
  
}
/////////////////////////////////////////////////////////





//选择某张照片之后
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //关闭相册界面
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if([type isEqualToString:@"public.image"]){
        //先把图片转成NSData
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        [self reloadDataWithImage:image];
        
        NSData *datas;
        if(UIImagePNGRepresentation(image)==nil){
            datas = UIImageJPEGRepresentation(image, kCompressqulitaty);
        }else{
            datas = UIImagePNGRepresentation(image);
        }
        
        //图片保存的路径
        //这里将图片放在沙盒的documents文件夹中
        NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        //文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //把刚才图片转换的data对象拷贝至沙盒中,并保存为image.png
        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image.png"] contents:datas attributes:nil];
        //得到选择后沙盒中图片的完整路径
        filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,@"/image.png"];
        
        //创建一个选择后图片的图片放在scrollview中
        
        //加载scrollview中
        
    }
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)reloadData {
    
}
- (void)dealloc {
    //self.shareMenuItems = nil;
    self.photoScrollView.delegate = nil;
    
    
    
    
    
    
//    self.shareMenuScrollView.delegate = self;
//    self.shareMenuScrollView = nil;
//    self.shareMenuPageControl = nil;
}

#pragma mark - MessagePhotoItemDelegate

-(void)messagePhotoItemView:(MessagePhotoMenuItem *)messagePhotoItemView didSelectDeleteButtonAtIndex:(NSInteger)index{
    [self.photoMenuItems removeObjectAtIndex:index];
    [self initlizerScrollView:self.photoMenuItems];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //每页宽度
    //CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
  //  NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
//    [self.shareMenuPageControl setCurrentPage:currentPage];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
