//
//  UpLoadServiceEvidenceViewController.m
//  XunChangApp
//
//  Created by MrZhang on 16/5/18.
//  Copyright © 2016年 zhangyong. All rights reserved.
//

#import "UpLoadServiceEvidenceViewController.h"
#import "UIPlaceHolderTextView.h"
#import "LoginModel.h"
#import "ImageObjectModel.h"
#import "ShenBaoLeiXingCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ITTAdditions.h"
@interface UpLoadServiceEvidenceViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    NSMutableArray *imageDataArray;
  UIImagePickerController *imagePicker;
}

@property (weak, nonatomic) IBOutlet UIView *textViewBackView;
@property (strong, nonatomic) UIPlaceHolderTextView *placeHolderView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *submitButt;

@end

@implementation UpLoadServiceEvidenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"完成服务凭证";
    [self createNavBackButt];
    self.submitButt.layer.cornerRadius=4.0f;
    self.tableView.tableFooterView=[UIView new];
    
    _placeHolderView=[[UIPlaceHolderTextView alloc]initWithFrame:CGRectMake(10, 37, SCREEN_WIDTH-20, 137) andPlaceholder:@"请输入说明" andLayerRadius:3.0f andBorderColor:[UIColor whiteColor] andBorderWidth:1.0f];
    [self.textViewBackView addSubview:_placeHolderView];
    
    //初始化imageDataArray
    imageDataArray=[NSMutableArray arrayWithCapacity:12];
}
- (IBAction)tapResignKeyBoard:(id)sender {
    [self.placeHolderView resignFirstResponder];
}

