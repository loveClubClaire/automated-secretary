//
//  ShowTableView.m
//  Automated Secretary
//
//  Created by Zachary Whitten on 7/28/15.
//  Copyright (c) 2015 WCNURadio. All rights reserved.
//

#import "ShowTableView.h"

@implementation ShowTableView 

//Creates the object
-(id)init{
    return self;
}

//Initalization of the ShowTableView creates an empty mutiable array and makes it the datasource for the object
-(void)initalize{
    //Get the filepaths of files containing saved data from the last session
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSURL *filepath = [[NSURL alloc]init];
    filepath = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSString *stringFilepath = [filepath path];
    NSString *savedDataFilepath = [NSString stringWithFormat:@"%@/WCNURadio Automated Secretary",stringFilepath];
    if ([fileManager fileExistsAtPath:savedDataFilepath] == false) {
        [fileManager createDirectoryAtPath:savedDataFilepath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    _showsFilePath = [savedDataFilepath stringByAppendingPathComponent:@"allShows.txt"];
    _excusedAbsencesFilePath = [savedDataFilepath stringByAppendingPathComponent:@"excusedAbsences.txt"];
    
    //unarchive saved data
    _allShows = [NSKeyedUnarchiver unarchiveObjectWithFile:_showsFilePath];
    [self.tableView reloadData];
    if(_allShows == Nil){
        _allShows = [[NSMutableArray alloc]init];
    }
    
    _excusedAbsences = [NSKeyedUnarchiver unarchiveObjectWithFile:_excusedAbsencesFilePath];
    [self.tableView reloadData];
    if(_excusedAbsences == Nil){
        _excusedAbsences = [[NSMutableArray alloc]init];
    }
    
    //Custom compare function for dates
    NSComparator compareDates = ^(id obj1, id obj2) {
        
        NSComparisonResult result = NSOrderedSame;
        
        if([obj1 isEqualToString:obj2]){
            result = NSOrderedSame;
        }
        if([obj1 isEqualToString:@"Monday"]){
            result = NSOrderedAscending;
        }
        if([obj1 isEqualToString:@"Tuesday"]){
            if([obj2 isEqualToString:@"Monday"]){
                result = NSOrderedDescending;
            }
            else{
                result = NSOrderedAscending;
            }
        }
        if([obj1 isEqualToString:@"Wednesday"]){
            if([obj2 isEqualToString:@"Monday"] || [obj2 isEqualToString:@"Tuesday"] ){
                result = NSOrderedDescending;
            }
            else{
                result = NSOrderedAscending;
            }
        }
        if([obj1 isEqualToString:@"Thursday"]){
            if([obj2 isEqualToString:@"Monday"] || [obj2 isEqualToString:@"Tuesday"] || [obj2 isEqualToString:@"Wednesday"]){
                result = NSOrderedDescending;
            }
            else{
                result = NSOrderedAscending;
            }
        }
        if([obj1 isEqualToString:@"Friday"]){
            if([obj2 isEqualToString:@"Saturday"] || [obj2 isEqualToString:@"Sunday"]){
                result = NSOrderedAscending;
            }
            else{
                result = NSOrderedDescending;
            }
        }
        if([obj1 isEqualToString:@"Saturday"]){
            if([obj2 isEqualToString:@"Sunday"]){
                result = NSOrderedAscending;
            }
            else{
                result = NSOrderedDescending;
            }
        }
        if([obj1 isEqualToString:@"Sunday"]){
            result = NSOrderedDescending;
        }
        
        
        return result;
    };
    
    //Creates sorting for schedular window
    NSTableColumn *showColumn = [self.tableView tableColumnWithIdentifier:@"showname"];
    NSSortDescriptor *showSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"showName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    [showColumn setSortDescriptorPrototype:showSortDescriptor];
    
    NSTableColumn *tableColumnII = [self.tableView tableColumnWithIdentifier:@"showday"];
    NSSortDescriptor *daySortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"aWeekday" ascending:YES comparator:compareDates];
    [tableColumnII setSortDescriptorPrototype:daySortDescriptor];
 
    //Inatalizes the view so that it starts being assendingly sorted by show name
    NSArray *columnDescriptors = [NSArray arrayWithObjects:showSortDescriptor,nil];
    _allShows = [[_allShows sortedArrayUsingDescriptors:columnDescriptors] mutableCopy];
    [self.tableView setSortDescriptors:columnDescriptors];
    
}

//Returns the number of rows in the table view
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return _allShows.count;
}

