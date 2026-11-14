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
    val drawingStatus: StateFlow<DrawingStatus> = _drawingStatus.asStateFlow()

    private val _progress = MutableStateFlow(DrawingProgress())
    val progress: StateFlow<DrawingProgress> = _progress.asStateFlow()

    private val _speedPxPerSec = MutableStateFlow(750f)
    val speedPxPerSec: StateFlow<Float> = _speedPxPerSec.asStateFlow()

    private val _isAccessibilityConnected = MutableStateFlow(false)
    val isAccessibilityConnected: StateFlow<Boolean> = _isAccessibilityConnected.asStateFlow()

    private val _isOverlayRunning = MutableStateFlow(false)
    val isOverlayRunning: StateFlow<Boolean> = _isOverlayRunning.asStateFlow()

    private val _commands = MutableSharedFlow<DrawingCommand>(extraBufferCapacity = 16)
    val commands: SharedFlow<DrawingCommand> = _commands.asSharedFlow()

    fun setSketchData(data: SketchData?) {
        _sketchData.value = data
        val total = data?.strokes?.size ?: 0
        _drawingStatus.value = DrawingStatus.IDLE
        _progress.value = DrawingProgress(
            completedStrokes = 0,
            totalStrokes = total,
            percentage = 0,
            statusMessage = if (data != null) "Sketch ready ($total strokes)" else "Select an image"
        )
    }

    fun setTargetCanvasRect(rect: RectF) {
        _targetCanvasRect.value = RectF(rect)
    }

    fun setSpeedPxPerSec(speed: Float) {
        _speedPxPerSec.value = speed.coerceIn(150f, 2500f)
    }

    fun setAccessibilityConnected(connected: Boolean) {
        _isAccessibilityConnected.value = connected
    }

    fun setOverlayRunning(running: Boolean) {
        _isOverlayRunning.value = running
    }

    fun updateStatus(status: DrawingStatus, message: String? = null) {
        _drawingStatus.value = status
        if (message != null) {
            _progress.value = _progress.value.copy(statusMessage = message)
        }
    }

    fun updateProgress(completedStrokes: Int, totalStrokes: Int, message: String) {
        val pct = if (totalStrokes > 0) {
            ((completedStrokes.toFloat() / totalStrokes) * 100f).toInt().coerceIn(0, 100)
        } else 0
        _progress.value = DrawingProgress(
            completedStrokes = completedStrokes,
            totalStrokes = totalStrokes,
            percentage = pct,
            statusMessage = message
        )
    }

    fun sendCommand(command: DrawingCommand) {
        _commands.tryEmit(command)
    }
}
EOF

cat <<'EOF' > "$ROOT/app/src/main/java/com/sketchpilot/app/processing/PathVectorizer.kt"
package com.sketchpilot.app.processing

import android.graphics.PointF
import kotlin.math.abs
import kotlin.math.hypot

object PathVectorizer {

    private val dx = intArrayOf(1, 1, 0, -1, -1, -1, 0, 1)
    private val dy = intArrayOf(0, 1, 1, 1, 0, -1, -1, -1)

    fun vectorizeAndOrder(
        edgeMap: BooleanArray,
        width: Int,
        height: Int,
        minPathPoints: Int = 4,
        rdpEpsilon: Float = 1.2f,
        minArcLength: Float = 8.0f
    ): List<List<PointF>> {
        val visited = BooleanArray(width * height)
        val rawPaths = ArrayList<List<PointF>>()

        // Pass 1: Trace from true endpoints (degree == 1) so open curves stay continuous
        for (y in 1 until height - 1) {
            val row = y * width
            for (x in 1 until width - 1) {
                val startIdx = row + x
                if (!edgeMap[startIdx] || visited[startIdx]) continue
                if (neighborCount(edgeMap, width, x, y) != 1) continue

                val traced = traceBidirectional(edgeMap, visited, width, height, x, y)
                acceptTracedPath(traced, minPathPoints, rdpEpsilon, minArcLength, rawPaths)
            }
        }

        // Pass 2: Trace remaining closed loops and junctions bidirectionally
        for (y in 1 until height - 1) {
            val row = y * width
            for (x in 1 until width - 1) {
                val startIdx = row + x
                if (!edgeMap[startIdx] || visited[startIdx]) continue

                val traced = traceBidirectional(edgeMap, visited, width, height, x, y)
                acceptTracedPath(traced, minPathPoints, rdpEpsilon, minArcLength, rawPaths)
            }
        }

        val merged = mergeNearbyStrokes(rawPaths, maxGap = 4.2f)
        return orderNearestNeighbor(merged)
    }

    private fun acceptTracedPath(
        traced: List<PointF>,
        minPathPoints: Int,
        rdpEpsilon: Float,
        minArcLength: Float,
        out: MutableList<List<PointF>>
    ) {
        if (traced.size < minPathPoints) return

        val isClosedLoop = traced.size >= 8 &&
            hypot(traced.first().x - traced.last().x, traced.first().y - traced.last().y) <= 2.5f

        val simplified = ramerDouglasPeucker(traced, rdpEpsilon)
        if (simplified.size < 2) return

        val smoothed = smoothCurvePreservingCorners(simplified)

        val result = if (isClosedLoop && smoothed.size >= 3 &&
            hypot(smoothed.first().x - smoothed.last().x, smoothed.first().y - smoothed.last().y) > 0.5f
        ) {
            ArrayList<PointF>(smoothed.size + 1).apply {
                addAll(smoothed)
                add(PointF(smoothed.first().x, smoothed.first().y))
            }
        } else {
            smoothed
        }

        if (strokeArcLength(result) >= minArcLength) {
            out.add(result)
        }
    }

    private fun smoothCurvePreservingCorners(points: List<PointF>): List<PointF> {
        if (points.size < 4) return points

        val out = ArrayList<PointF>(points.size)
        out.add(points.first())

        for (i in 1 until points.size - 1) {
            val prev = points[i - 1]
            val curr = points[i]
            val next = points[i + 1]

            val dx1 = curr.x - prev.x
            val dy1 = curr.y - prev.y
            val dx2 = next.x - curr.x
            val dy2 = next.y - curr.y
            val len1 = hypot(dx1, dy1)
            val len2 = hypot(dx2, dy2)

            if (len1 < 1e-4f || len2 < 1e-4f) {
                out.add(curr)
                continue
            }

            val dot = (dx1 * dx2 + dy1 * dy2) / (len1 * len2)
            // Keep sharp corners crisp; lightly smooth gentle curve vertices
            if (dot < 0.45f) {
                out.add(curr)
            } else {
                out.add(
                    PointF(
                        0.20f * prev.x + 0.60f * curr.x + 0.20f * next.x,
                        0.20f * prev.y + 0.60f * curr.y + 0.20f * next.y
                    )
                )
            }
        }

        out.add(points.last())
        return out
    }