- (IBAction)takePhotoButtAction:(UIButton *)sender {
    
         imagePicker=[[UIImagePickerController alloc]init];
         imagePicker.delegate=self;
    if (IOS8_OR_LATER) {
        UIAlertController *actionView=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
       [actionView addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
           imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
           imagePicker.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
           [self presentViewController:imagePicker animated:YES completion:nil];
        }]];
        [actionView addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            imagePicker.allowsEditing=YES;
            imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
            [self presentViewController:imagePicker animated:YES completion:nil];
        }]];
        [actionView addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:actionView animated:YES completion:nil];
    }else
    {
        UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:@"拍照" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册", nil];
        [actionSheet showInView:self.view];
    }
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        NSString *fileName=[NSString stringWithFormat:@"%@.png",[[NSDate date] stringWithFormat:@"yyyy-MM-dd_HHmmss"]];
        [SVProgressHUD showWithStatus:@"正在上传数据..." maskType:SVProgressHUDMaskTypeBlack];
       [ShenBaoDataRequest requestUpLoadImageData:[info objectForKey:@"UIImagePickerControllerOriginalImage"] fileName:fileName successCallBackBlock:^(id result) {
            [SVProgressHUD dismiss];
           ImageObjectModel *imageModel=[ImageObjectModel yy_modelWithDictionary:result];
           if (imageModel.code==0) {
               imageModel.originalImage=[[UIImage alloc]initWithData:UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"], 0.4)];
               imageModel.editImage=[[info objectForKey:@"UIImagePickerControllerEditedImage"] imageScaleToFillInSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT/2)];
               ITTDINFO(@"imageModel.originalImageSize====%d",UIImageJPEGRepresentation(imageModel.originalImage, 1).length/1024);
               ITTDINFO(@"imageModel.edittingImageSize====%d",UIImageJPEGRepresentation(imageModel.editImage, 1).length/1024);
               imageModel.originalImageName=[NSString stringWithFormat:@"%@_original",[[NSDate date] stringWithFormat:@"yyyy-MM-dd_HHmmss"]];
               imageModel.editImageName=[NSString stringWithFormat:@"%@",[[NSDate date] stringWithFormat:@"yyyy-MM-dd_HHmmss"]];
               imageModel.data.source.size=[self bytesToMBOrKB:imageModel.data.source.size];
               [imageDataArray addObject:imageModel];//将上传成功的图片模型加入数组
               [self.tableView reloadData];
           }else if (imageModel.code==9999)
           {
               [SVProgressHUD  showErrorWithStatus:imageModel.message maskType:SVProgressHUDMaskTypeBlack];
           }else if(imageModel.code==1001)
           {
               [USER_DEFAULT removeObjectForKey:@"user_token"];
               [self.navigationController popToRootViewControllerAnimated:YES];
           }
       } errorBlock:^(NSError *error) {
           [SVProgressHUD setErrorImage:[UIImage imageNamed:@"icon_cry"]];
           [SVProgressHUD  showErrorWithStatus:@"网络请求错误了..." maskType:SVProgressHUDMaskTypeBlack];
       } noNetworkingBlock:^(NSString *noNetWorking) {
           [SVProgressHUD setErrorImage:[UIImage imageNamed:@"icon_cry"]];
           [SVProgressHUD  showErrorWithStatus:@"没网了..." maskType:SVProgressHUDMaskTypeBlack];
       }];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return imageDataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShenBaoLeiXingCell *uploadImageCell=[tableView dequeueReusableCellWithIdentifier:@"UploadServiceEvidenceCell"];
    ImageObjectModel *tempModel=[imageDataArray objectAtIndex:indexPath.row];
    [uploadImageCell.uploadServiceImageView sd_setImageWithURL:[NSURL URLWithString:tempModel.data.url] placeholderImage:[UIImage imageNamed:@"icon_cpmrt"] options:SDWebImageProgressiveDownload];
    uploadImageCell.uploadServiceNameLabel.text=tempModel.data.source.name;
    uploadImageCell.uploadServiceTimeLabel.text=[tempModel.originalImageName substringToIndex:16];
    uploadImageCell.uploadServiceSizeLabel.text=tempModel.data.source.size;
    return uploadImageCell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageObjectModel *tempModel=[imageDataArray objectAtIndex:indexPath.row];
    [self deleteImageWithPicName:tempModel.data.savename andIndexPath:indexPath];
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
}
-(void)deleteImageWithPicName:(NSString*)picName andIndexPath:(NSIndexPath*)indexPath
{
    NSMutableDictionary *paramsDic=[NSMutableDictionary dictionaryWithObjectsAndKeys:picName,@"savename", nil];
    [SVProgressHUD showWithStatus:@"正在上传数据..." maskType:SVProgressHUDMaskTypeBlack];
    [ShenBaoDataRequest requestAFWithURL:DELETEPIC params:paramsDic httpMethod:@"POST" block:^(id result) {
        NSLog(@"result====%@",result);
        [SVProgressHUD dismiss];
        LoginModel *model=[LoginModel yy_modelWithDictionary:result];
        if (model.code==0) {
            [SVProgressHUD  showSuccessWithStatus:@"删除成功" maskType:SVProgressHUDMaskTypeBlack];
             [imageDataArray removeObjectAtIndex:indexPath.row];
             [self.tableView reloadData];
        }else
        {
            [SVProgressHUD showErrorWithStatus:model.message maskType:SVProgressHUDMaskTypeClear];
        }
    } errorBlock:^(NSError *error) {
        [SVProgressHUD setErrorImage:[UIImage imageNamed:@"icon_cry"]];
        [SVProgressHUD  showErrorWithStatus:@"网络请求错误了..." maskType:SVProgressHUDMaskTypeBlack];
    } noNetWorking:^(NSString *noNetWorking) {
        [SVProgressHUD setErrorImage:[UIImage imageNamed:@"icon_cry"]];
        [SVProgressHUD  showErrorWithStatus:@"没网了..." maskType:SVProgressHUDMaskTypeBlack];
    }];

}
- (IBAction)submittEvidenceButtAction:(UIButton *)sender {
    //图片字符串哈
    NSString *picString=[self convertArrayToJsonString:imageDataArray];
    
    if ([imageDataArray count]==0&&([self.placeHolderView.text isEqualToString:@""]||self.placeHolderView.text==nil)) {
        [SVProgressHUD showErrorWithStatus:@"请输入文字或选择图片" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    //参数字典
    NSMutableDictionary *paramsDic=[NSMutableDictionary dictionaryWithObjectsAndKeys:self.placeHolderView.text,@"service_message",self.orderNum,@"order_num",picString,@"service_file", nil];
     [SVProgressHUD showWithStatus:@"正在上传数据..." maskType:SVProgressHUDMaskTypeBlack];
    [ShenBaoDataRequest requestAFWithURL:ORDERFINISH params:paramsDic httpMethod:@"POST" block:^(id result) {
        NSLog(@"result====%@",result);
        [SVProgressHUD dismiss];
        LoginModel *model=[LoginModel yy_modelWithDictionary:result];
        if (model.code==0) {
            [SVProgressHUD  showSuccessWithStatus:@"上传成功" maskType:SVProgressHUDMaskTypeBlack];
            [self backToFrontViewController];
        }else
        {
            [SVProgressHUD showErrorWithStatus:model.message maskType:SVProgressHUDMaskTypeClear];
        }
    } errorBlock:^(NSError *error) {
        [SVProgressHUD setErrorImage:[UIImage imageNamed:@"icon_cry"]];
        [SVProgressHUD  showErrorWithStatus:@"网络请求错误了..." maskType:SVProgressHUDMaskTypeBlack];
    } noNetWorking:^(NSString *noNetWorking) {
        [SVProgressHUD setErrorImage:[UIImage imageNamed:@"icon_cry"]];
        [SVProgressHUD  showErrorWithStatus:@"没网了..." maskType:SVProgressHUDMaskTypeBlack];
    }];
}
-(NSString*)convertArrayToJsonString:(NSArray*)imageArray
{
    NSMutableArray *tempArray=[NSMutableArray arrayWithCapacity:12];
    NSMutableDictionary *tempDic=[NSMutableDictionary dictionary];
    [imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ImageObjectModel *tempImageModel=(ImageObjectModel*)obj;
        [tempDic setObject:tempImageModel.data.savename forKey:@"filename"];
        [tempDic setObject:tempImageModel.data.url forKey:@"url"];
        [tempDic setObject:tempImageModel.editImageName forKey:@"create_time"];
        [tempDic setObject:tempImageModel.data.source.size forKey:@"size"];
        [tempArray addObject:tempDic];
    }];
    NSString *jsonString=[tempArray yy_modelToJSONString];
    return jsonString;
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
         [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }else if (buttonIndex==1)
    {
        imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    
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