//Updates the row's individual collums with the corresponding data from the datasource
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString *indetifer = [tableColumn identifier];
    if([indetifer isEqualToString:@"showname"]){
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"showname" owner:self];
        [cellView.textField setStringValue: [[_allShows objectAtIndex:row] showName]];
        return cellView;
    }
    if ([indetifer isEqualToString:@"showday"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"showday" owner:self];
        [cellView.textField setStringValue: [[_allShows objectAtIndex:row] aWeekday]];
        return cellView;
    }
    if ([indetifer isEqualToString:@"emails"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"emails" owner:self];
        [cellView.textField setStringValue: [self convertEmailsToString:[[_allShows objectAtIndex:row] eMails]]];
        return cellView;
    }
    
    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    NSLog(@"User has selected row %ld", (long)tableView.selectedRow);
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors{
    [_allShows sortUsingDescriptors:oldDescriptors];
    [tableView reloadData];
}

//A shows emails are stored as an NSArray in the Show object. This function converts that array into a string where the emails are seperated by a comma. This string is used for display in the table view
-(NSString *)convertEmailsToString:(NSMutableArray *)allEmails{
    NSMutableString *toReturn = [[NSMutableString alloc]initWithString:@""];
    for (int i = 0; i < [allEmails count] ; i++) {
        [toReturn appendString:[allEmails objectAtIndex:i]] ;
        if (i + 1 < [allEmails count]) {
            [toReturn appendString:@", "];
        }
    }
    return toReturn;
}

//Add a show to the datasource 
-(void)AddShow:(Show *)aShow{
    [_allShows addObject:aShow];
}


//Save excusedAbsesnces to file
-(void)saveExcusedAbsencesToFile{
    [NSKeyedArchiver archiveRootObject:_excusedAbsences toFile:_excusedAbsencesFilePath];
}

//Save allShows data to file
-(BOOL)saveShowsToFile{
    bool toReturn = [NSKeyedArchiver archiveRootObject:_allShows toFile:_showsFilePath];
    return toReturn;
}

-(NSArray *)parseEmailArray:(NSArray*)allEmails{
    NSMutableArray *allValidEmails = [[NSMutableArray alloc]init];
    for (int i = 0; i < [allEmails count]; i++) {
        for (int j = 0; j < [_allShows count]; j++) {
            for (int k = 0; k < [[[_allShows objectAtIndex:j]eMails] count]; k++) {
                if ([[allEmails objectAtIndex:i] isEqualToString:[[[_allShows objectAtIndex:j] eMails] objectAtIndex:k]] == true) {
                    [allValidEmails addObject:[allEmails objectAtIndex:i]];
                    k = (int)[[[_allShows objectAtIndex:j]eMails] count] - 1;
                    j = (int)[_allShows count] - 1;
                }
            }
            

            
            
        }
    }
    NSArray *toReturn = [[NSArray alloc]initWithArray:allValidEmails];
    return toReturn;
}

-(NSMutableArray*)parseAttendanceFile:(NSString *)attendanceLogFile{
    NSString *filecontents = [NSString stringWithContentsOfFile:attendanceLogFile encoding:NSUTF8StringEncoding error:nil];
    if(filecontents == NULL){
        filecontents = [NSString stringWithContentsOfFile:attendanceLogFile encoding:NSASCIIStringEncoding error:nil];
    }
    NSMutableArray *allEmails = [[NSMutableArray alloc]init];
    if (filecontents != NULL) {
    NSArray *allShows = [filecontents componentsSeparatedByString:@"\n\n"];
    allShows  = [allShows filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];

    
    for (int i = 0; i < [allShows count]; i++) {
        NSMutableArray *showEmails = [[NSMutableArray alloc]init];
        NSString *aShow = [allShows objectAtIndex:i];
        NSArray *showExploded = [aShow componentsSeparatedByString:@"<delim>"];
        [showEmails addObject:[showExploded objectAtIndex:1]];
        [showEmails addObject:[showExploded objectAtIndex:2]];
        [allEmails addObject:showEmails];
    }
    }
    return allEmails;
}

