//
//  ImagePickerViewController.m
//  Locshare
//
//  Created by Felianne Teng on 7/26/21.
//

#import "ImagePickerViewController.h"
#import "ImagePickerCell.h"
#import <Photos/Photos.h>

@interface ImagePickerViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *libraryCollectionView;

@property (strong, nonatomic) PHFetchResult *photosToDisplay;
@property (strong, nonatomic) NSMutableArray *selectedPhotos;

@end

@implementation ImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.libraryCollectionView.delegate = self;
    self.libraryCollectionView.dataSource = self;
    self.libraryCollectionView.allowsMultipleSelection = true;
    [self setCollectionViewLayout];
    
    // Check if app has authorization to access photos, and request authorization if it does not
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
            // Order retrieved photos by date of creation
            PHFetchOptions *options = [PHFetchOptions new];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:true]];
            
            // Fetch photos from photo library
            self.photosToDisplay = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
            [self.libraryCollectionView reloadData];
        }];
    }
    else {
        // Order retrieved photos by date of creation
        PHFetchOptions *options = [PHFetchOptions new];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:true]];
        
        // Fetch photos from photo library
        self.photosToDisplay = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
        [self.libraryCollectionView reloadData];
    }
}

- (void)setCollectionViewLayout {
    // Set layout settings for the collectionView
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.libraryCollectionView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    
    // size of photos depends on device size
    CGFloat photosPerLine = 5;
    CGFloat itemWidth = (self.libraryCollectionView.frame.size.width - layout.minimumInteritemSpacing * (photosPerLine - 1)) / photosPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photosToDisplay count];
}

- (IBAction)onNextTap:(id)sender {
}

- (IBAction)onCancelTap:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImagePickerCell *cell = [self.libraryCollectionView dequeueReusableCellWithReuseIdentifier:@"ImagePickerCell" forIndexPath:indexPath];
    
    // Get indicated PHAsset from array of assets and display its image in the image view
    PHAsset *toDisplay = self.photosToDisplay[indexPath.item];
    [[PHImageManager defaultManager] requestImageForAsset:toDisplay targetSize:CGSizeMake(128, 128) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.imageView.image = result;
    }];
    
    return cell;
}

@end
