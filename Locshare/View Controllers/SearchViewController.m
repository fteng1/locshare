//
//  SearchViewController.m
//  Locshare
//
//  Created by Felianne Teng on 7/22/21.
//

#import "SearchViewController.h"
#import "UserSearchCell.h"
#import "ProfileViewController.h"

@interface SearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *resultsTableView;

@property (strong, nonatomic) NSArray *results;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.resultsTableView.delegate = self;
    self.resultsTableView.dataSource = self;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // Searches for users with username matching the inputted query
    searchBar.showsCancelButton = false;
    [searchBar resignFirstResponder];
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" matchesRegex:searchBar.text modifiers:@"i"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable returnedUsers, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error performing search: %@", error);
        }
        else {
            self.results = returnedUsers;
            [self.resultsTableView reloadData];
        }
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = false;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = true;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserSearchCell"];
    
    PFUser *user = self.results[indexPath.row];
    cell.usernameLabel.text = user[@"username"];
    cell.descriptionLabel.text = user[@"tagline"];
    cell.profileImageView.file = user[@"profilePicture"];
    [cell.profileImageView loadInBackground];
    
    return cell;
}

// Deselect row in table after it has been tapped
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UserSearchCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.resultsTableView indexPathForCell:tappedCell];
    PFUser *userToView = self.results[indexPath.row];
    
    ProfileViewController *profileViewController = [segue destinationViewController];
    profileViewController.user = userToView;
}

@end
