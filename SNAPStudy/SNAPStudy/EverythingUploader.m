//
//  EverythingUploader.m
//  SNAPStudy
//
//  Created by Patryk Laurent on 12/14/14.
//  Copyright (c) 2014 faucetEndeavors. All rights reserved.
//

#import "EverythingUploader.h"
#import "DropboxHandling.h"
#import "AppDelegate.h"
#import <OneDriveSDK/OneDriveSDK.h>

@interface EverythingUploader ()
@end

@implementation EverythingUploader

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)uploadEverything
{
    NSLog(@"ONEDRIVE: uploadEverything called.");
    
    
    NSLog(@"Uploading everything.");
    AppDelegate* app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    DropboxHandling* dropbox = app.dropBoxHandling;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray* directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    

 
    ODClient* odClient __block;
    [ODClient setMicrosoftAccountAppId:@"73277e31-2f24-45a7-82ad-e6646fb96ec3" scopes:@[@"onedrive.readwrite", @"offline_access"]];
    
    [ODClient authenticatedClientWithCompletion:^(ODClient *client, NSError *error){
        if (!error){
            NSLog(@"ONEDRIVE Sign in succeeded.");
            odClient = client;
            
            
            
            
            
            
            for (NSString* filename in directoryContent) {
                if (![filename containsString:@"local_copy.xml"]) {
                    NSLog(@"Uploading %@ to Dropbox", filename);
                    NSError *err;
                    NSString* filepath = [documentsDirectory stringByAppendingPathComponent:filename];
                    
                    NSString* data = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&err];
                    
                    NSData* datadata = [data dataUsingEncoding:NSUTF8StringEncoding];
                    if (err != nil) {
                        NSLog(@"Error is %@", err.description);
                    }
                    
                    
                    ODItemContentRequest *contentRequest = [[[[odClient drive] items:@"root"] itemByPath:filename] contentRequest];
                    [contentRequest uploadFromData:datadata completion:^(ODItem *response, NSError *error) {
                        
                        NSLog(@"Completed upload of %@", filename);
                        
                    }];
                    


                        
                    
                    
                    // [dropbox write:data toFile:filename alsoWriteLocally:NO];
                }
            }
            
            
            
            
            
        } else {
            NSLog(@"ONEDRIVE Sign in error: %@", [error description]);
        }
    }];
    
    
    

    
    
    [odClient signOutWithCompletion:^(NSError *error){
        NSLog(@"ONEDRIVE Sign out completed.");
        // This will remove any client information from disk.
        // An error will be passed back if an error occured during the sign out process.
    }];
}
@end
