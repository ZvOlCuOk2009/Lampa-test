//
//  Parser.m
//  Lampa test
//
//  Created by Admin on 06.03.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import "Parser.h"
#import "Item.h"

@implementation Parser

+ (NSMutableArray *)initDataFromServer:(NSArray *)dataSource
{
    NSMutableArray *items = [NSMutableArray array];
    
    for (int i = 0; i < [dataSource count]; i++) {
        NSDictionary *dictionary = dataSource[i];
        Item *item = [[Item alloc] init];
        item.name = [dictionary objectForKey:@"name"];
        item.url = [[dictionary objectForKey:@"image"] objectForKey:@"url"];
        item.favorite = [[dictionary objectForKey:@"favorite"] integerValue];
        item.price = [[dictionary objectForKey:@"price"] integerValue];
        item.priceWeek = [[dictionary objectForKey:@"price_week"] integerValue];
        item.priceMonth = [[dictionary objectForKey:@"price_month"] integerValue];
        item.phoneCount = [[dictionary objectForKey:@"phone_count"] integerValue];
        [items addObject:item];
    }
    return items;
}

@end
