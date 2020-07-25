//
//  ViewController.swift
//  MetalTest6
//
//  Created by 福山帆士 on 2020/07/25.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    
    private let device = MTLCreateSystemDefaultDevice()!
    
    private var commandQuere: MTLCommandQueue!
    
    private let vertexData: [Float] = [
        -1, -1, 0, 1,
        1, -1, 0, 1,
        -1, 1, 0, 1,
        1, 1, 0, 1
    ]
    
    private var vertexBuffer: MTLBuffer!
    
    private var renderPipelline: MTLRenderPipelineState!
    
    private var renderPassDescriptor = MTLRenderPassDescriptor()
    
    
    lazy var myMLKView: MTKView = {
        let view = MTKView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), device: device)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(myMLKView)
        
        
        setup()
        
        vertexdataToBuffer()
        
        createPipiline()
        
        myMLKView.enableSetNeedsDisplay = true
        
        myMLKView.setNeedsDisplay()
        
    }
    
    func setup() {
        
        myMLKView.delegate = self
        commandQuere = device.makeCommandQueue()!
    }
    
    func vertexdataToBuffer() {
        
        let size = vertexData.count * MemoryLayout<Float>.size
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: size)
    }
    
    func createPipiline() {
        
        let renderDescriptor = MTLRenderPipelineDescriptor()
        renderDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        guard let library = device.makeDefaultLibrary() else { fatalError() }
        renderDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        renderDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        
        renderPipelline = try! device.makeRenderPipelineState(descriptor: renderDescriptor)
    }

}

extension ViewController: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable else { fatalError() }
        
        guard let commandBuffer = commandQuere.makeCommandBuffer() else { fatalError() }
        
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        guard let pipeline = renderPipelline else { fatalError() }
        
        encoder.setRenderPipelineState(pipeline)
        
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        encoder.drawPrimitives(type: .triangleStrip,
                               vertexStart: 0,
                               vertexCount: 4)
        
        encoder.endEncoding()
        
        commandBuffer.present(drawable)
        
        commandBuffer.commit()
        
        commandBuffer.waitUntilCompleted()
        
    }
    
    
}

