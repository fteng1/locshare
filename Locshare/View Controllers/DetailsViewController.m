//
//  DetailsViewController.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "DetailsViewController.h"
#import "PhotoViewCell.h"
#import <DateTools/DateTools.h>
#import <Parse/Parse.h>

@interface DetailsViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set information about post in page
    self.usernameLabel.text = self.post.authorUsername;
    self.captionLabel.text = self.post.caption;
    
    // Format createdAt date string
    NSString *createdAtOriginalString = self.post.createdAt.description;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // Configure the input format to parse the date string
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
    // Convert String to Date
    NSDate *date = [formatter dateFromString:createdAtOriginalString];
    // Put date in time ago format
    self.timestampLabel.text = date.shortTimeAgoSinceNow;
    
    self.photoCollectionView.dataSource = self;
    self.photoCollectionView.delegate = self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.post.photos count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoViewCell" forIndexPath:indexPath];
    PFFileObject *photo = self.post.photos[indexPath.item];
    cell.photoImageView.image = [UIImage systemImageNamed:@"photo"];
    cell.photoImageView.file = photo;
    [cell.photoImageView loadInBackground];
    return cell;
}

@end
