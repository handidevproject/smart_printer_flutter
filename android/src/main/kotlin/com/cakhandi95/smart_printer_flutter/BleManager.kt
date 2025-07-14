package com.cakhandi95.smart_printer_flutter

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import com.cakhandi95.smart_printer_flutter.models.PeripheralStatus
import net.posprinter.IConnectListener
import net.posprinter.IDeviceConnection
import net.posprinter.POSConnect
import net.posprinter.POSPrinter
import net.posprinter.TSPLPrinter

/**
 * Created by handy on 14/07/25.
 * it.handy@borwita.co.id / it.handy
 */
class BleManager(
    private val context: Context,
    val onDevicesChanged: (devices: ArrayList<BluetoothDevice>) -> Unit,
    val onStatusChanged: (status: Map<String, Any?>) -> Unit,
    val onScanningChanged: (isScanning: Boolean) -> Unit,
) {
    private val TAG = "BleManager"
    private val bluetoothAdapter: BluetoothAdapter by lazy {
        (context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager).adapter
    }

    private var curConnect: IDeviceConnection? = null

    val posPrinter: POSPrinter?
        get() = curConnect?.let { POSPrinter(it) }

    val tsplPrinter: TSPLPrinter?
        get() = curConnect?.let { TSPLPrinter(it) }

    val isConnected: Boolean
        get() = _isConnected

    val isScanning: Boolean
        get() = bluetoothAdapter.isDiscovering

    private var _isConnected: Boolean = false

    private val devices: ArrayList<BluetoothDevice> = arrayListOf()

    private val mBroadcastReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == BluetoothDevice.ACTION_FOUND) {
                val device =
                    intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE) ?: return

                if (device.type == BluetoothDevice.DEVICE_TYPE_LE) return
                if (deviceIsExist(device.address)) return

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
        if (!bluetoothAdapter.isDiscovering) {
            bluetoothAdapter.startDiscovery()
            onScanningChanged(true)
        }
        onDevicesChanged(devices)
    }

    @SuppressLint("MissingPermission")
    fun stopScan() {
        if (bluetoothAdapter.isDiscovering) {
            bluetoothAdapter.cancelDiscovery()
            onScanningChanged(false)
        }
    }

    @SuppressLint("MissingPermission")
    fun connectToDevice(mac: String) {
        onStatusChanged(mapOf("status" to PeripheralStatus.CONNECTING.value))
        curConnect?.close()
        curConnect = POSConnect.createDevice(POSConnect.DEVICE_TYPE_BLUETOOTH)
        curConnect?.connect(mac, connectListener)
    }

    fun disconnect() {
        _isConnected = false
        curConnect?.close()
        curConnect = null
        onStatusChanged(mapOf("status" to PeripheralStatus.DISCONNECTED.value))
    }

    private fun deviceIsExist(address: String): Boolean {
        return devices.any { it.address == address }
    }

    private val connectListener = IConnectListener { code, address, msg ->
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
                        "statusMessage" to msg,
                        "uuid" to address
                    )
                )
            }

            POSConnect.CONNECT_INTERRUPT -> {
                _isConnected = false
                onStatusChanged(
                    mapOf(
                        "status" to PeripheralStatus.DISCONNECTED.value,
                        "uuid" to address
                    )
                )
            }
        }
    }
}