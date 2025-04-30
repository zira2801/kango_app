# ML Kit Text Recognition Rules
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions* { *; }
-keep class com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions* { *; }
-keep class com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions* { *; }
-keep class com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions* { *; }

# Giữ các lớp liên quan đến SplitCompatApplication
-keep class com.google.android.play.core.splitcompat.** { *; }
-dontwarn com.google.android.play.core.splitcompat.**

# Giữ các lớp liên quan đến SplitInstallManager
-keep class com.google.android.play.core.splitinstall.** { *; }
-dontwarn com.google.android.play.core.splitinstall.**

# Giữ các lớp liên quan đến Task và các Listener
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.tasks.**

# Giữ các lớp liên quan đến TextRecognizerOptions
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.vision.text.**

# Giữ các lớp liên quan đến Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
