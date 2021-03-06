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
#import "Constants.h"
#import "NetworkStatusManager.h"
#import "AppDelegate.h"
#import "CachedUserManager.h"

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
@property (weak, nonatomic) IBOutlet UIButton *privateDisplay;

@property (strong, nonatomic) PFUser *postAuthor;
@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation DetailsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self updateFields];

    self.photoCollectionView.dataSource = self;
    self.photoCollectionView.delegate = self;
    self.commentTableView.dataSource = self;
    self.commentTableView.delegate = self;
    self.context = ((AppDelegate *) UIApplication.sharedApplication.delegate).persistentContainer.viewContext;
    
    [self initializeUI];

    [self fetchComments];
    if ([NetworkStatusManager isConnectedToInternet]) {
        [self getAuthorInfoInBackground];
    }
    else {
        CachedUser *user = [self fetchUserFromMemory:self.post.author.objectId];
        if (user != nil) {
            self.postAuthor = [CachedUserManager getPFUserFromCachedUser:user];
            self.profileImageView.image = [UIImage imageWithData:((PFFileObject *) self.postAuthor[USER_PROFILE_PICTURE_KEY]).getData];
        }
    }
}

- (void)initializeUI {
    // Set images for button for liked and not liked states
    [self.likeButton setImage:[UIImage systemImageNamed:LIKE_BUTTON_IMAGE_NORMAL] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage systemImageNamed:LIKE_BUTTON_IMAGE_SELECTED] forState:UIControlStateSelected];
    
    // Make profile image circular
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / PROFILE_PICTURE_CORNER_RADIUS_RATIO;;
    self.profileImageView.layer.masksToBounds = MASKS_TO_BOUNDS;
    
    self.commentTableView.tableFooterView = [UIView new];
    
    [self setCollectionViewLayout];
}

- (void)setCollectionViewLayout {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.photoCollectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = POST_PREVIEW_COLLECTION_VIEW_SPACING;
    layout.minimumLineSpacing = POST_PREVIEW_COLLECTION_VIEW_SPACING;
    
    // size of posts depends on device size
    CGFloat itemWidth = self.photoCollectionView.collectionViewLayout.collectionViewContentSize.width;
    CGFloat itemHeight = self.photoCollectionView.collectionViewLayout.collectionViewContentSize.height;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (NSString *)formatDate:(NSString *)creationTime {
    // Format createdAt date string
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // Configure the input format to parse the date string
    formatter.dateFormat = DATE_FORMAT;
    // Convert String to Date
    NSDate *date = [formatter dateFromString:creationTime];
    NSString *timestamp = date.shortTimeAgoSinceNow;
    return timestamp;
}

- (void)updateFields {
    // Set information about post in page
    self.usernameLabel.text = self.post.authorUsername;
    self.captionLabel.text = self.post.caption;
    self.privateDisplay.selected = self.post.private;
    NSArray *likedPosts = [PFUser currentUser][USER_LIKED_POSTS_KEY];
    self.likeButton.selected = [likedPosts containsObject:self.post.objectId];
    if ([self.post.numLikes intValue] == 1) {
        self.likesLabel.text = LIKE_LABEL_SINGULAR;
    }
    else {
        self.likesLabel.text = LIKE_LABEL_PLURAL;
    }
    self.numLikesLabel.text = [NSString stringWithFormat:OBJECT_STRING, self.post.numLikes];
    
    self.timestampLabel.text = [self formatDate:self.post.createdAt.description];
    
    [self.commentTableView reloadData];
}

- (CachedComment *)retrieveExistingComment:(NSString *)objectID {
    NSFetchRequest *request = CachedComment.fetchRequest;
    [request setPredicate:[NSPredicate predicateWithFormat:CACHED_OBJECT_ID_FILTER_PREDICATE, objectID]];
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    if (error == nil && results.count > 0) {
        return [results firstObject];
    }
    return nil;
}

- (void)storeComment:(Comment *)comment {
    NSError *error = nil;
    CachedComment *cachedComment = [self retrieveExistingComment:comment.objectId];
    if (cachedComment == nil) {
        cachedComment = [comment cachedComment];
    }
    [self.context save:&error];
}

- (void)fetchComments {
    if ([NetworkStatusManager isConnectedToInternet]) {
        // Make query to retrieve comments on post from the database
        PFQuery *query = [PFQuery queryWithClassName:COMMENT_PARSE_CLASS_NAME];
        [query whereKey:COMMENT_POST_ID_KEY equalTo:self.post.objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable postComments, NSError * _Nullable error) {
            if (error == nil) {
                for (Comment *comment in postComments) {
                    [self storeComment:comment];
                }
                self.comments = [postComments mutableCopy];
                [self.commentTableView reloadData];
            }
            else {
                [AlertManager displayAlertWithTitle:FETCH_COMMENT_ERROR_TITLE text:FETCH_COMMENT_ERROR_MESSAGE presenter:self];
            }
        }];
    }
    else {
        NSFetchRequest *request = CachedComment.fetchRequest;
        [request setPredicate:[NSPredicate predicateWithFormat:CACHED_POST_ID_FILTER_PREDICATE, self.post.objectId]];
        NSError *error = nil;
        NSArray *results = [self.context executeFetchRequest:request error:&error];
        self.comments = [results mutableCopy];
        [self.commentTableView reloadData];
    }
}

