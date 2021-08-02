//
//  ImagePickerViewController.m
//  Locshare
//
//  Created by Felianne Teng on 7/26/21.
//

#import "ImagePickerViewController.h"
#import "ImagePickerCell.h"
#import <Photos/Photos.h>
#import "AlertManager.h"

@interface ImagePickerViewController () <UICollectionViewDelegate, UICollectionViewDataSource, AVCapturePhotoCaptureDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *libraryCollectionView;
@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (strong, nonatomic) PHFetchResult *photosToDisplay;
@property (strong, nonatomic) NSMutableArray *selectedPhotos;
@property (strong, nonatomic) NSMutableArray *photosFromCamera;
@property (strong, nonatomic) AVCapturePhotoOutput *photoOutput;
@property (weak, nonatomic) IBOutlet UIView *blackScreen;

@end

@implementation ImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set delegates and initialize variables
    self.libraryCollectionView.delegate = self;
    self.libraryCollectionView.dataSource = self;
    self.libraryCollectionView.allowsMultipleSelection = true;
    [self setCollectionViewLayout];
    self.selectedPhotos = [NSMutableArray new];
    self.photosFromCamera = [NSMutableArray new];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.useCamera) {
        // Select photos from photo library
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
    else {
        // Select photos from camera
        // Check if app has authorization to use camera, and request authorization if it does not
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                [self takePhotos];
            }];
        }
        else {
            [self takePhotos];
        }
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

- (void)takePhotos {
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *camera = [self findCamera];
    if (camera) {
        [self initializeSessionConfiguration:captureSession camera:camera];
        
        // Show a camera preview of the photos that will be taken
        self.previewView.hidden = false;
        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
        previewLayer.frame = self.previewView.bounds;
        [self.previewView.layer insertSublayer:previewLayer atIndex:0];
        
        [captureSession startRunning];
    }
    else {
        [self dismissViewControllerAnimated:true completion:nil];
        [AlertManager displayAlertWithTitle:@"Cannot Take Photo" text:@"Camera is not available on this device" presenter:self];
    }
}

- (AVCaptureDevice *)findCamera {
    // Search for rear camera of phone and set it to be capture device
    AVCaptureDevice *inputDevice = nil;
    AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                          mediaType:AVMediaTypeVideo
                                           position:AVCaptureDevicePositionBack];
    NSArray *cameras = [captureDeviceDiscoverySession devices];
    
    for (AVCaptureDevice *camera in cameras) {
        if([camera position] == AVCaptureDevicePositionBack) {
            inputDevice = camera;
            break;
        }
    }
    return inputDevice;
}

- (void)initializeSessionConfiguration:(AVCaptureSession *)session camera:(AVCaptureDevice *)inputDevice {
    [session beginConfiguration];

    // Configure the input to be the rear camera and add to session
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:nil];
    if (videoInput) {
        if ([session canAddInput:videoInput]) {
            [session addInput:videoInput];
        }
    }
    
    // Configure the photo output and add it to the session
    self.photoOutput = [[AVCapturePhotoOutput alloc] init];
    if ([session canAddOutput:self.photoOutput]) {
        [session addOutput:self.photoOutput];
    }
    [session commitConfiguration];
}

- (IBAction)capturePhoto:(id)sender {
    // Animate to show that picture has been taken
    [UIView transitionWithView:self.previewView duration:0.05 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.blackScreen.hidden = false;
    } completion:^(BOOL finished) {
        [UIView transitionWithView:self.previewView duration:0.05 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.blackScreen.hidden = true;
        } completion:nil];
    }];

    // Occurs on press of shutter button
    AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettings];
    [self.photoOutput capturePhotoWithSettings:photoSettings delegate:self];
}

- (IBAction)selectPhotos:(id)sender {
    // Hides the camera preview view so the user can select photos to post
    self.previewView.hidden = true;
    [self.libraryCollectionView reloadData];
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    // Add photo to array after it has been processed
    [self.photosFromCamera addObject:photo.fileDataRepresentation];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.useCamera) {
        return [self.photosFromCamera count];
    }
    else {
        return [self.photosToDisplay count];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.selectedPhotos count] < self.limitSelection) {
        [self.selectedPhotos addObject: [NSNumber numberWithLong: indexPath.item]];
        ImagePickerCell *cell = (ImagePickerCell *) [collectionView cellForItemAtIndexPath:indexPath];
        cell.selectedView.hidden = false;
    }
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
        if (!self.useCamera) {
            PHImageRequestOptions *options = [PHImageRequestOptions new];
            options.synchronous = true;
            [[PHImageManager defaultManager] requestImageForAsset:self.photosToDisplay[[num intValue]] targetSize:CGSizeMake(400, 300) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                [imagesToReturn addObject:result];
                
                // Check if this is the final image to load
                if ([imagesToReturn count] == [self.selectedPhotos count]) {
                    [self.delegate didFinishPicking:[imagesToReturn copy]];
                    [self dismissViewControllerAnimated:true completion:nil];
                }
            }];
        }
        else {
            [imagesToReturn addObject:[UIImage imageWithData:self.photosFromCamera[[num intValue]]]];
            // Check if this is the final image to load
            if ([imagesToReturn count] == [self.selectedPhotos count]) {
                [self.delegate didFinishPicking:[imagesToReturn copy]];
                [self dismissViewControllerAnimated:true completion:nil];
            }
        }
    }
}

- (IBAction)onCancelTap:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImagePickerCell *cell = [self.libraryCollectionView dequeueReusableCellWithReuseIdentifier:@"ImagePickerCell" forIndexPath:indexPath];
    
    if (!self.useCamera) {
        // Get indicated PHAsset from array of assets and display its thumbnail in the image view
        PHAsset *toDisplay = self.photosToDisplay[indexPath.item];
        [[PHImageManager defaultManager] requestImageForAsset:toDisplay targetSize:CGSizeMake(128, 128) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            cell.imageView.image = result;
        }];
    }
    else {
        cell.imageView.image = [UIImage imageWithData:self.photosFromCamera[indexPath.item]];
    }
    return cell;
}

@end
