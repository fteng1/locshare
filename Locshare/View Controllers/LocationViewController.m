//
//  LocationViewController.m
//  Locshare
//
//  Created by Felianne Teng on 7/12/21.
//

#import "LocationViewController.h"
#import <Parse/Parse.h>
#import "PostLocationCell.h"
#import "Post.h"
#import "DetailsViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AlertManager.h"
#import "Constants.h"

@interface LocationViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITabBarControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *postCollectionView;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.location.name;
    self.postCollectionView.delegate = self;
    self.postCollectionView.dataSource = self;
    self.tabBarController.delegate = self;
    
    [self loadPosts];
    
    [self setCollectionViewLayout];
    
    [self setMapLocation];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventValueChanged];
    [self.postCollectionView insertSubview:self.refreshControl atIndex:0];
    
    [self.postCollectionView reloadData];
}

- (void)setCollectionViewLayout {
    // Set layout settings for the collectionView
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.postCollectionView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = POST_PREVIEW_COLLECTION_VIEW_SPACING;
    layout.minimumLineSpacing = POST_PREVIEW_COLLECTION_VIEW_SPACING;
    
    // size of posts depends on device size
    CGFloat postsPerLine = POST_PREVIEW_COLLECTION_VIEW_POSTS_PER_LINE;
    CGFloat itemWidth = (self.postCollectionView.frame.size.width - layout.minimumInteritemSpacing * (postsPerLine - 1)) / postsPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

// Set default map camera at the given location and place a marker
- (void)setMapLocation {
    GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(self.location.coordinate.latitude, self.location.coordinate.longitude)];
    marker.map = self.mapView;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:marker.position.latitude longitude:marker.position.longitude zoom:LOCATION_VIEW_DEFAULT_ZOOM];
    [self.mapView setCamera:camera];
}

- (void)refreshPage {
    // Get new array of posts for current location
    PFQuery *query = [PFQuery queryWithClassName:LOCATION_PARSE_CLASS_NAME];
    [query whereKey:LOCATION_OBJECT_ID_KEY equalTo:self.location.objectId];
    query.limit = 1;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error != nil) {
            [AlertManager displayAlertWithTitle:UPDATE_LOCATION_ERROR_TITLE text:UPDATE_LOCATION_ERROR_MESSAGE presenter:self];
        }
        else {
            self.location = [objects firstObject];
            [self loadPosts];
        }
    }];
}

- (void)loadPosts {
    // Get posts with location matching the current location and matching the current user, if relevant
    PFQuery *query = [PFQuery queryWithClassName:POST_PARSE_CLASS_NAME];
    [query whereKey:POST_LOCATION_KEY equalTo:self.location.placeID];
    if (self.isUserFiltered) {
        [query whereKey:POST_AUTHOR_KEY equalTo:self.userToFilter];
        
    }
    [query orderByDescending:POST_CREATED_AT_KEY];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable postsAtLocation, NSError * _Nullable error) {
        if (error == nil) {
            NSMutableArray *visiblePosts = [NSMutableArray new];
            
            // Only retrieve posts from user's friends and user, or public posts
            NSMutableArray *friendsWithSelf = [PFUser currentUser][USER_FRIENDS_KEY];
            [friendsWithSelf addObject:[PFUser currentUser].objectId];
            
            for (Post *post in postsAtLocation) {
                if (!post.private || [friendsWithSelf containsObject:post.author.objectId]) {
                    [visiblePosts addObject:post];
                }
            }
            self.postsToDisplay = visiblePosts;
            [self.postCollectionView reloadData];
        }
        else {
            [AlertManager displayAlertWithTitle:RETRIEVE_POSTS_ERROR_TITLE text:RETRIEVE_POSTS_ERROR_MESSAGE presenter:self];
        }
        [self.refreshControl endRefreshing];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.postsToDisplay count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostLocationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:POST_CELL_IDENTIFIER forIndexPath:indexPath];
    Post *post = self.postsToDisplay[indexPath.item];
    PFFileObject *imageToDisplay = [post.photos firstObject];
    cell.postImageView.image = [UIImage systemImageNamed:DEFAULT_POST_PREVIEW_IMAGE_NAME];
    cell.postImageView.file = imageToDisplay;
    [cell.postImageView loadInBackground];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:DETAIL_SEGUE sender:self.postsToDisplay[indexPath.item]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Bring up post details screen if post is tapped
    if ([[segue identifier] isEqualToString:DETAIL_SEGUE]) {
        Post *post = sender;
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.post = post;
    }
}
@end
