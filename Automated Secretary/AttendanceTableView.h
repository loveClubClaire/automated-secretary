//
//  AttendanceTableView.h
//  Automated Secretary
//
//  Created by Zachary Whitten on 8/4/15.
//  Copyright (c) 2015 WCNURadio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface AttendanceTableView : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property NSArray *attendance;
@property (weak) IBOutlet NSWindow *attendanceWindow;

- (IBAction)okClick:(id)sender;
-(void)updateDataSouce:(NSArray*)dataSource;
@end
