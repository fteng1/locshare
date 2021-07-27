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
    self.selectedPhotos = [NSMutableArray new];
    
    // Check if app has authorization to access photos, and request authorization if it does not
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
            [self fetchPhotos];
        }];
    }
    else {
        [self fetchPhotos];
    }
}

- (void)fetchPhotos {
    // Order retrieved photos by date of creation
    PHFetchOptions *options = [PHFetchOptions new];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:true]];
    
    // Fetch photos from photo library
    self.photosToDisplay = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    [self.libraryCollectionView reloadData];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.selectedPhotos addObject: [NSNumber numberWithLong: indexPath.item]];
    ImagePickerCell *cell = (ImagePickerCell *) [collectionView cellForItemAtIndexPath:indexPath];
    cell.selectedView.hidden = false;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.selectedPhotos removeObject: [NSNumber numberWithLong: indexPath.item]];
    ImagePickerCell *cell = (ImagePickerCell *) [collectionView cellForItemAtIndexPath:indexPath];
    cell.selectedView.hidden = true;
}

- (IBAction)onNextTap:(id)sender {
    NSMutableArray *imagesToReturn = [NSMutableArray new];
    // Get larger version of each selected image
    for (NSNumber *num in self.selectedPhotos) {
        [[PHImageManager defaultManager] requestImageForAsset:self.photosToDisplay[[num intValue]] targetSize:CGSizeMake(400, 300) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [imagesToReturn addObject:result];
            
            // Check if this is the final image to load
            if ([imagesToReturn count] == [self.selectedPhotos count]) {
                [self.delegate didFinishPicking:imagesToReturn];
                [self dismissViewControllerAnimated:true completion:nil];
            }
        }];
    }

}

- (IBAction)onCancelTap:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImagePickerCell *cell = [self.libraryCollectionView dequeueReusableCellWithReuseIdentifier:@"ImagePickerCell" forIndexPath:indexPath];
    
    // Get indicated PHAsset from array of assets and display its thumbnail in the image view
    PHAsset *toDisplay = self.photosToDisplay[indexPath.item];
    [[PHImageManager defaultManager] requestImageForAsset:toDisplay targetSize:CGSizeMake(128, 128) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.imageView.image = result;
    }];
    
    return cell;
}

@end