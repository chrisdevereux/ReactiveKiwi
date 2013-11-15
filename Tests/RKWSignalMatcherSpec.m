//
//  RKWSignalMatcherSpec.m
//  Project
//
//  Created by chrisd.
//  Copyright (c) 2013. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RKWSignalMatcher.h"

SPEC_BEGIN(RKWSignalMatcherSpec)

describe(@"RKWSignalMatcher", ^{
    registerMatchers(@"RKW");
    
    describe(@"-complete", ^{
        it(@"should match when signal completes", ^{
            [[[RACSignal empty] should] complete];
        });
        
        it(@"should not match when signal does not complete", ^{
            [[[RACSignal never] shouldNot] complete];
        });
    });
    
    describe(@"-send:", ^{
        it(@"should match when value is sent", ^{
            [[[RACSignal return:@"foo"] should] send:@"foo"];
        });
        
        it(@"should not match when value is not sent", ^{
            [[[RACSignal empty] shouldNot] send:@"foo"];
        });
    });
});

SPEC_END
