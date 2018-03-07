//
//  TabsView.m
//  Lampa test
//
//  Created by Admin on 05.03.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import "TabsView.h"
#import "PrefixHeader.pch"

#define SELF_SIZE self.frame.size

@implementation TabsView

- (void)drawRect:(CGRect)rect {
    
    self.indicationView = [[UIView alloc] initWithFrame:CGRectMake(0, SELF_SIZE.height - 2, SELF_SIZE.width / 3, 2)];
    self.indicationView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.indicationView];
}

#pragma mark - init

+ (TabsView *)initTabsView
{
    UINib *nib = [UINib nibWithNibName:@"TabsView" bundle:nil];
    TabsView *tabsView = [nib instantiateWithOwner:self options:nil][0];
    [tabsView setNeedsDisplay];
    return tabsView;
}

#pragma mark - Actions

- (IBAction)actionStoriesButton:(UIButton *)sender
{
    [self.delegate actionStoriesButtonDelegate];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self updateTabButtons];
                         [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                         
                         //change location indication view
                         self.indicationView.frame = CGRectMake(0, SELF_SIZE.height - 2, SELF_SIZE.width / 3, 2);
                     }];
}

- (IBAction)actionVideoButton:(UIButton *)sender
{
    [self.delegate actionVideoButtonDelegate];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self updateTabButtons];
                         [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                         
                         self.indicationView.frame = CGRectMake(SELF_SIZE.width / 3, SELF_SIZE.height - 2, SELF_SIZE.width / 3, 2);
                     }];
    
}

- (IBAction)actionFavoriteButton:(UIButton *)sender
{
    [self.delegate actionFavoriteButtonDelegate];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self updateTabButtons];
                         [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                         
                         self.indicationView.frame = CGRectMake((SELF_SIZE.width / 3) * 2, SELF_SIZE.height - 2, SELF_SIZE.width / 3, 2);
                     }];
}

- (void)updateTabButtons
{
    for (UIButton *tab in self.collectionButtons) {
        [tab setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

@end
