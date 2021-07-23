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
#import "ProfileViewController.h"

@interface DetailsViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *numLikesLabel;

@property (strong, nonatomic) PFUser *postAuthor;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set images for button for liked and not liked states
    [self.likeButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateSelected];
    
    [self updateFields];

    self.photoCollectionView.dataSource = self;
    self.photoCollectionView.delegate = self;
    
    [self getAuthorInfoInBackground];
}

- (void)updateFields {
    // Set information about post in page
    self.usernameLabel.text = self.post.authorUsername;
    self.captionLabel.text = self.post.caption;
    NSArray *likedPosts = [PFUser currentUser][@"likedPosts"];
    self.likeButton.selected = [likedPosts containsObject:self.post.objectId];
    self.numLikesLabel.text = [NSString stringWithFormat:@"%@", self.post.numLikes];
    
    // Format createdAt date string
    NSString *createdAtOriginalString = self.post.createdAt.description;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // Configure the input format to parse the date string
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
    // Convert String to Date
    NSDate *date = [formatter dateFromString:createdAtOriginalString];
    // Put date in time ago format
    self.timestampLabel.text = date.shortTimeAgoSinceNow;
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

- (void)getAuthorInfoInBackground {
    // Get information about post author from database
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"objectId" equalTo:self.post.author.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Issue with obtaining user profile: %@", error);
        }
        else {
            if ([objects count] == 1) {
                self.postAuthor = objects[0];
                self.profileImageView.file = self.postAuthor[@"profilePicture"];
                [self.profileImageView loadInBackground];
            }
        }
    }];
}

- (IBAction)onHeaderTap:(id)sender {
    [self performSegueWithIdentifier:@"profileSegue" sender:self.postAuthor];
}

- (IBAction)onLikeTap:(id)sender {
    NSNumber *amountToIncrementLikes = @(1);
    PFUser *currUser = [PFUser currentUser];
    if (!self.likeButton.selected) {
        // Occurs when the post is liked
        [currUser addObject:self.post.objectId forKey:@"likedPosts"];
    }
    else {
        // Occurs when the post is unliked
        amountToIncrementLikes = @(-1);
        [currUser removeObject:self.post.objectId forKey:@"likedPosts"];
    }
    [self.post incrementKey:@"numLikes" byAmount:amountToIncrementLikes];
    self.likeButton.selected = !self.likeButton.selected;
    [self updateFields];
    
    // Update database
    [currUser saveInBackground];
    [self.post saveInBackground];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Bring up profile view screen if username is tapped
    if ([[segue identifier] isEqualToString:@"profileSegue"]) {
        PFUser *user = sender;
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.user = user;
    }
}

@end
