//
//  AccGraphVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation
import CorePlot

class AccGraphVC: UIViewController {
    fileprivate let accGraphBuilder:GraphBuilder
    
    required init?(coder aDecoder: NSCoder) {
        accGraphBuilder = GraphBuilder(title: "Accelerometer", type: .accelerometer, dataCache: SensorProcessor.dataCache)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        let accGraphView = self.view as! CPTGraphHostingView
        accGraphBuilder.initLoad(accGraphView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        accGraphBuilder.resume()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        accGraphBuilder.pause()
    }
}
