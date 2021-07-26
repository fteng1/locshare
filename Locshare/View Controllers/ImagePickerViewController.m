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

@property (strong, nonatomic) NSArray *photosToDisplay;
@property (strong, nonatomic) NSMutableArray *selectedPhotos;

@end

@implementation ImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.libraryCollectionView.delegate = self;
    self.libraryCollectionView.dataSource = self;
    
    [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {}];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photosToDisplay count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImagePickerCell *cell = [self.libraryCollectionView dequeueReusableCellWithReuseIdentifier:@"ImagePickerCell" forIndexPath:indexPath];
    
    
    return cell;
}

@end
