//
//  ExperimentXMLLoader.m
//  SNAPStudy
//
//  Created by Patryk Laurent on 9/7/14.
//  Copyright (c) 2014 faucetEndeavors. All rights reserved.
//

#import "ExperimentXMLLoader.h"
#import "XMLDictionary.h"
#import "EverythingUploader.h"

@interface ExperimentXMLLoader ()
@property NSDictionary* experiment;
@end

@implementation ExperimentXMLLoader


- (instancetype) initWithURL:(NSString*)URL forceDownload:(BOOL)downloadForced
{
    if (self = [super init]) {
        XMLDictionaryParser* parser = [XMLDictionaryParser sharedInstance];
        parser.alwaysUseArrays = YES;
        NSURL* url = [NSURL URLWithString:URL];
        NSError* error = nil;
        
        NSString* xml = nil;
        
        if (!downloadForced && [self localCopyExists:URL]) {
            NSLog(@"Local copy exists, we'll use that instead of reaching to the network.");
            xml = [self loadTextForFile:[self localFilenameFromURL:URL]];
            self.loadedOK = YES;
        } else {
            xml = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];

            if (error != nil) {
                NSString *msg = [NSString stringWithFormat:@"Could not load XML Data file from URL %@ (and no local copy).", URL];
                UIAlertView* alert = [[UIAlertView alloc]
                                      initWithTitle:@"Error"
                                      message:msg
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                
                [alert show];
                NSLog(@"Error: %@", [error description]);
            } else {
                [self saveLocalCopy:xml originalURL:URL];
                self.loadedOK = YES;
            }
        }
            //            EverythingUploader* e = [[EverythingUploader alloc] init];
            //            [e uploadEverything];

        

        if (self.loadedOK) {
            self.experiment = [NSDictionary dictionaryWithXMLString:xml];
            NSLog(@"Experiment loaded with %lu runs", (unsigned long)[self.experiment[@"run"] count]);

            self.numRuns = [self.experiment[@"run"] count];
            self.participantID = self.experiment[@"participant"][0][@"_id"];
            NSLog(@"Participant ID is %@", self.participantID);
        }
    }
    return self;
}

- (NSString*)localFilenameFromURL:(NSString*)urlString {
    NSString* result = [urlString copy];
    result = [result stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    result = [result stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return result;
}

- (void)saveLocalCopy:(NSString*)xml originalURL:(NSString*)originalURL
{
    NSString* docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString* filename = [self localFilenameFromURL:originalURL];
    NSString *filepath = [docsDir stringByAppendingPathComponent:filename];
    [xml writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (BOOL)localCopyExists:(NSString*)originalURL
{
    NSString* docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString* filename = [self localFilenameFromURL:originalURL];
    NSString *filepath = [docsDir stringByAppendingPathComponent:filename];
    return [[NSFileManager defaultManager] fileExistsAtPath:filepath];
}

- (NSString*)loadTextForFile:(NSString*)filename
{
    NSString* docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString* filepath = [docsDir stringByAppendingPathComponent:filename];
    NSString* data = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    return data;
}

- (NSArray<ExperimentTrial*>*)loadRun:(NSInteger)runNumber
{
    NSMutableArray* experimentRun = [[NSMutableArray alloc] init];

    NSInteger numRuns = [self.experiment[@"run"] count];
    NSLog(@"User requested run number %ld, and we have %ld runs.", (long)runNumber, (long)numRuns);
    if (runNumber > numRuns) {
        return nil;
    }
    NSDictionary* run = self.experiment[@"run"][runNumber-1];
    NSInteger numTrials = [run[@"trials"][0][@"trial"] count];
    if ([[run allKeys] containsObject:@"_forceFirstOneOfTheDay"])
    {
        self.forceFirstOneOfTheDay = YES;
    }
    BOOL isAuditory = NO;
    self.loadedRunIsAuditory = NO;  // Assume no
    if ([[run allKeys] containsObject:@"_isAuditory"])
    {
        isAuditory = YES;
        self.loadedRunIsAuditory = YES;
    }
    for (int i = 0; i < numTrials; i++) {
        NSDictionary* trialData = run[@"trials"][0][@"trial"][i];
        
        NSInteger initialFixationDuration = [trialData[@"_initialFixationDuration"] intValue];
        NSString* stimulusString = trialData[@"_stimulus"];
        NSString* cueConditionString = trialData[@"_cue"];
        NSString* targetLocationString = trialData[@"_target"];

        CueCondition cueCondition = [ExperimentTrial CueConditionFrom:cueConditionString];
        Stimulus stimulus = [ExperimentTrial StimulusFrom:stimulusString];
        TargetLocation targetLocation = [ExperimentTrial TargetLocationFrom:targetLocationString];
        
        SensoryModality sensoryModality = [ExperimentTrial SensoryModalityFrom:@"Visual"];
        if (isAuditory) {
            sensoryModality = [ExperimentTrial SensoryModalityFrom:@"Auditory"];
        }
        ExperimentTrial* trial = [[ExperimentTrial alloc]
                          initWithInitialFixationDuration:initialFixationDuration
                          cueCondition:cueCondition
                          stimulus:stimulus
                          targetLocation:targetLocation
                          sensoryModality:sensoryModality];
        
        if (trial.isAuditory) {
            BOOL ok = [cueConditionString containsString:@"Auditory"];
            ok = ok & [stimulusString containsString:@"Auditory"];
            ok = ok & [targetLocationString containsString:@"Auditory"];
            if (!ok) {
                
                NSString* msg = [NSString stringWithFormat:@"Trial in run labeled as Auditory (run %lu, trial %d) has invalid settings. Cue, stimulus, and target location must all be Auditory type.", (long)runNumber, i+1];
                UIAlertView* alert = [[UIAlertView alloc]
                                      initWithTitle:@"Error"
                                      message:msg
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                
                [alert show];
                break;
            }
        }
        
        [experimentRun addObject:trial];
    }
    return experimentRun;
}

- (NSArray*)loadRunBreaks:(NSInteger)runNumber
{
    NSMutableArray* experimentRunBreaks = [[NSMutableArray alloc] init];
    
    NSInteger numRuns = [self.experiment[@"run"] count];
    if (runNumber > numRuns) {
        return nil;
    }
    NSDictionary* run = self.experiment[@"run"][runNumber-1];
    NSInteger numBreaks = [run[@"breaks"][0][@"break"] count];
    
    for (int i = 0; i < numBreaks; i++) {
        NSDictionary* breakData = run[@"breaks"][0][@"break"][i];
        [experimentRunBreaks addObject:breakData]; // _after_trial and _duration
    }
    return experimentRunBreaks;
}
@end
