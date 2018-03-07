//
//  TransportSerice.m
//  Lampa test
//
//  Created by Admin on 05.03.18.
//  Copyright © 2018 Tsvigun Aleksander. All rights reserved.
//

#import "TransportSerice.h"
#import "Parser.h"
#import "PrefixHeader.pch"

@implementation TransportSerice

+ (TransportSerice *)sharedService
{
    static TransportSerice *serice = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serice = [[TransportSerice alloc] init];
    });
    return serice;
}

- (void)getDataFromServer:(void(^)(NSArray *items, NSError *error))success
{
    NSURL *URL = [NSURL URLWithString:@BASEURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      if (error) {
                                          NSLog(@"ERROR %@!!!", error.localizedDescription);
                                          return;
                                      }
                                      
                                      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                      NSArray *initItems = nil;
                                      if ([json objectForKey:@"results"]) {
                                          //parsing data
                                          initItems =
                                          [Parser initDataFromServer:[json objectForKey:@"results"]];
                                          if (success) {
                                              success(initItems, error);
                                          }
                                      }
                                  }];
    [task resume];
}

@end
