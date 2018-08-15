//
//  DarwinAdvertisementData.swift
//  GATT
//
//  Created by Alsey Coleman Miller on 7/15/18.
//

import Foundation
import Bluetooth
import GATT

#if os(macOS) || os(iOS) || os(tvOS) || (os(watchOS) && swift(>=3.2))

import CoreBluetooth

public struct DarwinAdvertisementData: AdvertisementDataProtocol {
    
    /// The local name of a peripheral.
    public let localName: String?
    
    /// The Manufacturer data of a peripheral.
    public let manufacturerData: GAPManufacturerSpecificData?
    
    /// Service-specific advertisement data.
    public let serviceData: [BluetoothUUID: Data]?
    
    /// An array of service UUIDs
    public let serviceUUIDs: [BluetoothUUID]?
    
    /// An array of one or more `BluetoothUUID`, representing Service UUIDs that were found
    /// in the “overflow” area of the advertisement data.
    public let overflowServiceUUIDs: [BluetoothUUID]?
    
    /// This value is available if the broadcaster (peripheral) provides its Tx power level in its advertising packet.
    /// Using the RSSI value and the Tx power level, it is possible to calculate path loss.
    public let txPowerLevel: Double?
    
    /// A Boolean value that indicates whether the advertising event type is connectable.
    public let isConnectable: Bool?
    
    /// An array of one or more `BluetoothUUID`, representing Service UUIDs.
    public let solicitedServiceUUIDs: [BluetoothUUID]?
}

// MARK: - Equatable

extension DarwinAdvertisementData: Equatable {
    
    public static func == (lhs: DarwinAdvertisementData, rhs: DarwinAdvertisementData) -> Bool {
        
        return lhs.localName == rhs.localName
            && lhs.manufacturerData == rhs.manufacturerData
            && lhs.serviceData == rhs.serviceData
            && lhs.serviceUUIDs == rhs.serviceUUIDs
            && lhs.overflowServiceUUIDs == rhs.overflowServiceUUIDs
            && lhs.txPowerLevel == rhs.txPowerLevel
            && lhs.isConnectable == rhs.isConnectable
            && lhs.solicitedServiceUUIDs == rhs.solicitedServiceUUIDs
    }
}

// MARK: - CoreBluetooth

internal extension DarwinAdvertisementData {
    
    init(_ coreBluetooth: [String: Any]) {
        
        self.localName = coreBluetooth[CBAdvertisementDataLocalNameKey] as? String
        
        if let manufacturerDataBytes = coreBluetooth[CBAdvertisementDataManufacturerDataKey] as? Data,
            let manufacturerData = GAPManufacturerSpecificData(data: manufacturerDataBytes) {
            
            self.manufacturerData = manufacturerData
            
        } else {
            
            self.manufacturerData = nil
        }
        
        if let coreBluetoothServiceData = coreBluetooth[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data] {
            
            var serviceData = [BluetoothUUID: Data](minimumCapacity: coreBluetoothServiceData.count)
            
            for (key, value) in coreBluetoothServiceData {
                
                let uuid = BluetoothUUID(coreBluetooth: key)
                
                serviceData[uuid] = value
            }
            
            self.serviceData = serviceData
            
        } else {
            
            self.serviceData = nil
        }
        
        self.serviceUUIDs = (coreBluetooth[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID])?.map { BluetoothUUID(coreBluetooth: $0) }
        
        self.overflowServiceUUIDs = (coreBluetooth[CBAdvertisementDataOverflowServiceUUIDsKey] as? [CBUUID])?.map { BluetoothUUID(coreBluetooth: $0) }
        
        self.txPowerLevel = (coreBluetooth[CBAdvertisementDataTxPowerLevelKey] as? NSNumber)?.doubleValue
        
        self.isConnectable = (coreBluetooth[CBAdvertisementDataIsConnectable] as? NSNumber)?.boolValue
        
        self.solicitedServiceUUIDs = (coreBluetooth[CBAdvertisementDataSolicitedServiceUUIDsKey] as? [CBUUID])?.map { BluetoothUUID(coreBluetooth: $0) }
    }
}

#endif
