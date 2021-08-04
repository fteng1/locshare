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
#import "AlertManager.h"
#import "Constants.h"

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
    self.resultsTableView.tableFooterView = [UIView new];
    
    [self initializeUI];
    [self fetchInitialUsers];
}

- (void)initializeUI {
    // Change color of search bar
    self.searchBar.searchTextField.backgroundColor = [ProjectColors tanBackgroundColor];
    [self.searchBar setSearchFieldBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    self.searchBar.searchTextField.layer.cornerRadius = TEXT_FIELD_CORNER_RADIUS;
    self.searchBar.searchTextField.clipsToBounds = CLIPS_TO_BOUNDS;
    self.searchBar.searchTextField.font = [ProjectFonts searchBarFont];
}

- (void)fetchInitialUsers {
    // Before searching, fetch users with most posts
    PFQuery *query = [PFQuery queryWithClassName:USER_PARSE_CLASS_NAME];
    [query orderByDescending:USER_NUM_POSTS_KEY];
    query.limit = INITIAL_USER_QUERY_LIMIT;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable returnedUsers, NSError * _Nullable error) {
        if (error != nil) {
            [AlertManager displayAlertWithTitle:SEARCH_ERROR_INITIAL_USERS_TITLE text:SEARCH_ERROR_INITIAL_USERS_MESSAGE presenter:self];
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
    PFQuery *query = [PFQuery queryWithClassName:USER_PARSE_CLASS_NAME];
    [query whereKey:USER_USERNAME_KEY matchesRegex:searchBar.text modifiers:SEARCH_BAR_REGEX_MODIFIERS];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable returnedUsers, NSError * _Nullable error) {
        if (error != nil) {
            [AlertManager displayAlertWithTitle:PERFORM_SEARCH_ERROR_TITLE text:PERFORM_SEARCH_ERROR_MESSAGE presenter:self];
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
    UserSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:SEARCH_CELL_IDENTIFIER];
    cell.user = self.results[indexPath.row];
    [cell setFieldsWithUser];
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
