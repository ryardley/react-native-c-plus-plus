#!/bin/bash

set -e

npx -p react-native-cli react-native init CppReactNative && cd ./CppReactNative

cat <<'EOT' > ./App.js
// @flow
import React, { Component } from "react";
import { NativeModules, StyleSheet, Text, View } from "react-native";
type Props = {};
type State = { message: string };
const { HelloWorld } = NativeModules;
export default class App extends Component<Props, State> {
  state = {
    message: "loading..."
  };
  async componentDidMount() {
    try {
      const message = await HelloWorld.sayHello();
      this.setState({
        message
      });
    } catch(e) {
      alert(e);
    }
  }
  render() {
    const { message } = this.state;
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>Message from Native:</Text>
        <Text style={styles.welcome}>"{message}"</Text>
      </View>
    );
  }
}
const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#F5FCFF"
  },
  welcome: {
    fontSize: 20,
    textAlign: "center",
    margin: 10
  }
});
EOT

mkdir -p ios/ReactBridge

cat <<'EOT' > ./ios/ReactBridge/RCTHelloWorld.h
#import <React/RCTBridgeModule.h>

@interface RCTHelloWorld : NSObject <RCTBridgeModule>
@end
EOT

cat <<'EOT' > ./ios/ReactBridge/RCTHelloWorld.m
#import "RCTHelloWorld.h"

@implementation RCTHelloWorld

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(sayHello,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
  resolve(@"Hello from Objective-C");
}
@end
EOT

open ios/CppReactNative.xcodeproj

echo "Configure Xcode and hit return when ready."
read

echo "Building Android React Native Bridge"

mkdir -p ./android/app/src/main/java/com/cppreactnative/helloworld

cat <<'EOT' > android/app/src/main/java/com/cppreactnative/helloworld/HelloWorldModule.java
package com.cppreactnative.helloworld;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

public class HelloWorldModule extends ReactContextBaseJavaModule {

    public HelloWorldModule(ReactApplicationContext reactContext) {
        super(reactContext); //required by React Native
    }

    @Override
    public String getName() {
        return "HelloWorld"; //HelloWorld is how this module will be referred to from React Native
    }

    @ReactMethod
    public void sayHello(Promise promise) { //this method will be called from JS by React Native
        promise.resolve("Hello from Android");
    }
}
EOT

cat <<'EOT' > android/app/src/main/java/com/cppreactnative/helloworld/HelloWorldPackage.java
package com.cppreactnative.helloworld;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class HelloWorldPackage implements ReactPackage {

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        return Collections.emptyList();
    }

    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        List<NativeModule> modules = new ArrayList<>();

        modules.add(new HelloWorldModule(reactContext)); //this is where we register our module, and any others we may later add

        return modules;
    }
}
EOT

cat <<'EOT' > android/app/src/main/java/com/cppreactnative/MainApplication.java
package com.cppreactnative;

import android.app.Application;

import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.soloader.SoLoader;

import com.cppreactnative.helloworld.HelloWorldPackage;

import java.util.Arrays;
import java.util.List;

public class MainApplication extends Application implements ReactApplication {

  private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
    @Override
    public boolean getUseDeveloperSupport() {
      return BuildConfig.DEBUG;
    }

    @Override
    protected List<ReactPackage> getPackages() {
      return Arrays.<ReactPackage>asList(
          new MainReactPackage(),
          new HelloWorldPackage()
      );
    }

    @Override
    protected String getJSMainModuleName() {
      return "index";
    }
  };

  @Override
  public ReactNativeHost getReactNativeHost() {
    return mReactNativeHost;
  }

  @Override
  public void onCreate() {
    super.onCreate();
    SoLoader.init(this, /* native exopackage */ false);
  }
}
EOT

