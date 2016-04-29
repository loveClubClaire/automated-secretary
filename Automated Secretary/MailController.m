//
//  MailController.m
//  Automated Secretary
//
//  Created by Zachary Whitten on 7/27/15.
//  Copyright (c) 2015 WCNURadio. All rights reserved.
//

#import "MailController.h"



@implementation MailController

-(id)initMailController:(NSString*)IMAPHostName IMAPPort:(int)IMAPPort IMAPUsername:(NSString*)IMAPUsername IMAPPassword:(NSString*)IMAPPassword :(NSString*)SMTPHostName :(int)SMTPPort :(NSString*)SMTPUsername :(NSString*)SMTPPassword{
        
    //Initalize the Mailcore IMAP object
    _IMAPSession = [[MCOIMAPSession alloc]init];
    [_IMAPSession setHostname:IMAPHostName];
    [_IMAPSession setPort:IMAPPort];
    [_IMAPSession setUsername:IMAPUsername];
    [_IMAPSession setPassword:IMAPPassword];
    [_IMAPSession setConnectionType:MCOConnectionTypeTLS];

    //Initalize the Mailcore SMTP Object
    _SMTPSession = [[MCOSMTPSession alloc] init];
    _SMTPSession.hostname = SMTPHostName;
    _SMTPSession.port = SMTPPort;
    _SMTPSession.username = SMTPUsername;
    _SMTPSession.password = SMTPPassword;
    _SMTPSession.connectionType = MCOConnectionTypeTLS;
    
    return self;
}

-(id)initMailController:(NSString*)anAccessToken aUserEmail:(NSString*)aUserEmail{
    NSString * email = aUserEmail;
    NSString * accessToken = anAccessToken;
    
    MCOIMAPSession * imapSession = [[MCOIMAPSession alloc] init];
    [imapSession setAuthType:MCOAuthTypeXOAuth2];
    [imapSession setOAuth2Token:accessToken];
    [imapSession setUsername:email];
    // Use a different hostname if you oauth authenticate against a different provider
    [imapSession setHostname:@"imap.gmail.com"];
    [imapSession setPort:993];

    MCOSMTPSession * smtpSession = [[MCOSMTPSession alloc] init];
    [smtpSession setAuthType:MCOAuthTypeXOAuth2];
    [smtpSession setOAuth2Token:accessToken];
    [smtpSession setUsername:email];
    
    return self;
}




//Function to send an email to any number of email addresses. CC and BCC fields are nullible, everything else is not.
-(Boolean)SendEmail:(NSArray*)ToAddresses :(NSArray*)CCs :(NSArray*)BCCs :(NSString*)Subject :(NSString*)Message{
    //Set the global var didWork to false by default
    _didWork = true;
    //Create a message builder object
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    //Set the send from field to the SMTPSession Username
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox:_SMTPSession.username]];
    //Get all to Address from array and insert them into the builder objects
    NSMutableArray *to = [[NSMutableArray alloc] init];
    for (int i = 0; i < [ToAddresses count]; i++) {
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:[ToAddresses objectAtIndex:i]];
        [to addObject:newAddress];
    }
    [[builder header] setTo:to];
    //Check if user gave emails to CC. If yes, get them from the array and place them into the builder obejct
    if (CCs != nil) {
        if ([CCs count]>0) {
        NSMutableArray *cc = [[NSMutableArray alloc] init];
        for (int i = 0; i < [CCs count]; i++) {
            MCOAddress *newAddress = [MCOAddress addressWithMailbox:[CCs objectAtIndex:i]];
            [cc addObject:newAddress];
        }
        [[builder header] setCc:cc];
        }
    }
    //Check if user gave emails to BCC. If yes, get them from the array and place them into the builder obejct
    if (BCCs != nil) {
        if ([BCCs count]>0) {
        NSMutableArray *bcc = [[NSMutableArray alloc] init];
        for (int i = 0; i < [BCCs count]; i++) {
            MCOAddress *newAddress = [MCOAddress addressWithMailbox:[BCCs objectAtIndex:i]];
            [bcc addObject:newAddress];
        }
        [[builder header] setBcc:bcc];
        }
    }
    //Semaphore
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    //Insert both the subject line and the actual message into the builder object
    [[builder header] setSubject:Subject];
    [builder setHTMLBody:Message];
    //Convert the builder object into data
    NSData * rfc822Data = [builder data];
    //Create a sendOperation object with both the SMTPSession and the builder object data
    MCOSMTPSendOperation *sendOperation = [_SMTPSession sendOperationWithData:rfc822Data];
    //Execute sendOperation object. Return false on error, true on sucuess
    [sendOperation start:^(NSError *error) {
        if(error) {
            _didWork = false;
            dispatch_semaphore_signal(sema);
        }
        else{
            dispatch_semaphore_signal(sema);
        }

        }];
        while (dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW)) { [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];}
    return _didWork;
}

