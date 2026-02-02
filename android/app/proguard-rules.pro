-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Razorpay
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-keep interface com.razorpay.** {*;}
-optimizations !method/inlining/
-keepclasseswithmembers class * {
  public void onPayment*(...);
}

# Prevent obfuscation of payment callback methods
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep WebView JavaScript interface
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String);
}

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# OkHttp (used by Razorpay)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Retrofit (if used by Razorpay)
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }

# Gson (used for JSON serialization)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Google Play Services (for Razorpay SMS Retriever)
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.android.gms.auth.api.phone.** { *; }
-keep class com.google.android.gms.auth.api.credentials.** { *; }

# Google Play Core (Flutter deferred components - optional)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# SMS Retriever API - Comprehensive rules
-keep class com.google.android.gms.auth.api.phone.SmsRetriever { *; }
-keep class com.google.android.gms.auth.api.phone.SmsRetrieverReceiver { *; }
-keep class com.google.android.gms.auth.api.phone.SmsRetrieverClient { *; }
-keep class com.google.android.gms.auth.api.phone.** { *; }

# Keep all BroadcastReceivers
-keep public class * extends android.content.BroadcastReceiver {
    public <init>(...);
}

# Prevent stripping of SMS receiver
-keep class com.google.android.gms.auth.api.phone.SmsRetrieverReceiver {
    public <init>();
    public void onReceive(...);
}

# Keep all classes referenced in AndroidManifest.xml
-keep class com.razorpay.CheckoutActivity { *; }
-keep class com.yalantis.ucrop.UCropActivity { *; }

# Flutter wrapper classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }