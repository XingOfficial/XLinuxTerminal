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
