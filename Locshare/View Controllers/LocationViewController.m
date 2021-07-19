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

@interface LocationViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) NSArray *posts;
@property (weak, nonatomic) IBOutlet UICollectionView *postCollectionView;

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.location.name;
    self.postCollectionView.delegate = self;
    self.postCollectionView.dataSource = self;
    
    [self loadPosts];
    
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

- (void)loadPosts {
    // Get posts with object id's stored in the location's array of posts
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"objectId" containedIn:self.location.posts];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            self.posts = objects;
            [self.postCollectionView reloadData];
        }
        else {
            NSLog(@"Error retrieving posts: %@", error);
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.posts count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostLocationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostLocationCell" forIndexPath:indexPath];
    Post *post = self.posts[indexPath.item];
    PFFileObject *imageToDisplay = [post.photos firstObject];
    if (imageToDisplay != nil) {
        cell.postImageView.image = [UIImage imageWithData:imageToDisplay.getData];
    }
    
    return cell;
}

@end
