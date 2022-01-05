// Tono (Tools Of New Operation) library
//  MIT Lisence (c) 2021 Manabu Tonosaki all rights reserved
//
//  Created by Manabu Tonosaki on 2022/01/05.

import Foundation

open class GeoEu {

    public static let EarthRadiusX = 6378137000.0
    public static let EarthRadiusY = 6356752000.0
    
    public class func getDistanceGrateCircle(lon0: Double, lat0: Double, lon1: Double, lat1: Double) -> Double {
        var dx = lon1 - lon0
        var dy = lat1 - lat0
        dx = dx / 360.0 * 2.0 * Double.pi * EarthRadiusX / 1000.0 * cos((lat0 + lat1) / 2.0 * Double.pi / 180.0)
        dy = dy / 360.0 * 2.0 * Double.pi * EarthRadiusY / 1000.0
        var ret = sqrt(dx * dx + dy * dy)
        ret = ret * 246060.92770516232 / 245998.87656939359
        return ret
    }
}