    private fun mergeNearbyStrokes(
        paths: List<List<PointF>>,
        maxGap: Float
    ): List<List<PointF>> {
        if (paths.size <= 1) return paths

        val maxGapSq = maxGap * maxGap
        val working = paths.map { it.toMutableList() }.toMutableList()
        val consumed = BooleanArray(working.size)
        val result = ArrayList<List<PointF>>(working.size)

        for (i in working.indices) {
            if (consumed[i]) continue
            consumed[i] = true
            val current = working[i]

            // Do not chain closed loops onto other strokes
            if (isClosedStroke(current)) {
                result.add(current)
                continue
            }

            var extended: Boolean
            do {
                extended = false
                if (current.size < 2) break

                val tail = current.last()
                val prevTail = current[current.size - 2]
                val tx = tail.x - prevTail.x
                val ty = tail.y - prevTail.y
                val tLen = hypot(tx, ty)

                var bestJ = -1
                var bestReverse = false
                var bestDistSq = maxGapSq

                for (j in working.indices) {
                    if (consumed[j]) continue
                    val candidate = working[j]
                    if (candidate.size < 2 || isClosedStroke(candidate)) continue

                    val dStart = distSq(tail, candidate.first())
                    if (dStart < bestDistSq && isAligned(tx, ty, tLen, candidate[0], candidate[1])) {
                        bestDistSq = dStart
                        bestJ = j
                        bestReverse = false
                    }

                    val dEnd = distSq(tail, candidate.last())
                    if (dEnd < bestDistSq && isAligned(
                            tx,
                            ty,
                            tLen,
                            candidate.last(),
                            candidate[candidate.size - 2]
                        )
                    ) {
                        bestDistSq = dEnd
                        bestJ = j
                        bestReverse = true
                    }
                }

                if (bestJ != -1) {
                    consumed[bestJ] = true
                    val nextList = if (bestReverse) working[bestJ].asReversed() else working[bestJ]
                    if (distSq(tail, nextList.first()) < 1.0f && nextList.size > 1) {
                        current.addAll(nextList.subList(1, nextList.size))
                    } else {
                        current.addAll(nextList)
                    }
                    extended = true
                }
            } while (extended)

            result.add(current)
        }

        return result
    }

    private fun isClosedStroke(stroke: List<PointF>): Boolean {
        if (stroke.size < 4) return false
        return distSq(stroke.first(), stroke.last()) <= 9f
    }

    private fun isAligned(
        tx: Float,
        ty: Float,
        tLen: Float,
        c0: PointF,
        c1: PointF
    ): Boolean {
        if (tLen < 1e-4f) return false
        val cx = c1.x - c0.x
        val cy = c1.y - c0.y
        val cLen = hypot(cx, cy)
        if (cLen < 1e-4f) return false
        val dot = (tx * cx + ty * cy) / (tLen * cLen)
        return dot >= 0.35f
    }

    private fun neighborCount(edgeMap: BooleanArray, width: Int, x: Int, y: Int): Int {
        var count = 0
        for (dir in 0 until 8) {
            val nIdx = (y + dy[dir]) * width + (x + dx[dir])
            if (edgeMap[nIdx]) count++
        }
        return count
    }

    private fun traceBidirectional(
        edgeMap: BooleanArray,
        visited: BooleanArray,
        width: Int,
        height: Int,
        startX: Int,
        startY: Int
    ): List<PointF> {
        val forward = traceHalf(edgeMap, visited, width, height, startX, startY, initialPrevDir = -1)

        var backDir = -1
        for (dir in 0 until 8) {
            val nx = startX + dx[dir]
            val ny = startY + dy[dir]
            if (nx <= 0 || nx >= width - 1 || ny <= 0 || ny >= height - 1) continue
            val nIdx = ny * width + nx
            if (edgeMap[nIdx] && !visited[nIdx]) {
                backDir = dir
                break
            }
        }

        if (backDir == -1) {
            return forward
        }

        val bx = startX + dx[backDir]
        val by = startY + dy[backDir]
        val backward = traceHalf(edgeMap, visited, width, height, bx, by, initialPrevDir = backDir)

        val combined = ArrayList<PointF>(backward.size + forward.size)
        for (i in backward.indices.reversed()) {
            combined.add(backward[i])
        }
        combined.addAll(forward)
        return combined
    }

    private fun traceHalf(
        edgeMap: BooleanArray,
        visited: BooleanArray,
        width: Int,
        height: Int,
        startX: Int,
        startY: Int,
        initialPrevDir: Int
    ): List<PointF> {
        val points = ArrayList<PointF>(64)
        var cx = startX
        var cy = startY
        var prevDir = initialPrevDir

        while (true) {
            val cIdx = cy * width + cx
            visited[cIdx] = true
            points.add(PointF(cx.toFloat(), cy.toFloat()))

            var bestDir = -1
            var bestScore = Int.MAX_VALUE

            for (dir in 0 until 8) {
                val nx = cx + dx[dir]
                val ny = cy + dy[dir]
                if (nx <= 0 || nx >= width - 1 || ny <= 0 || ny >= height - 1) continue

                val nIdx = ny * width + nx
                if (!edgeMap[nIdx] || visited[nIdx]) continue

                val turnCost = if (prevDir == -1) {
                    0
                } else {
                    val diff = abs(dir - prevDir)
                    minOf(diff, 8 - diff) * 2
                }
                val orthoBias = dir and 1
                val score = turnCost + orthoBias
                if (score < bestScore) {
                    bestScore = score
                    bestDir = dir
                }
            }

            if (bestDir == -1) break
            cx += dx[bestDir]
            cy += dy[bestDir]
            prevDir = bestDir
        }

        return points
    }

    private fun ramerDouglasPeucker(points: List<PointF>, epsilon: Float): List<PointF> {
        if (points.size < 3) return points

        var maxDist = 0f
        var splitIndex = 0
        val first = points.first()
        val last = points.last()

        for (i in 1 until points.size - 1) {
            val d = perpendicularDistance(points[i], first, last)
            if (d > maxDist) {
                maxDist = d
                splitIndex = i
            }
        }

        return if (maxDist > epsilon) {
            val left = ramerDouglasPeucker(points.subList(0, splitIndex + 1), epsilon)
            val right = ramerDouglasPeucker(points.subList(splitIndex, points.size), epsilon)
            ArrayList<PointF>(left.size + right.size - 1).apply {
                addAll(left.dropLast(1))
                addAll(right)
            }
        } else {
            listOf(first, last)
        }
    }

    private fun perpendicularDistance(p: PointF, a: PointF, b: PointF): Float {
        val dxAB = b.x - a.x
        val dyAB = b.y - a.y
        val len = hypot(dxAB, dyAB)
        if (len < 1e-5f) return hypot(p.x - a.x, p.y - a.y)
        return abs(dyAB * p.x - dxAB * p.y + b.x * a.y - b.y * a.x) / len
    }

    private fun strokeArcLength(points: List<PointF>): Float {
        var total = 0f
        for (i in 0 until points.size - 1) {
            total += hypot(points[i + 1].x - points[i].x, points[i + 1].y - points[i].y)
        }
        return total
    }

