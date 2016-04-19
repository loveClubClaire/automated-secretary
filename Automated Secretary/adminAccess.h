//
//  adminAccess.h
//  Automated Secretary
//
//  Created by Zachary Whitten on 8/6/15.
//  Copyright (c) 2015 WCNURadio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface adminAccess : NSObject

@property (weak) IBOutlet NSButton *isAdmin;

-(Boolean)isAuthorized;

@end
