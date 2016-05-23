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
@interface UpLoadServiceEvidenceViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *imageDataArray;
}
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *placeHolderView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation UpLoadServiceEvidenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"完成服务凭证";
    [self createNavBackButt];
    self.tableView.tableFooterView=[UIView new];
    //初始化imageDataArray
    imageDataArray=[NSMutableArray arrayWithCapacity:12];
}
- (IBAction)tapResignKeyBoard:(id)sender {
    [self.placeHolderView resignFirstResponder];
}

- (IBAction)takePhotoButtAction:(UIButton *)sender {
    UIImagePickerController *imagePicker=[[UIImagePickerController alloc]init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
    }
    imagePicker.delegate=self;
    imagePicker.allowsEditing=YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        NSString *fileName=[NSString stringWithFormat:@"%@_original",[[NSDate date] stringWithFormat:@"yyyy-MM-dd_HHmmss"]];
        [SVProgressHUD showWithStatus:@"正在上传数据..." maskType:SVProgressHUDMaskTypeBlack];
       [ShenBaoDataRequest requestUpLoadImageData:[info objectForKey:@"UIImagePickerControllerOriginalImage"] fileName:fileName successCallBackBlock:^(id result) {
            [SVProgressHUD dismiss];
           ImageObjectModel *imageModel=[ImageObjectModel yy_modelWithDictionary:result];
           if (imageModel.code==0) {
               imageModel.originalImage=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
               imageModel.editImage=[info objectForKey:@"UIImagePickerControllerEditedImage"];
               imageModel.originalImageName=[NSString stringWithFormat:@"%@_original",[[NSDate date] stringWithFormat:@"yyyy-MM-dd_HHmmss"]];
               imageModel.editImageName=[NSString stringWithFormat:@"%@_editing",[[NSDate date] stringWithFormat:@"yyyy-MM-dd_HHmmss"]];
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
    [uploadImageCell.uploadServiceImageView sd_setImageWithURL:[NSURL URLWithString:tempModel.data.url] placeholderImage:[UIImage imageNamed:@"icon_"] options:SDWebImageProgressiveDownload];
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
    [imageDataArray removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (IBAction)submittEvidenceButtAction:(UIButton *)sender {
  
    //图片字符串哈
    NSMutableString *imageString=[NSMutableString string];
    [imageDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ImageObjectModel *tempImageModel=(ImageObjectModel*)obj;
        [imageString stringByAppendingFormat:@"%@,",tempImageModel.data.savename ];
    }];
    [imageString substringToIndex:imageString.length-2];
    //参数字典
    NSMutableDictionary *paramsDic=[NSMutableDictionary dictionaryWithObjectsAndKeys:self.placeHolderView.text,@"service_message",self.orderNum,@"order_num",imageString,@"service_pic", nil];
     [SVProgressHUD showWithStatus:@"正在上传数据..." maskType:SVProgressHUDMaskTypeBlack];
    [ShenBaoDataRequest requestAFWithURL:@"api/xcapply_mock/orderFinish" params:paramsDic httpMethod:@"POST" block:^(id result) {
        NSLog(@"result====%@",result);
        [SVProgressHUD dismiss];
        LoginModel *model=[LoginModel yy_modelWithDictionary:result];
        if (model.code==0) {
            [SVProgressHUD  showSuccessWithStatus:@"上传成功" maskType:SVProgressHUDMaskTypeBlack];
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
