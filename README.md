# Integrate the GVL in a React Native project


## iOS


### Integrate pods


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

### Bridge to GVL

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

To pass the GVL results from the `GiniVisionResultsDelegate` back to JavaScript you may use [promises](https://facebook.github.io/react-native/docs/native-modules-ios#promises).

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

### Call from JavaScript

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

## Android

### Add the Gini Vision Library dependencies

Add the Gini maven repo and the Gini libraries to your Gradle build files:

```Groovy
repositories {
    maven {
        url 'https://repo.gini.net/nexus/content/repositories/open'
    }
}

dependencies {
    implementation "net.gini:gini-vision-lib:3.11.3" // or the latest version
    implementation "net.gini:gini-vision-network-lib:3.11.3" // or the latest version
}
```

### Bridge to GVL

Create a Java Native Module in which you start the Gini Vision Library and pass the result back to JavaScript.

```Java

public class GiniBridge extends ReactContextBaseJavaModule {

    (...)

    private Promise mPromise;

    public GiniBridge(@NonNull final ReactApplicationContext reactContext) {
        super(reactContext);

        reactContext.addActivityEventListener(new BaseActivityEventListener() {
            @Override
            public void onActivityResult(final Activity activity, final int requestCode,
                    final int resultCode,
                    final Intent data) {

                (...)
                
                mPromise.resolve("resultCode " + resultCode);
            }
        });
    }

    (...)

    @ReactMethod
    public void showGini(final Promise promise) {

        (...)

        GiniVisionNetworkService giniNetworkService = (...)

        GiniVision.newInstance()
                .setGiniVisionNetworkService(giniNetworkService)
                .build();

        final Intent intent = new Intent(currentActivity, CameraActivity.class);
        currentActivity.startActivityForResult(intent, GINI_REQUEST_CODE);
    }
}

```

This class implements the `showGini` method you will be able to call from JavaScript. You need to create the `GiniVisionNetworkService` with your client credentials and the `GiniVision` instance. Finally you need to start the `CameraActivity` for result. Please refer to the example app to see how it can be done.

To register the Native Module you have to create a custom `ReactPackage`.

```Java
public class GiniPackage implements ReactPackage {

    @NonNull
    @Override
    public List<NativeModule> createNativeModules(
            @NonNull final ReactApplicationContext reactContext) {
        List<NativeModule> modules = new ArrayList<>();
        modules.add(new GiniBridge(reactContext));
        return modules;
    }

    (...)
}
```

Finally in your `ReactApplication` subclass you need to add your custom package manually.

```Java
private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
            
            (...)

            @Override
            protected List<ReactPackage> getPackages() {
                List<ReactPackage> packages = new PackageList(this).getPackages();
                packages.add(new GiniPackage());
                return packages;
            }

            (...)

        };
```

### Call from JavaScript

Now you can call into `GiniBridge.showGini()` through `NativeModules` and wait for the result. For example:

```JavaScript

class RNGiniBridge extends Component {

  constructor(props) {
    super(props);

    this.handleLaunchGini = this.handleLaunchGini.bind(this);
  }

  async handleLaunchGini() {
    const result = await NativeModules.GiniBridge.showGini();
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          GiniVision
        </Text>
        <Button
          title="Launch"
          onPress={this.handleLaunchGini}
        />
      </View>
    );
  }
}

AppRegistry.registerComponent('giniReactnative', () => RNGiniBridge);

```
