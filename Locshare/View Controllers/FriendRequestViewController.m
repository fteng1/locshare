//
//  FriendRequestViewController.m
//  Locshare
//
//  Created by Felianne Teng on 7/30/21.
//

#import "FriendRequestViewController.h"
#import "UserSearchCell.h"
#import <Parse/Parse.h>

@interface FriendRequestViewController () <UITableViewDelegate, UITableViewDataSource, UserSearchCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *requestTableView;

@property (strong, nonatomic) NSMutableArray *requests;

@end

@implementation FriendRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.requestTableView.delegate = self;
    self.requestTableView.dataSource = self;
    self.requestTableView.tableFooterView = [UIView new];
    
    [self fetchRequests];
}

- (void)fetchRequests {
    NSArray *requestIDs = [PFUser currentUser][@"pendingFriends"];
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"objectId" containedIn:requestIDs];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error fetching requests: %@", error);
        }
        else {
            self.requests = [NSMutableArray arrayWithArray:users];
            [self.requestTableView reloadData];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.requests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RequestCell"];
    cell.delegate = self;
    cell.user = self.requests[indexPath.row];
    cell.cellIndex = indexPath.row;
    [cell setFieldsWithUser];
    return cell;
}

- (void)didFinishRespondingToFriendRequest:(NSInteger)index {
    [self.requests removeObjectAtIndex:index];
    [self.requestTableView reloadData];
}

@end