    private fun orderNearestNeighbor(paths: List<List<PointF>>): List<List<PointF>> {
        if (paths.size <= 1) return paths

        val remaining = BooleanArray(paths.size) { true }
        val ordered = ArrayList<List<PointF>>(paths.size)

        var currentPos = PointF(0f, 0f)
        repeat(paths.size) {
            var bestIdx = -1
            var bestDist = Float.MAX_VALUE
            var reverseBest = false

            for (i in paths.indices) {
                if (!remaining[i]) continue
                val stroke = paths[i]
                val dStart = distSq(currentPos, stroke.first())
                val dEnd = distSq(currentPos, stroke.last())

                if (dStart < bestDist) {
                    bestDist = dStart
                    bestIdx = i
                    reverseBest = false
                }
                if (dEnd < bestDist) {
                    bestDist = dEnd
                    bestIdx = i
                    reverseBest = true
                }
            }

            if (bestIdx == -1) return ordered
            remaining[bestIdx] = false
            val chosen = if (reverseBest) paths[bestIdx].asReversed() else paths[bestIdx]
            ordered.add(chosen)
            currentPos = chosen.last()
        }

        return ordered
    }

    private fun distSq(a: PointF, b: PointF): Float {
        val dx = a.x - b.x
        val dy = a.y - b.y
        return dx * dx + dy * dy
    }
}
EOF

cat <<'EOF' > "$ROOT/app/src/main/java/com/sketchpilot/app/processing/SketchProcessor.kt"
package com.sketchpilot.app.processing

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.PointF
import android.net.Uri
import androidx.exifinterface.media.ExifInterface
import com.sketchpilot.app.model.SketchData
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.exp
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

object SketchProcessor {

    private const val MAX_WORKING_DIM = 900
    private const val MIN_WORKING_DIM = 480
    private const val TARGET_UPSCALE_DIM = 640
    private const val EDGE_BORDER_MARGIN = 6

    suspend fun processImageUri(
        context: Context,
        uri: Uri,
        detailLevel: Int = 55
    ): SketchData = withContext(Dispatchers.Default) {
        val clampedDetail = detailLevel.coerceIn(1, 100)
        val detailNorm = clampedDetail / 100f

        val rawBitmap = decodeScaledWithExif(context, uri)
            ?: throw IllegalArgumentException("Unable to decode selected image.")

        val workingBitmap = scalePreservingAspectRatio(rawBitmap)
        if (rawBitmap !== workingBitmap) {
            rawBitmap.recycle()
        }

        val width = workingBitmap.width
        val height = workingBitmap.height

        val gray = toGrayscale(workingBitmap)
        workingBitmap.recycle()

        val contrasted = stretchContrast(gray, width, height)
        val rangeSigma = 29f - detailNorm * 11f
        val denoised = bilateralFilter5x5(contrasted, width, height, rangeSigma = rangeSigma)

        val smoothed = if (clampedDetail < 35) {
            gaussianBlur5x5(denoised, width, height)
        } else {
            gaussianBlur3x3(denoised, width, height)
        }

        val edges = extractCannyThinEdges(smoothed, width, height, clampedDetail)

        if (clampedDetail >= 30) {
            mergeThinDarkLineRidges(denoised, edges, width, height, clampedDetail)
        }

        zhangSuenThin(edges, width, height, maxIterations = 25)
        removeIsolatedDots(edges, width, height)
        pruneShortSpurs(edges, width, height, maxSpurLen = 3)

        val minComponentPixels = (24f - detailNorm * 14f).roundToInt().coerceAtLeast(8)
        val minComponentSpan = (14f - detailNorm * 6f).roundToInt().coerceAtLeast(6)
        filterSmallComponents(edges, width, height, minComponentPixels, minComponentSpan)

        val rdpEpsilon = 1.55f - detailNorm * 0.65f
        val minPathPoints = if (clampedDetail >= 50) 3 else 4
        val minArcLength = 11f - detailNorm * 4f

        val strokes = PathVectorizer.vectorizeAndOrder(
            edgeMap = edges,
            width = width,
            height = height,
            minPathPoints = minPathPoints,
            rdpEpsilon = rdpEpsilon,
            minArcLength = minArcLength
        )

        val previewBitmap = renderStrokesToBitmap(strokes, width, height)

        SketchData(
            canvasWidth = width,
            canvasHeight = height,
            previewBitmap = previewBitmap,
            strokes = strokes,
            totalPoints = strokes.sumOf { it.size }
        )
    }

