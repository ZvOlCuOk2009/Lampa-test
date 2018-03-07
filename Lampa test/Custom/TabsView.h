//
//  TabsView.h
//  Lampa test
//
//  Created by Admin on 05.03.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TabsView;

@protocol TabsViewDelegate <NSObject>

- (void)actionStoriesButtonDelegate;
- (void)actionVideoButtonDelegate;
- (void)actionFavoriteButtonDelegate;

@end

@interface TabsView : UIView

@property (strong, nonatomic) IBOutletCollection (UIButton) NSArray *collectionButtons;
@property (strong, nonatomic) UIView *indicationView;

@property (weak, nonatomic) id <TabsViewDelegate> delegate;

+ (TabsView *)initTabsView;

- (IBAction)actionStoriesButton:(UIButton *)sender;
- (IBAction)actionVideoButton:(UIButton *)sender;
- (IBAction)actionFavoriteButton:(UIButton *)sender;

@end
