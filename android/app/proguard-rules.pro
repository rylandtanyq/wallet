# Play Core 和 Split Install 相关类
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
# 保留Google Tink相关类
-keep class com.google.crypto.tink.** { *; }

# 保留javax.lang.model相关类
-keep class javax.lang.model.** { *; }

# 保留error-prone注解
-keep class com.google.errorprone.annotations.** { *; }

# 保留注解属性
-keepattributes *Annotation*,Signature,InnerClasses

# 保留所有注解类
-keep @interface *
# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn javax.lang.model.element.Modifier
# 保留所有注解
-keepattributes *Annotation*
# Flutter 动态组件相关
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# Flutter core
-keep class io.flutter.** { *; }

# InAppWebView
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }

# 保留 WebView 通信类
-keepclassmembers class * extends android.webkit.WebViewClient { *; }
-keepclassmembers class * extends android.webkit.WebChromeClient { *; }
