import AppKit
import Foundation

@_cdecl("is_process_running")
public func is_process_running() -> Bool {
    return false
}

@_cdecl("list_processes")
public func list_processes(length: UnsafeMutablePointer<UInt32>,  out_bytes:  UnsafeMutablePointer<UnsafeMutablePointer<UInt8>>) {
    var klist = Keeproto_KStringList.init();
    
    let path = NSWorkspace.shared.frontmostApplication?.executableURL?.absoluteString
    
    let k_path = Keeproto_KString.with {
        $0.value = path ?? ""
    };
    klist.values.append(k_path);
    
    
    /*for app in NSWorkspace.shared.runningApplications {
        let k_path = Keeproto_KString.with {
            $0.value = String(app.isActive);
        }
        klist.values.append(k_path)
        //let ex = app.executableURL
        /*
        let path =  ex?.absoluteString ?? ""
        let k_path = Keeproto_KString.with {
            $0.value = path
        }
         */
        //klist.values.append(k_path);
        //break;
       
    }*/
    
    
    
    var bytes:[UInt8] = [UInt8].init();
    do {
       try bytes = [UInt8](klist.serializedData());
    }
    catch {
        
    }
    
    length.pointee = UInt32(bytes.count);

    var x = UnsafeMutablePointer<UInt8>.allocate(capacity: bytes.count);
    //print("UInt8 aligntment: %", MemoryLayout<UInt16>.stride)
    
    let head = x;
    for b in bytes {
        x.pointee = b;
        //x.advanced(by: 1);
        x = x.successor()
    }
    x=head;
    out_bytes.pointee = x;
    //x.deallocate();
    
}

/*
    swiftc Sources/keemac/keemac.swift -emit-library
    cp libkeemac* /usr/local/lib/
 */
@_cdecl("get_running_app")
public func get_running_app() -> Int32 {
  /*
    for app in NSWorkspace.init().runningApplications {
        if app.isActive {
            let ex = app.executableURL
            return ex?.absoluteString ?? ""
        }
    }
    */
    return 3
}

@_cdecl("is_wow_active")
public func is_wow_active() -> Bool  {
    
  
    for app in NSWorkspace.shared.runningApplications {
    
        if app.isActive {
            let ex = app.executableURL
            let path =  ex?.absoluteString ?? ""
            return path.hasSuffix("Warcraft%20Classic")
        }
    }
    return false
}

@available(macOS 10.11, *)
@_cdecl("send_key")
public func send_key() {
    let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
    
    let kspd = CGEvent(keyboardEventSource: src, virtualKey: 0x31, keyDown: true)   // space-down
    let kspu = CGEvent(keyboardEventSource: src, virtualKey: 0x31, keyDown: false)  // space-up

    let pids = [ 93407 ]; // real PID-s from command 'ps -ax' - e.g. for example 3 different processes
    
    for i in 0 ..< pids.count {
        print("sending to pid: ", pids[i]);
        kspd?.postToPid( pid_t(pids[i]) ); // convert int to pid_t
        kspu?.postToPid( pid_t(pids[i]) );
    }
}

@_cdecl("are_we_trusted")
public func are_we_trusted() -> Bool {
    return AXIsProcessTrusted()
}

@_cdecl("acquire_privileges")
public func acquirePrivileges() -> Bool {
  let accessEnabled = AXIsProcessTrustedWithOptions(
    [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)
    
  if accessEnabled != true {
    print("You need to enable the keylogger in the System Prefrences")
  }
  return accessEnabled == true;
}


@available(macOS 10.15, *)
@_cdecl("request_io_access")
public func request_io_access_check()  {
    IOHIDRequestAccess(kIOHIDRequestTypeListenEvent);
    IOHIDRequestAccess(kIOHIDRequestTypePostEvent);
}

@available(macOS 10.15, *)
@_cdecl("check_io_access")
public func check_io_access() -> Bool {
    let accessType = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent)
    switch accessType {
        case kIOHIDAccessTypeGranted:
        // User has approved the app to listen to all keystrokes
            return true
        case kIOHIDAccessTypeDenied:
            return false
        case kIOHIDAccessTypeUnknown:
        // Denied; approval dialog has not yet been displayed.
            return false
        default:
        // Unknown status
            return false
        }
}


let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
@available(macOS 10.11, *)
@_cdecl("send_key_to_pid")
public func send_key_to_pid(pid: Int32, virtual_key: UInt16) {
    send_key_down_to_pid(pid: pid,virtual_key: virtual_key,shift:false,alt:false,control:false);
    send_key_up_to_pid(pid: pid,virtual_key: virtual_key);
}

@available(macOS 10.11, *)
@_cdecl("send_key_up_to_pid")
public func send_key_up_to_pid(pid: Int32, virtual_key: UInt16) {
    let kspu = CGEvent(keyboardEventSource: src, virtualKey: virtual_key, keyDown: false)
        kspu?.postToPid(pid_t(pid));
}

@available(macOS 10.11, *)
@_cdecl("send_key_down_to_pid")
public func send_key_down_to_pid(pid: Int32, virtual_key: UInt16, shift: Bool, alt:Bool, control: Bool) {
    let kspu = CGEvent(keyboardEventSource: src, virtualKey: virtual_key, keyDown: true);
    
    if(shift) {
        kspu?.flags.insert(CGEventFlags.maskShift);
        
        
        
    }

    if(alt) {
        kspu?.flags.insert(CGEventFlags.maskAlternate);
    }

    if(control) {
        kspu?.flags.insert(CGEventFlags.maskControl);
    }
    
    kspu?.postToPid(pid_t(pid));
}


/*
import Foundation

let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
    
let kspd = CGEvent(keyboardEventSource: src, virtualKey: 0x31, keyDown: true)   // space-down
let kspu = CGEvent(keyboardEventSource: src, virtualKey: 0x31, keyDown: false)  // space-up

let pids = [ 24834, 24894, 24915 ]; // real PID-s from command 'ps -ax' - e.g. for example 3 different processes
    
for i in 0 ..< pids.count {
    print("sending to pid: ", pids[i]);
    kspd?.postToPid( pid_t(pids[i]) ); // convert int to pid_t
    kspu?.postToPid( pid_t(pids[i]) );
}
*/


