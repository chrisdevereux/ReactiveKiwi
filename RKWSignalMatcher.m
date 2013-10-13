//
//  RKWTestHelpers.m
//  Project
//
//  Created by Chris Devereux on 11/10/2013.
//  Copyright (c) 2013 TouchFirst. All rights reserved.
//

#import "RKWSignalMatcher.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RKWSignalMatcher ()
@property (nonatomic) enum {Waiting, Failed, Completed} status;
@property (strong, nonatomic) NSError *error;
@end

@implementation RKWSignalMatcher

+ (BOOL)canMatchSubject:(id)anObject
{
    return [anObject isKindOfClass:RACSignal.class];
}

- (id)initWithSubject:(RACSignal *)anObject
{
    self = [super initWithSubject:anObject];
    if (!self)
        return nil;
    
    [anObject subscribeError:^(NSError *error) {
        self.error = error;
        self.status = Failed;
    } completed:^{
        self.status = Completed;
    }];
    
    return self;
}

+ (NSArray *)matcherStrings
{
    return @[@"complete"];
}

- (void)complete
{
    
}

- (BOOL)evaluate
{
    return self.status == Completed;
}

- (NSString *)failureMessageForShould
{
    if (self.status == Failed) {
        return [NSString stringWithFormat:@"expected signal to complete, but raised error: %@", self.error];
    } else {
        return @"expected signal to complete, but did not";
    }
}

- (NSString *)failureMessageForShouldNot
{
    return @"expected signal not to complete, but signal completed";
}

- (NSString *)description
{
    return @"complete";
}

@end