-(NSArray*)GetAllSendersFromInbox{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSMutableArray *toReturn = [[NSMutableArray alloc]init];
        MCOIMAPMessagesRequestKind requestKind = MCOIMAPMessagesRequestKindHeaders;
        NSString *folder = @"INBOX";
        MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)];
        MCOIMAPFetchMessagesOperation *fetchOperation = [_IMAPSession fetchMessagesByUIDOperationWithFolder:folder requestKind:requestKind uids:uids];
    
        [fetchOperation start:^(NSError * error, NSArray * fetchedMessages, MCOIndexSet * vanishedMessages) {
            //We've finished downloading the messages!
    
            //Let's check if there was an error:
            if(error) {
                NSLog(@"Seems we've failed to get messages from this inbox");
                dispatch_semaphore_signal(sema);
            }
            
            
            //And, let's print out the messages...
            for (int i = 0; i < fetchedMessages.count; i++) {
                NSString *newString = [[[[fetchedMessages objectAtIndex:i]header]from] RFC822String];
                NSArray *newArray = [[NSArray alloc] init];
                newArray = [newString componentsSeparatedByString:@"<"];
                newString = [newArray objectAtIndex:1];
                newString = [newString stringByReplacingOccurrencesOfString:@">" withString:@""];
                [toReturn addObject:newString];
            }
            dispatch_semaphore_signal(sema);
        }];
    while (dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW)) { [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];}
    return toReturn;
}

-(Boolean)EmptyInbox{
    
    //More testing required to see if semaphores are required
    
    _didWork = true;
    //Fetch all folders from the email account
    MCOIMAPFetchFoldersOperation * op = [_IMAPSession fetchAllFoldersOperation];
    [op start:^(NSError * error, NSArray *folders) {
        Boolean hasReadMailFolder = false;
        //Search all folders for the read mail folder
        for (int i = 0; i < [folders count] - 1; i++) {
            if ([[[folders objectAtIndex:i]path] isEqualToString:@"Read Mail"]) {
                hasReadMailFolder = true;
            }
        }
        //If the read mail folder does not exist, then create it
        if (hasReadMailFolder == false) {
            MCOIMAPOperation * op = [_IMAPSession createFolderOperation:@"Read Mail"];
            [op start:^(NSError * error) { }];
        }
    }];
    
    //Move all the mail from the Inbox folder to the Read mail folder (This framework requires you to create an object with the proper peramaters then execute that object)
    MCOIMAPCopyMessagesOperation *opt = [_IMAPSession copyMessagesOperationWithFolder:@"INBOX" uids:[MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)] destFolder:@"Read Mail"];
    [opt start:^ (NSError *error,NSDictionary *usDict) {
        
    }];
    
    //Add a delete flag to all the mail in the inbox folder (Create object, then execute object)
    MCOIMAPOperation *operation = [_IMAPSession storeFlagsOperationWithFolder:@"INBOX"
                                                                    uids:[MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)]
                                                                    kind:MCOIMAPStoreFlagsRequestKindSet
                                                                   flags:MCOMessageFlagDeleted];
    [operation start:^(NSError * error) {
        
    }];
    //Expunge inbox folder. This deletes all mail in the inbox folder with a delete flag. Duplicate emails in other folders are not affected
    MCOIMAPOperation *deleteOp = [_IMAPSession expungeOperation:@"INBOX"];
    [deleteOp start:^(NSError *error) {
        if(error) {
            _didWork = false;
        } else {
            
        }
    }];
    return _didWork;
}


-(Boolean)IsInboundAccountValid{
    //IMAP
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSMutableString *isValidString = [[NSMutableString alloc]initWithString:@"true"];
    if (_IMAPSession == nil) {
        [isValidString setString:@"false"];
    }
    
    else{
    MCOIMAPOperation * op = [_IMAPSession checkAccountOperation];
    [op start:^(NSError * error) {
        if (error) {
        [isValidString setString:@"false"];
        dispatch_semaphore_signal(sema);
        }
        else{
            dispatch_semaphore_signal(sema);
        }
    }];
        while (dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW)) { [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]]; }
    }
    Boolean isValid;
    if ([isValidString isEqualToString:@"true"]) {
        isValid = true;
    }
    else{
        isValid = false;
    }
    return isValid;
}
-(Boolean)IsOutboundAccountValid{
    //STMP
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSMutableString *isValidString = [[NSMutableString alloc]initWithString:@"true"];
    if (_SMTPSession == nil) {
        [isValidString setString:@"false"];
    }
    else{
    MCOSMTPOperation * op = [_SMTPSession loginOperation];
    [op start:^(NSError * error) {
        if (error) {
        [isValidString setString:@"false"];
        dispatch_semaphore_signal(sema);
        }
        else{
            dispatch_semaphore_signal(sema);
        }
    }];
        while (dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW)) { [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        }
}
    
    
    Boolean isValid;
    if ([isValidString isEqualToString:@"true"]) {
        isValid = true;
    }
    else{
        isValid = false;
    }
    return isValid;
}


@end
