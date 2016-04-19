//
//  MailController.h
//  Automated Secretary
//
//  Created by Zachary Whitten on 7/27/15.
//  Copyright (c) 2015 WCNURadio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mailcore/Mailcore.h>

@interface MailController : NSObject

-(id)initMailController:(NSString*)IMAPHostName IMAPPort:(int)IMAPPort IMAPUsername:(NSString*)IMAPUsername IMAPPassword:(NSString*)IMAPPassword :(NSString*)SMTPHostName :(int)SMTPPort :(NSString*)SMTPUsername :(NSString*)SMTPPassword;

-(Boolean)SendEmail:(NSArray*)ToAddresses :(NSArray*)CCs :(NSArray*)BCCs :(NSString*)Subject :(NSString*)Message;
-(NSArray*)GetAllSendersFromInbox;
-(Boolean)IsInboundAccountValid;
-(Boolean)IsOutboundAccountValid;
-(Boolean)EmptyInbox;

@property MCOIMAPSession *IMAPSession;
@property MCOSMTPSession *SMTPSession;
@property bool didWork;


@end
