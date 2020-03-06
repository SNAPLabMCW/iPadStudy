//
//  ExperimentXMLLoader.h
//  SNAPStudy
//
//  Created by Patryk Laurent on 9/7/14.
//  Copyright (c) 2014 faucetEndeavors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExperimentTrial.h"

@interface ExperimentXMLLoader : NSObject

- (instancetype) initWithURL:(NSString*)URL forceDownload:(BOOL)downloadForced;
- (NSArray<ExperimentTrial*>*)loadRun:(NSInteger)runNumber;
- (NSArray*)loadRunBreaks:(NSInteger)runNumber;
@property NSInteger numRuns;
@property NSString* participantID;
@property (nonatomic) BOOL loadedOK;
@property (nonatomic) BOOL loadedRunIsAuditory;
@property (nonatomic) BOOL forceFirstOneOfTheDay;
@end
