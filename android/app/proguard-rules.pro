# Keep all ML Kit vision classes (text recognition uses dynamic feature splits).
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_internal.** { *; }

# Silence warnings from ML Kit shading.
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.internal.mlkit_vision_common.**
-dontwarn com.google.android.gms.internal.mlkit_vision_text_common.**
-dontwarn com.google.android.gms.internal.mlkit_vision_text_internal.**