- (CachedUser *)fetchUserFromMemory:(NSString *)userID {
    NSFetchRequest *request = CachedUser.fetchRequest;
    [request setPredicate:[NSPredicate predicateWithFormat:CACHED_OBJECT_ID_FILTER_PREDICATE, userID]];
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    if (error == nil && results.count > 0) {
        return [results firstObject];
    }
    else {
        return nil;
    }
}

- (IBAction)makeComment:(id)sender {
    if ([NetworkStatusManager isConnectedToInternet]) {
        if ([self.commentTextField.text length] != 0) {
            Comment *newComment = [Comment initWithText:self.commentTextField.text author:[PFUser currentUser] post:self.post];
            [self.comments addObject:newComment];
            [newComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [self.commentTableView reloadData];
            }];
            self.commentTextField.text = EMPTY_STRING;
            [self.commentTextField resignFirstResponder];
        }
    }
    else {
        [AlertManager displayAlertWithTitle:NETWORK_ERROR_TITLE text:NETWORK_ERROR_MESSAGE presenter:self];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.post.photos count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PHOTO_CELL_IDENTIFIER forIndexPath:indexPath];
    PFFileObject *photo = self.post.photos[indexPath.item];
    if ([NetworkStatusManager isConnectedToInternet]) {
        cell.photoImageView.image = [UIImage systemImageNamed:DEFAULT_PROFILE_PICTURE_NAME];
        cell.photoImageView.file = photo;
        [cell.photoImageView loadInBackground];
    }
    else {
        // when offline, set image directly using NSData
        cell.photoImageView.image = [UIImage imageWithData:photo.getData];
    }
    
    return cell;
}

- (void)getAuthorInfoInBackground {
    // Get information about post author from database
    PFQuery *query = [PFQuery queryWithClassName:USER_PARSE_CLASS_NAME];
    [query whereKey:USER_OBJECT_ID_KEY equalTo:self.post.author.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error != nil) {
            [AlertManager displayAlertWithTitle:PROFILE_ERROR_TITLE text:PROFILE_ERROR_MESSAGE presenter:self];
        }
        else {
            if ([objects count] == 1) {
                self.postAuthor = [objects firstObject];
                self.profileImageView.file = self.postAuthor[USER_PROFILE_PICTURE_KEY];
                [self.profileImageView loadInBackground];
                
                CachedUser *userToStore = [self fetchUserFromMemory:self.postAuthor.objectId];
                if (userToStore == nil) {
                    [CachedUserManager getCachedUserFromPFUser:self.postAuthor];
                }
                else {
                    userToStore.friends = self.postAuthor[USER_FRIENDS_KEY];
                    userToStore.likedPosts = self.postAuthor[USER_LIKED_POSTS_KEY];
                    userToStore.numFriends = [(NSNumber *) self.postAuthor[USER_NUM_FRIENDS_KEY] intValue];
                    userToStore.numPosts = [(NSNumber *) self.postAuthor[USER_NUM_POSTS_KEY] intValue];
                    userToStore.profilePicture = [((PFFileObject *) self.postAuthor[USER_PROFILE_PICTURE_KEY]) getData];
                    userToStore.pendingFriends = self.postAuthor[USER_PENDING_FRIENDS_KEY];
                    userToStore.requestsSent = self.postAuthor[USER_REQUESTS_SENT_KEY];
                }
                NSError *error = nil;
                [self.context save:&error];
            }
        }
    }];
}

- (IBAction)onHeaderTap:(id)sender {
    [self performSegueWithIdentifier:HEADER_TO_PROFILE_SEGUE sender:self.postAuthor];
}

- (IBAction)onLikeTap:(id)sender {
    if ([NetworkStatusManager isConnectedToInternet]) {
        NSNumber *amountToIncrementLikes = [ProjectNumbers one];
        PFUser *currUser = [PFUser currentUser];
        if (!self.likeButton.selected) {
            // Occurs when the post is liked
            [currUser addObject:self.post.objectId forKey:USER_LIKED_POSTS_KEY];
        }
        else {
            // Occurs when the post is unliked
            amountToIncrementLikes = [ProjectNumbers negativeOne];
            [currUser removeObject:self.post.objectId forKey:USER_LIKED_POSTS_KEY];
        }
        [self.post incrementKey:POST_NUM_LIKES_KEY byAmount:amountToIncrementLikes];
        self.likeButton.selected = !self.likeButton.selected;
        [self updateFields];
        
        // Update database
        [currUser saveInBackground];
        [self.post saveInBackground];
    }
    else {
        [AlertManager displayAlertWithTitle:NETWORK_ERROR_TITLE text:NETWORK_ERROR_MESSAGE presenter:self];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:COMMENT_CELL_IDENTIFIER];
    Comment *comment = self.comments[indexPath.row];
    cell.commentTextLabel.text = comment.text;
    cell.usernameLabel.text = comment.username;
    cell.timestampLabel.text = [self formatDate:comment.createdAt.description];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Bring up profile view screen if username is tapped
    if ([[segue identifier] isEqualToString:HEADER_TO_PROFILE_SEGUE]) {
        PFUser *user = sender;
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.user = user;
    }
}

@end
