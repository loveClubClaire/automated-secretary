//
//  AppDelegate.m
//  Automated Secretary
//
//  Created by Zachary Whitten on 7/27/15.
//  Copyright (c) 2015 WCNURadio. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate{
    Boolean isEdit;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification{
    //Initalize the preferences window
    [_preferences initalize];
    //Initalize the days of the week combo box on the add show window
    NSArray *daysOfTheWeek = [[NSArray alloc]initWithObjects:@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday",@"Sunday", nil];
    [_dayAddShow addItemsWithTitles:daysOfTheWeek];
    [_dayAddShow selectItemAtIndex:-1];
    
    //Creates the menu bar and its drop down window
    NSMenuItem *separator = [[NSMenuItem alloc]init];
    separator = [NSMenuItem separatorItem];
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Show Scheduler" action:@selector(displayAutomatedSecretary) keyEquivalent:@""];
    [menu addItemWithTitle:@"Open Schedule" action:@selector(loadSchedule:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Save Schedule" action:@selector(saveSchedule:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Check Mail Servers" action:@selector(checkServers) keyEquivalent:@""];
    [menu addItemWithTitle:@"Export Attendance Log" action:@selector(exportAttendanceLog) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Preferences" action:@selector(openPreferencePane) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Quit" action:@selector(quitApplication) keyEquivalent:@""];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.menu = menu;
    NSImage *iconImage = [NSImage imageNamed:@"GearIcon.icns"];
    NSSize mySize; mySize.height = 18.0; mySize.width = 18.0;
    [iconImage setSize:mySize];
    _statusItem.image = iconImage;
    _statusItem.highlightMode = YES;

    //Initalize the table view object. Done in this function to guarantee the GUI has already been created.  
    [_tableViewObject initalize];
    
    //Initalize Timers
    //Selector is labelSet and that is the method the timer calls on cue. Edit that to work with timer.
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(masterTimeControler:) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(checkEmailTimeControler:) userInfo:nil repeats:YES];
    
}

//Timers and timer functions for the NSThread
-(void)masterTimeControler:(NSTimer*)timer{
    NSDate *date= [NSDate date];
    NSDateFormatter *formatter3 = [[NSDateFormatter alloc]init];
    formatter3.dateFormat =@"HH:mm";
    //Get this time from a function
    //maybe make this a setting in preferences?
    
    NSLog(@"Timer is working: current time is %@",[formatter3 stringFromDate:date]);

    if ([[formatter3 stringFromDate:date] isEqualToString:@"06:00" ]) {
        NSThread *timerThread = [[NSThread alloc]initWithTarget:self selector:@selector(masterTimeControllerFunction) object:nil];
        [timerThread start];
    }
}
-(void)checkEmailTimeControler:(NSTimer*)timer{
    NSDate *date= [NSDate date];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"mm";
    if ([[formatter1 stringFromDate:date] isEqualTo:@"15"] || [[formatter1 stringFromDate:date] isEqualTo:@"30"] || [[formatter1 stringFromDate:date] isEqualTo:@"45"]) {
        NSThread *timerThread = [[NSThread alloc]initWithTarget:self selector:@selector(checkEmailTimerControllerFunction) object:nil];
        [timerThread start];
    }
    
}
-(void)masterTimeControllerFunction{
    NSDate *date= [NSDate date];
    NSDate *dateTwo = [date dateByAddingTimeInterval:-86400];
    NSDateFormatter *formater2 = [[NSDateFormatter alloc] init];
    [formater2 setDateFormat:@"yyyy-MM-dd"];
    //get the name of the log file
    //get the log file path
    NSString *filepath = [_preferences attendanceFolderPath];
    //send that to the parce attendance function
    NSString *stringFromDate = [formater2 stringFromDate:dateTwo];
    //Get filepath from function call to system preferences pane
    NSString *filepathAndFile = [NSString stringWithFormat:@"%@/%@.txt", filepath, stringFromDate];
    [_tableViewObject takeAttendance:filepathAndFile];
    //Email side of the client
    //get the string to be emailed and then email it
    MailController *myMailController = [_preferences CreateMailController];
    //need to generate an array of emails to send this off to
    [myMailController SendEmail:[_preferences toEmails] :[_preferences ccEmails] :[_preferences bccEmails] :@"WCNURadio Status Report" :[_tableViewObject generateStatusEmail:filepathAndFile]];
}
-(void)checkEmailTimerControllerFunction{
    //get all emails from inbox
    //clear inbox
    MailController *myMailController = [_preferences CreateMailController];
    NSArray *allEmails = [myMailController GetAllSendersFromInbox];
    [myMailController EmptyInbox];
    //Parse out all emails not in the schedular
    allEmails = [_tableViewObject parseEmailArray:allEmails];
    
    
    //excuse all shows with assoicated emails
    //add all emails to an excused absance mutablearray
    [[_tableViewObject excusedAbsences]addObjectsFromArray:allEmails];
    [_tableViewObject saveExcusedAbsencesToFile];
    
    
    //For makeing shows automated
    //When an email is received, make sure the email address corosponds to a show, then send the show name over to the automated DJ and make that show automated
    NSArray *allShows = [_tableViewObject getShowNames:allEmails];
    for (int i = 0; i < [allShows count]; i++) {
        NSString *script1 =
        @"tell application \"WCNURadio Automated DJ\"\n"
        @"automate \"";
        NSString *script2 =
        @"\"\n"
        @"end tell";
        NSString *script = [NSString stringWithFormat:@"%@%@%@",script1,[allShows objectAtIndex:i],script2];
        NSAppleScript *myScript = [[NSAppleScript alloc] initWithSource:script];
        [myScript executeAndReturnError:nil];
    }
}

//Toolbar and window buttons
//When the add button in the toolbar is clicked, make the add show window appear in the center. runModalFOrWindow makes it the only clickable window.
- (IBAction)addButtonToolbarClick:(id)sender{
    isEdit = false;
    [_addShowWindow center];
    [_addShowWindow makeKeyAndOrderFront:self];
    [NSApp runModalForWindow:_addShowWindow];
}
- (IBAction)deleteButtonToolbarClick:(id)sender{
    NSIndexSet *allIndices = [self.tableView selectedRowIndexes];
    NSUInteger count = [allIndices count];
    if(count > 0){
        NSAlert *daysWarning = [[NSAlert alloc]init];
        [daysWarning setMessageText:@"Are you sure you want to delete the selected shows?"];
        [daysWarning addButtonWithTitle:@"OK"];
        [daysWarning addButtonWithTitle:@"Cancel"];
        NSModalResponse userResponce = [daysWarning runModal];
        if (userResponce == NSAlertFirstButtonReturn) {
            [[_tableViewObject allShows] removeObjectsAtIndexes:allIndices];
            [_tableViewObject saveShowsToFile];
            [self.tableView reloadData];
        }
    }
}
- (IBAction)editButtonToolbarClick:(id)sender{
    isEdit = true;
    NSIndexSet *allIndices = [self.tableView selectedRowIndexes];
    NSUInteger count = [allIndices count];
    if(count > 0){
        BOOL canEdit = true;
        if (count > 1) {
            NSAlert *daysWarning = [[NSAlert alloc]init];
            [daysWarning setMessageText:@"Are you sure you want to edit the information for multiple programs?"];
            [daysWarning addButtonWithTitle:@"OK"];
            [daysWarning addButtonWithTitle:@"Cancel"];
            NSModalResponse userResponce = [daysWarning runModal];
            if (userResponce == NSAlertSecondButtonReturn) {
                canEdit = false;
            }
        }
            if (canEdit == true) {
                [self.addShowWindow setTitle:@"Edit Show"];
                [self.showNameAddShow setStringValue:[self compareAllSelected:@"showName" :allIndices:nil]];
                //Hacky but I'm just trying to patch this :/ Sorry
                if ([[self.showNameAddShow stringValue] isEqual: @"Mixed"]) {
                    [self.showNameAddShow setStringValue:@""];
                    [self.showNameAddShow setPlaceholderString:@"Mixed"];
                }
                [self.dayAddShow selectItemWithTitle:[self compareAllSelected:@"aWeekday" :allIndices:nil]];
                if ([@"Mixed" isEqualToString:[self compareAllSelected:@"eMails" :allIndices:nil]]) {
                    [self.emailsAddShow setPlaceholderString:@"Mixed"];
                }
                else{
                    [self.emailsAddShow setObjectValue:[[[_tableViewObject allShows]objectAtIndex:[allIndices firstIndex]] eMails]];
                }
                [_addShowWindow center];
                [_addShowWindow makeKeyAndOrderFront:self];
                [NSApp runModalForWindow:_addShowWindow];
        }
    }

}
- (IBAction)showAttendance:(id)sender{
    
    NSIndexSet *allIndices = [self.tableView selectedRowIndexes];
    //get the attendance array :/
    NSArray *attendance = [_tableViewObject getAttendance:allIndices];
    //Send that array to the attendanceWindow Object 
    [_attendanceObject updateDataSouce:attendance];
    [_attendanceView reloadData];
    
    
    [_attendanceWindow center];
    [_attendanceWindow makeKeyAndOrderFront:self];
    [NSApp runModalForWindow:_attendanceWindow];
}
- (IBAction)addShowCancel:(id)sender{
    [_showNameAddShow setPlaceholderString:@""];
    [_showNameAddShow setStringValue:@""];
    [_dayAddShow selectItemAtIndex:-1];
    [_emailsAddShow setPlaceholderString:@""];
    [_emailsAddShow setObjectValue:nil];
    [NSApp stopModal];
    [_addShowWindow orderOut:self];
}
- (IBAction)addShowOK:(id)sender{
    //get the table view source object which is binded to the table view (passed by reference thank god)
    if (isEdit == false) {
        //Create a new show based on the values in the new show window
        NSString *day = @"";
        if ([_dayAddShow indexOfSelectedItem] == -1) {
            day = @"Monday";
        }
        else{
            day = [_dayAddShow titleOfSelectedItem];
        }
        Show *aShow = [[Show alloc]initShow:[_showNameAddShow stringValue] :[_emailsAddShow objectValue] :day];
        //Add this new show to the table view source
        [_tableViewObject AddShow:aShow];
    }
    else{
        //Create and set bools to determine if paramater has been changed or if the original values should remain
        Boolean shownameUnchanged = false;
        Boolean dayunchanged = false;
        Boolean emailunchanged = false;
        if ([[self.showNameAddShow placeholderString]  isEqualToString: @"Mixed"] && [[self.showNameAddShow stringValue] isEqualToString:@""]) {
            shownameUnchanged = true;
        }
        if ([self.dayAddShow indexOfSelectedItem] == -1) {
            dayunchanged = true;
        }
        if ([[self.emailsAddShow placeholderString] isEqualToString:@"Mixed"] && ((NSArray *)[_emailsAddShow objectValue]).count == 0){
            emailunchanged = true;
        }
        NSIndexSet *selectedValues = [self.tableView selectedRowIndexes];
        NSUInteger index = [selectedValues firstIndex];
        NSUInteger linearIndex = 0;
        while(index != NSNotFound){
            //slew of checking if statements. System of bools used for efficiency
            if (shownameUnchanged == false) {
                [[[_tableViewObject allShows] objectAtIndex:index]setShowName:[_showNameAddShow stringValue]];
            }
            if (dayunchanged == false) {
                [[[_tableViewObject allShows] objectAtIndex:index]setAWeekday:[_dayAddShow titleOfSelectedItem]];
            }
            if (emailunchanged == false) {
               [[[_tableViewObject allShows] objectAtIndex:index]setEMails:[_emailsAddShow objectValue]];
            }
            index=[selectedValues indexGreaterThanIndex: index];
            linearIndex += 1;
        }
    }
    
    //Reload the table view and then dismiss the new show window
    [_showNameAddShow setStringValue:@""];
    [_showNameAddShow setPlaceholderString:@""];
    [_dayAddShow selectItemAtIndex:-1];
    [_emailsAddShow setPlaceholderString:@""];
    [_emailsAddShow setObjectValue:nil];
    [_tableViewObject saveShowsToFile];
    [_tableView reloadData];
    [NSApp stopModal];
    [_addShowWindow orderOut:self];
}
- (IBAction)connectionStatusOK:(id)sender {
    [[_preferences connectionStatusWindow] orderOut:self];
}

//Menu Buttons
- (void)openPreferencePane{
    if ([_adminAccessObject isAuthorized] == true) {
    //Focus application (I.E. programabily make it like the application was clicked by the user, that kinda focus)
    NSApplication *myApp = [NSApplication sharedApplication];
    [myApp activateIgnoringOtherApps:YES];
    //Pull up window
    [_preferences generalPreferences:self];
    [[_preferences defaultPreferenceWindow] center];
    [[_preferences defaultPreferenceWindow] makeKeyAndOrderFront:self];
    }
}
- (void)quitApplication{
    if ([_adminAccessObject isAuthorized] == true) {
        [[NSApplication sharedApplication] terminate:nil];
    }
}
- (void)checkServersFunction{
    MailController *myMailController = [_preferences CreateMailController];
    if ([myMailController IsInboundAccountValid] == true) {
        [[_preferences inboundProgress] stopAnimation:self];
        [[_preferences inboundMailImage] setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
    }
    else{
        [[_preferences inboundProgress] stopAnimation:self];
        [[_preferences inboundMailImage] setImage:[NSImage imageNamed:@"NSStatusUnavailable"]];
    }
    if ([myMailController IsOutboundAccountValid] == true) {
        [[_preferences outboundProgress] stopAnimation:self];
        [[_preferences outboundMailImage] setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
    }
    else{
        [[_preferences outboundProgress] stopAnimation:self];
        [[_preferences outboundMailImage] setImage:[NSImage imageNamed:@"NSStatusUnavailable"]];
    }
}
- (void)checkServers{
    [[_preferences inboundProgress] startAnimation:self];
    [[_preferences outboundProgress] startAnimation:self];
    [[_preferences inboundMailImage] setImage:nil];
    [[_preferences outboundMailImage] setImage:nil];
    
    NSApplication *myApp = [NSApplication sharedApplication];
    [myApp activateIgnoringOtherApps:YES];
    //Pull up window
    [[_preferences connectionStatusWindow] center];
    [[_preferences connectionStatusWindow] makeKeyAndOrderFront:self];
    
    NSThread *checkServersThread = [[NSThread alloc]initWithTarget:self selector:@selector(checkServersFunction) object:nil];
    [checkServersThread start];
    
}
- (void)displayAutomatedSecretary{
    if ([_adminAccessObject isAuthorized] == true) {
    NSApplication *myApp = [NSApplication sharedApplication];
    [myApp activateIgnoringOtherApps:YES];
    //Pull up window
    [_mainWindow center];
    [_mainWindow makeKeyAndOrderFront:self];
    }
}
- (void)exportAttendanceLog{
    if ([_adminAccessObject isAuthorized] == true) {
    NSSavePanel *theSavePanel = [NSSavePanel savePanel];
    if ( [theSavePanel runModal] == NSModalResponseOK ) {
        NSURL *pathURL = [theSavePanel URL];
        NSString *pathString = [pathURL path];
        NSString *finalPath = [pathString stringByAppendingString:@".txt"];
        [[_tableViewObject generateAttendanceLog] writeToFile:finalPath atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
        //[NSKeyedArchiver archiveRootObject:[_tableViewObject generateAttendanceLog] toFile:finalPath];
    }
    }
}

//Creates an array of emails from a string. Function removes commas and end of lines and spaces then splits the string apart
-(NSMutableArray *)generateEmailArray:(NSString *)allEmails{
    allEmails = [allEmails stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    allEmails = [allEmails stringByReplacingOccurrencesOfString:@"," withString:@" "];
    NSArray *toReturn = [[NSMutableArray alloc]initWithArray:[allEmails componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    toReturn  = [toReturn filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
    NSMutableArray *trueReturn = [[NSMutableArray alloc]initWithArray:toReturn];
    return trueReturn;
}

-(id)compareAllSelected:(NSString *)aSelector :(NSIndexSet *)anIndexSet :(NSString *)anotherSelector{
    //Function takes a set of indices, a selector, and another selector which can be passed as nil
    //compares all objects in the array extracted with the given selector at the given indices
    //If they are all equal, the value is returned, otherwise a 'null' value is returned. This value is by default an empty string but a group of if statments can allow for custom 'null' values based upon the value of the passed selector
    //If the second selector is not nil, then apply it to the result of the first selector, its assumed its an object, then compare those results.
    NSUInteger index = [anIndexSet firstIndex];
    NSString *firstSelector;
    id object = [[_tableViewObject allShows] objectAtIndex:index];
    id value = [object valueForKey:aSelector];
    if (anotherSelector != nil) {
        object = [object valueForKey:aSelector];
        value = [object valueForKey:anotherSelector];
        firstSelector = aSelector;
        aSelector = anotherSelector;
    }
    while(index != NSNotFound){
        id object = [[_tableViewObject allShows] objectAtIndex:index];
        if (anotherSelector != nil) {
            object = [object valueForKey:firstSelector];
        }
        if ([value isEqual:[object valueForKey:aSelector]] == true) {
            index=[anIndexSet indexGreaterThanIndex: index];
        }
        else{
            if ([aSelector isEqualToString:@"aWeekday"] == true || [aSelector isEqualToString:@"stopDay"] == true) {
                value = @"";
            }
            else if([aSelector isEqualToString:@"startTime"] == true || [aSelector isEqualToString:@"stopTime"] == true){
                value = @"00:01";
            }
            else if ([aSelector isEqualToString:@"theAutomator"] == true ||[aSelector isEqualToString:@"playlistSeed"] == true || [aSelector isEqualToString:@"addsPlaylist"] == true || [aSelector isEqualToString:@"dataArray"] == true){
                value = nil;
            }
            else{
                value = [NSString stringWithFormat:@"Mixed"];
            }
            index = NSNotFound;
        }
    }
    return value;
}

//Saving and loading functions
- (IBAction)saveSchedule:(id)sender{
    Boolean hasAccess = false;
    if ([_mainWindow isVisible] == true) {
        hasAccess = true;
    }
    else{
        if ([_adminAccessObject isAuthorized] == true) {
            hasAccess = true;
        }
    }
    if (hasAccess == true) {
    //create save panel, get file path selected by user, append file extenction, save file using NSKeyedArchiver
    NSSavePanel *theSavePanel = [NSSavePanel savePanel];
    if ( [theSavePanel runModal] == NSModalResponseOK ) {
        NSURL *pathURL = [theSavePanel URL];
        NSString *pathString = [pathURL path];
        NSString *finalPath = [pathString stringByAppendingString:@".wsec"];
        [NSKeyedArchiver archiveRootObject:[_tableViewObject allShows] toFile:finalPath];
    }
    }
}
- (IBAction)loadSchedule:(id)sender{
    Boolean hasAccess = false;
    if ([_mainWindow isVisible] == true) {
        hasAccess = true;
    }
    else{
        if ([_adminAccessObject isAuthorized] == true) {
            hasAccess = true;
        }
    }
    if (hasAccess == true) {
    //Alert user that loading a new schedule will delete all current schedule data and it must be saved to be preserved.
    NSAlert *confirmOpenSchedule = [[NSAlert alloc] init];
    [confirmOpenSchedule setMessageText:@"The current schedule will be lost. Are you sure you want to continue?"];
    [confirmOpenSchedule addButtonWithTitle:@"OK"];
    [confirmOpenSchedule addButtonWithTitle:@"Cancel"];
    NSInteger returnValue = [confirmOpenSchedule runModal];
    if (returnValue == NSAlertFirstButtonReturn) {
            //create load panel, make panel only accept files with correct file extenction, get file path selevted by user, load the data
            NSOpenPanel *openPanel = [NSOpenPanel openPanel];
            NSArray *fileTypes = [[NSArray alloc] initWithObjects:@"wsec", nil];
            [openPanel setAllowsMultipleSelection:NO];
            [openPanel setCanChooseDirectories:NO];
            [openPanel setCanChooseFiles:YES];
            [openPanel setAllowedFileTypes:fileTypes];
            if ( [openPanel runModal] == NSModalResponseOK ) {
                NSURL *pathURL = [openPanel URL];
                NSString *pathString = [pathURL path];
                [self processFile:pathString];
            }
    }
    }
}
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename{
    if([_adminAccessObject isAuthorized]){
    //Alert user that loading a new schedule will delete all current schedule data and it must be saved to be preserved.
    NSAlert *confirmOpenSchedule = [[NSAlert alloc] init];
    [confirmOpenSchedule setMessageText:@"The current schedule will be lost. Are you sure you want to continue?"];
    [confirmOpenSchedule addButtonWithTitle:@"OK"];
    [confirmOpenSchedule addButtonWithTitle:@"Cancel"];
    NSInteger returnValue = [confirmOpenSchedule runModal];
    //if user confirms load opperation
    if(returnValue == NSAlertFirstButtonReturn){
            return [self processFile:filename];
    }
    //if user cancels load opperation
    else{
        //don't load a file, thus returning a false to signify the function failed to load a file
        return false;
    }
    }
    else{
        return false;
    }
    
}

- (BOOL)processFile:(NSString *)file{
    [_tableViewObject setAllShows:[NSKeyedUnarchiver unarchiveObjectWithFile:file]];
    [_tableView reloadData];
    //Save _thePrograms data to system file to preserve the loading of data after application is terminated
    Boolean test = [_tableViewObject saveShowsToFile];
    return  test; // Return YES when file processed succesfull, else return NO.
}

@end
