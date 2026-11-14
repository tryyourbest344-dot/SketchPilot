#!/usr/bin/env bash
set -euo pipefail

ROOT="SketchPilot"
rm -rf "$ROOT" SketchPilot.zip

mkdir -p \
  "$ROOT/gradle/wrapper" \
  "$ROOT/app/src/main/java/com/sketchpilot/app/model" \
  "$ROOT/app/src/main/java/com/sketchpilot/app/state" \
  "$ROOT/app/src/main/java/com/sketchpilot/app/processing" \
  "$ROOT/app/src/main/java/com/sketchpilot/app/service" \
  "$ROOT/app/src/main/java/com/sketchpilot/app/ui" \
  "$ROOT/app/src/main/res/xml" \
  "$ROOT/app/src/main/res/values" \
  "$ROOT/app/src/main/res/drawable" \
  "$ROOT/app/src/main/res/layout"

cat <<'EOF' > "$ROOT/settings.gradle.kts"
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "SketchPilot"
include(":app")
EOF

cat <<'EOF' > "$ROOT/build.gradle.kts"
plugins {
    id("com.android.application") version "9.3.1" apply false
}
EOF

cat <<'EOF' > "$ROOT/gradle.properties"
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.nonTransitiveRClass=true
EOF

cat <<'EOF' > "$ROOT/gradle/wrapper/gradle-wrapper.properties"
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-9.5.0-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

cat <<'EOF' > "$ROOT/app/proguard-rules.pro"
# Add project specific ProGuard rules here.
EOF

cat <<'EOF' > "$ROOT/app/build.gradle.kts"
plugins {
    id("com.android.application")
}

android {
    namespace = "com.sketchpilot.app"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.sketchpilot.app"
        minSdk = 26
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        viewBinding = true
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.15.0")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.activity:activity-ktx:1.10.1")
    implementation("androidx.constraintlayout:constraintlayout:2.2.1")
    implementation("androidx.exifinterface:exifinterface:1.3.7")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
}
EOF

cat <<'EOF' > "$ROOT/app/src/main/AndroidManifest.xml"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <!-- INTERNET intentionally omitted for strict offline privacy -->

    <application
        android:allowBackup="false"
        android:icon="@drawable/ic_sketch_pilot"
        android:label="@string/app_name"
        android:roundIcon="@drawable/ic_sketch_pilot"
        android:supportsRtl="true"
        android:theme="@style/Theme.SketchPilot">

        <activity
            android:name=".ui.MainActivity"
            android:exported="true"
            android:screenOrientation="portrait">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <service
            android:name=".service.FloatingOverlayService"
            android:exported="false"
            android:foregroundServiceType="specialUse">
            <property
                android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
                android:value="User-initiated floating drawing controls and target canvas calibration overlay" />
        </service>

        <service
            android:name=".service.SketchAccessibilityService"
            android:exported="false"
            android:label="@string/accessibility_service_label"
            android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE">
            <intent-filter>
                <action android:name="android.accessibilityservice.AccessibilityService" />
            </intent-filter>
            <meta-data
                android:name="android.accessibilityservice"
                android:resource="@xml/accessibility_service_config" />
        </service>

    </application>
</manifest>
EOF

cat <<'EOF' > "$ROOT/app/src/main/res/xml/accessibility_service_config.xml"
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeWindowStateChanged"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:canPerformGestures="true"
    android:description="@string/accessibility_service_description"
    android:notificationTimeout="100"
    android:settingsActivity="com.sketchpilot.app.ui.MainActivity" />
EOF

cat <<'EOF' > "$ROOT/app/src/main/res/values/colors.xml"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="primary">#0066CC</color>
    <color name="surface_dark">#E61C1F26</color>
    <color name="white">#FFFFFF</color>
    <color name="black">#000000</color>
    <color name="accent_cyan">#00E5FF</color>
</resources>
EOF

cat <<'EOF' > "$ROOT/app/src/main/res/values/strings.xml"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">SketchPilot</string>
    <string name="accessibility_service_label">SketchPilot Gesture Drawer</string>
    <string name="accessibility_service_description">Replays your converted black-and-white sketch paths as touch gestures onto a calibrated screen region.</string>
</resources>
EOF

