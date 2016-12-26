//
//  BZProjectView.swift
//  ToolTiming
//
//  Created by Bradley Zellman on 12/26/16.
//  Copyright © 2016 Bradley Zellman. All rights reserved.
//

import Cocoa

let escapeKey = 53

protocol BZProjectViewDelegate {
    func didPressEscape()
}

class BZProjectView: NSView {
    
    var delegate : BZProjectViewDelegate?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }

    override func keyDown(with event: NSEvent) {
        let character = Int(event.keyCode)
        switch character {
        case escapeKey:
            delegate?.didPressEscape()
        default:
            super.keyDown(with: event)
        }
    }
    
    override var acceptsFirstResponder : Bool {
        return true
    }
    

    
}
