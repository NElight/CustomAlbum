//
//  ViewController.m
//  CustomAlbum
//
//  Created by Yioks-Mac on 17/3/9.
//  Copyright © 2017年 Yioks-Mac. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "PhotoScanViewController.h"

@interface ViewController ()<PHPhotoLibraryChangeObserver, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) PHFetchResult<PHAsset *> * allPhotos;
@property (nonatomic, strong) PHFetchResult<PHAssetCollection*> * smartAlbums;
@property (nonatomic, strong) PHFetchResult<PHCollection*> * userCollections;
@property (nonatomic, strong) NSArray *sectionLocalizedTitles;

@property (nonatomic, strong) UITableView *tableView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.sectionLocalizedTitles = @[@"all", @"smart albums", @"albums"];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAlbum)];
    self.navigationItem.rightBarButtonItem = item;
    
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc]init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    self.allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    self.smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    self.userCollections = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:nil];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 0) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    
}



- (void)addAlbum {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Album" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Album Name";
    }];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *tf = alert.textFields.firstObject;
        if (tf.text.length > 0) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:tf.text];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (!success) {
                    NSLog(@"--------%@",error);
                }
            }];
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:confirm];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else if (section == 1) {
        return self.smartAlbums.count;
    }else {
        return self.userCollections.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.text = @"all photos";
        return cell;
    }else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.text = self.smartAlbums[indexPath.row].localizedTitle;
        return cell;
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.text = self.userCollections[indexPath.row].localizedTitle;
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"全部";
    }else if (section == 1) {
        return @"smart album";
    }else {
        return @"user album";
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoScanViewController *vc = [[PhotoScanViewController alloc]init];
    PHFetchResult *rel = nil;
    if (indexPath.section == 0) {
        rel = self.allPhotos;
    }else if (indexPath.section == 1) {
        vc.assetCollection = self.smartAlbums[indexPath.row];
        rel = self.smartAlbums;
    }else {
        vc.assetCollection = self.userCollections[indexPath.row];
        rel = self.userCollections;
    }
    
    vc.fetchResult = rel;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_sync(dispatch_get_main_queue(), ^{
        PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:self.allPhotos];
        if (changeDetails) {
            self.allPhotos = changeDetails.fetchResultAfterChanges;
        }
        
        changeDetails = [changeInstance changeDetailsForFetchResult:self.smartAlbums];
        if (changeDetails) {
            self.smartAlbums = changeDetails.fetchResultAfterChanges;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
        changeDetails = [changeInstance changeDetailsForFetchResult:self.userCollections];
        if (changeDetails) {
            self.userCollections = [changeDetails fetchResultAfterChanges];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
