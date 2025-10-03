package com.cakhandi95.smart_printer_flutter

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Log
import com.cakhandi95.smart_printer_flutter.models.PeripheralStatus
import net.posprinter.IConnectListener
import net.posprinter.IDeviceConnection
import net.posprinter.POSConnect
import net.posprinter.POSPrinter
import net.posprinter.TSPLPrinter

/**
 * Created by handy on 01/10/25.
 * handi.tech.project@gmail.com / handytechproject (Github)
 */

class PrinterManager (
    private val context: Context,
    val onDevicesChanged: (devices: ArrayList<BluetoothDevice>) -> Unit,
    val onStatusChanged: (status: Map<String, Any?>) -> Unit,
    val onScanningChanged: (isScanning: Boolean) -> Unit,
) {

    private val TAG = "PRINTER_MANAGER"
    private val bluetoothAdapter: BluetoothAdapter by lazy {
        (context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager).adapter
    }

    private var curConnect: IDeviceConnection? = null
    private var _isConnected: Boolean = false

    val posPrinter: POSPrinter? get() = curConnect?.let {
        POSPrinter(it)
    }

    val tsplPrinter: TSPLPrinter? get() = curConnect?.let {
        TSPLPrinter(it)
    }

    val isConnected: Boolean get() = _isConnected

    val isScanning: Boolean get() = bluetoothAdapter.isDiscovering

    private val devices: ArrayList<BluetoothDevice> = arrayListOf()

    // --- Bluetooth scanning ---
    private val mBroadcastReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == BluetoothDevice.ACTION_FOUND) {
                val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
                } else {
                    @Suppress("DEPRECATION")
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                }
                device ?: return
                if (device.type == BluetoothDevice.DEVICE_TYPE_LE) return
                if (devices.any { it.address == device.address }) return

                if (device.bondState == BluetoothDevice.BOND_BONDED || device.name != null) {
                    devices.add(device)
                    onDevicesChanged(devices)
                }
            }
        }
    }

    init {
        POSConnect.init(context)
        devices.addAll(bluetoothAdapter.bondedDevices)

        context.registerReceiver(
            mBroadcastReceiver,
            IntentFilter(BluetoothDevice.ACTION_FOUND)
        )
        onScanningChanged(bluetoothAdapter.isDiscovering)
    }

    @SuppressLint("MissingPermission")
    fun startScan() {
        Log.d(TAG, "Start scan")
        if (!bluetoothAdapter.isDiscovering) {
            bluetoothAdapter.startDiscovery()
            onScanningChanged(true)
        }
        onDevicesChanged(devices)
    }

    @SuppressLint("MissingPermission")
    fun stopScan() {
        Log.d(TAG, "Stop scan")
        if (bluetoothAdapter.isDiscovering) {
            bluetoothAdapter.cancelDiscovery()
            onScanningChanged(false)
        }
    }

    // --- Connect Methods ---
    fun connectBluetooth(mac: String) {
        connect(POSConnect.DEVICE_TYPE_BLUETOOTH, mac)
    }

    fun connectEthernet(ipAddress: String) {
        connect(POSConnect.DEVICE_TYPE_ETHERNET, ipAddress)
    }

    fun connectUSB(path: String) {
        connect(POSConnect.DEVICE_TYPE_USB, path)
    }

    fun connectSerial(port: String, baudrate: String) {
        connect(POSConnect.DEVICE_TYPE_SERIAL, "$port,$baudrate")
    }

    private fun connect(type: Int, address: String) {
        Log.d(TAG, "connect $type $address ||| status: ${mapOf("status" to PeripheralStatus.CONNECTING.value)}" )
        onStatusChanged(mapOf("status" to PeripheralStatus.CONNECTING.value))
        curConnect?.close()
        curConnect = POSConnect.createDevice(type)
        curConnect?.connect(address, connectListener)
    }

    fun disconnect() {
        _isConnected = false
        curConnect?.close()
        curConnect = null
        onStatusChanged(mapOf("status" to PeripheralStatus.DISCONNECTED.value))
        Log.d(TAG, "disconnect - status: ${mapOf("status" to PeripheralStatus.DISCONNECTED.value)}" )
    }

    private fun reconnectWithDelay(address: String, delayMs: Long = 3000) {
        Log.d(TAG, "Schedule reconnect in ${delayMs}ms -> $address")
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            Log.d(TAG, "Trying reconnect to $address")
            curConnect?.close()
            curConnect = POSConnect.createDevice(POSConnect.DEVICE_TYPE_ETHERNET)
            curConnect?.connect(address, connectListener)
        }, delayMs)
    }

    private val connectListener = IConnectListener { code, address, msg ->
        println("$TAG connectListener $code $address $msg")
        when (code) {
            POSConnect.CONNECT_SUCCESS -> {
                _isConnected = true
                onStatusChanged(
                    mapOf(
                        "status" to PeripheralStatus.CONNECTED.value,
                        "uuid" to address
                    )
                )
            }

            POSConnect.CONNECT_FAIL -> {
                _isConnected = false
                onStatusChanged(
                    mapOf(
                        "status" to PeripheralStatus.CONNECT_FAILED.value,
                        "statusMessage" to (msg ?: "Unknown error"),
                        "uuid" to address
                    )
                )
            }

            POSConnect.CONNECT_INTERRUPT -> {
                _isConnected = false
                onStatusChanged(
                    mapOf(
                        "status" to PeripheralStatus.DISCONNECTED.value,
                        "statusMessage" to "Connection interrupted",
                        "uuid" to address
                    )
                )
                // optional: coba auto reconnect setelah delay
                reconnectWithDelay(address)
            }
        }
    }


}