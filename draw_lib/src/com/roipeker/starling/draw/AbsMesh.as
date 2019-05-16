// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 31/12/2018.
//
// =================================================================================================

package com.roipeker.starling.draw {
import starling.display.Mesh;
import starling.geom.Polygon;
import starling.rendering.IndexData;
import starling.rendering.VertexData;
import starling.styles.MeshStyle;

public class AbsMesh extends Mesh {

    protected var _poly:Polygon;
    protected var _color:int = 0xffffff;

    public function AbsMesh(vdata:VertexData = null, idata:IndexData = null, style:MeshStyle = null) {
        if (!vdata) vdata = new VertexData();
        if (!idata) idata = new IndexData();
        _poly = new Polygon();
        super(vdata, idata, style);
    }

    public function processVerticesList(vertices:Array, color:int = -1):void {

        var vdata:VertexData = vertexData;
        var idata:IndexData = indexData;

        vdata.clear();
        idata.clear();

        if (!_poly) {
            _poly = new Polygon( vertices )
        } else {
            _poly.numVertices = 0;
            _poly.addVertices.apply(null, vertices);
        }
        _poly.triangulate(idata);
        _poly.copyToVertexData(vdata);
        if (color > -1) {
            _color = color;
            vdata.colorize('color', _color);
        }
        setIndexDataChanged();
    }

    public function getVertex():VertexData {
        return vertexData;
    }

    public function getIndex():IndexData {
        return indexData;
    }
}
}
