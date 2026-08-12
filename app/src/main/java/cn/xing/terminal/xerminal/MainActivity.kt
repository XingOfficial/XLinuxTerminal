package cn.xing.terminal.xerminal

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.ScrollView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.File
import java.io.FileOutputStream

class MainActivity : AppCompatActivity() {

    private lateinit var outputText: TextView
    private lateinit var commandInput: EditText
    private lateinit var scrollView: ScrollView
    private val commandHistory = mutableListOf<String>()
    private var historyIndex = -1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        outputText = findViewById(R.id.output_text)
        commandInput = findViewById(R.id.command_input)
        scrollView = findViewById(R.id.scroll_view)
        val runButton: Button = findViewById(R.id.run_button)
        val clearButton: Button = findViewById(R.id.clear_button)

        setupBusybox()
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

    private fun setupBusybox() {
        val binDir = File(filesDir, "bin")
        if (!binDir.exists()) {
            binDir.mkdirs()
            assets.list("bin")?.forEach { file ->
                assets.open("bin/$file").use { input ->
                    File(binDir, file).outputStream().use { output ->
                        input.copyTo(output)
                    }
                }
                Runtime.getRuntime().exec("chmod 755 ${File(binDir, file).absolutePath}")
            }
            val busyboxPath = File(binDir, "busybox").absolutePath
            val commands = listOf("ls", "pwd", "echo", "cat", "mkdir", "touch", "rm", "cp", "mv", "grep", "awk", "sed", "tar", "gzip", "wget", "curl", "whoami", "id", "ps", "top", "kill", "chmod", "chown", "ln", "find", "sort", "uniq", "wc", "head", "tail", "date", "cal", "clear", "du", "df", "free", "uptime", "uname", "hostname", "ping", "netstat", "ifconfig", "route", "nslookup", "dig", "ssh", "scp", "sftp", "git", "python", "node", "ruby", "perl", "lua", "vim", "nano", "less", "more", "diff", "patch", "base64", "md5sum", "sha256sum", "openssl", "gpg", "zip", "unzip", "bzip2", "xz", "7z", "ar", "dd", "hexdump", "xxd", "strings", "objdump", "readelf", "strace", "ltrace", "gdb", "make", "gcc", "g++", "clang", "javac", "dexdump", "aapt", "aapt2", "zipalign", "apksigner", "jarsigner", "keytool", "proguard", "dx", "d8", "r8", "bundletool", "avdmanager", "sdkmanager", "emulator", "adb", "fastboot", "mke2fs", "tune2fs", "e2fsck", "resize2fs", "mkfs.ext4", "fsck.ext4", "mount", "umount", "blkid", "lsblk", "fdisk", "sfdisk", "parted", "gdisk", "mkfs", "mkswap", "swapon", "swapoff", "losetup", "cryptsetup", "dmsetup", "lvm", "pvcreate", "vgcreate", "lvcreate", "mdadm", "raidstart", "raidstop", "iscsiadm", "tgtadm", "rbd", "ceph", "gluster", "nfsstat", "showmount", "rpcinfo", "portmap", "mountd", "nfsd", "exportfs", "samba", "smbclient", "nmblookup", "net", "wbinfo", "ntlm_auth", "ldapsearch", "ldapadd", "ldapmodify", "ldapdelete", "slapcat", "slapadd", "mysql", "mysqldump", "mysqladmin", "psql", "pg_dump", "pg_restore", "mongo", "mongodump", "mongorestore", "redis-cli", "redis-server", "memcached", "curl", "wget", "axel", "aria2c", "rsync", "scp", "sftp", "ftp", "lftp", "ncftp", "tftp", "telnet", "nc", "nmap", "masscan", "zmap", "hping3", "iperf", "iperf3", "speedtest-cli", "mtr", "traceroute", "tracepath", "ping", "fping", "arping", "ndisc6", "rdisc6", "dhcpcd", "dhclient", "dhcpd", "dnsmasq", "bind", "named", "dig", "host", "nslookup", "drill", "knotc", "knotd", "pdns_server", "powerdns", "unbound", "unbound-control", "nsd", "nsd-control", "dnscrypt-proxy", "stubby", "cloudflared", "traefik", "caddy", "nginx", "apachectl", "httpd", "lighttpd", "haproxy", "varnishd", "squid", "privoxy", "tor", "torsocks", "i2p", "freenet", "zeronet", "ipfs", "ipfs-cluster-service", "ipfs-cluster-ctl", "go-ipfs", "kubo", "lotus", "lotus-miner", "lotus-worker", "boost", "boostd", "curio", "curio-seal", "curio-seal-worker", "venus", "venus-miner", "venus-messager", "venus-auth", "venus-gateway", "venus-wallet", "venus-market", "droplet", "sophon", "sophon-miner", "sophon-messager", "sophon-auth", "sophon-gateway", "filecoin-ffi", "rust-fil-proofs", "bellperson", "neptune", "forest", "fuhon", "forest-cli", "fuhon-cli", "estuary", "estuary-shuttle", "delta", "delta-dataset", "edge-ur")
            commands.forEach { cmd ->
                val link = File(binDir, cmd)
                if (!link.exists()) {
                    try {
                        Runtime.getRuntime().exec("ln -s $busyboxPath ${link.absolutePath}")
                    } catch (e: Exception) {
                    }
                }
            }
        }
    }

    private fun setupTerminal() {
        val termuxDir = File(filesDir, "termux")
        if (!termuxDir.exists()) {
            termuxDir.mkdirs()
        }
        appendOutput("XLinuxTerminal v1.0")
        appendOutput("====================")
        appendOutput("Busybox已集成")
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
            val env = pb.environment()
            val binDir = File(filesDir, "bin").absolutePath
            env["PATH"] = "$binDir:/system/bin:/system/xbin"
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
