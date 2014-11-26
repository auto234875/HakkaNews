//
//  DRPocketActivity.m
//  HackerNews
//
//  Created by Daniel Rosado on 09/11/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "PocketAPI.h"
#import "DRPocketActivity.h"
#import "AppDelegate.h"
#import "UIColor+Colours.h"
@interface DRPocketActivity()
@end


@implementation DRPocketActivity {
    NSURL *_URL;
}

- (NSString *)activityType {
    return NSStringFromClass([self class]);
}

- (NSString *)activityTitle {
    return NSLocalizedStringFromTable(@"Save to Pocket", @"DRPocketActivity", nil);
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"pocketActivity"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSURL class]] && [[UIApplication sharedApplication] canOpenURL:activityItem]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSURL class]]) {
            _URL = ((NSURL*)activityItem).absoluteURL;
        }
    }
}

- (void)performActivity {
	[[PocketAPI sharedAPI] saveURL:_URL handler: ^(PocketAPI *API, NSURL *URL, NSError *error) {
        BOOL activityCompletedSuccessfully = error ? NO : YES;
        [self activityDidFinish:activityCompletedSuccessfully];
    }];
}

@end