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
    <string name="accessibility_service_description">Replays your converted 900x900 black-and-white sketch paths as touch gestures onto a calibrated screen region.</string>
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
            android:text="Offline 900×900 Sketch &amp; Gesture Drawer"
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
                android:contentDescription="900x900 Sketch Preview"
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
    val canvasSize: Int = 900,
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
        minPathPoints: Int = 3,
        rdpEpsilon: Float = 1.0f
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
                acceptTracedPath(traced, minPathPoints, rdpEpsilon, rawPaths)
            }
        }

        // Pass 2: Trace remaining closed loops and junctions bidirectionally
        for (y in 1 until height - 1) {
            val row = y * width
            for (x in 1 until width - 1) {
                val startIdx = row + x
                if (!edgeMap[startIdx] || visited[startIdx]) continue

                val traced = traceBidirectional(edgeMap, visited, width, height, x, y)
                acceptTracedPath(traced, minPathPoints, rdpEpsilon, rawPaths)
            }
        }

        return orderNearestNeighbor(rawPaths)
    }

    private fun acceptTracedPath(
        traced: List<PointF>,
        minPathPoints: Int,
        rdpEpsilon: Float,
        out: MutableList<List<PointF>>
    ) {
        if (traced.size < minPathPoints) return

        val isClosedLoop = traced.size >= 6 &&
            hypot(traced.first().x - traced.last().x, traced.first().y - traced.last().y) <= 2.2f

        val simplified = ramerDouglasPeucker(traced, rdpEpsilon)
        if (simplified.size < 2) return

        val result = if (isClosedLoop && simplified.size >= 3 &&
            hypot(simplified.first().x - simplified.last().x, simplified.first().y - simplified.last().y) > 0.5f
        ) {
            ArrayList<PointF>(simplified.size + 1).apply {
                addAll(simplified)
                add(PointF(simplified.first().x, simplified.first().y))
            }
        } else {
            simplified
        }

        if (strokeArcLength(result) >= 2.5f) {
            out.add(result)
        }
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

        // Check if start pixel still has an unvisited branch in the opposite direction
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
                // Slight preference for 4-connected steps at equal turn cost for smoother raster walking
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
import kotlin.math.atan2
import kotlin.math.floor
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

object SketchProcessor {

    const val TARGET_SIZE = 900

    suspend fun processImageUri(
        context: Context,
        uri: Uri,
        detailLevel: Int = 55
    ): SketchData = withContext(Dispatchers.Default) {
        val clampedDetail = detailLevel.coerceIn(1, 100)

        val rawBitmap = decodeScaledWithExif(context, uri)
            ?: throw IllegalArgumentException("Unable to decode selected image.")

        val normalized900 = centerCropTo900(rawBitmap)
        if (rawBitmap !== normalized900) {
            rawBitmap.recycle()
        }

        val gray = toGrayscale(normalized900)
        normalized900.recycle()

        val enhanced = applyClahe(gray, TARGET_SIZE, TARGET_SIZE, gridSize = 8, clipLimitFactor = 2.4f)
        val blended = FloatArray(gray.size) { i ->
            0.60f * enhanced[i] + 0.40f * gray[i]
        }

        val smoothed = if (clampedDetail < 25) {
            gaussianBlur5x5(blended, TARGET_SIZE, TARGET_SIZE)
        } else {
            gaussianBlur3x3(blended, TARGET_SIZE, TARGET_SIZE)
        }

        val edges = extractCannyThinEdges(smoothed, TARGET_SIZE, TARGET_SIZE, clampedDetail)

        if (clampedDetail >= 25) {
            mergeThinDarkLineRidges(smoothed, edges, TARGET_SIZE, TARGET_SIZE, clampedDetail)
        }

        zhangSuenThin(edges, TARGET_SIZE, TARGET_SIZE, maxIterations = 2)
        removeIsolatedDots(edges, TARGET_SIZE, TARGET_SIZE)

        val detailNorm = clampedDetail / 100f
        val rdpEpsilon = 1.25f - detailNorm * 0.45f
        val minPathPoints = if (clampedDetail >= 35) 3 else 4

        val strokes = PathVectorizer.vectorizeAndOrder(
            edgeMap = edges,
            width = TARGET_SIZE,
            height = TARGET_SIZE,
            minPathPoints = minPathPoints,
            rdpEpsilon = rdpEpsilon
        )

        val previewBitmap = renderStrokesToBitmap(strokes, TARGET_SIZE)

        SketchData(
            canvasSize = TARGET_SIZE,
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

        val origMin = min(boundsOpts.outWidth, boundsOpts.outHeight)
        val origMax = max(boundsOpts.outWidth, boundsOpts.outHeight)

        // Keep the shorter dimension >= 900px whenever possible so center-cropping stays sharp
        var sampleSize = 1
        while (origMin / (sampleSize * 2) >= TARGET_SIZE &&
            origMax / (sampleSize * 2) >= TARGET_SIZE
        ) {
            sampleSize *= 2
        }
        while (origMax / sampleSize > 4096 && origMin / (sampleSize * 2) >= 450) {
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

    private fun centerCropTo900(source: Bitmap): Bitmap {
        val srcW = source.width
        val srcH = source.height
        val cropSide = min(srcW, srcH)
        val left = (srcW - cropSide) / 2
        val top = (srcH - cropSide) / 2

        val square = if (srcW == cropSide && srcH == cropSide) {
            source
        } else {
            Bitmap.createBitmap(source, left, top, cropSide, cropSide)
        }

        val scaled = if (square.width == TARGET_SIZE && square.height == TARGET_SIZE) {
            square
        } else {
            Bitmap.createScaledBitmap(square, TARGET_SIZE, TARGET_SIZE, true)
        }

        if (square !== source && square !== scaled) {
            square.recycle()
        }
        return scaled
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

    private fun applyClahe(
        gray: FloatArray,
        w: Int,
        h: Int,
        gridSize: Int,
        clipLimitFactor: Float
    ): FloatArray {
        val luts = Array(gridSize) { Array(gridSize) { FloatArray(256) } }
        val hist = IntArray(256)

        for (ty in 0 until gridSize) {
            val y0 = (ty * h) / gridSize
            val y1 = ((ty + 1) * h) / gridSize
            for (tx in 0 until gridSize) {
                val x0 = (tx * w) / gridSize
                val x1 = ((tx + 1) * w) / gridSize
                hist.fill(0)

                for (y in y0 until y1) {
                    val row = y * w
                    for (x in x0 until x1) {
                        val bin = gray[row + x].roundToInt().coerceIn(0, 255)
                        hist[bin]++
                    }
                }

                val tilePixels = (x1 - x0) * (y1 - y0)
                if (tilePixels <= 0) continue

                val clipLimit = max(1, ((clipLimitFactor * tilePixels) / 256f).roundToInt())
                var excess = 0
                for (i in 0 until 256) {
                    if (hist[i] > clipLimit) {
                        excess += hist[i] - clipLimit
                        hist[i] = clipLimit
                    }
                }

                val avgInc = excess / 256
                val rem = excess % 256
                for (i in 0 until 256) {
                    hist[i] += avgInc + if (i < rem) 1 else 0
                }

                var cdf = 0
                val lut = luts[ty][tx]
                val scale = 255f / tilePixels.toFloat()
                for (i in 0 until 256) {
                    cdf += hist[i]
                    lut[i] = (cdf * scale).coerceIn(0f, 255f)
                }
            }
        }

        val out = FloatArray(w * h)
        val tileW = w.toFloat() / gridSize
        val tileH = h.toFloat() / gridSize

        for (y in 0 until h) {
            val fy = (y + 0.5f) / tileH - 0.5f
            val ty0 = floor(fy).toInt().coerceIn(0, gridSize - 1)
            val ty1 = (ty0 + 1).coerceIn(0, gridSize - 1)
            val ay = (fy - ty0).coerceIn(0f, 1f)
            val row = y * w

            for (x in 0 until w) {
                val fx = (x + 0.5f) / tileW - 0.5f
                val tx0 = floor(fx).toInt().coerceIn(0, gridSize - 1)
                val tx1 = (tx0 + 1).coerceIn(0, gridSize - 1)
                val ax = (fx - tx0).coerceIn(0f, 1f)

                val bin = gray[row + x].roundToInt().coerceIn(0, 255)
                val v00 = luts[ty0][tx0][bin]
                val v10 = luts[ty0][tx1][bin]
                val v01 = luts[ty1][tx0][bin]
                val v11 = luts[ty1][tx1][bin]

                val top = v00 + (v10 - v00) * ax
                val bot = v01 + (v11 - v01) * ax
                out[row + x] = top + (bot - top) * ay
            }
        }

        return out
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
        val mag = FloatArray(w * h)
        val dir = ByteArray(w * h)
        val borderMargin = 3

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

        val nms = FloatArray(w * h)
        var maxMag = 0f
        var sigCount = 0
        val noiseFloor = 5f

        for (y in borderMargin until h - borderMargin) {
            val row = y * w
            for (x in borderMargin until w - borderMargin) {
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

        val detailNorm = detailLevel.coerceIn(1, 100) / 100f
        val keepFraction = 0.08f + detailNorm * 0.64f
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
        val minHigh = 10f + (1f - detailNorm) * 20f
        val maxHigh = maxMag * (0.62f - detailNorm * 0.27f)
        val highThresh = quantileHigh.coerceIn(minHigh, max(minHigh, maxHigh))
        val lowThresh = max(noiseFloor, highThresh * 0.36f)

        val edges = BooleanArray(w * h)
        val stack = IntArray(w * h)
        var stackTop = 0

        for (y in borderMargin until h - borderMargin) {
            val row = y * w
            for (x in borderMargin until w - borderMargin) {
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
            if (x <= borderMargin || x >= w - borderMargin - 1 ||
                y <= borderMargin || y >= h - borderMargin - 1
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
     * Extracts 1-pixel centerlines of thin dark strokes (pupils, eyelashes, fine ink lines)
     * by requiring BOTH opposing sides to be brighter, avoiding double-edges on step boundaries.
     */
    private fun mergeThinDarkLineRidges(
        gray: FloatArray,
        edges: BooleanArray,
        w: Int,
        h: Int,
        detailLevel: Int
    ) {
        val margin = 4
        val detailNorm = detailLevel.coerceIn(1, 100) / 100f
        val valleyThresh = 26f - detailNorm * 14f

        for (y in margin until h - margin) {
            val row = y * w
            for (x in margin until w - margin) {
                val idx = row + x
                if (edges[idx]) continue
                val c = gray[idx]

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

    private fun renderStrokesToBitmap(strokes: List<List<PointF>>, size: Int): Bitmap {
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
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
                sourceSize = sketch.canvasSize.toFloat(),
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
        sourceSize: Float,
        targetRect: RectF
    ): List<List<PointF>> {
        val metrics = resources.displayMetrics
        val maxX = (metrics.widthPixels - 2).toFloat()
        val maxY = (metrics.heightPixels - 2).toFloat()

        val scale = min(targetRect.width() / sourceSize, targetRect.height() / sourceSize)
        val offsetX = targetRect.left + (targetRect.width() - sourceSize * scale) / 2f
        val offsetY = targetRect.top + (targetRect.height() - sourceSize * scale) / 2f

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

        val view = LayoutInflater.from(this).inflate(R.layout.overlay_controls, null)
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = (bubbleParams?.x ?: 24) + 20
            y = (bubbleParams?.y ?: 260) + 120
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

        view.post {
            calView.setInitialRectIfNeeded(SketchSessionManager.targetCanvasRect.value)
        }

        btnLock.setOnClickListener {
            SketchSessionManager.setTargetCanvasRect(calView.getScreenTargetRect())
            SketchSessionManager.updateStatus(DrawingStatus.IDLE, "Canvas calibrated")
            removeCalibrationOverlay()
            showControlPanel()
        }

        btnCancel.setOnClickListener {
            SketchSessionManager.updateStatus(DrawingStatus.IDLE, "Calibration cancelled")
            removeCalibrationOverlay()
            showControlPanel()
        }

        calibrationView = view
        windowManager.addView(view, params)
    }

    private fun observeSessionState() {
        serviceScope.launch {
            combine(
                SketchSessionManager.drawingStatus,
                SketchSessionManager.progress,
                SketchSessionManager.isAccessibilityConnected
            ) { _, _, _ -> Unit }.collect {
                refreshPanelUi()
            }
        }
    }

    private fun refreshPanelUi() {
        val view = panelView ?: return
        val status = SketchSessionManager.drawingStatus.value
        val prog = SketchSessionManager.progress.value
        val accessibilityOk = SketchSessionManager.isAccessibilityConnected.value
        val hasSketch = SketchSessionManager.sketchData.value != null
        val hasRect = SketchSessionManager.targetCanvasRect.value != null

        val tvStatus = view.findViewById<TextView>(R.id.tvOverlayStatus)
        val progressBar = view.findViewById<ProgressBar>(R.id.overlayProgressBar)
        val tvProgress = view.findViewById<TextView>(R.id.tvOverlayProgress)
        val btnStart = view.findViewById<Button>(R.id.btnStart)
        val btnPauseResume = view.findViewById<Button>(R.id.btnPauseResume)
        val btnStop = view.findViewById<Button>(R.id.btnStop)

        tvStatus.text = when {
            !accessibilityOk -> "Enable Accessibility Service in Settings"
            !hasSketch -> "Select & convert an image first"
            !hasRect -> "Tap 'Calibrate Target Canvas' over app"
            else -> prog.statusMessage
        }

        progressBar.max = 100
        progressBar.progress = prog.percentage
        tvProgress.text = "${prog.percentage}% (${prog.completedStrokes}/${prog.totalStrokes})"

        btnStart.isEnabled = accessibilityOk && hasSketch && hasRect &&
            (status == DrawingStatus.IDLE || status == DrawingStatus.COMPLETED || status == DrawingStatus.ERROR)

        btnPauseResume.isEnabled = status == DrawingStatus.DRAWING || status == DrawingStatus.PAUSED
        btnPauseResume.text = if (status == DrawingStatus.PAUSED) "Resume" else "Pause"

        btnStop.isEnabled = status == DrawingStatus.DRAWING || status == DrawingStatus.PAUSED
    }

    private fun removeBubble() {
        bubbleView?.let { windowManager.removeView(it) }
        bubbleView = null
    }

    private fun removePanel() {
        panelView?.let { windowManager.removeView(it) }
        panelView = null
    }

    private fun removeCalibrationOverlay() {
        calibrationView?.let { windowManager.removeView(it) }
        calibrationView = null
    }

    companion object {
        private const val NOTIFICATION_ID = 4041
    }
}
EOF

cat <<'EOF' > "$ROOT/app/src/main/java/com/sketchpilot/app/ui/CanvasCalibrationView.kt"
package com.sketchpilot.app.ui

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.DashPathEffect
import android.graphics.Paint
import android.graphics.RectF
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.View
import kotlin.math.max
import kotlin.math.min

class CanvasCalibrationView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : View(context, attrs) {

    private val boxRect = RectF(140f, 380f, 840f, 1080f)
    private val handleRadius = 46f
    private val minBoxSize = 180f

    private var dragMode = DragMode.NONE
    private var lastX = 0f
    private var lastY = 0f

    private val scrimPaint = Paint().apply {
        color = Color.argb(120, 0, 0, 0)
        style = Paint.Style.FILL
    }

    private val borderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#00E5FF")
        style = Paint.Style.STROKE
        strokeWidth = 6f
        pathEffect = DashPathEffect(floatArrayOf(22f, 14f), 0f)
    }

    private val handlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#00E5FF")
        style = Paint.Style.FILL
    }

    private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        textSize = 36f
        textAlign = Paint.Align.CENTER
    }

    private enum class DragMode { NONE, MOVE, RESIZE }

    fun setInitialRectIfNeeded(savedScreenRect: RectF?) {
        if (savedScreenRect != null && savedScreenRect.width() > 50f) {
            val loc = IntArray(2)
            getLocationOnScreen(loc)
            boxRect.set(
                savedScreenRect.left - loc[0],
                savedScreenRect.top - loc[1],
                savedScreenRect.right - loc[0],
                savedScreenRect.bottom - loc[1]
            )
        } else if (width > 0 && height > 0) {
            val side = min(width, height) * 0.72f
            val left = (width - side) / 2f
            val top = (height - side) / 2f
            boxRect.set(left, top, left + side, top + side)
        }
        invalidate()
    }

    fun getScreenTargetRect(): RectF {
        val loc = IntArray(2)
        getLocationOnScreen(loc)
        return RectF(
            boxRect.left + loc[0],
            boxRect.top + loc[1],
            boxRect.right + loc[0],
            boxRect.bottom + loc[1]
        )
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val w = width.toFloat()
        val h = height.toFloat()

        canvas.drawRect(0f, 0f, w, boxRect.top, scrimPaint)
        canvas.drawRect(0f, boxRect.bottom, w, h, scrimPaint)
        canvas.drawRect(0f, boxRect.top, boxRect.left, boxRect.bottom, scrimPaint)
        canvas.drawRect(boxRect.right, boxRect.top, w, boxRect.bottom, scrimPaint)

        canvas.drawRect(boxRect, borderPaint)
        canvas.drawCircle(boxRect.right, boxRect.bottom, handleRadius * 0.55f, handlePaint)

        canvas.drawText(
            "Drag box over drawing canvas • Drag corner to resize",
            boxRect.centerX(),
            max(60f, boxRect.top - 28f),
            textPaint
        )
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        val x = event.x
        val y = event.y

        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                val nearCorner = (x - boxRect.right) * (x - boxRect.right) +
                    (y - boxRect.bottom) * (y - boxRect.bottom) <= handleRadius * handleRadius * 2.2f

                dragMode = when {
                    nearCorner -> DragMode.RESIZE
                    boxRect.contains(x, y) -> DragMode.MOVE
                    else -> DragMode.NONE
                }
                lastX = x
                lastY = y
                return dragMode != DragMode.NONE
            }

            MotionEvent.ACTION_MOVE -> {
                val dx = x - lastX
                val dy = y - lastY
                lastX = x
                lastY = y

                when (dragMode) {
                    DragMode.MOVE -> {
                        val clampedDx = dx.coerceIn(-boxRect.left, width - boxRect.right)
                        val clampedDy = dy.coerceIn(-boxRect.top, height - boxRect.bottom)
                        boxRect.offset(clampedDx, clampedDy)
                    }
                    DragMode.RESIZE -> {
                        boxRect.right = (boxRect.right + dx).coerceIn(boxRect.left + minBoxSize, width.toFloat())
                        boxRect.bottom = (boxRect.bottom + dy).coerceIn(boxRect.top + minBoxSize, height.toFloat())
                    }
                    DragMode.NONE -> return false
                }
                invalidate()
                return true
            }

            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                dragMode = DragMode.NONE
                return true
            }
        }
        return super.onTouchEvent(event)
    }
}
EOF

cat <<'EOF' > "$ROOT/app/src/main/java/com/sketchpilot/app/ui/MainActivity.kt"
package com.sketchpilot.app.ui

import android.Manifest
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.text.TextUtils
import android.view.View
import android.widget.SeekBar
import android.widget.Toast
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import com.sketchpilot.app.databinding.ActivityMainBinding
import com.sketchpilot.app.processing.SketchProcessor
import com.sketchpilot.app.service.FloatingOverlayService
import com.sketchpilot.app.service.SketchAccessibilityService
import com.sketchpilot.app.state.SketchSessionManager
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlin.math.roundToInt

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private var selectedImageUri: Uri? = null
    private var conversionJob: Job? = null

    private val pickMediaLauncher = registerForActivityResult(
        ActivityResultContracts.PickVisualMedia()
    ) { uri ->
        if (uri != null) {
            selectedImageUri = uri
            runSketchConversion(uri)
        }
    }

    private val notificationPermLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) {
            startOverlayIfPermitted()
        } else {
            Toast.makeText(
                this,
                "Notification permission is needed to keep the floating bubble alive.",
                Toast.LENGTH_LONG
            ).show()
        }
    }

    private val overlayPermLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) {
        updatePermissionUi()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupUi()
        observeSession()
    }

    override fun onResume() {
        super.onResume()
        updatePermissionUi()
    }

    private fun setupUi() {
        binding.btnPickImage.setOnClickListener {
            pickMediaLauncher.launch(
                PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)
            )
        }

        binding.seekDetail.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(sb: SeekBar?, progress: Int, fromUser: Boolean) {
                binding.tvDetailValue.text = "Sketch Detail: ${progress.coerceAtLeast(1)}%"
            }

            override fun onStartTrackingTouch(sb: SeekBar?) {}

            override fun onStopTrackingTouch(sb: SeekBar?) {
                selectedImageUri?.let { runSketchConversion(it) }
            }
        })

        binding.seekSpeed.max = 2350
        binding.seekSpeed.progress = (SketchSessionManager.speedPxPerSec.value - 150f).roundToInt()
        binding.tvSpeedValue.text =
            "Drawing Speed: ${SketchSessionManager.speedPxPerSec.value.roundToInt()} px/s"

        binding.seekSpeed.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(sb: SeekBar?, progress: Int, fromUser: Boolean) {
                val speed = 150f + progress
                binding.tvSpeedValue.text = "Drawing Speed: ${speed.roundToInt()} px/s"
                if (fromUser) SketchSessionManager.setSpeedPxPerSec(speed)
            }
            override fun onStartTrackingTouch(sb: SeekBar?) {}
            override fun onStopTrackingTouch(sb: SeekBar?) {}
        })

        binding.btnGrantOverlay.setOnClickListener {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            overlayPermLauncher.launch(intent)
        }

        binding.btnEnableAccessibility.setOnClickListener {
            showAccessibilityGuideDialog()
        }

        binding.btnLaunchBubble.setOnClickListener {
            if (!Settings.canDrawOverlays(this)) {
                Toast.makeText(this, "Grant 'Display over other apps' first.", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            if (!isAccessibilityServiceEnabled()) {
                Toast.makeText(this, "Enable SketchPilot Accessibility Service first.", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) !=
                PackageManager.PERMISSION_GRANTED
            ) {
                notificationPermLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
            } else {
                startOverlayIfPermitted()
            }
        }
    }

    private fun startOverlayIfPermitted() {
        val intent = Intent(this, FloatingOverlayService::class.java)
        ContextCompat.startForegroundService(this, intent)
        Toast.makeText(
            this,
            "Floating bubble started! Switch to WePlay or any drawing app.",
            Toast.LENGTH_LONG
        ).show()
    }

    private fun runSketchConversion(uri: Uri) {
        conversionJob?.cancel()
        val detail = binding.seekDetail.progress.coerceIn(1, 100)

        conversionJob = lifecycleScope.launch {
            binding.progressConverting.visibility = View.VISIBLE
            binding.tvSketchInfo.text = "Converting to 900×900 sketch & tracing paths..."

            try {
                val sketch = SketchProcessor.processImageUri(this@MainActivity, uri, detail)
                SketchSessionManager.setSketchData(sketch)
                binding.ivSketchPreview.setImageBitmap(sketch.previewBitmap)
                binding.tvSketchInfo.text =
                    "900×900 Sketch Ready • ${sketch.strokes.size} strokes • ${sketch.totalPoints} points"
            } catch (e: Exception) {
                Toast.makeText(
                    this@MainActivity,
                    "Failed to convert image: ${e.message}",
                    Toast.LENGTH_LONG
                ).show()
                binding.tvSketchInfo.text = "Conversion failed."
            } finally {
                binding.progressConverting.visibility = View.GONE
            }
        }
    }

    private fun observeSession() {
        lifecycleScope.launch {
            SketchSessionManager.progress.collect { prog ->
                binding.tvMainProgress.text =
                    "Drawing Progress: ${prog.percentage}% (${prog.completedStrokes}/${prog.totalStrokes}) — ${prog.statusMessage}"
                binding.mainProgressBar.progress = prog.percentage
            }
        }
        lifecycleScope.launch {
            SketchSessionManager.isOverlayRunning.collect { running ->
                binding.btnLaunchBubble.text =
                    if (running) "Floating Bubble Active" else "Start Floating Bubble"
            }
        }
    }

    private fun updatePermissionUi() {
        val overlayGranted = Settings.canDrawOverlays(this)
        val accessibilityGranted = isAccessibilityServiceEnabled()

        binding.tvOverlayStatus.text = if (overlayGranted) {
            "Overlay Permission: Granted"
        } else {
            "Overlay Permission: Required"
        }
        binding.btnGrantOverlay.isEnabled = !overlayGranted

        binding.tvAccessibilityStatus.text = if (accessibilityGranted) {
            "Accessibility Service: Enabled"
        } else {
            "Accessibility Service: Disabled"
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedComponent = ComponentName(this, SketchAccessibilityService::class.java)
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(enabledServices)
        while (splitter.hasNext()) {
            val component = ComponentName.unflattenFromString(splitter.next())
            if (component == expectedComponent) return true
        }
        return false
    }

    private fun showAccessibilityGuideDialog() {
        AlertDialog.Builder(this)
            .setTitle("Enable Accessibility Service")
            .setMessage(
                "1. Tap 'Open Settings' below.\n" +
                "2. Open 'Installed apps' or 'Downloaded apps'.\n" +
                "3. Select 'SketchPilot' and turn it ON.\n\n" +
                "Note for Android 13–16 sideloaded APKs: If the toggle is greyed out, go to " +
                "Settings → Apps → SketchPilot → ⋮ (top right) → Allow restricted settings, then return here."
            )
            .setPositiveButton("Open Settings") { _, _ ->
                startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
            }
            .setNegativeButton("Cancel", null)
            .show()
    }
}
EOF

if command -v zip >/dev/null 2>&1; then
    zip -r SketchPilot.zip "$ROOT"
elif command -v python3 >/dev/null 2>&1; then
    python3 -c '
import os, zipfile
with zipfile.ZipFile("SketchPilot.zip", "w", zipfile.ZIP_DEFLATED) as zf:
    for root, _, files in os.walk("SketchPilot"):
        for f in files:
            p = os.path.join(root, f)
            zf.write(p)
'
else
    echo "Created ./$ROOT directory. Compress it into SketchPilot.zip using your file manager."
    exit 0
fi

echo "Done! Created SketchPilot.zip containing all 26 project files."
