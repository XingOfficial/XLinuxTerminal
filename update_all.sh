cd ~/XLinuxTerminal

curl -s https://termbin.com/4d2l > README.md

cat > app/build.gradle.kts << 'BEOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "cn.xing.terminal.xerminal"
    compileSdk = 34

    defaultConfig {
        applicationId = "cn.xing.terminal.xerminal"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
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
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    buildFeatures {
        viewBinding = true
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")

    implementation("com.termux.termux-app:termux-shared:0.118.0")
    implementation("com.termux.termux-app:terminal-view:0.118.0")
    implementation("com.termux.termux-app:terminal-emulator:0.118.0")
    implementation("com.google.guava:listenablefuture:9999.0-empty-to-avoid-conflict-with-guava")
}
BEOF

cat > app/src/main/java/cn/xing/terminal/xerminal/MainActivity.kt << 'KEOF'
package cn.xing.terminal.xerminal

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.ScrollView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.termux.terminal.TerminalSession
import com.termux.view.TerminalView
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.File

class MainActivity : AppCompatActivity() {

    private lateinit var terminalView: TerminalView
    private lateinit var outputText: TextView
    private lateinit var commandInput: EditText
    private lateinit var scrollView: ScrollView
    private val commandHistory = mutableListOf<String>()
    private var historyIndex = -1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        terminalView = findViewById(R.id.terminal_view)
        outputText = findViewById(R.id.output_text)
        commandInput = findViewById(R.id.command_input)
        scrollView = findViewById(R.id.scroll_view)
        val runButton: Button = findViewById(R.id.run_button)
        val clearButton: Button = findViewById(R.id.clear_button)

        setupTerminal()

        runButton.setOnClickListener {
            val command = commandInput.text.toString().trim()
            if (command.isNotEmpty()) {
                commandHistory.add(command)
                historyIndex = commandHistory.size
                executeCommand(command)
                commandInput.setText("")
            }
        }

        clearButton.setOnClickListener {
            outputText.text = ""
        }
    }

    private fun setupTerminal() {
        val termuxDir = File(filesDir, "termux")
        if (!termuxDir.exists()) {
            termuxDir.mkdirs()
        }
        appendOutput("XLinuxTerminal v1.0")
        appendOutput("====================")
        appendOutput("Termux 终端库已集成")
        appendOutput("环境初始化完成...")
        appendOutput("支持命令: ls, pwd, echo, cat, mkdir, touch, whoami")
        appendOutput("输入命令后点击运行")
        appendOutput("")
    }

    private fun executeCommand(command: String) {
        appendOutput("$ $command")
        lifecycleScope.launch(Dispatchers.IO) {
            val result = runCommand(command)
            withContext(Dispatchers.Main) {
                result.forEach { appendOutput(it) }
                appendOutput("")
            }
        }
    }

    private fun runCommand(command: String): List<String> {
        val output = mutableListOf<String>()
        return try {
            val pb = ProcessBuilder("sh", "-c", command)
            pb.directory(filesDir)
            pb.redirectErrorStream(true)
            val process = pb.start()
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            var line: String?
            while (reader.readLine().also { line = it } != null) {
                output.add(line!!)
            }
            process.waitFor()
            if (output.isEmpty()) listOf("[命令执行完成,无输出]") else output
        } catch (e: Exception) {
            listOf("错误: ${e.message}")
        }
    }

    private fun appendOutput(text: String) {
        outputText.append("$text\n")
        scrollView.post { scrollView.fullScroll(ScrollView.FOCUS_DOWN) }
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
KEOF

cat > app/src/main/res/layout/activity_main.xml << 'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="#1E1E1E"
    android:padding="8dp">

    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="XLinuxTerminal"
        android:textColor="#00FF00"
        android:textSize="20sp"
        android:textStyle="bold"
        android:padding="8dp"
        android:gravity="center" />

    <com.termux.view.TerminalView
        android:id="@+id/terminal_view"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:background="#000000"
        android:visibility="gone" />

    <ScrollView
        android:id="@+id/scroll_view"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:background="#0D0D0D"
        android:padding="8dp">

        <TextView
            android:id="@+id/output_text"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textColor="#00FF00"
            android:textSize="12sp"
            android:fontFamily="monospace"
            android:textIsSelectable="true"
            android:lineSpacingMultiplier="1.2" />
    </ScrollView>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:paddingTop="8dp">

        <EditText
            android:id="@+id/command_input"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:background="#2D2D2D"
            android:textColor="#FFFFFF"
            android:textColorHint="#888888"
            android:hint="输入命令..."
            android:padding="12dp"
            android:textSize="14sp"
            android:fontFamily="monospace"
            android:inputType="text"
            android:imeOptions="actionDone" />

        <Button
            android:id="@+id/run_button"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="运行"
            android:backgroundTint="#00AA00"
            android:textColor="#FFFFFF"
            android:layout_marginStart="8dp" />

        <Button
            android:id="@+id/clear_button"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="清空"
            android:backgroundTint="#AA0000"
            android:textColor="#FFFFFF"
            android:layout_marginStart="8dp" />
    </LinearLayout>

</LinearLayout>
XEOF

git add .
git commit -m "Integrate Termux libraries and update README"
git push
