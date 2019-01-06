#!/bin/bash

set -e

cd CppReactNative

cat <<'EOT' > ios/ReactBridge/RCTHelloWorld.m
#import "RCTHelloWorld.h"
#import "HWHelloWorld.h"
@implementation RCTHelloWorld{
  HWHelloWorld *_cppApi;
}
- (RCTHelloWorld *)init
{
  self = [super init];
  _cppApi = [HWHelloWorld create];
  return self;
}
+ (BOOL)requiresMainQueueSetup
{
  return NO;
}
RCT_EXPORT_MODULE();
RCT_REMAP_METHOD(sayHello,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *response = [_cppApi getHelloWorld];
  resolve(response);
}
@end
EOT

echo "Configure Xcode by adding the following files:"
echo ""
echo "Add the following groups:"
echo " * ObjCBridge"
echo " * Djinni"
echo " * CppSrc"
echo ""
echo "Add the following files one by one to the groups:"
echo " 1. 'ObjCBridge' -> './djinni/objc/*'"
echo " 2. 'ObjCBridge' -> '/djinni/cpp/hello_world.hpp'"
echo " 3. 'Djinni' -> './node_modules/djinni/support-lib/objc/*'"
echo " 4. 'CppSrc' -> './src/cpp/*'"
echo ""
echo "Build your project. "
echo ""
echo "Press Enter when you are ready to prepare your Android distribution"
read

mkdir -p ./android/app/src/main/jni