cat <<'EOF' > "$ROOT/app/src/main/res/values/themes.xml"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.SketchPilot" parent="Theme.Material3.DayNight.NoActionBar" />
</resources>
EOF

cat <<'EOF' > "$ROOT/app/src/main/res/drawable/ic_sketch_pilot.xml"
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M3,17.25V21h3.75L17.81,9.94l-3.75,-3.75L3,17.25zM20.71,7.04c0.39,-0.39 0.39,-1.02 0,-1.41l-2.34,-2.34c-0.39,-0.39 -1.02,-0.39 -1.41,0l-1.83,1.83 3.75,3.75 1.83,-1.83z" />
</vector>
EOF

cat <<'EOF' > "$ROOT/app/src/main/res/drawable/bg_bubble.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="#0066CC" />
    <stroke android:width="2dp" android:color="#00E5FF" />
</shape>
EOF

cat <<'EOF' > "$ROOT/app/src/main/res/drawable/bg_panel.xml"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <solid android:color="#EE1C1F26" />
    <corners android:radius="16dp" />
    <stroke android:width="1dp" android:color="#33FFFFFF" />
</shape>
EOF

cat <<'EOF' > "$ROOT/app/src/main/res/layout/activity_main.xml"
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="16dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical">

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="SketchPilot"
            android:textSize="26sp"
            android:textStyle="bold" />

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginBottom="12dp"
            android:text="Offline Sketch &amp; Gesture Drawer"
            android:textSize="14sp" />

        <Button
            android:id="@+id/btnPickImage"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="Select Image from Gallery" />

        <FrameLayout
            android:layout_width="match_parent"
            android:layout_height="280dp"
            android:layout_marginTop="12dp"
            android:background="#F2F2F2">

            <ImageView
                android:id="@+id/ivSketchPreview"
                android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:contentDescription="Sketch Preview"
                android:scaleType="fitCenter" />

            <ProgressBar
                android:id="@+id/progressConverting"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_gravity="center"
                android:visibility="gone" />
        </FrameLayout>

        <TextView
            android:id="@+id/tvSketchInfo"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:text="No image selected yet."
            android:textSize="13sp" />

        <TextView
            android:id="@+id/tvDetailValue"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="14dp"
            android:text="Sketch Detail: 55%" />

        <SeekBar
            android:id="@+id/seekDetail"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:max="100"
            android:progress="55" />

        <TextView
            android:id="@+id/tvSpeedValue"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="10dp"
            android:text="Drawing Speed: 750 px/s" />

        <SeekBar
            android:id="@+id/seekSpeed"
            android:layout_width="match_parent"
            android:layout_height="wrap_content" />

        <TextView
            android:id="@+id/tvMainProgress"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="14dp"
            android:text="Drawing Progress: 0%" />

        <ProgressBar
            android:id="@+id/mainProgressBar"
            style="?android:attr/progressBarStyleHorizontal"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:max="100" />

        <View
            android:layout_width="match_parent"
            android:layout_height="1dp"
            android:layout_marginVertical="16dp"
            android:background="#22000000" />

        <TextView
            android:id="@+id/tvOverlayStatus"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="Overlay Permission: Required" />

        <Button
            android:id="@+id/btnGrantOverlay"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="4dp"
            android:text="Grant Overlay Permission" />

        <TextView
            android:id="@+id/tvAccessibilityStatus"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="10dp"
            android:text="Accessibility Service: Disabled" />

        <Button
            android:id="@+id/btnEnableAccessibility"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="4dp"
            android:text="Enable Accessibility Service" />

        <Button
            android:id="@+id/btnLaunchBubble"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:text="Start Floating Bubble" />

    </LinearLayout>
</ScrollView>
EOF

cat <<'EOF' > "$ROOT/app/src/main/res/layout/overlay_bubble.xml"
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="56dp"
    android:layout_height="56dp"
    android:background="@drawable/bg_bubble"
    android:elevation="8dp"
    android:padding="14dp">

    <ImageView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:contentDescription="SketchPilot Bubble"
        android:src="@drawable/ic_sketch_pilot" />
</FrameLayout>
EOF

