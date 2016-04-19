//
//  adminAccess.m
//  Automated Secretary
//
//  Created by Zachary Whitten on 8/6/15.
//  Copyright (c) 2015 WCNURadio. All rights reserved.
//

#import "adminAccess.h"

@implementation adminAccess

-(Boolean)getAdminAccess{
    Boolean result = false;
    AuthorizationRef myAuthorizationRef;
    OSStatus myStatus;
    myStatus = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment , kAuthorizationFlagDefaults, &myAuthorizationRef);
    AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &right};
    AuthorizationFlags flags = kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
    
    // Call AuthorizationCopyRights to determine or extend the allowable rights.
    myStatus = AuthorizationCopyRights(myAuthorizationRef, &rights, NULL, flags, NULL);
    if (myStatus == errAuthorizationSuccess){
        result = true;
    }
    return result;
}

-(Boolean)isAuthorized{
    Boolean toReturn = false;
    if ([_isAdmin state] == NSOffState) {
        toReturn = true;
    }
    else{
        toReturn = [self getAdminAccess];
    }
    return toReturn;
}

@end
