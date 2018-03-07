//
//  Item.h
//  Lampa test
//
//  Created by Admin on 05.03.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Item : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *url;
@property (assign, nonatomic) NSInteger category;
@property (assign, nonatomic) NSInteger favorite;
@property (assign, nonatomic) NSInteger idItem;
@property (assign, nonatomic) NSInteger price;
@property (assign, nonatomic) NSInteger priceMonth;
@property (assign, nonatomic) NSInteger priceWeek;
@property (assign, nonatomic) NSInteger phoneCount;

@end