    private fun decodeScaledWithExif(context: Context, uri: Uri): Bitmap? {
        val resolver = context.contentResolver

        val boundsOpts = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        resolver.openInputStream(uri)?.use { stream ->
            BitmapFactory.decodeStream(stream, null, boundsOpts)
        }
        if (boundsOpts.outWidth <= 0 || boundsOpts.outHeight <= 0) return null

        val origMax = max(boundsOpts.outWidth, boundsOpts.outHeight)
        var sampleSize = 1
        while (origMax / (sampleSize * 2) >= MAX_WORKING_DIM) {
            sampleSize *= 2
        }

        val decodeOpts = BitmapFactory.Options().apply {
            inSampleSize = sampleSize
            inPreferredConfig = Bitmap.Config.ARGB_8888
        }
        val decoded = resolver.openInputStream(uri)?.use { stream ->
            BitmapFactory.decodeStream(stream, null, decodeOpts)
        } ?: return null

        val orientation = resolver.openInputStream(uri)?.use { stream ->
            ExifInterface(stream).getAttributeInt(
                ExifInterface.TAG_ORIENTATION,
                ExifInterface.ORIENTATION_NORMAL
            )
        } ?: ExifInterface.ORIENTATION_NORMAL

        val matrix = Matrix()
        when (orientation) {
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.preScale(-1f, 1f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> matrix.preScale(1f, -1f)
            ExifInterface.ORIENTATION_TRANSPOSE -> {
                matrix.postRotate(90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_TRANSVERSE -> {
                matrix.postRotate(270f)
                matrix.postScale(-1f, 1f)
            }
            else -> return decoded
        }

        val rotated = Bitmap.createBitmap(decoded, 0, 0, decoded.width, decoded.height, matrix, true)
        if (rotated !== decoded) decoded.recycle()
        return rotated
    }

    private fun scalePreservingAspectRatio(source: Bitmap): Bitmap {
        val srcW = source.width
        val srcH = source.height
        val maxSrc = max(srcW, srcH)

        val targetMax = when {
            maxSrc > MAX_WORKING_DIM -> MAX_WORKING_DIM
            maxSrc < MIN_WORKING_DIM -> TARGET_UPSCALE_DIM
            else -> maxSrc
        }

        if (targetMax == maxSrc) return source

        val scale = targetMax.toFloat() / maxSrc.toFloat()
        val outW = (srcW * scale).roundToInt().coerceAtLeast(32)
        val outH = (srcH * scale).roundToInt().coerceAtLeast(32)
        return Bitmap.createScaledBitmap(source, outW, outH, true)
    }

    private fun toGrayscale(bitmap: Bitmap): FloatArray {
        val w = bitmap.width
        val h = bitmap.height
        val pixels = IntArray(w * h)
        bitmap.getPixels(pixels, 0, w, 0, 0, w, h)
        val gray = FloatArray(w * h)
        for (i in pixels.indices) {
            val c = pixels[i]
            val a = ((c ushr 24) and 0xFF) / 255f
            val r = (c shr 16) and 0xFF
            val g = (c shr 8) and 0xFF
            val b = c and 0xFF
            val lum = 0.299f * r + 0.587f * g + 0.114f * b
            gray[i] = lum * a + 255f * (1f - a)
        }
        return gray
    }

    private fun stretchContrast(gray: FloatArray, w: Int, h: Int): FloatArray {
        val total = w * h
        if (total == 0) return gray

        val hist = IntArray(256)
        for (v in gray) {
            hist[v.roundToInt().coerceIn(0, 255)]++
        }

        val lowTarget = (total * 0.015f).roundToInt()
        val highTarget = (total * 0.985f).roundToInt()

        var acc = 0
        var lowVal = 0
        for (i in 0 until 256) {
            acc += hist[i]
            if (acc >= lowTarget) {
                lowVal = i
                break
            }
        }

        acc = 0
        var highVal = 255
        for (i in 0 until 256) {
            acc += hist[i]
            if (acc >= highTarget) {
                highVal = i
                break
            }
        }

        val span = (highVal - lowVal).toFloat()
        if (span < 18f) return gray

        // Cap contrast gain so flat/low-contrast backgrounds don't amplify sensor noise
        val scale = (255f / span).coerceAtMost(2.2f)
        val out = FloatArray(total)
        for (i in gray.indices) {
            out[i] = ((gray[i] - lowVal) * scale).coerceIn(0f, 255f)
        }
        return out
    }

    private fun bilateralFilter5x5(
        src: FloatArray,
        w: Int,
        h: Int,
        rangeSigma: Float
    ): FloatArray {
        val dst = FloatArray(w * h)
        val spatialSigma = 1.6f
        val spatialWeights = FloatArray(25)
        val invTwoSpatial = 1f / (2f * spatialSigma * spatialSigma)

        var idx = 0
        for (dy in -2..2) {
            for (dx in -2..2) {
                val distSq = (dx * dx + dy * dy).toFloat()
                spatialWeights[idx++] = exp(-distSq * invTwoSpatial)
            }
        }

        val rangeLut = FloatArray(256)
        val invTwoRange = 1f / (2f * rangeSigma * rangeSigma)
        for (d in 0 until 256) {
            rangeLut[d] = exp(-(d * d).toFloat() * invTwoRange)
        }

        for (y in 0 until h) {
            val row = y * w
            for (x in 0 until w) {
                val centerVal = src[row + x]
                var sumWeight = 0f
                var sumVal = 0f
                var k = 0

                for (dy in -2..2) {
                    val ny = (y + dy).coerceIn(0, h - 1)
                    val nRow = ny * w
                    for (dx in -2..2) {
                        val nx = (x + dx).coerceIn(0, w - 1)
                        val nVal = src[nRow + nx]
                        val diff = abs(nVal - centerVal).roundToInt().coerceIn(0, 255)
                        val weight = spatialWeights[k++] * rangeLut[diff]
                        sumWeight += weight
                        sumVal += nVal * weight
                    }
                }

                dst[row + x] = if (sumWeight > 1e-5f) sumVal / sumWeight else centerVal
            }
        }
        return dst
    }

    private fun gaussianBlur3x3(src: FloatArray, w: Int, h: Int): FloatArray {
        val temp = FloatArray(w * h)
        val dst = FloatArray(w * h)

        for (y in 0 until h) {
            val row = y * w
            for (x in 0 until w) {
                val xm = max(0, x - 1)
                val xp = min(w - 1, x + 1)
                temp[row + x] = (src[row + xm] + 2f * src[row + x] + src[row + xp]) * 0.25f
            }
        }

        for (y in 0 until h) {
            val ym = max(0, y - 1) * w
            val yc = y * w
            val yp = min(h - 1, y + 1) * w
            for (x in 0 until w) {
                dst[yc + x] = (temp[ym + x] + 2f * temp[yc + x] + temp[yp + x]) * 0.25f
            }
        }
        return dst
    }

    private fun gaussianBlur5x5(src: FloatArray, w: Int, h: Int): FloatArray {
        val temp = FloatArray(w * h)
        val dst = FloatArray(w * h)

        for (y in 0 until h) {
            val rowOffset = y * w
            for (x in 0 until w) {
                val x0 = max(0, x - 2)
                val x1 = max(0, x - 1)
                val x2 = x
                val x3 = min(w - 1, x + 1)
                val x4 = min(w - 1, x + 2)
                temp[rowOffset + x] = (
                    src[rowOffset + x0] +
                    4f * src[rowOffset + x1] +
                    6f * src[rowOffset + x2] +
                    4f * src[rowOffset + x3] +
                    src[rowOffset + x4]
                ) / 16f
            }
        }

        for (y in 0 until h) {
            val y0 = max(0, y - 2) * w
            val y1 = max(0, y - 1) * w
            val y2 = y * w
            val y3 = min(h - 1, y + 1) * w
            val y4 = min(h - 1, y + 2) * w
            for (x in 0 until w) {
                dst[y2 + x] = (
                    temp[y0 + x] +
                    4f * temp[y1 + x] +
                    6f * temp[y2 + x] +
                    4f * temp[y3 + x] +
                    temp[y4 + x]
                ) / 16f
            }
        }
        return dst
    }

    private fun extractCannyThinEdges(
        gray: FloatArray,
        w: Int,
        h: Int,
        detailLevel: Int
    ): BooleanArray {
        if (w <= EDGE_BORDER_MARGIN * 2 + 2 || h <= EDGE_BORDER_MARGIN * 2 + 2) {
            return BooleanArray(w * h)
        }

        val mag = FloatArray(w * h)
        val dir = ByteArray(w * h)

        for (y in 1 until h - 1) {
            val ym = (y - 1) * w
            val yc = y * w
            val yp = (y + 1) * w
            for (x in 1 until w - 1) {
                val gx = -gray[ym + x - 1] + gray[ym + x + 1] -
                    2f * gray[yc + x - 1] + 2f * gray[yc + x + 1] -
                    gray[yp + x - 1] + gray[yp + x + 1]

                val gy = -gray[ym + x - 1] - 2f * gray[ym + x] - gray[ym + x + 1] +
                    gray[yp + x - 1] + 2f * gray[yp + x] + gray[yp + x + 1]

                val m = hypot(gx, gy)
                val idx = yc + x
                mag[idx] = m

                var angle = Math.toDegrees(atan2(gy.toDouble(), gx.toDouble())).toFloat()
                if (angle < 0f) angle += 180f
                dir[idx] = when {
                    angle < 22.5f || angle >= 157.5f -> 0
                    angle < 67.5f -> 1
                    angle < 112.5f -> 2
                    else -> 3
                }
            }
        }

        val detailNorm = detailLevel.coerceIn(1, 100) / 100f
        val noiseFloor = 13f - detailNorm * 6f
        val nms = FloatArray(w * h)
        var maxMag = 0f
        var sigCount = 0

        for (y in EDGE_BORDER_MARGIN until h - EDGE_BORDER_MARGIN) {
            val row = y * w
            for (x in EDGE_BORDER_MARGIN until w - EDGE_BORDER_MARGIN) {
                val idx = row + x
                val m = mag[idx]
                if (m < noiseFloor) continue

                val (n1, n2) = when (dir[idx].toInt()) {
                    0 -> mag[idx - 1] to mag[idx + 1]
                    1 -> mag[idx - w + 1] to mag[idx + w - 1]
                    2 -> mag[idx - w] to mag[idx + w]
                    else -> mag[idx - w - 1] to mag[idx + w + 1]
                }

                if (m >= n1 && m >= n2) {
                    nms[idx] = m
                    if (m > maxMag) maxMag = m
                    sigCount++
                }
            }
        }

        if (sigCount == 0 || maxMag <= noiseFloor) {
            return BooleanArray(w * h)
        }

        val bins = 512
        val hist = IntArray(bins)
        val binScale = (bins - 1) / maxMag
        for (i in nms.indices) {
            val v = nms[i]
            if (v >= noiseFloor) {
                val b = (v * binScale).toInt().coerceIn(0, bins - 1)
                hist[b]++
            }
        }

        val keepFraction = 0.08f + detailNorm * 0.28f
        val targetCount = max(1, (sigCount * keepFraction).roundToInt())

        var acc = 0
        var quantileBin = bins - 1
        for (b in bins - 1 downTo 0) {
            acc += hist[b]
            if (acc >= targetCount) {
                quantileBin = b
                break
            }
        }

        val quantileHigh = quantileBin / binScale
        val minHigh = 24f - detailNorm * 10f
        val maxHigh = maxMag * (0.55f - detailNorm * 0.20f)
        val highThresh = quantileHigh.coerceIn(minHigh, max(minHigh, maxHigh))
        val lowThresh = max(noiseFloor, highThresh * 0.40f)

        val edges = BooleanArray(w * h)
        val stack = IntArray(w * h)
        var stackTop = 0

        for (y in EDGE_BORDER_MARGIN until h - EDGE_BORDER_MARGIN) {
            val row = y * w
            for (x in EDGE_BORDER_MARGIN until w - EDGE_BORDER_MARGIN) {
                val idx = row + x
                if (nms[idx] >= highThresh) {
                    edges[idx] = true
                    stack[stackTop++] = idx
                }
            }
        }

        while (stackTop > 0) {
            val idx = stack[--stackTop]
            val x = idx % w
            val y = idx / w
            if (x <= EDGE_BORDER_MARGIN || x >= w - EDGE_BORDER_MARGIN - 1 ||
                y <= EDGE_BORDER_MARGIN || y >= h - EDGE_BORDER_MARGIN - 1
            ) continue

            for (dy in -1..1) {
                val ny = (y + dy) * w
                for (dx in -1..1) {
                    if (dx == 0 && dy == 0) continue
                    val nIdx = ny + x + dx
                    if (!edges[nIdx] && nms[nIdx] >= lowThresh) {
                        edges[nIdx] = true
                        stack[stackTop++] = nIdx
                    }
                }
            }
        }

        return edges
    }

    /**
     * Captures 1-pixel centerlines of thin dark strokes (pupils, eyelashes, fine ink lines)
     * without duplicating step edges or adding bright background texture.
     */
    private fun mergeThinDarkLineRidges(
        gray: FloatArray,
        edges: BooleanArray,
        w: Int,
        h: Int,
        detailLevel: Int
    ) {
        if (w <= EDGE_BORDER_MARGIN * 2 + 2 || h <= EDGE_BORDER_MARGIN * 2 + 2) return

        val detailNorm = detailLevel.coerceIn(1, 100) / 100f
        val valleyThresh = 36f - detailNorm * 14f

        for (y in EDGE_BORDER_MARGIN until h - EDGE_BORDER_MARGIN) {
            val row = y * w
            for (x in EDGE_BORDER_MARGIN until w - EDGE_BORDER_MARGIN) {
                val idx = row + x
                if (edges[idx]) continue
                val c = gray[idx]
                if (c >= 165f) continue

                val hValley = min(gray[idx - 2], gray[idx + 2]) - c
                val hMin = c <= gray[idx - 1] && c <= gray[idx + 1]

                val vValley = min(gray[idx - 2 * w], gray[idx + 2 * w]) - c
                val vMin = c <= gray[idx - w] && c <= gray[idx + w]

                val d1Valley = min(gray[idx - 2 * w - 2], gray[idx + 2 * w + 2]) - c
                val d1Min = c <= gray[idx - w - 1] && c <= gray[idx + w + 1]

                val d2Valley = min(gray[idx - 2 * w + 2], gray[idx + 2 * w - 2]) - c
                val d2Min = c <= gray[idx - w + 1] && c <= gray[idx + w - 1]

                val isThinDarkLine =
                    (hMin && hValley >= valleyThresh) ||
                    (vMin && vValley >= valleyThresh) ||
                    (d1Min && d1Valley >= valleyThresh) ||
                    (d2Min && d2Valley >= valleyThresh)

                if (isThinDarkLine) {
                    edges[idx] = true
                }
            }
        }
    }

    private fun zhangSuenThin(img: BooleanArray, w: Int, h: Int, maxIterations: Int) {
        val toClear = ArrayList<Int>(4096)

        repeat(maxIterations) {
            var changed = false
            for (step in 0..1) {
                toClear.clear()
                for (y in 1 until h - 1) {
                    val row = y * w
                    for (x in 1 until w - 1) {
                        val idx = row + x
                        if (!img[idx]) continue

                        val p2 = if (img[idx - w]) 1 else 0
                        val p3 = if (img[idx - w + 1]) 1 else 0
                        val p4 = if (img[idx + 1]) 1 else 0
                        val p5 = if (img[idx + w + 1]) 1 else 0
                        val p6 = if (img[idx + w]) 1 else 0
                        val p7 = if (img[idx + w - 1]) 1 else 0
                        val p8 = if (img[idx - 1]) 1 else 0
                        val p9 = if (img[idx - w - 1]) 1 else 0

                        val b = p2 + p3 + p4 + p5 + p6 + p7 + p8 + p9
                        if (b < 2 || b > 6) continue

                        var a = 0
                        if (p2 == 0 && p3 == 1) a++
                        if (p3 == 0 && p4 == 1) a++
                        if (p4 == 0 && p5 == 1) a++
                        if (p5 == 0 && p6 == 1) a++
                        if (p6 == 0 && p7 == 1) a++
                        if (p7 == 0 && p8 == 1) a++
                        if (p8 == 0 && p9 == 1) a++
                        if (p9 == 0 && p2 == 1) a++
                        if (a != 1) continue

                        val cond1 = if (step == 0) (p2 * p4 * p6 == 0) else (p2 * p4 * p8 == 0)
                        val cond2 = if (step == 0) (p4 * p6 * p8 == 0) else (p2 * p6 * p8 == 0)
                        if (cond1 && cond2) {
                            toClear.add(idx)
                        }
                    }
                }
                if (toClear.isNotEmpty()) {
                    changed = true
                    for (idx in toClear) img[idx] = false
                }
            }
            if (!changed) return
        }
    }

    private fun removeIsolatedDots(edges: BooleanArray, w: Int, h: Int) {
        for (y in 1 until h - 1) {
            val row = y * w
            for (x in 1 until w - 1) {
                val idx = row + x
                if (!edges[idx]) continue
                val hasNeighbor =
                    edges[idx - w - 1] || edges[idx - w] || edges[idx - w + 1] ||
                    edges[idx - 1] || edges[idx + 1] ||
                    edges[idx + w - 1] || edges[idx + w] || edges[idx + w + 1]
                if (!hasNeighbor) {
                    edges[idx] = false
                }
            }
        }
    }

    private fun pruneShortSpurs(edges: BooleanArray, w: Int, h: Int, maxSpurLen: Int) {
        val spurBuffer = IntArray(maxSpurLen + 1)

        for (y in 1 until h - 1) {
            val row = y * w
            for (x in 1 until w - 1) {
                val startIdx = row + x
                if (!edges[startIdx]) continue
                if (countNeighbors8(edges, w, startIdx) != 1) continue

                var len = 0
                var curr = startIdx
                var prev = -1
                var hitsJunction = false

                while (len < maxSpurLen) {
                    spurBuffer[len++] = curr
                    val next = findSingleNextNeighbor(edges, w, curr, prev)
                    if (next == -1) break

                    val nx = next % w
                    val ny = next / w
                    if (nx <= 0 || nx >= w - 1 || ny <= 0 || ny >= h - 1) break

                    val deg = countNeighbors8(edges, w, next)
                    if (deg >= 3) {
                        hitsJunction = true
                        break
                    }
                    if (deg != 2) break

                    prev = curr
                    curr = next
                }

                if (hitsJunction) {
                    for (i in 0 until len) {
                        edges[spurBuffer[i]] = false
                    }
                }
            }
        }
    }

    private fun countNeighbors8(edges: BooleanArray, w: Int, idx: Int): Int {
        var count = 0
        if (edges[idx - w - 1]) count++
        if (edges[idx - w]) count++
        if (edges[idx - w + 1]) count++
        if (edges[idx - 1]) count++
        if (edges[idx + 1]) count++
        if (edges[idx + w - 1]) count++
        if (edges[idx + w]) count++
        if (edges[idx + w + 1]) count++
        return count
    }

    private fun findSingleNextNeighbor(
        edges: BooleanArray,
        w: Int,
        idx: Int,
        prevIdx: Int
    ): Int {
        val candidates = intArrayOf(
            idx - w, idx + 1, idx + w, idx - 1,
            idx - w - 1, idx - w + 1, idx + w + 1, idx + w - 1
        )
        for (c in candidates) {
            if (c != prevIdx && edges[c]) return c
        }
        return -1
    }

    private fun filterSmallComponents(
        edges: BooleanArray,
        w: Int,
        h: Int,
        minPixels: Int,
        minSpan: Int
    ) {
        val visited = BooleanArray(w * h)
        val queue = IntArray(w * h)
        val component = ArrayList<Int>(256)

        for (y in 1 until h - 1) {
            val row = y * w
            for (x in 1 until w - 1) {
                val startIdx = row + x
                if (!edges[startIdx] || visited[startIdx]) continue

                component.clear()
                var qHead = 0
                var qTail = 0
                queue[qTail++] = startIdx
                visited[startIdx] = true

                var minX = x
                var maxX = x
                var minY = y
                var maxY = y

                while (qHead < qTail) {
                    val idx = queue[qHead++]
                    component.add(idx)

                    val cx = idx % w
                    val cy = idx / w
                    if (cx < minX) minX = cx
                    if (cx > maxX) maxX = cx
                    if (cy < minY) minY = cy
                    if (cy > maxY) maxY = cy

                    if (cx <= 0 || cx >= w - 1 || cy <= 0 || cy >= h - 1) continue

                    for (dy in -1..1) {
                        val nRow = (cy + dy) * w
                        for (dx in -1..1) {
                            if (dx == 0 && dy == 0) continue
                            val nIdx = nRow + cx + dx
                            if (edges[nIdx] && !visited[nIdx]) {
                                visited[nIdx] = true
                                queue[qTail++] = nIdx
                            }
                        }
                    }
                }

                val span = max(maxX - minX, maxY - minY)
                if (component.size < minPixels && span < minSpan) {
                    for (idx in component) {
                        edges[idx] = false
                    }
                }
            }
        }
    }

    private fun renderStrokesToBitmap(
        strokes: List<List<PointF>>,
        width: Int,
        height: Int
    ): Bitmap {
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        canvas.drawColor(Color.WHITE)

        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.BLACK
            style = Paint.Style.STROKE
            strokeWidth = 2.0f
            strokeCap = Paint.Cap.ROUND
            strokeJoin = Paint.Join.ROUND
        }

        val path = android.graphics.Path()
        for (stroke in strokes) {
            if (stroke.size < 2) continue
            path.reset()
            path.moveTo(stroke[0].x, stroke[0].y)
            for (i in 1 until stroke.size) {
                path.lineTo(stroke[i].x, stroke[i].y)
            }
            canvas.drawPath(path, paint)
        }
        return bitmap
    }
}
EOF

cat <<'EOF' > "$ROOT/app/src/main/java/com/sketchpilot/app/service/SketchAccessibilityService.kt"
package com.sketchpilot.app.service

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.graphics.PointF
import android.graphics.RectF
import android.view.accessibility.AccessibilityEvent
import com.sketchpilot.app.model.DrawingStatus
import com.sketchpilot.app.model.SketchData
import com.sketchpilot.app.state.DrawingCommand
import com.sketchpilot.app.state.SketchSessionManager
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToLong

class SketchAccessibilityService : AccessibilityService() {

    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private var drawingJob: Job? = null

    @Volatile
    private var pauseRequested = false

    @Volatile
    private var stopRequested = false

    private var savedStrokeIndex = 0
    private var savedPointIndex = 0

    override fun onServiceConnected() {
        super.onServiceConnected()
        SketchSessionManager.setAccessibilityConnected(true)
        listenForCommands()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Unused: we never read other apps' screen content.
    }

    override fun onInterrupt() {
        pauseRequested = true
    }

    override fun onDestroy() {
        stopDrawingImmediately()
        SketchSessionManager.setAccessibilityConnected(false)
        serviceScope.cancel()
        super.onDestroy()
    }

    private fun listenForCommands() {
        serviceScope.launch {
            SketchSessionManager.commands.collect { cmd ->
                when (cmd) {
                    DrawingCommand.Start -> startNewDrawing()
                    DrawingCommand.Pause -> pauseDrawing()
                    DrawingCommand.Resume -> resumeDrawing()
                    DrawingCommand.Stop -> stopDrawingImmediately()
                }
            }
        }
    }

    private fun startNewDrawing() {
        val sketch = SketchSessionManager.sketchData.value
        val targetRect = SketchSessionManager.targetCanvasRect.value

        if (sketch == null || sketch.strokes.isEmpty()) {
            SketchSessionManager.updateStatus(DrawingStatus.ERROR, "Load a sketch first")
            return
        }
        if (targetRect == null || targetRect.width() < 20f || targetRect.height() < 20f) {
            SketchSessionManager.updateStatus(DrawingStatus.ERROR, "Calibrate target canvas first")
            return
        }

        drawingJob?.cancel()
        savedStrokeIndex = 0
        savedPointIndex = 0
        pauseRequested = false
        stopRequested = false

        launchReplayLoop(sketch, targetRect)
    }

    private fun pauseDrawing() {
        if (SketchSessionManager.drawingStatus.value == DrawingStatus.DRAWING) {
            pauseRequested = true
            SketchSessionManager.updateStatus(DrawingStatus.PAUSED, "Pausing...")
        }
    }

    private fun resumeDrawing() {
        if (SketchSessionManager.drawingStatus.value != DrawingStatus.PAUSED) return
        val sketch = SketchSessionManager.sketchData.value ?: return
        val targetRect = SketchSessionManager.targetCanvasRect.value ?: return

        pauseRequested = false
        stopRequested = false
        launchReplayLoop(sketch, targetRect)
    }

    private fun stopDrawingImmediately() {
        stopRequested = true
        pauseRequested = false
        drawingJob?.cancel()
        drawingJob = null
        savedStrokeIndex = 0
        savedPointIndex = 0

        val total = SketchSessionManager.sketchData.value?.strokes?.size ?: 0
        SketchSessionManager.updateStatus(DrawingStatus.IDLE)
        SketchSessionManager.updateProgress(0, total, "Stopped")
    }

    private fun launchReplayLoop(sketch: SketchData, targetRect: RectF) {
        val totalStrokes = sketch.strokes.size
        SketchSessionManager.updateStatus(DrawingStatus.DRAWING, "Drawing...")

        drawingJob = serviceScope.launch {
            val scaledStrokes = scaleStrokesToRect(
                strokes = sketch.strokes,
                sourceWidth = sketch.canvasWidth.toFloat(),
                sourceHeight = sketch.canvasHeight.toFloat(),
                targetRect = targetRect
            )

            val chunkSize = 14
            var strokeIdx = savedStrokeIndex

            while (strokeIdx < scaledStrokes.size) {
                val stroke = scaledStrokes[strokeIdx]
                if (stroke.size < 2) {
                    strokeIdx++
                    savedPointIndex = 0
                    continue
                }

                var ptIdx = if (strokeIdx == savedStrokeIndex) savedPointIndex else 0
                if (ptIdx >= stroke.size - 1) ptIdx = 0

                var continuingStroke: GestureDescription.StrokeDescription? = null

                while (ptIdx < stroke.size - 1) {
                    if (stopRequested) {
                        liftActiveStrokeIfNeeded(continuingStroke, stroke[ptIdx])
                        return@launch
                    }
                    if (pauseRequested) {
                        liftActiveStrokeIfNeeded(continuingStroke, stroke[ptIdx])
                        savedStrokeIndex = strokeIdx
                        savedPointIndex = ptIdx
                        SketchSessionManager.updateStatus(DrawingStatus.PAUSED, "Paused")
                        return@launch
                    }

                    val endPtIdx = min(ptIdx + chunkSize, stroke.size - 1)
                    val hasMoreChunks = endPtIdx < stroke.size - 1

                    val chunkPath = Path().apply {
                        moveTo(stroke[ptIdx].x, stroke[ptIdx].y)
                        for (i in (ptIdx + 1)..endPtIdx) {
                            lineTo(stroke[i].x, stroke[i].y)
                        }
                    }

                    val chunkDistance = pathLength(stroke, ptIdx, endPtIdx)
                    val speedPxPerSec = SketchSessionManager.speedPxPerSec.value
                    val durationMs = max(20L, ((chunkDistance / speedPxPerSec) * 1000f).roundToLong())
                        .coerceAtMost(15000L)

                    val strokeDesc = if (continuingStroke == null) {
                        GestureDescription.StrokeDescription(chunkPath, 0L, durationMs, hasMoreChunks)
                    } else {
                        continuingStroke.continueStroke(chunkPath, 0L, durationMs, hasMoreChunks)
                    }

                    val gesture = GestureDescription.Builder().addStroke(strokeDesc).build()
                    val ok = dispatchAndAwait(gesture)

                    if (!ok) {
                        savedStrokeIndex = strokeIdx
                        savedPointIndex = ptIdx
                        SketchSessionManager.updateStatus(
                            DrawingStatus.PAUSED,
                            "Paused (gesture interrupted)"
                        )
                        return@launch
                    }

                    continuingStroke = if (hasMoreChunks) strokeDesc else null
                    ptIdx = endPtIdx
                }

                strokeIdx++
                savedStrokeIndex = strokeIdx
                savedPointIndex = 0
                SketchSessionManager.updateProgress(
                    completedStrokes = strokeIdx,
                    totalStrokes = totalStrokes,
                    message = "Drawing ($strokeIdx / $totalStrokes)"
                )

                val liftDelay = (40000f / SketchSessionManager.speedPxPerSec.value).roundToLong()
                    .coerceIn(18L, 80L)
                delay(liftDelay)
            }

            savedStrokeIndex = 0
            savedPointIndex = 0
            SketchSessionManager.updateStatus(DrawingStatus.COMPLETED)
            SketchSessionManager.updateProgress(totalStrokes, totalStrokes, "Completed!")
        }
    }

    private suspend fun liftActiveStrokeIfNeeded(
        active: GestureDescription.StrokeDescription?,
        lastPoint: PointF
    ) {
        if (active == null) return
        val liftPath = Path().apply {
            moveTo(lastPoint.x, lastPoint.y)
            lineTo(lastPoint.x, lastPoint.y)
        }
        val liftStroke = active.continueStroke(liftPath, 0L, 12L, false)
        dispatchAndAwait(GestureDescription.Builder().addStroke(liftStroke).build())
    }

    private suspend fun dispatchAndAwait(gesture: GestureDescription): Boolean {
        val deferred = CompletableDeferred<Boolean>()
        val started = dispatchGesture(
            gesture,
            object : GestureResultCallback() {
                override fun onCompleted(gestureDescription: GestureDescription?) {
                    if (!deferred.isCompleted) deferred.complete(true)
                }

                override fun onCancelled(gestureDescription: GestureDescription?) {
                    if (!deferred.isCompleted) deferred.complete(false)
                }
            },
            null
        )
        if (!started) return false
        return deferred.await()
    }

    private fun scaleStrokesToRect(
        strokes: List<List<PointF>>,
        sourceWidth: Float,
        sourceHeight: Float,
        targetRect: RectF
    ): List<List<PointF>> {
        val safeW = max(1f, sourceWidth)
        val safeH = max(1f, sourceHeight)

        val metrics = resources.displayMetrics
        val maxX = (metrics.widthPixels - 2).toFloat().coerceAtLeast(2f)
        val maxY = (metrics.heightPixels - 2).toFloat().coerceAtLeast(2f)

        val scale = min(targetRect.width() / safeW, targetRect.height() / safeH)
        val drawnW = safeW * scale
        val drawnH = safeH * scale
        val offsetX = targetRect.left + (targetRect.width() - drawnW) / 2f
        val offsetY = targetRect.top + (targetRect.height() - drawnH) / 2f

        return strokes.map { stroke ->
            stroke.map { pt ->
                PointF(
                    (offsetX + pt.x * scale).coerceIn(1f, maxX),
                    (offsetY + pt.y * scale).coerceIn(1f, maxY)
                )
            }
        }
    }

    private fun pathLength(points: List<PointF>, start: Int, end: Int): Float {
        var sum = 0f
        for (i in start until end) {
            sum += hypot(points[i + 1].x - points[i].x, points[i + 1].y - points[i].y)
        }
        return sum
    }
}
EOF

cat <<'EOF' > "$ROOT/app/src/main/java/com/sketchpilot/app/service/FloatingOverlayService.kt"
package com.sketchpilot.app.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.WindowManager
import android.widget.Button
import android.widget.ProgressBar
import android.widget.SeekBar
import android.widget.TextView
import androidx.core.app.NotificationCompat
import com.sketchpilot.app.R
import com.sketchpilot.app.model.DrawingStatus
import com.sketchpilot.app.state.DrawingCommand
import com.sketchpilot.app.state.SketchSessionManager
import com.sketchpilot.app.ui.CanvasCalibrationView
import com.sketchpilot.app.ui.MainActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.launch
import kotlin.math.abs
import kotlin.math.roundToInt

class FloatingOverlayService : Service() {

    private lateinit var windowManager: WindowManager
    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    private var bubbleView: View? = null
    private var bubbleParams: WindowManager.LayoutParams? = null

    private var panelView: View? = null
    private var panelParams: WindowManager.LayoutParams? = null

    private var calibrationView: View? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        startForeground(NOTIFICATION_ID, createNotification())
        SketchSessionManager.setOverlayRunning(true)

        showBubble()
        observeSessionState()
    }

    override fun onDestroy() {
        removeCalibrationOverlay()
        removePanel()
        removeBubble()
        SketchSessionManager.setOverlayRunning(false)
        serviceScope.cancel()
        super.onDestroy()
    }

    private fun createNotification(): Notification {
        val channelId = "sketchpilot_overlay_channel"
        val mgr = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "SketchPilot Floating Overlay",
                NotificationManager.IMPORTANCE_LOW
            )
            mgr.createNotificationChannel(channel)
        }

