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
@property (nonatomic) enum {Active, Failed, Completed} status;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSMutableArray *values;
@end

@implementation RKWSignalMatcher {
    BOOL(^_block)(RKWSignalMatcher *matcher);
    NSString *_description;
}

#pragma mark - Nil-handling:

static inline NSObject *
NilPlaceholder(void)
{
    static NSObject *placeholder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placeholder = [NSObject new];
    });
    return placeholder;
}

static inline NSObject *
PackValue(NSObject *x) 
{
    return x ? x : NilPlaceholder();
}

static inline NSObject *
UnpackValue(NSObject *x) 
{
    return (x == NilPlaceholder()) ? nil : x;
}


#pragma mark - KWMatcher:

+ (BOOL)canMatchSubject:(id)anObject
{
    return [anObject isKindOfClass:RACSignal.class];
}

- (id)initWithSubject:(RACSignal *)anObject
{
    self = [super initWithSubject:anObject];
    if (!self)
        return nil;

    _values = [NSMutableArray new];
    
    [anObject subscribeNext:^(id x) {
        [self.values addObject:PackValue(x)];
    } error:^(NSError *error) {
        self.error = error;
        self.status = Failed;
    } completed:^{
        self.status = Completed;
    }];
    
    return self;
}

- (BOOL)evaluate
{
    NSAssert(_block != nil, @"No block defined by matcher '%@'", self);
    return _block(self);
}

- (NSString *)failureMessageForShould
{
    return [NSString stringWithFormat:@"expected signal to %@", _description];
}

- (NSString *)failureMessageForShouldNot
{
    return [NSString stringWithFormat:@"expected signal not to %@", _description];
}

- (NSString *)description
{
    return _description;
}


#pragma mark - Signal matchers:

+ (NSArray *)matcherStrings
{
    return @[@"complete", @"send:"];
}

- (void)complete
{
    _description = @"complete";
    _block = ^BOOL(RKWSignalMatcher *self) {
        return self.status == Completed;
    };
}

- (void)send:(id)value
{
    _description = [NSString stringWithFormat:@"send %@", value];
    _block = ^BOOL(RKWSignalMatcher *self) {
        return [self.values containsObject:PackValue(value)];
    };
}

@end
