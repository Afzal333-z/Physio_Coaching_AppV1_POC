# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep Capacitor classes
-keep class com.getcapacitor.** { *; }
-keep class com.capacitorjs.** { *; }

# Keep React classes
-keep class com.facebook.react.** { *; }
-keep class com.facebook.hermes.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep MediaPipe classes if bundled
-keep class com.google.mediapipe.** { *; }