cat <<'EOF' > "$ROOT/app/src/main/res/layout/overlay_controls.xml"
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="270dp"
    android:layout_height="wrap_content"
    android:background="@drawable/bg_panel"
    android:elevation="10dp"
    android:orientation="vertical"
    android:padding="12dp">

    <TextView
        android:id="@+id/tvOverlayStatus"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Ready"
        android:textColor="#FFFFFF"
        android:textSize="13sp"
        android:textStyle="bold" />

    <ProgressBar
        android:id="@+id/overlayProgressBar"
        style="?android:attr/progressBarStyleHorizontal"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="6dp"
        android:max="100" />

    <TextView
        android:id="@+id/tvOverlayProgress"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="0% (0/0)"
        android:textColor="#CCFFFFFF"
        android:textSize="12sp" />

    <TextView
        android:id="@+id/tvOverlaySpeed"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="8dp"
        android:text="Speed: 750 px/s"
        android:textColor="#CCFFFFFF"
        android:textSize="12sp" />

    <SeekBar
        android:id="@+id/seekOverlaySpeed"
        android:layout_width="match_parent"
        android:layout_height="wrap_content" />

    <Button
        android:id="@+id/btnCalibrate"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="6dp"
        android:text="Calibrate Target Canvas" />

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="4dp"
        android:orientation="horizontal">

        <Button
            android:id="@+id/btnStart"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="Start" />

        <Button
            android:id="@+id/btnPauseResume"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginStart="4dp"
            android:layout_weight="1"
            android:text="Pause" />
    </LinearLayout>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="4dp"
        android:orientation="horizontal">

        <Button
            android:id="@+id/btnStop"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="Stop" />

        <Button
            android:id="@+id/btnMinimize"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginStart="4dp"
            android:layout_weight="1"
            android:text="Hide" />
    </LinearLayout>

    <Button
        android:id="@+id/btnCloseOverlay"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="4dp"
        android:text="Exit Bubble" />
</LinearLayout>
EOF

cat <<'EOF' > "$ROOT/app/src/main/res/layout/overlay_calibration.xml"
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <com.sketchpilot.app.ui.CanvasCalibrationView
        android:id="@+id/calibrationCanvasView"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />

    <LinearLayout
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom|center_horizontal"
        android:layout_marginBottom="40dp"
        android:orientation="horizontal">

        <Button
            android:id="@+id/btnCancelArea"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Cancel" />

        <Button
            android:id="@+id/btnLockArea"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginStart="12dp"
            android:text="Lock Canvas Area" />
    </LinearLayout>
</FrameLayout>
EOF

cat <<'EOF' > "$ROOT/app/src/main/java/com/sketchpilot/app/model/SketchModels.kt"
package com.sketchpilot.app.model

import android.graphics.Bitmap
import android.graphics.PointF

data class SketchData(
    val canvasWidth: Int,
    val canvasHeight: Int,
    val previewBitmap: Bitmap,
    val strokes: List<List<PointF>>,
    val totalPoints: Int
)

enum class DrawingStatus {
    IDLE,
    CALIBRATING,
    DRAWING,
    PAUSED,
    COMPLETED,
    ERROR
}

data class DrawingProgress(
    val completedStrokes: Int = 0,
    val totalStrokes: Int = 0,
    val percentage: Int = 0,
    val statusMessage: String = "Ready"
)
EOF

cat <<'EOF' > "$ROOT/app/src/main/java/com/sketchpilot/app/state/SketchSessionManager.kt"
package com.sketchpilot.app.state

import android.graphics.RectF
import com.sketchpilot.app.model.DrawingProgress
import com.sketchpilot.app.model.DrawingStatus
import com.sketchpilot.app.model.SketchData
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow

sealed interface DrawingCommand {
    data object Start : DrawingCommand
    data object Pause : DrawingCommand
    data object Resume : DrawingCommand
    data object Stop : DrawingCommand
}

object SketchSessionManager {

    private val _sketchData = MutableStateFlow<SketchData?>(null)
    val sketchData: StateFlow<SketchData?> = _sketchData.asStateFlow()

    private val _targetCanvasRect = MutableStateFlow<RectF?>(null)
    val targetCanvasRect: StateFlow<RectF?> = _targetCanvasRect.asStateFlow()

    private val _drawingStatus = MutableStateFlow(DrawingStatus.IDLE)
    val drawingStatus: StateFlow<Dr
