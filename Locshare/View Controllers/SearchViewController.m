//
//  SearchViewController.m
//  Locshare
//
//  Created by Felianne Teng on 7/22/21.
//

#import "SearchViewController.h"
#import "UserSearchCell.h"
#import "ProfileViewController.h"
#import <IQKeyboardManager/IQKeyboardManager.h>

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
    
    [self initializeUI];
    [self fetchInitialPosts];
}

- (void)initializeUI {
    // Change color of search bar
    self.searchBar.searchTextField.backgroundColor = [UIColor colorWithRed:250/255.0 green:243/255.0 blue:221/255.0 alpha:1];
    [self.searchBar setSearchFieldBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    self.searchBar.searchTextField.layer.cornerRadius = 10;
    self.searchBar.searchTextField.clipsToBounds = true;
    self.searchBar.searchTextField.font = [UIFont fontWithName:@"Kohinoor Devanagari" size:17];
}

- (void)fetchInitialPosts {
    // Before searching, fetch users with most posts
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query orderByDescending:@"numPosts"];
    query.limit = 10;
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
    [cell setFieldsWithUser:self.results[indexPath.row]];
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
