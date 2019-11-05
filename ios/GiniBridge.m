//
//  GiniBridge.m
//  giniReactnative
//
//  Created by Maciej Trybilo on 31.10.19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(GiniBridge, NSObject)

RCT_EXTERN_METHOD(showGini)

+ (BOOL)requiresMainQueueSetup {
  return TRUE;
}

@end
