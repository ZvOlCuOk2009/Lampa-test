//
//  TransportSerice.h
//  Lampa test
//
//  Created by Admin on 05.03.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransportSerice : NSObject

+ (TransportSerice *)sharedService;

- (void)getDataFromServer:(void(^)(NSArray *items, NSError *error))success;

@end
