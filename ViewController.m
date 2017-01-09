//
//  ViewController.m
//  PhotoKit
//
//  Created by 周建波 on 2016/12/26.
//  Copyright © 2016年 周建波. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>

@interface ViewController ()
{
    
    NSMutableArray*assetDate;
}
@property (weak, nonatomic) IBOutlet UIImageView *SlectedImage;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    assetDate = [[NSMutableArray alloc]init];
    [self getAllPhotos];
    
}

-(void)getAllPhotos{
    /*
     typedef NS_ENUM(NSInteger, ALAuthorizationStatus) {
     PHAuthorizationStatusNotDetermined = 0, 用户尚未做出了选择这个应用程序的问候
     PHAuthorizationStatusRestricted, 此应用程序没有被授权访问的照片数据。可能是家长控制权限。
     PHAuthorizationStatusDenied, 用户已经明确否认了这一照片数据的应用程序访问.
     PHAuthorizationStatusAuthorized 用户已授权应用访问照片数据.
     }
     */

    PHAuthorizationStatus photosAuthStatus = [PHPhotoLibrary authorizationStatus];
    
    if(photosAuthStatus == PHAuthorizationStatusRestricted || photosAuthStatus == PHAuthorizationStatusDenied){
        
        NSString *errorStr = @"应用相册权限受限,请在设置中启用";
        
        UIAlertController*alter = [UIAlertController alertControllerWithTitle:@"提示" message:errorStr preferredStyle:UIAlertControllerStyleAlert];
        
        [alter addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            
        }]];

        [self presentViewController:alter animated:YES completion:nil];
        return;
    }
    
    PHFetchOptions * options = [[PHFetchOptions alloc]init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    // 多媒体类型的渭词
    NSPredicate * media = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    // 查询1小时之内的
    NSDate *date = [NSDate date];
    NSDate*lastDate = [date initWithTimeIntervalSinceNow:-3600];
    NSPredicate *predicateDate = [NSPredicate predicateWithFormat:@"creationDate >= %@", lastDate];
    //
    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[media, predicateDate]];
    //
    options.predicate = compoundPredicate;
    PHFetchResult * result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    
    if (result.count==0) {
        NSLog(@"没有查询到数据");
    }else{
        NSLog(@"一个小时以内的图片一共%ld张",result.count);
        PHAsset * asset = [result lastObject];
        [self getImageWithAsset:asset withBlock:^(UIImage *image) {
            self.SlectedImage.image = image;
        }];
    }
    
}


//获取image
- (void)getImageWithAsset:(PHAsset *)asset withBlock:(void(^)(UIImage*image))block{
    
    //通过asset资源获取图片
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        block(result);
    }];
    
}
@end
