# ML Kit OCR Missing Classes Fix
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Keep ML Kit classes
-keep class com.google.mlkit.** { *; }
-keep interface com.google.mlkit.** { *; }