cat <<'EOT' > android/app/src/main/jni/Android.mk
LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
NDK_DEBUG=1
LOCAL_CPPFLAGS := -std=c++14
LOCAL_CPPFLAGS += -fexceptions
LOCAL_CPPFLAGS += -frtti
LOCAL_CPPFLAGS += -Wall
LOCAL_CPPFLAGS += -Wextra
LOCAL_CPPFLAGS += -I$(LOCAL_PATH)/../../../../../djinni/jni
LOCAL_CPPFLAGS += -I$(LOCAL_PATH)/../../../../../djinni/cpp
LOCAL_CPPFLAGS += -I$(LOCAL_PATH)/../../../../../node_modules/djinni/support-lib/jni
LOCAL_CPPFLAGS += -I$(LOCAL_PATH)/../../../../../node_modules/djinni/support-lib
LOCAL_CPPFLAGS += -I$(LOCAL_PATH)/../../../../../src/cpp
LOCAL_SRC_FILES += $(LOCAL_PATH)/../../../../../djinni/jni/NativeHelloWorld.cpp
LOCAL_SRC_FILES += $(wildcard $(LOCAL_PATH)/../../../../../src/cpp/*.cpp)
LOCAL_SRC_FILES += $(wildcard $(LOCAL_PATH)/../../../../../node_modules/djinni/support-lib/jni/*.cpp)
LOCAL_SRC_FILES += $(wildcard $(LOCAL_PATH)/../../../../../node_modules/djinni/support-lib/*.cpp)
LOCAL_MODULE := helloworld
include $(BUILD_SHARED_LIBRARY)
EOT


cat <<'EOT' > android/app/src/main/jni/Application.mk
APP_STL := c++_static
EOT

cat <<'EOT' > ./android/app/build.gradle
apply plugin: "com.android.application"

import com.android.build.OutputFile

/**
 * The react.gradle file registers a task for each build variant (e.g. bundleDebugJsAndAssets
 * and bundleReleaseJsAndAssets).
 * These basically call `react-native bundle` with the correct arguments during the Android build
 * cycle. By default, bundleDebugJsAndAssets is skipped, as in debug/dev mode we prefer to load the
 * bundle directly from the development server. Below you can see all the possible configurations
 * and their defaults. If you decide to add a configuration block, make sure to add it before the
 * `apply from: "../../node_modules/react-native/react.gradle"` line.
 *
 * project.ext.react = [
 *   // the name of the generated asset file containing your JS bundle
 *   bundleAssetName: "index.android.bundle",
 *
 *   // the entry file for bundle generation
 *   entryFile: "index.android.js",
 *
 *   // whether to bundle JS and assets in debug mode
 *   bundleInDebug: false,
 *
 *   // whether to bundle JS and assets in release mode
 *   bundleInRelease: true,
 *
 *   // whether to bundle JS and assets in another build variant (if configured).
 *   // See http://tools.android.com/tech-docs/new-build-system/user-guide#TOC-Build-Variants
 *   // The configuration property can be in the following formats
 *   //         'bundleIn${productFlavor}${buildType}'
 *   //         'bundleIn${buildType}'
 *   // bundleInFreeDebug: true,
 *   // bundleInPaidRelease: true,
 *   // bundleInBeta: true,
 *
 *   // whether to disable dev mode in custom build variants (by default only disabled in release)
 *   // for example: to disable dev mode in the staging build type (if configured)
 *   devDisabledInStaging: true,
 *   // The configuration property can be in the following formats
 *   //         'devDisabledIn${productFlavor}${buildType}'
 *   //         'devDisabledIn${buildType}'
 *
 *   // the root of your project, i.e. where "package.json" lives
 *   root: "../../",
 *
 *   // where to put the JS bundle asset in debug mode
 *   jsBundleDirDebug: "$buildDir/intermediates/assets/debug",
 *
 *   // where to put the JS bundle asset in release mode
 *   jsBundleDirRelease: "$buildDir/intermediates/assets/release",
 *
 *   // where to put drawable resources / React Native assets, e.g. the ones you use via
 *   // require('./image.png')), in debug mode
 *   resourcesDirDebug: "$buildDir/intermediates/res/merged/debug",
 *
 *   // where to put drawable resources / React Native assets, e.g. the ones you use via
 *   // require('./image.png')), in release mode
 *   resourcesDirRelease: "$buildDir/intermediates/res/merged/release",
 *
 *   // by default the gradle tasks are skipped if none of the JS files or assets change; this means
 *   // that we don't look at files in android/ or ios/ to determine whether the tasks are up to
 *   // date; if you have any other folders that you want to ignore for performance reasons (gradle
 *   // indexes the entire tree), add them here. Alternatively, if you have JS files in android/
 *   // for example, you might want to remove it from here.
 *   inputExcludes: ["android/**", "ios/**"],
 *
 *   // override which node gets called and with what additional arguments
 *   nodeExecutableAndArgs: ["node"],
 *
 *   // supply additional arguments to the packager
 *   extraPackagerArgs: []
 * ]
 */

project.ext.react = [
    entryFile: "index.js"
]

apply from: "../../node_modules/react-native/react.gradle"

/**
 * Set this to true to create two separate APKs instead of one:
 *   - An APK that only works on ARM devices
 *   - An APK that only works on x86 devices
 * The advantage is the size of the APK is reduced by about 4MB.
 * Upload all the APKs to the Play Store and people will download
 * the correct one based on the CPU architecture of their device.
 */
def enableSeparateBuildPerCPUArchitecture = false

/**
 * Run Proguard to shrink the Java bytecode in release builds.
 */
def enableProguardInReleaseBuilds = false

android {
    compileSdkVersion rootProject.ext.compileSdkVersion
    buildToolsVersion rootProject.ext.buildToolsVersion

    defaultConfig {
        applicationId "com.cppreactnative"
        minSdkVersion rootProject.ext.minSdkVersion
        targetSdkVersion rootProject.ext.targetSdkVersion
        versionCode 1
        versionName "1.0"
        ndk {
            abiFilters "armeabi-v7a", "x86"
            moduleName "helloworld"
            ldLibs "log"
        }
    }
    splits {
        abi {
            reset()
            enable enableSeparateBuildPerCPUArchitecture
            universalApk false  // If true, also generate a universal APK
            include "armeabi-v7a", "x86"
        }
    }
    sourceSets {
        main {
            java.srcDirs = ["../../djinni/java", "src/main/java"]
            jni.srcDirs = ["../../djinni/jni"]
        }
    }
    externalNativeBuild {
        ndkBuild {
            path file('src/main/jni/Android.mk')
        }
    }
    buildTypes {
        release {
            minifyEnabled enableProguardInReleaseBuilds
            proguardFiles getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro"
        }
    }
    // applicationVariants are e.g. debug, release
    applicationVariants.all { variant ->
        variant.outputs.each { output ->
            // For each separate APK per architecture, set a unique version code as described here:
            // http://tools.android.com/tech-docs/new-build-system/user-guide/apk-splits
            def versionCodes = ["armeabi-v7a":1, "x86":2]
            def abi = output.getFilter(OutputFile.ABI)
            if (abi != null) {  // null for the universal-debug, universal-release variants
                output.versionCodeOverride =
                        versionCodes.get(abi) * 1048576 + defaultConfig.versionCode
            }
        }
    }
}

dependencies {
    implementation fileTree(dir: "libs", include: ["*.jar"])
    implementation "com.android.support:appcompat-v7:${rootProject.ext.supportLibVersion}"
    implementation "com.facebook.react:react-native:+"  // From node_modules
}

// Run this once to be able to run the application with BUCK
// puts all compile dependencies into folder libs for BUCK to use
task copyDownloadableDepsToLibs(type: Copy) {
    from configurations.compile
    into 'libs'
}
EOT

cat <<'EOT' > ./android/app/src/main/java/com/cppreactnative/helloworld/HelloWorldModule.java

package com.cppreactnative.helloworld;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

public class HelloWorldModule extends ReactContextBaseJavaModule {
  
    // Add the following lines
    private HelloWorld cppApi; // instance var for our cppApi
  
    static {
        System.loadLibrary("helloworld"); // load the "helloworld" JNI module
    }
  
    public HelloWorldModule(ReactApplicationContext reactContext) {
        super(reactContext); 
        cppApi = HelloWorld.create(); // create a new instance of our cppApi
    }
  
    @Override
    public String getName() {
        return "HelloWorld";
    }
  
    @ReactMethod
    public void sayHello(Promise promise) { 
        // call the "getHelloWorld()" method on our C++ class and get the results.
        String myString = cppApi.getHelloWorld();
        promise.resolve(myString);
    }
}
EOT
