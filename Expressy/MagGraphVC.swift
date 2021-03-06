//
//  MagGraphVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation
import CorePlot

class MagGraphVC: UIViewController {
    fileprivate let magGraphBuilder:GraphBuilder
    
    required init?(coder aDecoder: NSCoder) {
        magGraphBuilder = GraphBuilder(title: "Magnetometer", type: .magnetometer, dataCache: SensorProcessor.dataCache)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        let magGraphView = self.view as! CPTGraphHostingView
        magGraphBuilder.initLoad(magGraphView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        magGraphBuilder.resume()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        magGraphBuilder.pause()
    }
}
