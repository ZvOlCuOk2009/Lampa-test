//
//  ViewController.m
//  Lampa test
//
//  Created by Admin on 05.03.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import "ViewController.h"
#import "TabsView.h"
#import "TransportSerice.h"
#import "Item.h"
#import "TableViewCell.h"
#import "PrefixHeader.pch"

#import <SVProgressHUD.h>

static NSString * const headerCellIdentifier = @"headerCell";
static NSString * const imageCellIdentifier = @"imageCell";
static NSString * const titleCellIdentifier = @"titleCell";

@interface ViewController () <TabsViewDelegate, UIScrollViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSMutableArray *filterArray;
@property (strong, nonatomic) NSMutableArray *banners;
@property (strong, nonatomic) TableViewCell *tableViewHeaderCell;

@property (assign, nonatomic) NSInteger stateTableView;
@property (assign, nonatomic) BOOL loadHeader;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"News";
    
    //substrate for custom navbar
    UIView *parentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.navigationController.navigationBar.frame.size.width, HEIGHT_TABS_BAR)];
    
    TabsView *tabsView = [TabsView initTabsView];
    tabsView.delegate = self;
    tabsView.frame = CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height);
    [self.view addSubview:parentView];
    [parentView addSubview:tabsView];
    
    self.tableView.contentInset = UIEdgeInsetsMake(HEIGHT_TABS_BAR, 0.0, 0.0, 0.0);
    self.stateTableView = 0;
    
    self.filterArray = [NSMutableArray array];
    self.loadHeader = NO;
    
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height / 2, self.view.frame.size.width, 21)];
    self.infoLabel.hidden = YES;
    self.view.center = self.infoLabel.center;
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.infoLabel];
    
    [self getData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - API

- (void)getData
{
    [SVProgressHUD show];
    [SVProgressHUD setBackgroundColor:LIGHT_GRAY_COLOR];
    
    [[TransportSerice sharedService] getDataFromServer:^(NSArray *items, NSError *error) {
        self.items = items;
        self.dataSource = items;
        //cgeated random banners
        self.banners = [self createdBanners:items];
        
        //update asynchronously interface
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UPDATE_INTERVAL * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                self.loadHeader = YES;
                [SVProgressHUD dismiss];
            });
        });
    }];
}

#pragma mark - set random banners

- (NSMutableArray *)createdBanners:(NSArray *)items
{
    NSMutableArray *banners = [NSMutableArray array];
    for (int i = 0; i < [items count]; i++) {
        Item *randomItem = items[arc4random_uniform((int)[items count])];
        if (randomItem.url && ![banners containsObject:randomItem]) {
            [banners addObject:randomItem];
        }
        if ([banners count] == 3) {
            break;
        }
    }
    return banners;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger countRow = 0;
    if (self.stateTableView == 0) {
        countRow = [self.dataSource count] + 1;
    }
    return countRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (self.stateTableView == 0) {
        
        if (indexPath.row == 0) {
//            if (!self.tableViewHeaderCell) {
                self.tableViewHeaderCell = [self.tableView dequeueReusableCellWithIdentifier:headerCellIdentifier];
                [self setupHeaderScrollview];
//            }
            
            if (!self.tableViewHeaderCell) {
                self.tableViewHeaderCell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerCellIdentifier];
            }
            self.tableViewHeaderCell.scrollView.delegate = self;
            
            Item *item = [self.banners firstObject];
            
            self.tableViewHeaderCell.titleLabel.text = item.name;
            self.tableViewHeaderCell.priceLabel.text = [NSString stringWithFormat:@"%ld", item.price];
            self.tableViewHeaderCell.phoneCountLabel.text = [NSString stringWithFormat:@"%ld", item.phoneCount];
            
            cell = self.tableViewHeaderCell;
        } else {
            
            Item *item = self.dataSource[indexPath.row - 1];
            
            if (item.url) {
                TableViewCell *tableViewImageCell = [self.tableView dequeueReusableCellWithIdentifier:imageCellIdentifier];
                if (!tableViewImageCell) {
                    tableViewImageCell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imageCellIdentifier];
                }
                tableViewImageCell.titleLabel.text = item.name;
                tableViewImageCell.priceLabel.text = [NSString stringWithFormat:@" - %ld", item.price];
                tableViewImageCell.phoneCountLabel.text = [NSString stringWithFormat:@" - %ld", item.phoneCount];
                tableViewImageCell.itemImage.image = [UIImage imageNamed:@"placecholder"];
                tableViewImageCell.indicatorView.hidden = NO;
                [tableViewImageCell.indicatorView startAnimating];
                
                //loading image in background
                NSURL *url = [NSURL URLWithString:item.url];
                NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (data) {
                        UIImage *image = [UIImage imageWithData:data];
                        if (image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                tableViewImageCell.itemImage.image = image;
                                tableViewImageCell.indicatorView.hidden = YES;
                            });
                        }
                    }
                }];
                [task resume];
                cell = tableViewImageCell;
            } else {
                TableViewCell *tableViewTitleCell = [self.tableView dequeueReusableCellWithIdentifier:titleCellIdentifier];
                if (!tableViewTitleCell) {
                    tableViewTitleCell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:titleCellIdentifier];
                }
                tableViewTitleCell.titleLabel.text = item.name;
                tableViewTitleCell.priceLabel.text = [NSString stringWithFormat:@" - %ld", item.price];
                tableViewTitleCell.phoneCountLabel.text = [NSString stringWithFormat:@" - %ld", item.phoneCount];
                tableViewTitleCell.itemImage.image = [UIImage imageNamed:@"placecholder"];
                cell = tableViewTitleCell;
            }
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = HEIGHT_CELL;
    if (indexPath.row == 0) {
        height = HEIGHT_HEADER_CELL;
    } else {
        Item *item = self.dataSource[indexPath.row - 1];
        if (item.url) {
            height = HEIGHT_IMAGE_CELL;
        }
    }
    return height;
}

