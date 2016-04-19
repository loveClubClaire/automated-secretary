//
//  AttendanceTableView.m
//  Automated Secretary
//
//  Created by Zachary Whitten on 8/4/15.
//  Copyright (c) 2015 WCNURadio. All rights reserved.
//

#import "AttendanceTableView.h"

@implementation AttendanceTableView

//Returns the number of rows in the table view
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return _attendance.count;
}

//Updates the row's individual collums with the corresponding data from the datasource
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString *indetifer = [tableColumn identifier];
    if([indetifer isEqualToString:@"date"]){
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"date" owner:self];
        //code this after you know how the array you're sending in looks. lols 
        [cellView.textField setStringValue: [[_attendance objectAtIndex:row] objectAtIndex:0]];
        return cellView;
    }
    if ([indetifer isEqualToString:@"status"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"status" owner:self];
        [cellView.textField setStringValue: [[_attendance objectAtIndex:row] objectAtIndex:1]];
        return cellView;
    }
    return nil;
}

//This method implemented in the way that it is, prevents any rows from ever being selected
- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes{
    return 0;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    float colWidth = [[[tableView tableColumns] objectAtIndex:0]width];
    NSString *content = @"";
    NSString *content1 = [[_attendance objectAtIndex:row] objectAtIndex:0];
    NSString *content2 = [[_attendance objectAtIndex:row] objectAtIndex:1];
    
    if ([content1 length] > [content2 length]) {
        content = content1;
    }
    else{
        content = content2;
    }
    
    float textWidth = [content sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Neue" size:13],NSFontAttributeName ,nil]].width;
    
    float newHeight = ceil(textWidth/colWidth);
    
    newHeight = (newHeight * 17);
//    if(newHeight < 31){
//        return 18;
//    }
    return newHeight;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    NSLog(@"User has selected row %ld", (long)tableView.selectedRow);
}

-(void)updateDataSouce:(NSArray*)dataSource{
    _attendance = dataSource;
}

- (IBAction)okClick:(id)sender {
    [NSApp stopModal];
    [_attendanceWindow orderOut:self];
}

@end