-(void)takeAttendance:(NSString *)attendanceLogFile{
    [self takeAttendanceCore:[self parseAttendanceFile:attendanceLogFile]];
}

-(NSString *)generateStatusEmail:(NSString *)attendanceLogFile{
    
    //Have fun debugging this clusterfuck
    
    NSDate *date= [NSDate date];
    NSDate *dateTwo = [date dateByAddingTimeInterval:-86400];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.dateStyle = NSDateFormatterMediumStyle;
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"EEEE";
    NSString *stringFromDate = [formater stringFromDate:dateTwo];
    
    //Parse the attendance file (to get the show names and station status) first, use the order of the show names to order the attendance of shows
    
    //Get all the station statuses from the log
    NSString *filecontents = [NSString stringWithContentsOfFile:attendanceLogFile encoding:NSUTF8StringEncoding error:nil];
    if(filecontents == NULL){
        filecontents = [NSString stringWithContentsOfFile:attendanceLogFile encoding:NSASCIIStringEncoding error:nil];
    }
    NSArray *allLoggedShows = [filecontents componentsSeparatedByString:@"\n\n"];
    allLoggedShows  = [allLoggedShows filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
    NSMutableArray *allStationStatus = [[NSMutableArray alloc]init];
    NSMutableArray *allEmails = [[NSMutableArray alloc] init];
    for (int i = 0; i < [allLoggedShows count]; i++) {
        NSMutableArray *stationStatus = [[NSMutableArray alloc]init];
        NSMutableArray *emails = [[NSMutableArray alloc] init];
        NSString *aShow = [allLoggedShows objectAtIndex:i];
        NSArray *showExploded = [aShow componentsSeparatedByString:@"<delim>"];
        [stationStatus addObject:[showExploded objectAtIndex:0]];
        [stationStatus addObject:[showExploded objectAtIndex:3]];
        [allStationStatus addObject:stationStatus];
        [emails addObject:[showExploded objectAtIndex:1]];
        [emails addObject:[showExploded objectAtIndex:2]];
        [allEmails addObject:emails];
    }
    
    //Get the attendance status from all of yesterdays shows
    //go through all shows
    //Use day of the week to get of the shows you're looking for
    //Then go through those shows and parse out their show name and status :P
    //Now was that so bad?
    NSMutableArray *attendance = [[NSMutableArray alloc] init];
    NSMutableArray *showName = [[NSMutableArray alloc] init];
    NSMutableArray *allEmailsFromObject = [[NSMutableArray alloc] init];
    for (int i = 0; i < [_allShows count]; i++) {
        for (int j = 0; j < [[[_allShows objectAtIndex:i]attendanceDate] count]; j++) {
            if ([[formater stringFromDate:[[[_allShows objectAtIndex:i]attendanceDate] objectAtIndex:j]] isEqualToString:[formater stringFromDate:dateTwo]]) {
                [attendance addObject:[[[_allShows objectAtIndex:i]attendance] objectAtIndex:j]];
                [showName addObject:[[_allShows objectAtIndex:i]showName]];
                [allEmailsFromObject addObject:[[_allShows objectAtIndex:i]eMails]];
            }
        }
    }
    
    //get the true show name, station status, and attedance status from every show in the attendance log
    NSMutableArray *allInformation = [[NSMutableArray alloc] init];
     for (int j = 0; j < [allEmailsFromObject count]; j++) {
         for (int i = 0; i < [allEmails count]; i++) {
            if ([[allEmailsFromObject objectAtIndex:j]containsObject:[[allEmails objectAtIndex:i]objectAtIndex:0]] == true || [[allEmailsFromObject objectAtIndex:j]containsObject:[[allEmails objectAtIndex:i]objectAtIndex:1]] == true) {
                NSMutableArray *temp = [[NSMutableArray alloc] init];
                [temp addObject:[showName objectAtIndex:j]];
                [temp addObject:[[allStationStatus objectAtIndex:i] objectAtIndex:1]];
                [temp addObject:[attendance objectAtIndex:j]];
                [allInformation addObject:temp];
            }
        }
    }
    

    //concat double sign ins
       for (int i = 0; i < [allInformation count]; i++) {
        for (int  j = i + 1; j < [allInformation count]; j++) {
            if ([[[allInformation objectAtIndex:i] objectAtIndex:0]isEqualToString:[[allInformation objectAtIndex:j]objectAtIndex:0]]) {
                NSString *temp = [NSString stringWithFormat:@"%@ %@",[[allInformation objectAtIndex:i]objectAtIndex:1],[[allInformation objectAtIndex:j] objectAtIndex:1]];
                [[allInformation objectAtIndex:i]removeObjectAtIndex:1];
                [[allInformation objectAtIndex:i]insertObject:temp atIndex:1];
                [allInformation removeObjectAtIndex:j];
                j--;
            }
        }
    }
    
    //Create an array list of all shows which were scheduled but did not appear in the log
        //Uh, I'm not sure why it does some N^3 thing. I think it could just do with that first if statment. But it works and I didn't want to keep fucking with it. Again, good luck if this breaks.
            //So it broke. The fuck was I thinking when I wrote the N^3 thing? Maybe it'll be obvious later? IDK
    NSMutableArray *allShowsCopy = [[NSMutableArray alloc] initWithArray:_allShows];
    for (int i = 0; i < [allShowsCopy count]; i++) {
        bool isFound = false;
        
        if ([[[allShowsCopy objectAtIndex:i]aWeekday] isEqualToString:[formatter1 stringFromDate:dateTwo]]) {
            for(int j = 0; j < [allInformation count]; j++){
                if ([[[allShowsCopy objectAtIndex:i]showName] isEqualToString:[[allInformation objectAtIndex:j]objectAtIndex:0]]) {
                    [allShowsCopy removeObject:[allShowsCopy objectAtIndex:i]];
                    isFound = true;
                }
            }
            
            
//            for (int j = 0; j < [[[allShowsCopy objectAtIndex:i]attendanceDate] count]; j++) {
//                
//                
//                if ([[formatter1 stringFromDate:[[[allShowsCopy objectAtIndex:i]attendanceDate] objectAtIndex:j]] isEqualToString:[formatter1 stringFromDate:dateTwo]]) {
//                    for (int k = 0; k < [allInformation count]; k++) {
//                        if ([[[allShowsCopy objectAtIndex:i]showName] isEqualToString:[[allInformation objectAtIndex:k] objectAtIndex:0]]) {
//                            //remove from showcopy
//                            [allShowsCopy removeObject:[allShowsCopy objectAtIndex:i]];
//                            isFound = true;
//                            j = [[[allShowsCopy objectAtIndex:i]attendanceDate] count] + 1; k = [allInformation count];
//                        }
//                    }
//                }
//            }
            
        }
        
            
        else{
            [allShowsCopy removeObject:[allShowsCopy objectAtIndex:i]];
            isFound = true;
        }

        if (isFound == true) {
            i = i - 1;
        }
    }
    
    
    
    //Add all non attending shows to the master array
    for (int i = 0; i < [allShowsCopy count]; i++) {
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        [temp addObject:[[allShowsCopy objectAtIndex:i]showName]];
        [temp addObject:@"NULL"];
            for (int j = 0; j < [[[allShowsCopy objectAtIndex:i]attendanceDate] count]; j++) {
                if ([[formater stringFromDate:[[[allShowsCopy objectAtIndex:i]attendanceDate] objectAtIndex:j]] isEqualToString:[formater stringFromDate:dateTwo]]) {
                    [temp addObject:[[[allShowsCopy objectAtIndex:i]attendance] objectAtIndex:j]];
                }
            }
        [allInformation addObject:temp];
    }
    //Create final String to return
    NSMutableString *statusEmail = [[NSMutableString alloc] init];
    
    [statusEmail appendString:[NSString stringWithFormat:@"WCNURadio Status Report for %@<br><br>",stringFromDate]];
    [statusEmail appendString:@"Attendance:<br>"];
    
    for (int i = 0; i < [allInformation count]; i++) {
        for (int j = 0; j < [[allInformation objectAtIndex:i] count]; j++) {
        }
        NSString *temp = [NSString stringWithFormat:@"%@: %@<br>",[[allInformation objectAtIndex:i]objectAtIndex:0],[[allInformation objectAtIndex:i] objectAtIndex:1]];
        [statusEmail appendString:temp];
    }
    [statusEmail appendString:@"<br>Station Status:<br>"];
    for (int i = 0; i < [allInformation count]; i++) {
        if ([[[allInformation objectAtIndex:i] objectAtIndex:1] isEqualToString:@"NULL"] == false) {
                NSString *temp = [NSString stringWithFormat:@"%@: %@<br>",[[allInformation objectAtIndex:i]objectAtIndex:0],[[allInformation objectAtIndex:i] objectAtIndex:1]];
                [statusEmail appendString:temp];
        }
    }

    return statusEmail;
}

-(void)takeAttendanceCore:(NSMutableArray *)allShowEmails{
    //takes in an array of arrays containing user emails
    //Gets the current date
    //Gets yesterdays date
    //Get array of all shows which take place on yesterdays date
    
    //For all of yesterdays shows
    //compare to all emails in allShowEmails
    //If emails match, DJ attended show, mark person as attended
    //Else, mark person as absent
    NSDate *yesterday = [[NSDate date] dateByAddingTimeInterval:-86400];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"EEEE";
    NSString *yesterdayWeekday = [formatter1 stringFromDate:yesterday];
    NSMutableArray *yesterdaysShows = [[NSMutableArray alloc]init];
    NSMutableArray *showIndices = [[NSMutableArray alloc]init];
    for (int i = 0; i < [_allShows count]; i++) {
        if ([[[_allShows objectAtIndex:i]aWeekday] isEqualToString:yesterdayWeekday]) {
            [yesterdaysShows addObject:[_allShows objectAtIndex:i]];
            [showIndices addObject:[NSNumber numberWithInt:i]];
        };
    }
    
    if ([yesterdaysShows count] > 0) {
    for (int i = 0; i < [yesterdaysShows count]; i++) {
        bool isAbsent = true;
        if ([[[yesterdaysShows objectAtIndex:i]eMails] count] > 0) {
        for (int j = 0; j < [[[yesterdaysShows objectAtIndex:i]eMails] count] ; j++) {
            for (int k = 0; k < [allShowEmails count] ; k++) {
                if ([[[[yesterdaysShows objectAtIndex:i]eMails] objectAtIndex:j] isEqualToString:[[allShowEmails objectAtIndex:k] objectAtIndex:0]] || [[[[yesterdaysShows objectAtIndex:i]eMails] objectAtIndex:j] isEqualToString:[[allShowEmails objectAtIndex:k] objectAtIndex:1]]) {
                    isAbsent = false;
                }
            }
        }
        if (isAbsent == true) {
            //attendance
            [[[_allShows objectAtIndex:[[showIndices objectAtIndex:i] intValue]] attendance] addObject:@"absent"];
            [[[_allShows objectAtIndex:[[showIndices objectAtIndex:i] intValue]] attendanceDate] addObject:yesterday];
        }
        else{
            [[[_allShows objectAtIndex:[[showIndices objectAtIndex:i] intValue]] attendance] addObject:@"present"];
            [[[_allShows objectAtIndex:[[showIndices objectAtIndex:i] intValue]] attendanceDate] addObject:yesterday];
        }
    }
    }
    }
    //loop through yesterdays shows
        //loop through excused email array
            //If an excused email matches an email from yesterdays show, then mark that show with an excused absense and remove email from excused absence array
    for (int i = 0; i < [yesterdaysShows count]; i++) {
        for (int j = 0; j < [[[yesterdaysShows objectAtIndex:i] eMails] count]; j++) {
            for (int k = 0; k < [_excusedAbsences count]; k++) {
                if ([[[[yesterdaysShows objectAtIndex:i] eMails] objectAtIndex:j] isEqualToString:[_excusedAbsences objectAtIndex:k]]) {
                    
                    if ([[[[_allShows objectAtIndex:[[showIndices objectAtIndex:i] intValue]] attendance]lastObject]isEqualToString:@"absent"]) {
                    [[[_allShows objectAtIndex:[[showIndices objectAtIndex:i] intValue]] attendance]removeObject:[[[_allShows objectAtIndex:[[showIndices objectAtIndex:i] intValue]] attendance] lastObject]];
                    [[[_allShows objectAtIndex:[[showIndices objectAtIndex:i] intValue]] attendance] addObject:@"excused absence"];
                        }
                    
                    [_excusedAbsences removeObjectAtIndex:k];
                }
            }
        }
    }
    
    //Save data when complete
    [self saveShowsToFile];
    [self saveExcusedAbsencesToFile];
}

-(NSArray *)getAttendance:(NSIndexSet *)selectedRows{
    NSMutableArray *toReturn = [[NSMutableArray alloc]init];
    NSMutableArray *days = [[NSMutableArray alloc]init];
    NSMutableArray *status = [[NSMutableArray alloc]init];
    NSMutableArray *object = [[NSMutableArray alloc]init];
  
    NSUInteger idx = [selectedRows firstIndex];
    while (idx != NSNotFound) {
        //for (int i = 0; i < [[_allShows objectAtIndex:idx] count]; i++) {
            for (int j = 0; j < [[[_allShows objectAtIndex:idx] attendance]count]; j++) {
                [days addObject:[[[_allShows objectAtIndex:idx]attendanceDate]objectAtIndex:j]];
                [status addObject:[[[_allShows objectAtIndex:idx]attendance]objectAtIndex:j]];
                [object addObject:[_allShows objectAtIndex:idx]];
            }
        //}
        idx = [selectedRows indexGreaterThanIndex: idx];
    }
    //Have arrays filled with Show names, dates they arrived, and status of their attendance. Now make this into an array I can return. Pls and Thxs
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:object];
    NSArray *uniqueShows = [orderedSet array];
    for (int i = 0; i < [uniqueShows count]; i++) {
        NSMutableArray *row = [[NSMutableArray alloc] init];
        int present = 0;
        int absent = 0;
        int excused = 0;
        for (int j = 0; j < [days count]; j++) {
            if ([[object objectAtIndex:j] isEqual:[uniqueShows objectAtIndex:i]]) {
                if ([[status objectAtIndex:j] isEqualToString:@"present"]) {
                    present = present + 1;
                }
                else if ([[status objectAtIndex:j] isEqualToString:@"absent"]){
                    absent = absent + 1;
                }
                else if ([[status objectAtIndex:j] isEqualToString:@"excused absence"]){
                    excused = excused + 1;
                }
            }
        }
        [row addObject:[[uniqueShows objectAtIndex:i]showName]];
        int totalDays = present + absent + excused;
        //String is hard coded to non changing NSTableView because I'm lazy
        NSString *allData = [NSString stringWithFormat:@"Present: %d times                                Absent:  %d times                                Excused absences: %d                 Total days: %d",present,absent,excused,totalDays];
        [row addObject:allData];
        [toReturn addObject:row];
    }
    
    if ([toReturn count] == 1) {
        NSDateFormatter *logDateFormatter = [[NSDateFormatter alloc] init];
        logDateFormatter.dateStyle = NSDateFormatterMediumStyle;
        for (int i = 0; i < [days count]; i++) {
            NSMutableArray *row = [[NSMutableArray alloc] init];
            [row addObject:[logDateFormatter stringFromDate:[days objectAtIndex:i]]];
            [row addObject:[status objectAtIndex:i]];
            [toReturn addObject:row];
        }

    }
    return toReturn;
}

