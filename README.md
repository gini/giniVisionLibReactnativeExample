Integrate the GVL in a React Native project on iOS
=============================

1. Integrate pods
----------------------

Add the pod source to your Podfile

```bash
source 'https://github.com/gini/gini-podspecs.git'
```

Make sure you use the `use_frameworks!` directive.

Specify the pods

```bash
pod 'GiniVision'
pod 'GiniVision/Networking'
```

2. Bridge to GVL
----------------------

Add a Swift file, e.g. `GiniBridge.swift` to your project. If asked, create the bridging header file.

```Swift
import Foundation
import GiniVision
import Gini

@objc(GiniBridge)
class GiniBridge: NSObject {

  private lazy var giniConfiguration: GiniConfiguration = {...}()

  private weak var gvlViewController: UIViewController?
  
  @objc func showGini() {
    
    DispatchQueue.main.async {
      
      let client = ...
      
      let vc = GiniVision.viewController(withClient: client,
                                         importedDocuments: nil,
                                         configuration: self.giniConfiguration,
                                         resultsDelegate: self,
                                         documentMetadata: nil)
      
      self.gvlViewController = vc
            
      UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
    }
  }
}
```

This class implements the `showGini` function you will be able to call from JavaScript. You need to create the 
`GiniConfiguration` and `Client` with your credentials as well as implement the `GiniVisionResultsDelegate`. 
Please refer to the example app to see how it can be done.

To make this work you need to add some Objective-C. To expose `showGini` create a `GiniBridge.m` file:

```Objective-C
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(GiniBridge, NSObject)

RCT_EXTERN_METHOD(showGini)

+ (BOOL)requiresMainQueueSetup {
  return TRUE;
}

@end

```

3. Call from JavaScript
----------------------

You can call into `GiniBridge.showGini()` through `NativeModules`. For example:

```JavaScript

import React, { Component } from 'react';

import {
    AppRegistry,
    View,
    NativeModules,
} from 'react-native';

class RNGiniBridge extends Component {
    
    render() {
        return (
                <View>
                <Button
                title="Launch GVL"
                onPress={() => NativeModules.GiniBridge.showGini() }
                />
                </View>
                );
    }
}

AppRegistry.registerComponent('giniReactnative', () => RNGiniBridge);

```
