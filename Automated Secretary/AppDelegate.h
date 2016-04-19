//
//  AppDelegate.h
//  Automated Secretary
//
//  Created by Zachary Whitten on 7/29/15.
//  Copyright (c) 2015 WCNURadio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#import "MailController.h"
#import "ShowTableView.h"
#import "Preferences.h"
#import "AttendanceTableView.h"
#import "adminAccess.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;

@property (weak) IBOutlet NSWindow *addShowWindow;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSWindow *attendanceWindow;
@property (weak) IBOutlet NSTableView *attendanceView;
@property (weak) IBOutlet NSWindow *mainWindow;

@property (weak) IBOutlet NSToolbarItem *showAttendanceToolbar;
@property (weak) IBOutlet NSToolbarItem *addButtonToolbar;
@property (weak) IBOutlet NSToolbarItem *editButtonToolbar;
@property (weak) IBOutlet NSToolbarItem *deleteButtonToolbar;
@property (weak) IBOutlet NSTextField *showNameAddShow;
@property (weak) IBOutlet NSPopUpButton *dayAddShow;
@property (unsafe_unretained) IBOutlet NSTextView *emailsAddShow;
@property (weak) IBOutlet Preferences *preferences;
@property (weak) IBOutlet ShowTableView *tableViewObject;
@property (weak) IBOutlet AttendanceTableView *attendanceObject;
@property (weak) IBOutlet NSMenu *mainMenu;
@property (weak) IBOutlet adminAccess *adminAccessObject;


- (IBAction)addShowCancel:(id)sender;
- (IBAction)addShowOK:(id)sender;
- (IBAction)addButtonToolbarClick:(id)sender;
- (IBAction)deleteButtonToolbarClick:(id)sender;
- (IBAction)editButtonToolbarClick:(id)sender;
- (IBAction)showAttendance:(id)sender;
- (IBAction)saveSchedule:(id)sender;
- (IBAction)loadSchedule:(id)sender;
- (IBAction)connectionStatusOK:(id)sender;

@end