-(NSString *)generateAttendanceLog{
    NSDate *date= [NSDate date];
    NSDateFormatter *formater2 = [[NSDateFormatter alloc] init];
    [formater2 setDateFormat:@"MM-dd-yyyy"];
    NSString *start = [NSString stringWithFormat:@"WCNURadio Attendance log. Generated %@",[formater2 stringFromDate:date]];
    NSMutableString *masterString = [[NSMutableString alloc] initWithString:start];
    
    for (int i = 0; i < [_allShows count]; i++) {
        NSMutableArray *toReturn = [[NSMutableArray alloc]init];
        NSMutableArray *row = [[NSMutableArray alloc] init];
        int present = 0;
        int absent = 0;
        int excused = 0;
        for (int j = 0; j < [[[_allShows objectAtIndex:i] attendance] count]; j++) {
                if ([[[[_allShows objectAtIndex:i] attendance] objectAtIndex:j] isEqualToString:@"present"]) {
                    present = present + 1;
                }
                else if ([[[[_allShows objectAtIndex:i] attendance] objectAtIndex:j] isEqualToString:@"absent"]){
                    absent = absent + 1;
                }
                else if ([[[[_allShows objectAtIndex:i] attendance] objectAtIndex:j] isEqualToString:@"excused absence"]){
                    excused = excused + 1;
                }
        }
        [row addObject:[[_allShows objectAtIndex:i]showName]];
        int totalDays = present + absent + excused;
        NSString *presentS = @"";
        NSString *absentS = @"";
        if (present != 1) {
            presentS = @"s";
        }
        if (absent != 1) {
            absentS = @"s";
        }
        NSString *allData = [NSString stringWithFormat:@"Present: %d time%@\nAbsent: %d time%@\nExcused absences: %d\nTotal days: %d\n",present,presentS,absent,absentS,excused,totalDays];
        [row addObject:allData];
        [toReturn addObject:row];
        NSDateFormatter *logDateFormatter = [[NSDateFormatter alloc] init];
        logDateFormatter.dateStyle = NSDateFormatterMediumStyle;
        for (int k = 0; k < [[[_allShows objectAtIndex:i] attendanceDate] count]; k++) {
            NSMutableArray *row = [[NSMutableArray alloc] init];
            [row addObject:[logDateFormatter stringFromDate:[[[_allShows objectAtIndex:i] attendanceDate] objectAtIndex:k]]];
            [row addObject:[[[_allShows objectAtIndex:i]attendance] objectAtIndex:k]];
            [toReturn addObject:row];
        }
        //Convert to a string here
        for (int w = 0; w < [toReturn count]; w++) {
            if (w == 0) {
                NSString *temp = [NSString stringWithFormat:@"\n\n%@\n%@\nAttendance Log:\n",[[toReturn objectAtIndex:w] objectAtIndex:0],[[toReturn objectAtIndex:w] objectAtIndex:1]];
                [masterString appendString:temp];
            }
            else{
                NSString *temp = [NSString stringWithFormat:@"%@ -- %@\n",[[toReturn objectAtIndex:w]objectAtIndex:0],[[toReturn objectAtIndex:w]objectAtIndex:1]];
                [masterString appendString:temp];
            }
        }
    }

    
    return masterString;
}

-(NSArray *)getShowNames:(NSArray *)emails{
    NSMutableArray *allShowNames = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [emails count]; i++) {
        for (int j = 0; j < [_allShows count]; j++) {
            if ([[[_allShows objectAtIndex:j] eMails] containsObject:[emails objectAtIndex:i]]) {
                [allShowNames addObject:[[_allShows objectAtIndex:j]showName]];
                j = (int)[_allShows count] - 1;
            }
        }
    }
    return allShowNames;
}

@end


