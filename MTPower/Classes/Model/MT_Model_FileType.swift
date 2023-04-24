//
//  MT_Model_FileType.swift
//  Alamofire
//
//  Created by pulei yu on 2023/4/19.
//

import Foundation
public enum MT_Server_FileType: String {
    case directory
    case regular
    case diary
    case net_link

    public var name: String { rawValue }
}

public struct MT_Model_KeyValue {
    public let key: String
    public let value: String
}

public enum MT_FileType_Source {
    public static let video: [String] = ["mp4", "MP4", "avi", "AVI", "wmv", "WMV", "asf", "ASF", "asx", "ASX", "rm", "RM", "rM", "Rm", "rmvb", "RMVB", "mpg", "MPG", "mpeg", "MPEG", "mpe", "MPE", "3gp", "3GP", "mov", "MOV", "m4v", "M4V", "dat", "DAT", "mkv", "MKV", "flv", "FLV", "vob", "VOB", "ts", "TS"]
    public static let text: [String] = ["PDF", "pdf", "XLS", "xls", "XLSX", "xlsx", "ppt", "PPT", "pptx", "PPTX", "docx", "DOCX", "dox", "DOC", "doc", "TXT", "txt"]
    public static let audio: [String] = ["WMA", "wma", "FLAC", "flac", "APE", "ape", "WAV", "wav", "MP3", "mp3", "ogg", "OGG"]
    public static let image: [String] = ["jpg", "JPG", "jpeg", "JPEG", "png", "PNG", "heic", "HEIC"]
}

public enum MT_FileType: String{
    case image
    case video
    case audio
    case txt
    case other
    case directory
    
    public static func type(from ext: String)-> MT_FileType{
        if MT_FileType_Source.video.contains(ext){   return .video}
        if MT_FileType_Source.audio.contains(ext){   return .audio}
        if MT_FileType_Source.text.contains(ext){   return .txt}
        if MT_FileType_Source.image.contains(ext){   return .image}
        return .other
    }
    
    public static func type(of name: String)-> MT_FileType{
        let ext = (name as NSString).pathExtension
        return type(from: ext)
    }
}
