//
//  Show.m
//  Automated Secretary
//
//  Created by Zachary Whitten on 7/28/15.
//  Copyright (c) 2015 WCNURadio. All rights reserved.
//

#import "Show.h"

@implementation Show

//Create a new show object with the following paramaters 
-(id)initShow:(NSString *)aShowName :(NSMutableArray *)allEmails :(NSString *)aWeekday{
    _showName = aShowName;
    _eMails = allEmails;
    _aWeekday = aWeekday;
    //Attendance is an array of strings containing "absent", "present", or "excused absence" which indicate attendance status. AttendanceDate is an array which contains dates. The date at attendanceDate[0] is the day the attendance status in attendance[0] was taken.
    _attendance = [[NSMutableArray alloc]init];
    _attendanceDate = [[NSMutableArray alloc]init];
    return self;
}


-(id)initWithCoder:(NSCoder *)decoder{
    self = [super init];
    if(!self){
        return nil;
    }
    self.showName = [decoder decodeObjectForKey:@"showName"];
    self.eMails = [decoder decodeObjectForKey:@"eMails"];
    self.aWeekday = [decoder decodeObjectForKey:@"aWeekday"];
    self.attendance = [decoder decodeObjectForKey:@"attendance"];
    self.attendanceDate = [decoder decodeObjectForKey:@"attendanceDate"];
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:self.showName forKey:@"showName"];
    [encoder encodeObject:self.eMails forKey:@"eMails"];
    [encoder encodeObject:self.aWeekday forKey:@"aWeekday"];
    [encoder encodeObject:self.attendance forKey:@"attendance"];
    [encoder encodeObject:self.attendanceDate forKey:@"attendanceDate"];
}

@end
