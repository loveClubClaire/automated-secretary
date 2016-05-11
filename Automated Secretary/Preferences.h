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
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2WindowController.h"
#import "GTMHTTPFetcher.h"



@interface Preferences : NSObject
@property (weak) IBOutlet adminAccess *adminAccess;

-(MailController*)CreateMailController;
-(void)setTheAttendanceFolderMenu:(NSString *)aFilepath;

//View of general preferences pain
@property NSView *generalPreferencesView;
//View of the users preferences pain
@property NSView *usersPreferencesView;
//View of the OAuth2Window
@property NSView *oauth2PreferencesView;
@property NSString *preferencesFilePath;

//All preference pane variables
@property NSInteger adminState;
@property NSString *attendanceFolderPath;
@property NSArray *toEmails;
@property NSArray *ccEmails;
@property NSArray *bccEmails;
@property GTMOAuth2Authentication *auth;
@property NSString *CLIENT_ID;
@property NSString *KEYCHAIN_ITEM_NAME;
@property NSString *CLIENT_SECRET;

@property (weak) IBOutlet NSWindow *OAuth2Window;
@property (weak) IBOutlet NSWindow *defaultPreferenceWindow;
@property (weak) IBOutlet NSWindow *usersPreferenceWindow;
@property (weak) IBOutlet NSWindow *connectionStatusWindow;
@property (weak) IBOutlet NSImageView *inboundMailImage;
@property (weak) IBOutlet NSImageView *outboundMailImage;
@property (weak) IBOutlet NSToolbar *preferencesToolbar;


@property (weak) IBOutlet NSProgressIndicator *outboundProgress;
@property (weak) IBOutlet NSProgressIndicator *inboundProgress;

//All preference pane objects
@property (weak) IBOutlet NSPopUpButton *attendanceFolderMenu;
@property (weak) IBOutlet NSButton *adminPrivileges;
@property (weak) IBOutlet NSMenuItem *attendanceFolder;
@property (unsafe_unretained) IBOutlet NSTextView *usersToText;
@property (unsafe_unretained) IBOutlet NSTextView *usersCcText;
@property (unsafe_unretained) IBOutlet NSTextView *usersBccText;
@property (weak) IBOutlet NSTextField *OAuth2Email;



- (IBAction)Oauth2Preferences:(id)sender;
- (IBAction)generalPreferences:(id)sender;
- (IBAction)usersPreferences:(id)sender;
- (IBAction)prefSubmit:(id)sender;
- (IBAction)prefCancel:(id)sender;
- (IBAction)getAttendanceFolder:(id)sender;
- (IBAction)activateAdmin:(id)sender;
- (IBAction)UpdateOauth2Email:(id)sender;


-(void)initalize;



@end
