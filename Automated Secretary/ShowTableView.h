//
//  ShowTableView.h
//  Automated Secretary
//
//  Created by Zachary Whitten on 7/28/15.
//  Copyright (c) 2015 WCNURadio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Show.h"

@interface ShowTableView : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *tableView;

-(NSString *)convertEmailsToString:(NSMutableArray *)allEmails;
-(void)AddShow:(Show *)aShow;
-(BOOL)saveShowsToFile;
-(void)saveExcusedAbsencesToFile;
-(NSMutableArray*)parseAttendanceFile:(NSString *)attendanceLogFile;
-(NSArray *)parseEmailArray:(NSArray*)allEmails;
-(NSArray *)getAttendance:(NSIndexSet *)selectedRows;
-(void)takeAttendance:(NSString *)attendanceLogFile;
-(NSString *)generateStatusEmail:(NSString *)attendanceLogFile;
-(NSString *)generateAttendanceLog;
-(NSArray *)getShowNames:(NSArray *)emails;

-(void)initalize;

@property NSString *showsFilePath;
@property NSString *excusedAbsencesFilePath;
@property NSMutableArray *allShows;
@property NSMutableArray *excusedAbsences;

@end
