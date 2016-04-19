//
//  Show.h
//  Automated Secretary
//
//  Created by Zachary Whitten on 7/28/15.
//  Copyright (c) 2015 WCNURadio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Show : NSObject

-(id)initShow:(NSString *)aShowName :(NSMutableArray *)allEmails :(NSString *)aWeekday;

@property NSString *showName;
@property NSMutableArray *eMails;
@property NSString *aWeekday;
@property NSMutableArray *attendanceDate;
@property NSMutableArray *attendance;

@end
