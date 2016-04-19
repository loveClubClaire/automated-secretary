//
//  Preferences.h
//  Automated Secretary
//
//  Created by Zachary Whitten on 8/1/15.
//  Copyright (c) 2015 WCNURadio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "MailController.h"
#import "adminAccess.h"

@interface Preferences : NSObject
@property (weak) IBOutlet adminAccess *adminAccess;

-(MailController*)CreateMailController;
-(void)setTheAttendanceFolderMenu:(NSString *)aFilepath;

//View of general preferences pain
@property NSView *generalPreferencesView;
//View of account preferences pain
@property NSView *accountPreferencesView;
//View of the users preferences pain
@property NSView *usersPreferencesView;
@property NSString *preferencesFilePath;

//All preference pane variables
@property NSInteger adminState;
@property NSString *inboundUsernameValue;
@property NSString *inboundPasswordValue;
@property NSString *inboundServerValue;
@property NSInteger inboundPortValue;
@property NSString *outboundUsernameValue;
@property NSString *outboundPasswordValue;
@property NSString *outboundServerValue;
@property NSInteger outboundPortValue;
@property NSString *attendanceFolderPath;
@property NSArray *toEmails;
@property NSArray *ccEmails;
@property NSArray *bccEmails;


@property (weak) IBOutlet NSWindow *defaultPreferenceWindow;
@property (weak) IBOutlet NSWindow *accountPreferenceWindow;
@property (weak) IBOutlet NSWindow *usersPreferenceWindow;
@property (weak) IBOutlet NSWindow *connectionStatusWindow;
@property (weak) IBOutlet NSImageView *inboundMailImage;
@property (weak) IBOutlet NSImageView *outboundMailImage;

@property (weak) IBOutlet NSProgressIndicator *outboundProgress;
@property (weak) IBOutlet NSProgressIndicator *inboundProgress;

//All preference pane objects
@property (weak) IBOutlet NSPopUpButton *attendanceFolderMenu;
@property (weak) IBOutlet NSButton *adminPrivileges;
@property (weak) IBOutlet NSTextField *inboundUsername;
@property (weak) IBOutlet NSSecureTextField *inboundPassword;
@property (weak) IBOutlet NSTextField *inboundServer;
@property (weak) IBOutlet NSTextField *inboundPort;
@property (weak) IBOutlet NSTextField *outboundUsername;
@property (weak) IBOutlet NSSecureTextField *outboundPassword;
@property (weak) IBOutlet NSTextField *outboundServer;
@property (weak) IBOutlet NSTextField *outboundPort;
@property (weak) IBOutlet NSMenuItem *attendanceFolder;
@property (unsafe_unretained) IBOutlet NSTextView *usersToText;
@property (unsafe_unretained) IBOutlet NSTextView *usersCcText;
@property (unsafe_unretained) IBOutlet NSTextView *usersBccText;




- (IBAction)generalPreferences:(id)sender;
- (IBAction)accountsPreferences:(id)sender;
- (IBAction)usersPreferences:(id)sender;
- (IBAction)prefSubmit:(id)sender;
- (IBAction)prefCancel:(id)sender;
- (IBAction)getAttendanceFolder:(id)sender;
- (IBAction)activateAdmin:(id)sender;


-(void)initalize;



@end
