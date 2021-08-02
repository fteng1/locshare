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
#import "Comment.h"
#import "CommentCell.h"
#import "AlertManager.h"

@interface DetailsViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *numLikesLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIButton *postCommentButton;
@property (weak, nonatomic) IBOutlet UITableView *commentTableView;

@property (strong, nonatomic) PFUser *postAuthor;
@property (strong, nonatomic) NSMutableArray *comments;

@end

@implementation DetailsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeUI];
    
    [self updateFields];

    self.photoCollectionView.dataSource = self;
    self.photoCollectionView.delegate = self;
    self.commentTableView.dataSource = self;
    self.commentTableView.delegate = self;
    
    [self getAuthorInfoInBackground];
    [self fetchComments];
}

- (void)initializeUI {
    // Set images for button for liked and not liked states
    [self.likeButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateSelected];
    
    // Make profile image circular
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2;;
    self.profileImageView.layer.masksToBounds = true;}

- (void)setCollectionViewLayout {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.photoCollectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    
    // size of posts depends on device size
    CGFloat itemWidth = self.photoCollectionView.collectionViewLayout.collectionViewContentSize.width;
    CGFloat itemHeight = self.photoCollectionView.collectionViewLayout.collectionViewContentSize.height;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (NSString *)formatDate:(NSString *)creationTime {
    // Format createdAt date string
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // Configure the input format to parse the date string
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
    // Convert String to Date
    NSDate *date = [formatter dateFromString:creationTime];
    NSString *timestamp = date.shortTimeAgoSinceNow;
    return timestamp;
}

- (void)updateFields {
    // Set information about post in page
    self.usernameLabel.text = self.post.authorUsername;
    self.captionLabel.text = self.post.caption;
    NSArray *likedPosts = [PFUser currentUser][@"likedPosts"];
    self.likeButton.selected = [likedPosts containsObject:self.post.objectId];
    if ([self.post.numLikes intValue] == 1) {
        self.likesLabel.text = @"like";
    }
    else {
        self.likesLabel.text = @"likes";
    }
    self.numLikesLabel.text = [NSString stringWithFormat:@"%@", self.post.numLikes];
    
    self.timestampLabel.text = [self formatDate:self.post.createdAt.description];
    
    [self.commentTableView reloadData];
}

- (void)fetchComments {
    // Make query to retrieve comments on post from the database
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"postID" equalTo:self.post.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable postComments, NSError * _Nullable error) {
        if (error == nil) {
            self.comments = [postComments mutableCopy];
            [self.commentTableView reloadData];
        }
        else {
            [AlertManager displayAlertWithTitle:@"Error Fetching Comments" text:@"Could not retrieve comments on this post" presenter:self];
        }
    }];
}

- (IBAction)makeComment:(id)sender {
    if ([self.commentTextField.text length] != 0) {
        Comment *newComment = [Comment initWithText:self.commentTextField.text author:[PFUser currentUser] post:self.post];
        [self.comments addObject:newComment];
        [newComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self.commentTableView reloadData];
        }];
        self.commentTextField.text = @"";
        [self.commentTextField resignFirstResponder];
    }
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
            [AlertManager displayAlertWithTitle:@"User Profile Error" text:@"Could not obtain the current user profile" presenter:self];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    Comment *comment = self.comments[indexPath.row];
    cell.commentTextLabel.text = comment.text;
    cell.usernameLabel.text = comment.username;
    cell.timestampLabel.text = [self formatDate:comment.createdAt.description];
    return cell;
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