        val openAppIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("SketchPilot Active")
            .setContentText("Tap the floating bubble to control drawing")
            .setSmallIcon(R.drawable.ic_sketch_pilot)
            .setContentIntent(openAppIntent)
            .setOngoing(true)
            .build()
    }

    private fun showBubble() {
        if (bubbleView != null) return

        val view = LayoutInflater.from(this).inflate(R.layout.overlay_bubble, null)
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 24
            y = 260
        }

        val touchSlop = ViewConfiguration.get(this).scaledTouchSlop
        var downRawX = 0f
        var downRawY = 0f
        var startX = 0
        var startY = 0
        var isDragging = false

        view.setOnTouchListener { _, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    downRawX = event.rawX
                    downRawY = event.rawY
                    startX = params.x
                    startY = params.y
                    isDragging = false
                    true
                }

                MotionEvent.ACTION_MOVE -> {
                    val dx = (event.rawX - downRawX).roundToInt()
                    val dy = (event.rawY - downRawY).roundToInt()
                    if (abs(dx) > touchSlop || abs(dy) > touchSlop) {
                        isDragging = true
                    }
                    if (isDragging) {
                        params.x = startX + dx
                        params.y = startY + dy
                        windowManager.updateViewLayout(view, params)
                    }
                    true
                }

                MotionEvent.ACTION_UP -> {
                    if (!isDragging) {
                        toggleControlPanel()
                    }
                    true
                }

                else -> false
            }
        }

        bubbleView = view
        bubbleParams = params
        windowManager.addView(view, params)
    }

    private fun toggleControlPanel() {
        if (panelView == null) showControlPanel() else removePanel()
    }

    private fun showControlPanel() {
        if (panelView != null) return

        val metrics = resources.displayMetrics
        val maxPanelX = (metrics.widthPixels - (280 * metrics.density).roundToInt()).coerceAtLeast(16)
        val maxPanelY = (metrics.heightPixels - (360 * metrics.density).roundToInt()).coerceAtLeast(16)

        val view = LayoutInflater.from(this).inflate(R.layout.overlay_controls, null)
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = ((bubbleParams?.x ?: 24) + 20).coerceIn(16, maxPanelX)
            y = ((bubbleParams?.y ?: 260) + 120).coerceIn(16, maxPanelY)
        }

        val btnCalibrate = view.findViewById<Button>(R.id.btnCalibrate)
        val btnStart = view.findViewById<Button>(R.id.btnStart)
        val btnPauseResume = view.findViewById<Button>(R.id.btnPauseResume)
        val btnStop = view.findViewById<Button>(R.id.btnStop)
        val btnMinimize = view.findViewById<Button>(R.id.btnMinimize)
        val btnCloseOverlay = view.findViewById<Button>(R.id.btnCloseOverlay)
        val seekSpeed = view.findViewById<SeekBar>(R.id.seekOverlaySpeed)
        val tvSpeed = view.findViewById<TextView>(R.id.tvOverlaySpeed)

        val currentSpeed = SketchSessionManager.speedPxPerSec.value
        seekSpeed.max = 2350
        seekSpeed.progress = (currentSpeed - 150f).roundToInt().coerceIn(0, 2350)
        tvSpeed.text = "Speed: ${currentSpeed.roundToInt()} px/s"

        seekSpeed.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(sb: SeekBar?, progress: Int, fromUser: Boolean) {
                val speed = 150f + progress
                tvSpeed.text = "Speed: ${speed.roundToInt()} px/s"
                if (fromUser) SketchSessionManager.setSpeedPxPerSec(speed)
            }
            override fun onStartTrackingTouch(sb: SeekBar?) {}
            override fun onStopTrackingTouch(sb: SeekBar?) {}
        })

        btnCalibrate.setOnClickListener {
            removePanel()
            showCalibrationOverlay()
        }

        btnStart.setOnClickListener {
            SketchSessionManager.sendCommand(DrawingCommand.Start)
        }

        btnPauseResume.setOnClickListener {
            when (SketchSessionManager.drawingStatus.value) {
                DrawingStatus.DRAWING -> SketchSessionManager.sendCommand(DrawingCommand.Pause)
                DrawingStatus.PAUSED -> SketchSessionManager.sendCommand(DrawingCommand.Resume)
                else -> Unit
            }
        }

        btnStop.setOnClickListener {
            SketchSessionManager.sendCommand(DrawingCommand.Stop)
        }

        btnMinimize.setOnClickListener { removePanel() }

        btnCloseOverlay.setOnClickListener {
            SketchSessionManager.sendCommand(DrawingCommand.Stop)
            stopSelf()
        }

        panelView = view
        panelParams = params
        windowManager.addView(view, params)
        refreshPanelUi()
    }

    private fun showCalibrationOverlay() {
        if (calibrationView != null) return
        SketchSessionManager.updateStatus(DrawingStatus.CALIBRATING, "Position box over canvas")

        val view = LayoutInflater.from(this).inflate(R.layout.overlay_calibration, null)
        val calView = view.findViewById<CanvasCalibrationView>(R.id.calibrationCanvasView)
        val btnLock = view.findViewById<Button>(R.id.btnLockArea)
        val btnCancel = view.findViewById<Button>(R.id.btnCancelArea)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )

        vi
