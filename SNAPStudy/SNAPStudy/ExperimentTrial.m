//
//  ExperimentTrial.m
//  SNAPStudy
//
//  Created by Patryk Laurent on 8/3/14.
//  Copyright (c) 2014 faucetEndeavors. All rights reserved.
//

#import "ExperimentTrial.h"


@interface ExperimentTrial ()

@property (readwrite) NSInteger initialFixationDuration;
@property (readwrite) NSInteger cueDuration;
@property (readwrite) NSInteger postCueDelayDuration;
@property (readwrite) NSInteger maxTargetDuration;
@property (readwrite) NSInteger totalTrialDuration;

@property (readwrite) CFTimeInterval absoluteStartTime;
@property (readwrite) CueCondition cueCondition;
@property (readwrite) SensoryModality sensoryModality;
@property (readwrite) Stimulus stimulus;
@property (readwrite) TargetLocation targetLocation;

@property (readwrite) NSMutableArray* eventLog;
@property (readwrite) NSInteger showedAsTrialNumber;

@end

@implementation ExperimentTrial

- (instancetype)initWithInitialFixationDuration:(NSInteger)d1 cueCondition:(CueCondition)cueCondition stimulus:(Stimulus)stimulus targetLocation:(TargetLocation)targetLocation sensoryModality:(SensoryModality)sensoryModality
{
    if (self = [super init]) {
        self.initialFixationDuration = d1;
        self.isAuditory = (sensoryModality == SensoryModalityAuditory);
        self.isVisual = !self.isAuditory;
        
        
        if (self.isVisual) {
            self.cueDuration = 100;
            self.postCueDelayDuration = 400;
            self.maxTargetDuration = 1700;
            self.totalTrialDuration = 3500;
        }
        
        if (self.isAuditory) {
            self.cueDuration = 50;
            self.postCueDelayDuration = 600;
            self.maxTargetDuration = 1700;
            self.totalTrialDuration = 3500;
        }
        
        self.response = @"none";
        self.RT = 0;
        self.cueCondition = cueCondition;
        self.stimulus = stimulus;
        self.targetLocation = targetLocation;
        self.sensoryModality = sensoryModality;
        self.eventLog = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void)start:(NSInteger)labelWithNumber
{
    if (self.absoluteStartTime == 0)
    {
        self.absoluteStartTime = CACurrentMediaTime();
    }
    [self log:@"Start trial %d", labelWithNumber];
    self.showedAsTrialNumber = labelWithNumber;
}

- (NSString*)header
{
    return [[[self fieldNames] componentsJoinedByString:@","] stringByAppendingString:@"\n"];
}

- (NSArray*)fieldNames
{
    NSArray *result = @[@"trial_num",
                            @"init_fix",
                            @"cue",
                            @"target",
                            @"stimulus",
                            @"modality",
                            @"response",
                            @"rt"];
    return result;
}

//- (NSString*)summaryFormatString
//{
//    NSMutableArray* formats = [[NSMutableArray alloc] init];
//    for (id field __unused in [self fieldNames])
//    {
//        [formats addObject:@"%@"];
//    }
//    NSString* result = [formats componentsJoinedByString:@","];
//    result = [result stringByAppendingString:@"\n"];
//    return result;
//}

- (NSString*)summary
{
    NSString* result = @"";
    result = [result stringByAppendingFormat:@"%ld,", (long)self.showedAsTrialNumber];
    result = [result stringByAppendingFormat:@"%ld,", (long)self.initialFixationDuration];
    result = [result stringByAppendingFormat:@"%@,", [ExperimentTrial CueConditionString][@(self.cueCondition)]];
    result = [result stringByAppendingFormat:@"%@,", [ExperimentTrial TargetLocationString][@(self.targetLocation)]];
    result = [result stringByAppendingFormat:@"%@,", [ExperimentTrial StimulusString][@(self.stimulus)]];
    result = [result stringByAppendingFormat:@"%@,", [ExperimentTrial SensoryModalityString][@(self.sensoryModality)]];
    result = [result stringByAppendingFormat:@"%@,", self.response];
    result = [result stringByAppendingFormat:@"%@", [NSNumber numberWithDouble:self.absoluteFirstResponseTime-self.absoluteTargetShowTime]];
    
//    
//    
//    NSString* result = [NSString stringWithFormat:[self summaryFormatString],
//                        [NSString stringWithFormat:@"%ld", (long)self.showedAsTrialNumber],
//                        [NSString stringWithFormat:@"%ld", (long)self.initialFixationDuration],
//                        [ExperimentTrial CueConditionString][@(self.cueCondition)],
//                        [ExperimentTrial TargetLocationString][@(self.targetLocation)],
//                        [ExperimentTrial StimulusString][@(self.stimulus)],
//                        self.response,
//                        [NSNumber numberWithDouble:self.absoluteFirstResponseTime-self.absoluteTargetShowTime
//                            ]];
    
    return result;
}

- (void)log:(NSString*)event, ...
{
    CFTimeInterval delta = CACurrentMediaTime() - self.absoluteStartTime;
    NSString * logMessage;
    va_list args;
    va_start(args, event);
    logMessage = [[NSString alloc] initWithFormat:event arguments:args];
    va_end(args);
    [self.eventLog addObject:[NSString stringWithFormat:@"t=%0.4f,%@", delta, logMessage]];
}

- (NSInteger)timeRemainingTillEndOfTrial
{
    long remainder = self.totalTrialDuration - self.initialFixationDuration - self.RT;
    return remainder;
}

- (void)respondLeft
{
    if (self.RT == 0) {
        self.absoluteFirstResponseTime = CACurrentMediaTime();
        self.RT = CACurrentMediaTime() - self.absoluteStartTime;
        self.response = @"left";
        [self log:@"firstResponse=left"];
    } else {
        [self log:@"additionalResponse=left"];
    }
}

- (void)respondRight
{
    if (self.RT == 0) {
        self.absoluteFirstResponseTime = CACurrentMediaTime();
        self.RT = CACurrentMediaTime() - self.absoluteStartTime;
        self.response = @"right";
        [self log:@"firstResponse=right"];
    } else {
        [self log:@"additionalResponse=right"];
    }
}

- (void)respondAuditoryHigh
{
    if (self.RT == 0) {
        self.absoluteFirstResponseTime = CACurrentMediaTime();
        self.RT = CACurrentMediaTime() - self.absoluteStartTime;
        self.response = @"high";
        [self log:@"firstResponse=high"];
    } else {
        [self log:@"additionalResponse=high"];
    }
}

- (void)respondAuditoryLow
{
    if (self.RT == 0) {
        self.absoluteFirstResponseTime = CACurrentMediaTime();
        self.RT = CACurrentMediaTime() - self.absoluteStartTime;
        self.response = @"low";
        [self log:@"firstResponse=low"];
    } else {
        [self log:@"additionalResponse=low"];
    }
}

+ (CueCondition)CueConditionFrom:(NSString*)string
{
    NSArray* data = @[
                      @"CueConditionNone",
                      @"CueConditionCenter",
                      @"CueConditionDouble",
                      @"CueConditionSpatialUp",
                      @"CueConditionSpatialDown",
                      
                      @"CueConditionAuditoryNone",
                      @"CueConditionAuditoryCenter",
                      @"CueConditionAuditoryDouble",
                      @"CueConditionAuditoryLeft",
                      @"CueConditionAuditoryRight",
                      
                      
                      ];
    CueCondition result = [data indexOfObject:string];
    return result;
}

+ (NSDictionary*)CueConditionString
{
    return @{
             @(CueConditionCenter): @"CueConditionCenter",
             @(CueConditionDouble): @"CueConditionDouble",
             @(CueConditionNone): @"CueConditionNone",
             @(CueConditionSpatialDown): @"CueConditionSpatialDown",
             @(CueConditionSpatialUp): @"CueConditionSpatialUp",
             
             @(CueConditionAuditoryNone): @"CueConditionAuditoryNone",
             @(CueConditionAuditoryCenter): @"CueConditionAuditoryCenter",
             @(CueConditionAuditoryDouble): @"CueConditionAuditoryDouble",
             @(CueConditionAuditoryLeft): @"CueConditionAuditoryLeft",
             @(CueConditionAuditoryRight): @"CueConditionAuditoryRight",
             };
}

+ (Stimulus)StimulusFrom:(NSString*)string
{
    NSArray* data = @[
                      @"StimulusNeutralLeft",
                      @"StimulusNeutralRight",
                      @"StimulusCongruentLeft",
                      @"StimulusCongruentRight",
                      @"StimulusIncongruentLeft",
                      @"StimulusIncongruentRight",
                      
                          
                      @"StimulusAuditoryNeutralLow",
                      @"StimulusAuditoryNeutralHigh",
                      @"StimulusAuditoryCongruentLow",
                      @"StimulusAuditoryCongruentHigh",
                      @"StimulusAuditoryIncongruentLow",
                      @"StimulusAuditoryIncongruentHigh",
                      
                          
                          ];
    Stimulus result = [data indexOfObject:string];
    return result;
}

+ (SensoryModality)SensoryModalityFrom:(NSString*)string
{
    NSArray* data = @[    @"Visual",
                          @"Auditory",
                    ];
    SensoryModality result = [data indexOfObject:string];
    return result;
}



+ (NSDictionary*)StimulusString
{
    return @{
             @(StimulusNeutralLeft): @"StimulusNeutralLeft",
             @(StimulusNeutralRight): @"StimulusNeutralRight",
             @(StimulusCongruentLeft): @"StimulusCongruentLeft",
             @(StimulusCongruentRight): @"StimulusCongruentRight",
             @(StimulusIncongruentLeft): @"StimulusIncongruentLeft",
             @(StimulusIncongruentRight): @"StimulusIncongruentRight",
             
             @(StimulusAuditoryNeutralLow): @"StimulusAuditoryNeutralLow",
             @(StimulusAuditoryNeutralHigh): @"StimulusAuditoryNeutralHigh",
             @(StimulusAuditoryCongruentLow): @"StimulusAuditoryCongruentLow",
             @(StimulusAuditoryCongruentHigh): @"StimulusAuditoryCongruentHigh",
             @(StimulusAuditoryIncongruentLow): @"StimulusAuditoryIncongruentLow",
             @(StimulusAuditoryIncongruentHigh): @"StimulusAuditoryIncongruentHigh",
             
             
             };
}

+ (NSDictionary*)SensoryModalityString
{
    return @{   @(SensoryModalityVisual): @"Visual",
                @(SensoryModalityAuditory): @"Auditory",
                };
}

+ (TargetLocation)TargetLocationFrom:(NSString*)string
{
    NSArray* data = @[@"TargetLocationUp",
                      @"TargetLocationDown",
                      @"TargetLocationAuditoryLeft",
                      @"TargetLocationAuditoryRight"];
    TargetLocation result = [data indexOfObject:string];    
    return result;
}

+ (NSDictionary*)TargetLocationString
{
    return @{
             @(TargetLocationUp): @"TargetLocationUp",
             @(TargetLocationDown): @"TargetLocationDown",

             @(TargetLocationAuditoryLeft): @"TargetLocationAuditoryLeft",
             @(TargetLocationAuditoryRight): @"TargetLocationAuditoryRight"
             };
}
@end
