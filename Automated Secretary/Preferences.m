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
    _accountPreferencesView = [_accountPreferenceWindow contentView];
    _usersPreferencesView = [_usersPreferenceWindow contentView];
    
    //Load saved preference data
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSURL *filepath = [[NSURL alloc]init];
    filepath = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSString *stringFilepath = [filepath path];
    NSString *savedDataFilepath = [NSString stringWithFormat:@"%@/WCNURadio Automated Secretary",stringFilepath];
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
        _inboundUsernameValue = [tempArray objectAtIndex:1];
        _inboundPasswordValue = [tempArray objectAtIndex:2];
        _inboundServerValue = [tempArray objectAtIndex:3];
        _inboundPortValue = [[tempArray objectAtIndex:4]integerValue];
        _outboundUsernameValue = [tempArray objectAtIndex:5];
        _outboundPasswordValue = [tempArray objectAtIndex:6];
        _outboundServerValue = [tempArray objectAtIndex:7];
        _outboundPortValue = [[tempArray objectAtIndex:8]integerValue];
        _attendanceFolderPath = [tempArray objectAtIndex:9];
        _toEmails = [tempArray objectAtIndex:10];
        _ccEmails = [tempArray objectAtIndex:11];
        _bccEmails = [tempArray objectAtIndex:12];
        
        [_adminPrivileges setState:_adminState];
        [_inboundUsername setStringValue:_inboundUsernameValue];
        [_inboundPassword setStringValue:_inboundPasswordValue];
        [_inboundServer setStringValue:_inboundServerValue];
        [_inboundPort setIntegerValue:_inboundPortValue];
        [_outboundUsername setStringValue:_outboundUsernameValue];
        [_outboundPassword setStringValue:_outboundPasswordValue];
        [_outboundServer setStringValue:_outboundServerValue];
        [_outboundPort setIntegerValue:_outboundPortValue];
        [_usersToText setString:[self generateEmailString:_toEmails]];
        [_usersCcText setString:[self generateEmailString:_ccEmails]];
        [_usersBccText setString:[self generateEmailString:_bccEmails]];
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
- (IBAction)accountsPreferences:(id)sender{
    NSView *tempView = [[NSView alloc]init];
    [self.defaultPreferenceWindow setContentView:tempView];
    NSRect tempFrame = [self.defaultPreferenceWindow frame];
    tempFrame.origin.y += tempFrame.size.height;
    tempFrame.origin.y -= 485;
    tempFrame.size.height = 485;
    [self.defaultPreferenceWindow setFrame:tempFrame display:YES animate:YES];
    [self.defaultPreferenceWindow setTitle:@"Accounts"];
    [self.defaultPreferenceWindow setContentView:_accountPreferencesView];
    
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


//Ok and Cancel buttons
- (IBAction)prefSubmit:(id)sender {
    _adminState = [_adminPrivileges state];
    _inboundUsernameValue = [_inboundUsername stringValue];
    _inboundPasswordValue = [_inboundPassword stringValue];
    _inboundServerValue = [_inboundServer stringValue];
    _inboundPortValue = [_inboundPort integerValue];
    _outboundUsernameValue = [_outboundUsername stringValue];
    _outboundPasswordValue = [_outboundPassword stringValue];
    _outboundServerValue = [_outboundServer stringValue];
    _outboundPortValue = [_outboundPort integerValue];
    _toEmails = [self generateEmailArray:[_usersToText string]];
    _ccEmails = [self generateEmailArray:[_usersCcText string]];
    _bccEmails= [self generateEmailArray:[_usersBccText string]];
    
    [_inboundPort setIntegerValue:_inboundPortValue];
    [_outboundPort setIntegerValue:_outboundPortValue];
    
    [self.defaultPreferenceWindow orderOut:self];
    [self generalPreferences:nil];
    NSNumber *theAdminState = [[NSNumber alloc] initWithInteger:_adminState];
    NSNumber *inboundPort = [[NSNumber alloc] initWithInteger:_inboundPortValue];
    NSNumber *outboundPort = [[NSNumber alloc] initWithInteger:_outboundPortValue];
    NSArray *anArrayOfData = [[NSArray alloc]initWithObjects: theAdminState, _inboundUsernameValue, _inboundPasswordValue, _inboundServerValue, inboundPort, _outboundUsernameValue, _outboundPasswordValue, _outboundServerValue, outboundPort, _attendanceFolderPath,_toEmails,_ccEmails,_bccEmails, nil];
    [NSKeyedArchiver archiveRootObject:anArrayOfData toFile:_preferencesFilePath];
}
-(IBAction)prefCancel:(id)sender{
    [self.defaultPreferenceWindow orderOut:self];
    [self generalPreferences:nil];
    [_adminPrivileges setState:_adminState];
    [_inboundUsername setStringValue:_inboundUsernameValue];
    [_inboundPassword setStringValue:_inboundPasswordValue];
    [_inboundServer setStringValue:_inboundServerValue];
    [_inboundPort setIntegerValue:_inboundPortValue];
    [_outboundUsername setStringValue:_outboundUsernameValue];
    [_outboundPassword setStringValue:_outboundPasswordValue];
    [_outboundServer setStringValue:_outboundServerValue];
    [_outboundPort setIntegerValue:_outboundPortValue];
    [_usersToText setString:[self generateEmailString:_toEmails]];
    [_usersCcText setString:[self generateEmailString:_ccEmails]];
    [_usersBccText setString:[self generateEmailString:_bccEmails]];
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
-(void)setTheAttendanceFolderMenu:(NSString *)aFilepath{
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

//Custom functions for rest of application
-(MailController*)CreateMailController{
    MailController *newMailController = [[MailController alloc]initMailController:_inboundServerValue IMAPPort:_inboundPortValue IMAPUsername:_inboundUsernameValue IMAPPassword:_inboundPasswordValue :_outboundServerValue :_outboundPortValue :_outboundUsernameValue :_outboundPasswordValue];
    return newMailController;
}

-(NSMutableArray *)generateEmailArray:(NSString *)allEmails{
    allEmails = [allEmails stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    allEmails = [allEmails stringByReplacingOccurrencesOfString:@"," withString:@" "];
    NSArray *toReturn = [[NSMutableArray alloc]initWithArray:[allEmails componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    toReturn  = [toReturn filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
    NSMutableArray *trueReturn = [[NSMutableArray alloc]initWithArray:toReturn];
    return trueReturn;
}
-(NSString *)generateEmailString:(NSArray *)allEmails{
    NSMutableString *toReturn = [[NSMutableString alloc] init];
    for (int i = 0; i < [allEmails count]; i++) {
        [toReturn appendString:[allEmails objectAtIndex:i]];
        if (i != [allEmails count] - 1) {
            [toReturn appendString:@", "];
        }
    }
    return toReturn;
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
