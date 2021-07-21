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
    
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;
    
    // size of posts depends on device size
    CGFloat postsPerLine = 3;
    CGFloat itemWidth = (self.postCollectionView.frame.size.width - layout.minimumInteritemSpacing * (postsPerLine - 1)) / postsPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

// Set default map camera at the given location and place a marker
- (void)setMapLocation {
    GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(self.location.coordinate.latitude, self.location.coordinate.longitude)];
    marker.map = self.mapView;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:marker.position.latitude longitude:marker.position.longitude zoom:12.0];
    [self.mapView setCamera:camera];
}

- (void)refreshPage {
    // Get new array of posts for current location
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"objectId" equalTo:self.location.objectId];
    query.limit = 1;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error updating location: %@", error);
        }
        else {
            self.location = objects[0];
            [self loadPosts];
        }
    }];
}

- (BOOL)isUserFiltered {
    return self.tabBarController.selectedIndex == 3;
}

- (void)loadPosts {
    // Get posts with object id's stored in the location's array of posts
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"location" equalTo:self.location.placeID];
    if ([self isUserFiltered]) {
//        PFQuery *relationalQuery = [PFUser query];
//        [relationalQuery whereKey:@"objectId" equalTo:self.userToFilter.objectId];
//        [query whereKey:@"author" matchesQuery:relationalQuery];
        [query whereKey:@"author" equalTo:self.userToFilter];
        
    }
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            self.postsToDisplay = objects;
            [self.postCollectionView reloadData];
        }
        else {
            NSLog(@"Error retrieving posts: %@", error);
        }
        [self.refreshControl endRefreshing];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.postsToDisplay count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostLocationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostLocationCell" forIndexPath:indexPath];
    Post *post = self.postsToDisplay[indexPath.item];
    PFFileObject *imageToDisplay = [post.photos firstObject];
    cell.postImageView.image = [UIImage systemImageNamed:@"photo"];
    cell.postImageView.file = imageToDisplay;
    [cell.postImageView loadInBackground];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"detailSegue" sender:self.postsToDisplay[indexPath.item]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Bring up post details screen if post is tapped
    if ([[segue identifier] isEqualToString:@"detailSegue"]) {
        Post *post = sender;
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.post = post;
    }
}
@end