#pragma - TabsViewDelegate

- (void)actionStoriesButtonDelegate
{
    self.stateTableView = 0;
    [self.tableView reloadData];
    self.infoLabel.hidden = YES;
}

- (void)actionVideoButtonDelegate
{
    self.stateTableView = 1;
    [self.tableView reloadData];
    self.infoLabel.text = @"VIDEO SCREEN";
    self.infoLabel.hidden = NO;
}

- (void)actionFavoriteButtonDelegate
{
    self.stateTableView = 2;
    [self.tableView reloadData];
    self.infoLabel.text = @"FAVOURITES SCREEN";
    self.infoLabel.hidden = NO;
}

#pragma mark - setup header scroll view

- (void)setupHeaderScrollview {
    
    //check if there is a header
    if (self.loadHeader == NO) {
        self.tableViewHeaderCell.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * [self.banners count], self.tableViewHeaderCell.scrollView.bounds.size.height);
        [self.tableViewHeaderCell.scrollView setNeedsDisplay];
        
        for (int i = 0; i < [self.banners count]; i++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * self.view.bounds.size.width, 0 * self.view.bounds.size.height, self.view.bounds.size.width, self.tableViewHeaderCell.scrollView.bounds.size.height)];
            view.backgroundColor = [UIColor clearColor];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.clipsToBounds = YES;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
            Item *randomItem = [self.banners objectAtIndex:i];
            
            NSURL *url = [NSURL URLWithString:randomItem.url];
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [imageView setImage:image];
                        });
                    }
                }
            }];
            [task resume];
            [view addSubview:imageView];
            [self.tableViewHeaderCell.scrollView addSubview:view];
        }
        [self setupPageControll];
    }
}

#pragma mark - page controll

- (void)setupPageControll
{
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((self.tableViewHeaderCell.scrollView.frame.size.width / 2) - 20, self.tableViewHeaderCell.frame.size.height - 30, 40, 30)];
    self.pageControl.currentPage = 1;
    self.pageControl.numberOfPages = [self.banners count];
    self.pageControl.currentPageIndicatorTintColor = BLUE_COLOR;
    self.pageControl.pageIndicatorTintColor = LIGHT_GRAY_COLOR;
    [self.tableViewHeaderCell addSubview:self.pageControl];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.tableViewHeaderCell.scrollView.frame.size.width;
    NSInteger index = self.tableViewHeaderCell.scrollView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = index;
    Item *item = self.banners[index];
    
    self.tableViewHeaderCell.titleLabel.text = item.name;
    self.tableViewHeaderCell.priceLabel.text = [NSString stringWithFormat:@" - %ld", item.price];
    self.tableViewHeaderCell.phoneCountLabel.text = [NSString stringWithFormat:@" - %ld", item.phoneCount];
}

#pragma mark - Action

- (IBAction)actionSearchButton:(UIBarButtonItem *)barButtonItem
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(30, - 20,
                                                             self.view.bounds.size.width - 40, 44)];
    self.navigationItem.titleView = searchBar;
    searchBar.autocorrectionType = NO;
    searchBar.delegate = self;
    [searchBar becomeFirstResponder];
    [barButtonItem setImage:nil];
    [barButtonItem setTitle:@"Готово"];
    [barButtonItem setTintColor:[UIColor whiteColor]];
    [barButtonItem setTarget:self];
    [barButtonItem setAction:@selector(cancelInteraction:)];
    [self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
}

- (void)cancelInteraction:(UIBarButtonItem *)barButtonItem
{
    [barButtonItem setTarget:self];
    [barButtonItem setAction:@selector(actionSearchButton:)];
    [barButtonItem setTitle:nil];
    [barButtonItem setImage:[UIImage imageNamed:@"search"]];
    [self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
    self.navigationItem.titleView = nil;
    self.dataSource = self.items;
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    NSMutableArray *result = (NSMutableArray *)[self.items filteredArrayUsingPredicate:predicate];
    self.dataSource = result;
    if ([searchText isEqualToString:@""]) {
        self.dataSource = self.items;
    }
    [self.tableView reloadData];
    NSLog(@"result %@", result.description);
}

#pragma mark - Keyboard notification

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(HEIGHT_TABS_BAR, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.view.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.view.frame.origin.y - kbSize.height);
        [self.tableView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(HEIGHT_TABS_BAR, 0.0, 0.0, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

@end
