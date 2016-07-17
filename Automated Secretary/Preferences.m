//
//  Preferences.m
//  Automated Secretary
//
//  Created by Zachary Whitten on 8/1/15.
//  Copyright (c) 2015 WCNURadio. All rights reserved.
//

#import "Preferences.h"

@implementation Preferences

//This function is called after the application is finished launching. This is done rather than using init to guarantee that all IB objects have been created.
-(void)initalize{
    //Inialize the preference views
    _generalPreferencesView = [_defaultPreferenceWindow contentView];
    _usersPreferencesView = [_usersPreferenceWindow contentView];
    _oauth2PreferencesView = [_OAuth2Window contentView];
    //Set the selected toolbar item to be the general preferences window because that is the window displayed by default
    [_preferencesToolbar setSelectedItemIdentifier:@"general"];
    
    //Oauth2 Constants
    _CLIENT_ID = @"8207607529-urfp1826m7d044pu2rc4jco781241ms9.apps.googleusercontent.com";
    _KEYCHAIN_ITEM_NAME = @"automated-secretary";
    _CLIENT_SECRET = @"WDd-b14S7vNQqcefDklfH9_-";
    //Get the Oauth2 instance and if there is a refresh token (so if the user has approved OAuth2 authentication) refresh the authorization for the secesion. If there isn't a refresh token, user needs to set up OAuth2 for an email.
    _auth = [GTMOAuth2WindowController authForGoogleFromKeychainForName:_KEYCHAIN_ITEM_NAME clientID:_CLIENT_ID clientSecret:_CLIENT_SECRET];
    if (_auth.refreshToken != nil) {
        [_auth beginTokenFetchWithDelegate:self didFinishSelector:@selector(auth:finishedRefreshWithFetcher:error:)];
        [_OAuth2Email setStringValue:[_auth userEmail]];
    }
    
    //Load saved preference data
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSURL *filepath = [[NSURL alloc]init];
    filepath = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSString *stringFilepath = [filepath path];
    NSString *savedDataFilepath = [NSString stringWithFormat:@"%@/Automated Secretary",stringFilepath];
    if ([fileManager fileExistsAtPath:savedDataFilepath] == false) {
        [fileManager createDirectoryAtPath:savedDataFilepath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    _preferencesFilePath = [savedDataFilepath stringByAppendingPathComponent:@"preferences.txt"];
    
    
    NSArray *tempArray = [NSKeyedUnarchiver unarchiveObjectWithFile:_preferencesFilePath];
    if (tempArray == nil) {
        _adminPrivileges = false;
        filepath = [fileManager URLForDirectory:NSDesktopDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        stringFilepath = [filepath path];
        [self setTheAttendanceFolderMenu:stringFilepath];
        
    }
    else{
        //Don't forget about that file selector
        _adminState = [[tempArray objectAtIndex:0]integerValue];
        _attendanceFolderPath = [tempArray objectAtIndex:1];
        _toEmails = [tempArray objectAtIndex:2];
        _ccEmails = [tempArray objectAtIndex:3];
        _bccEmails = [tempArray objectAtIndex:4];
        
        [_adminPrivileges setState:_adminState];
        [_toTokenField setObjectValue:_toEmails];
        [_ccTokenField setObjectValue:_ccEmails];
        [_bccTokenField setObjectValue:_bccEmails];
        [self setTheAttendanceFolderMenu:_attendanceFolderPath];
    }

}

//Window functions
- (IBAction)generalPreferences:(id)sender{
    NSView *tempView = [[NSView alloc]init];
    [self.defaultPreferenceWindow setContentView:tempView];
    NSRect tempFrame = [self.defaultPreferenceWindow frame];
    tempFrame.origin.y += tempFrame.size.height;
    tempFrame.origin.y -= 226;
    tempFrame.size.height = 226;
    [self.defaultPreferenceWindow setFrame:tempFrame display:YES animate:YES];
    [self.defaultPreferenceWindow setTitle:@"General"];
    [self.defaultPreferenceWindow setContentView:_generalPreferencesView];
    
}

- (IBAction)usersPreferences:(id)sender {
    NSView *tempView = [[NSView alloc]init];
    [self.defaultPreferenceWindow setContentView:tempView];
    NSRect tempFrame = [self.defaultPreferenceWindow frame];
    tempFrame.origin.y += tempFrame.size.height;
    tempFrame.origin.y -= 473;
    tempFrame.size.height = 473;
    [self.defaultPreferenceWindow setFrame:tempFrame display:YES animate:YES];
    [self.defaultPreferenceWindow setTitle:@"Users"];
    [self.defaultPreferenceWindow setContentView:_usersPreferencesView];
}
- (IBAction)Oauth2Preferences:(id)sender;{
    NSView *tempView = [[NSView alloc]init];
    [self.defaultPreferenceWindow setContentView:tempView];
    NSRect tempFrame = [self.defaultPreferenceWindow frame];
    tempFrame.origin.y += tempFrame.size.height;
    tempFrame.origin.y -= 209;
    tempFrame.size.height = 209;
    [self.defaultPreferenceWindow setFrame:tempFrame display:YES animate:YES];
    [self.defaultPreferenceWindow setTitle:@"Account"];
    [self.defaultPreferenceWindow setContentView:_oauth2PreferencesView];
}

//Ok and Cancel buttons
- (IBAction)prefSubmit:(id)sender {
    _adminState = [_adminPrivileges state];
    _toEmails = _toTokenField.objectValue;
    _ccEmails = _ccTokenField.objectValue;
    _bccEmails = _bccTokenField.objectValue;
    
    [self.defaultPreferenceWindow orderOut:self];
    [self generalPreferences:nil];
    
    NSNumber *theAdminState = [[NSNumber alloc] initWithInteger:_adminState];
    NSArray *anArrayOfData = [[NSArray alloc]initWithObjects: theAdminState, _attendanceFolderPath,_toEmails,_ccEmails,_bccEmails, nil];
    [NSKeyedArchiver archiveRootObject:anArrayOfData toFile:_preferencesFilePath];
}
- (IBAction)prefCancel:(id)sender{
    [self.defaultPreferenceWindow orderOut:self];
    [self generalPreferences:nil];
    [_adminPrivileges setState:_adminState];
    [_toTokenField setObjectValue:_toEmails];
    [_ccTokenField setObjectValue:_ccEmails];
    [_bccTokenField setObjectValue:_bccEmails];
    [self setTheAttendanceFolderMenu:_attendanceFolderPath];
}

//Attendance folder functions
- (IBAction)getAttendanceFolder:(id)sender {
    NSString *theFilepath;
    NSOpenPanel *myPanel = [NSOpenPanel openPanel];
    [myPanel setAllowsMultipleSelection:NO];
    [myPanel setCanChooseDirectories:YES];
    [myPanel setCanChooseFiles:NO];
    if([myPanel runModal] == NSModalResponseOK){
        NSArray *fileArray = [myPanel URLs];
        theFilepath = [[fileArray objectAtIndex:0] path];
        [self setTheAttendanceFolderMenu:theFilepath];
    }

}
- (void)setTheAttendanceFolderMenu:(NSString *)aFilepath{
    NSWorkspace *myWorkspace = [[NSWorkspace alloc]init];
    NSImage *fileImage = [myWorkspace iconForFile:aFilepath];
    NSSize imageSize; imageSize.width = 16; imageSize.height = 16;
    [fileImage setSize:imageSize];
    NSArray *filepathParts = [aFilepath componentsSeparatedByString:@"/"];
    NSString *fileName = [filepathParts objectAtIndex:[filepathParts count] - 1];
    [_attendanceFolder setTitle:fileName];
    [_attendanceFolder setImage:fileImage];
    [_attendanceFolderMenu selectItemAtIndex:0];
    _attendanceFolderPath = aFilepath;
}

//OAuth2 functions
- (void)auth:(GTMOAuth2Authentication *)auth finishedRefreshWithFetcher:(GTMHTTPFetcher *)fetcher error:(NSError *)error {
    [self windowController:nil finishedWithAuth:auth error:error];
}
- (void)windowController:(GTMOAuth2WindowController *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error{
    if (error != nil) {
        // Authentication failed
        return;
    }
    
    _auth = auth;
    [_OAuth2Email setStringValue:[_auth userEmail]];
}
- (IBAction)UpdateOauth2Email:(id)sender {
    GTMOAuth2WindowController *windowController =
    [[GTMOAuth2WindowController alloc] initWithScope:@"https://mail.google.com/"
                                            clientID:_CLIENT_ID
                                        clientSecret:_CLIENT_SECRET
                                    keychainItemName:_KEYCHAIN_ITEM_NAME
                                      resourceBundle:[NSBundle bundleForClass:[GTMOAuth2WindowController class]]];
    
    [windowController signInSheetModalForWindow:nil
                                       delegate:self
                               finishedSelector:@selector(windowController:finishedWithAuth:error:)];
    
}


//Custom functions for rest of application
- (MailController*)CreateMailController{
    MailController *newMailController = [[MailController alloc] initMailController:[_auth accessToken] aUserEmail:[_auth userEmail]];
    return newMailController;
}

- (IBAction)activateAdmin:(id)sender {
    if ([_adminPrivileges state] == NSOnState) {
        if ([_adminAccess isAuthorized] == true) {
            [_adminPrivileges setState:NSOnState];
        }
        else{
            [_adminPrivileges setState:NSOffState];
        }
    }
    else{
        [_adminPrivileges setState:NSOffState];
    }
}



@end
