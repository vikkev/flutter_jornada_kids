package com.br.jornadakids.flutter_jornadakids

import android.app.Activity
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import android.content.Intent

class BlockedActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_blocked)

        val messageView = findViewById<TextView>(R.id.txtMessage)
        val btnHome = findViewById<Button>(R.id.btnHome)

        // Tenta obter o nome legível do app a partir do pacote
        val pkg = intent.getStringExtra("packageName")
        val appName = try {
            if (!pkg.isNullOrEmpty()) {
                val appInfo = packageManager.getApplicationInfo(pkg, 0)
                packageManager.getApplicationLabel(appInfo).toString()
            } else null
        } catch (_: Exception) {
            null
        }

        messageView.text = if (!appName.isNullOrEmpty()) {
            "O limite de uso diário para $appName foi atingido!"
        } else {
            "Este aplicativo está bloqueado pelo tempo limite!"
        }

        btnHome.setOnClickListener {
            val intent = Intent(Intent.ACTION_MAIN)
            intent.addCategory(Intent.CATEGORY_HOME)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(intent)
            finish()
        }
    }
}
