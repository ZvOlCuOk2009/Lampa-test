//
//  TableViewCell.h
//  Lampa test
//
//  Created by Admin on 06.03.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneCountLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *itemImage;
@property (strong, nonatomic) IBOutlet UIImageView *favImage;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end
