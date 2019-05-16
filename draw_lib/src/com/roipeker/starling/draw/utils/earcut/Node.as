// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 03/01/2019.
//
// =================================================================================================

package com.roipeker.starling.draw.utils.earcut {
public class Node {

    public var i:int;
    public var x:Number;
    public var y:Number;
    public var prev:Node = null;
    public var next:Node = null;
    public var z:uint = 0;
    public var prevZ:Node;
    public var nextZ:Node;
    public var steiner:Boolean = false;

    public function Node($i:int, $x:Number, $y:Number) {
        i = $i;
        x = $x;
        y = $y;
    }
}
}
