#!/bin/bash

set -e

cd CppReactNative

yarn add --dev dropbox/djinni#51bf14f228579a78bc979f0e57c6849a708ed8aa

cat <<'EOT' > ./helloworld.djinni
hello_world = interface +c {
  static create(): hello_world;
  get_hello_world(): string;
}
EOT


cat <<'EOT' > ./run_djinni.sh
#!/usr/bin/env bash
### Configuration
# Djinni IDL file location
djinni_file="helloworld.djinni"
# C++ namespace for generated src
namespace="helloworld"
# Objective-C class name prefix for generated src
objc_prefix="HW"
# Java package name for generated src
java_package="com.cppreactnative.helloworld"


### Script
# get base directory
base_dir=$(cd "`dirname "0"`" && pwd)
# get java directory from package name
java_dir=$(echo $java_package | tr . /)
# output directories for generated src
cpp_out="$base_dir/djinni/cpp"
objc_out="$base_dir/djinni/objc"
jni_out="$base_dir/djinni/jni"
java_out="$base_dir/djinni/java/$java_dir"
# clean generated src dirs
rm -rf $cpp_out
rm -rf $jni_out
rm -rf $objc_out
rm -rf $java_out 
# execute the djinni command
./node_modules/djinni/src/run \
   --java-out $java_out \
   --java-package $java_package \
   --ident-java-field mFooBar \
   --cpp-out $cpp_out \
   --cpp-namespace $namespace \
   --jni-out $jni_out \
   --ident-jni-class NativeFooBar \
   --ident-jni-file NativeFooBar \
   --objc-out $objc_out \
   --objc-type-prefix $objc_prefix \
   --objcpp-out $objc_out \
   --idl $djinni_file
EOT

chmod +x ./run_djinni.sh

./run_djinni.sh

mkdir -p ./src/cpp

cat <<'EOT' > ./src/cpp/hello_world_impl.hpp
#pragma once
 
#include "hello_world.hpp"
 
namespace helloworld {
    
    class HelloWorldImpl : public helloworld::HelloWorld {
        
    public:
        
        // Constructor
        HelloWorldImpl();
        
        // Our method that returns a string
        std::string get_hello_world();
        
    };
    
}
EOT

cat <<'EOT' > ./src/cpp/hello_world_impl.cpp
#include "hello_world_impl.hpp"
#include <string>
 
namespace helloworld {
    
    std::shared_ptr<HelloWorld> HelloWorld::create() {
        return std::make_shared<HelloWorldImpl>();
    }
    
    HelloWorldImpl::HelloWorldImpl() {
 
    }
    
    std::string HelloWorldImpl::get_hello_world() {
        std::string myString = "C++ says Hello World!";
        return myString;
    }   
}
EOT

