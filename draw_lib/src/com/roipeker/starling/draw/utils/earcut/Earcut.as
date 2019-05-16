// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 03/01/2019.
//
// =================================================================================================

package com.roipeker.starling.draw.utils.earcut {
import starling.utils.MathUtil;

/**
 * AS3 port of mapbox earcut
 * https://github.com/mapbox/earcut
 *
 */
public class Earcut {

    // static class.
    public function Earcut() {
    }

    public static function earcut(data:Object, holeIndices:Array = null, dim:uint = 2):Array {
        // data can be Vector or Array
        var hasHoles:Boolean = holeIndices && holeIndices.length,
                outerLen:int = hasHoles ? holeIndices[0] * dim : data.length,
                outerNode:Node = linkedList(data, 0, outerLen, dim, true),
                triangles:Array = [];
        if (!outerNode || outerNode.next === outerNode.prev) {
            return triangles;
        }
        var minX:Number = 0, minY:Number = 0, maxX:Number = 0, maxY:Number = 0, x:Number, y:Number, invSize:Number = 0;
        if (hasHoles) {
            outerNode = eliminateHoles(data, holeIndices, outerNode, dim);
        }

        // if the shape is not too simple, we'll use z-order curve hash later; calculate polygon bbox
        if (data.length > 80 * dim) {
            minX = maxX = data[0];
            minY = maxY = data[1];
            for (var i:int = dim; i < outerLen; i += dim) {
                x = data[i];
                y = data[i + 1];
                if (x < minX) minX = x;
                if (y < minY) minY = y;
                if (x > maxX) maxX = x;
                if (y > maxY) maxY = y;
            }
            // minX, minY and invSize are later used to transform coords into integers for z-order calculation
            invSize = MathUtil.max(maxX - minX, maxY - minY);
            invSize = invSize !== 0 ? 1 / invSize : 0;
        }
        earcutLinked(outerNode, triangles, dim, minX, minY, invSize);
        return triangles;
    }

    private static function linkedList(data:Object, start:int, end:int, dim:uint, clockwise:Boolean):Node {
        var i:int, last:Node = null;
        if (clockwise === (signedArea(data, start, end, dim) > 0)) {
            for (i = start; i < end; i += dim) {
                last = insertNode(i, data[i], data[i + 1], last);
            }
        } else {
            for (i = end - dim; i >= start; i -= dim) {
                last = insertNode(i, data[i], data[i + 1], last);
            }
        }
        if (last && equals(last, last.next)) {
            removeNode(last);
            last = last.next;
        }
        return last;
    }


// eliminate colinear or duplicate points
    private static function filterPoints(start:Node = null, end:Node = null):Node {
        if (!start) return start;
        if (!end) end = start;
        var p:Node = start,
                again:Boolean;
        do {
            again = false;
            if (!p.steiner && (equals(p, p.next) || area(p.prev, p, p.next) === 0)) {
                removeNode(p);
                p = end = p.prev;
                if (p === p.next) break;
                again = true;
            } else {
                p = p.next;
            }
        } while (again || p !== end);
        return end;
    }

// main ear slicing loop which triangulates a polygon (given as a linked list)
    private static function earcutLinked(ear:Node, triangles:Array, dim:uint, minX:Number, minY:Number, invSize:Number, pass:int = 0):void {
        if (!ear) return;

        // interlink polygon nodes in z-order
        if (!pass && invSize) indexCurve(ear, minX, minY, invSize);

        var stop:Node = ear, prev:Node, next:Node;

        // iterate through ears, slicing them one by one
        while (ear.prev !== ear.next) {
            prev = ear.prev;
            next = ear.next;
            if (invSize ? isEarHashed(ear, minX, minY, invSize) : isEar(ear)) {
                // cut off the triangle
                triangles.push(prev.i / dim);
                triangles.push(ear.i / dim);
                triangles.push(next.i / dim);
                removeNode(ear);
                // skipping the next vertex leads to less sliver triangles
                ear = next.next;
                stop = next.next;
                continue;
            }
            ear = next;

            // if we looped through the whole remaining polygon and can't find any more ears
            if (ear === stop) {
                // try filtering points and slicing again
                if (!pass) {
                    earcutLinked(filterPoints(ear), triangles, dim, minX, minY, invSize, 1);

                    // if this didn't work, try curing all small self-intersections locally
                } else if (pass === 1) {
                    ear = cureLocalIntersections(ear, triangles, dim);
                    earcutLinked(ear, triangles, dim, minX, minY, invSize, 2);

                    // as a last resort, try splitting the remaining polygon into two
                } else if (pass === 2) {
                    splitEarcut(ear, triangles, dim, minX, minY, invSize);
                }

                break;
            }
        }
    }


// go through all polygon nodes and cure small local self-intersections
    private static function cureLocalIntersections(start:Node, triangles:Array, dim:uint):Node {
        var p:Node = start;
        do {
            var a:Node = p.prev,
                    b:Node = p.next.next;

            if (!equals(a, b) && intersects(a, p, p.next, b) && locallyInside(a, b) && locallyInside(b, a)) {

                triangles.push(a.i / dim);
                triangles.push(p.i / dim);
                triangles.push(b.i / dim);

                // remove two nodes involved
                removeNode(p);
                removeNode(p.next);

                p = start = b;
            }
            p = p.next;
        } while (p !== start);

        return p;
    }


// try splitting polygon into two and triangulate them independently
    private static function splitEarcut(start:Node, triangles:Array, dim:uint, minX:Number, minY:Number, invSize:Number):void {
        // look for a valid diagonal that divides the polygon into two
        var a:Node = start;
        do {
            var b:Node = a.next.next;
            while (b !== a.prev) {
                if (a.i !== b.i && isValidDiagonal(a, b)) {
                    // split the polygon in two by the diagonal
                    var c:Node = splitPolygon(a, b);

                    // filter colinear points around the cuts
                    a = filterPoints(a, a.next);
                    c = filterPoints(c, c.next);

                    // run earcut on each half
                    earcutLinked(a, triangles, dim, minX, minY, invSize);
                    earcutLinked(c, triangles, dim, minX, minY, invSize);
                    return;
                }
                b = b.next;
            }
            a = a.next;
        } while (a !== start);
    }


// check if a diagonal between two polygon nodes is valid (lies in polygon interior)
    private static function isValidDiagonal(a:Node, b:Node):Boolean {
        return a.next.i !== b.i && a.prev.i !== b.i && !intersectsPolygon(a, b) &&
                locallyInside(a, b) && locallyInside(b, a) && middleInside(a, b);
    }


// link two polygon vertices with a bridge; if the vertices belong to the same ring, it splits polygon into two;
// if one belongs to the outer ring and another to a hole, it merges it into a single ring
    private static function splitPolygon(a:Node, b:Node):Node {
        var a2:Node = new Node(a.i, a.x, a.y),
                b2:Node = new Node(b.i, b.x, b.y),
                an:Node = a.next,
                bp:Node = b.prev;

        a.next = b;
        b.prev = a;

        a2.next = an;
        an.prev = a2;

        b2.next = a2;
        a2.prev = b2;

        bp.next = b2;
        b2.prev = bp;

        return b2;
    }


// check if the middle point of a polygon diagonal is inside the polygon
    private static function middleInside(a:Node, b:Node):Boolean {
        var p:Node = a,
                inside:Boolean = false,
                px:Number = (a.x + b.x) / 2,
                py:Number = (a.y + b.y) / 2;
        do {
            if (((p.y > py) !== (p.next.y > py)) && p.next.y !== p.y &&
                    (px < (p.next.x - p.x) * (py - p.y) / (p.next.y - p.y) + p.x))
                inside = !inside;
            p = p.next;
        } while (p !== a);
        return inside;
    }

//    check if two segments intersect
    private static function intersects(p1:Node, q1:Node, p2:Node, q2:Node):Boolean {
        if ((equals(p1, q1) && equals(p2, q2)) ||
                (equals(p1, q2) && equals(p2, q1))) return true;
        return area(p1, q1, p2) > 0 !== area(p1, q1, q2) > 0 &&
                area(p2, q2, p1) > 0 !== area(p2, q2, q1) > 0;
    }

// check if a polygon diagonal intersects any polygon segments
    private static function intersectsPolygon(a:Node, b:Node):Boolean {
        var p:Node = a;
        do {
            if (p.i !== a.i && p.next.i !== a.i && p.i !== b.i && p.next.i !== b.i &&
                    intersects(p, p.next, a, b)) return true;
            p = p.next;
        } while (p !== a);
        return false;
    }

// check if a polygon diagonal is locally inside the polygon
    private static function locallyInside(a:Node, b:Node):Boolean {
        return area(a.prev, a, a.next) < 0 ?
                area(a, b, a.next) >= 0 && area(a, a.prev, b) >= 0 :
                area(a, b, a.prev) < 0 || area(a, a.next, b) < 0;
    }

// check whether a polygon node forms a valid ear with adjacent nodes
    private static function isEar(ear:Node):Boolean {
        var a:Node = ear.prev,
                b:Node = ear,
                c:Node = ear.next;

        if (area(a, b, c) >= 0) return false; // reflex, can't be an ear

        // now make sure we don't have other points inside the potential ear
        var p:Node = ear.next.next;

        while (p !== ear.prev) {
            if (pointInTriangle(a.x, a.y, b.x, b.y, c.x, c.y, p.x, p.y) &&
                    area(p.prev, p, p.next) >= 0) return false;
            p = p.next;
        }

        return true;
    }

    private static function isEarHashed(ear:Node, minX:Number, minY:Number, invSize:Number):Boolean {
        var a:Node = ear.prev,
                b:Node = ear,
                c:Node = ear.next;

        if (area(a, b, c) >= 0) return false; // reflex, can't be an ear

        // triangle bbox; min & max are calculated like this for speed
        var minTX:Number = a.x < b.x ? (a.x < c.x ? a.x : c.x) : (b.x < c.x ? b.x : c.x),
                minTY:Number = a.y < b.y ? (a.y < c.y ? a.y : c.y) : (b.y < c.y ? b.y : c.y),
                maxTX:Number = a.x > b.x ? (a.x > c.x ? a.x : c.x) : (b.x > c.x ? b.x : c.x),
                maxTY:Number = a.y > b.y ? (a.y > c.y ? a.y : c.y) : (b.y > c.y ? b.y : c.y);

        // z-order range for the current triangle bbox;
        var minZ:Number = zOrder(minTX, minTY, minX, minY, invSize),
                maxZ:Number = zOrder(maxTX, maxTY, minX, minY, invSize);

        var p:Node = ear.prevZ,
                n:Node = ear.nextZ;

        // look for points inside the triangle in both directions
        while (p && p.z >= minZ && n && n.z <= maxZ) {
            if (p !== ear.prev && p !== ear.next &&
                    pointInTriangle(a.x, a.y, b.x, b.y, c.x, c.y, p.x, p.y) &&
                    area(p.prev, p, p.next) >= 0) return false;
            p = p.prevZ;

            if (n !== ear.prev && n !== ear.next &&
                    pointInTriangle(a.x, a.y, b.x, b.y, c.x, c.y, n.x, n.y) &&
                    area(n.prev, n, n.next) >= 0) return false;
            n = n.nextZ;
        }

        // look for remaining points in decreasing z-order
        while (p && p.z >= minZ) {
            if (p !== ear.prev && p !== ear.next &&
                    pointInTriangle(a.x, a.y, b.x, b.y, c.x, c.y, p.x, p.y) &&
                    area(p.prev, p, p.next) >= 0) return false;
            p = p.prevZ;
        }

        // look for remaining points in increasing z-order
        while (n && n.z <= maxZ) {
            if (n !== ear.prev && n !== ear.next &&
                    pointInTriangle(a.x, a.y, b.x, b.y, c.x, c.y, n.x, n.y) &&
                    area(n.prev, n, n.next) >= 0) return false;
            n = n.nextZ;
        }
        return true;
    }


// interlink polygon nodes in z-order
    private static function indexCurve(start:Node, minX:Number, minY:Number, invSize:Number):void {
        var p:Node = start;
        do {
            if (p.z == 0) p.z = zOrder(p.x, p.y, minX, minY, invSize);
            p.prevZ = p.prev;
            p.nextZ = p.next;
            p = p.next;
        } while (p !== start);
        p.prevZ.nextZ = null;
        p.prevZ = null;
        sortLinked(p);
    }


    private static function signedArea(data:Object, start:int, end:int, dim:uint):Number {
        var sum:Number = 0;
        for (var i:int = start, j:int = end - dim; i < end; i += dim) {
            sum += (data[j] - data[i]) * (data[i + 1] + data[j + 1]);
            j = i;
        }
        return sum;
    }

    private static function insertNode(i:int, x:Number, y:Number, last:Node):Node {
        var p:Node = new Node(i, x, y);
        if (!last) {
            p.prev = p;
            p.next = p;

        } else {
            p.next = last.next;
            p.prev = last;
            last.next.prev = p;
            last.next = p;
        }
        return p;
    }

    private static function removeNode(p:Node):void {
        p.next.prev = p.prev;
        p.prev.next = p.next;
        if (p.prevZ) p.prevZ.nextZ = p.nextZ;
        if (p.nextZ) p.nextZ.prevZ = p.prevZ;
    }


    // signed area of a triangle
    private static function area(p:Node, q:Node, r:Node):Number {
        return (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);
    }

// check if two points are equal
    private static function equals(p1:Node, p2:Node):Boolean {
        return p1.x === p2.x && p1.y === p2.y;
    }

    // check if a point lies within a convex triangle
    private static function pointInTriangle(ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number, px:Number, py:Number):Boolean {
        return (cx - px) * (ay - py) - (ax - px) * (cy - py) >= 0 &&
                (ax - px) * (by - py) - (bx - px) * (ay - py) >= 0 &&
                (bx - px) * (cy - py) - (cx - px) * (by - py) >= 0;
    }


// Simon Tatham's linked list merge sort algorithm
// http://www.chiark.greenend.org.uk/~sgtatham/algorithms/listsort.html
    private static function sortLinked(list:Node):Node {
        var i:int, p:Node, q:Node, e:Node, tail:Node, numMerges:int, pSize:int, qSize:int,
                inSize:int = 1;
        do {
            p = list;
            list = null;
            tail = null;
            numMerges = 0;

            while (p) {
                numMerges++;
                q = p;
                pSize = 0;
                for (i = 0; i < inSize; i++) {
                    pSize++;
                    q = q.nextZ;
                    if (!q) break;
                }
                qSize = inSize;

                while (pSize > 0 || (qSize > 0 && q)) {

                    if (pSize !== 0 && (qSize === 0 || !q || p.z <= q.z)) {
                        e = p;
                        p = p.nextZ;
                        pSize--;
                    } else {
                        e = q;
                        q = q.nextZ;
                        qSize--;
                    }

                    if (tail) tail.nextZ = e;
                    else list = e;

                    e.prevZ = tail;
                    tail = e;
                }

                p = q;
            }

            tail.nextZ = null;
            inSize *= 2;

        } while (numMerges > 1);

        return list;
    }

// z-order of a point given coords and inverse of the longer side of data bbox
    private static function zOrder(x:Number, y:Number, minX:Number, minY:Number, invSize:Number):uint {
        // coords are transformed into non-negative 15-bit integer range
        x = 32767 * (x - minX) * invSize;
        y = 32767 * (y - minY) * invSize;

        x = (x | (x << 8)) & 0x00FF00FF;
        x = (x | (x << 4)) & 0x0F0F0F0F;
        x = (x | (x << 2)) & 0x33333333;
        x = (x | (x << 1)) & 0x55555555;

        y = (y | (y << 8)) & 0x00FF00FF;
        y = (y | (y << 4)) & 0x0F0F0F0F;
        y = (y | (y << 2)) & 0x33333333;
        y = (y | (y << 1)) & 0x55555555;

        return x | (y << 1);
    }


    //===================================================================================================================================================
    //
    //      ------  HOLES
    //
    //===================================================================================================================================================

    // link every hole into the outer loop, producing a single-ring polygon without holes
    private static function eliminateHoles(data:Object, holeIndices:Array, outerNode:Node, dim:uint):Node {
        var queue:Array = [],
                i:int, len:int, start:int, end:int, list:Node;
        for (i = 0, len = holeIndices.length; i < len; i++) {
            start = holeIndices[i] * dim;
            end = i < len - 1 ? holeIndices[i + 1] * dim : data.length;
            list = linkedList(data, start, end, dim, false);
            if (list === list.next) list.steiner = true;
            queue.push(getLeftmost(list));
        }
        queue.sort(compareX);
        // process holes from left to right
        len = queue.length;
        for (i = 0; i < len; i++) {
            eliminateHole(queue[i], outerNode);
            outerNode = filterPoints(outerNode, outerNode.next);
        }
        return outerNode;
    }

    // find the leftmost node of a polygon ring
    private static function getLeftmost(start:Node):Node {
        var p:Node = start,
                leftmost:Node = start;
        do {
            if (p.x < leftmost.x) leftmost = p;
            p = p.next;
        } while (p !== start);
        return leftmost;
    }


    private static function compareX(a:Node, b:Node):Number {
        return a.x - b.x;
    }

// find a bridge between vertices that connects hole with an outer ring and and link it
    private static function eliminateHole(hole:Node, outerNode:Node):void {
        outerNode = findHoleBridge(hole, outerNode);
        if (outerNode) {
            var b:Node = splitPolygon(outerNode, hole);
            filterPoints(b, b.next);
        }
    }

// David Eberly's algorithm for finding a bridge between hole and outer polygon
    private static function findHoleBridge(hole:Node, outerNode:Node):Node {
        var p:Node = outerNode,
                hx:Number = hole.x,
                hy:Number = hole.y,
                qx:Number = -Infinity,
                m:Node;

        // find a segment intersected by a ray from the hole's leftmost point to the left;
        // segment's endpoint with lesser x will be potential connection point
        do {
            if (hy <= p.y && hy >= p.next.y && p.next.y !== p.y) {
                var x:Number = p.x + (hy - p.y) * (p.next.x - p.x) / (p.next.y - p.y);
                if (x <= hx && x > qx) {
                    qx = x;
                    if (x === hx) {
                        if (hy === p.y) return p;
                        if (hy === p.next.y) return p.next;
                    }
                    m = p.x < p.next.x ? p : p.next;
                }
            }
            p = p.next;
        } while (p !== outerNode);
        if (!m) return null;

        if (hx === qx) return m.prev; // hole touches outer segment; pick lower endpoint

        // look for points inside the triangle of hole point, segment intersection and endpoint;
        // if there are no points found, we have a valid connection;
        // otherwise choose the point of the minimum angle with the ray as connection point

        var stop:Node = m,
                mx:Number = m.x,
                my:Number = m.y,
                tanMin:Number = Infinity,
                tan:Number;

        p = m.next;
        while (p !== stop) {
            if (hx >= p.x && p.x >= mx && hx !== p.x &&
                    pointInTriangle(hy < my ? hx : qx, hy, mx, my, hy < my ? qx : hx, hy, p.x, p.y)) {

                tan = Math.abs(hy - p.y) / (hx - p.x); // tangential

                if ((tan < tanMin || (tan === tanMin && p.x > m.x)) && locallyInside(p, hole)) {
                    m = p;
                    tanMin = tan;
                }
            }
            p = p.next;
        }

        return m;
    }


    // turn a polygon in a multi-dimensional array form (e.g. as in GeoJSON) into a form Earcut accepts
    public static function flatten(data:Array):Object {
        var dim:uint = data[0][0].length,
                result:Object = {vertices: [], holes: [], dimensions: dim},
                holeIndex:uint = 0;
        var i:uint, j:uint, d:uint;
        for (i = 0; i < data.length; i++) {
            for (j = 0; j < data[i].length; j++) {
                for (d = 0; d < dim; d++) result.vertices.push(data[i][j][d]);
            }
            if (i > 0) {
                holeIndex += data[i - 1].length;
                result.holes.push(holeIndex);
            }
        }
        return result;
    }


// return a percentage difference between the polygon area and its triangulation area;
// used to verify correctness of triangulation
    public static function deviation(data:Array, holeIndices:Array, dim:uint, triangles:Array):Number {
        var hasHoles:Boolean = holeIndices && holeIndices.length;
        var outerLen:uint = hasHoles ? holeIndices[0] * dim : data.length;
        var polygonArea:Number = Math.abs(signedArea(data, 0, outerLen, dim));
        if (hasHoles) {
            for (var i:uint = 0, len:uint = holeIndices.length; i < len; i++) {
                var start:int = holeIndices[i] * dim;
                var end:int = i < len - 1 ? holeIndices[i + 1] * dim : data.length;
                polygonArea -= Math.abs(signedArea(data, start, end, dim));
            }
        }

        var trianglesArea:Number = 0, a:uint, b:uint, c:uint;
        for (i = 0; i < triangles.length; i += 3) {
            a = triangles[i] * dim;
            b = triangles[i + 1] * dim;
            c = triangles[i + 2] * dim;
            trianglesArea += Math.abs(
                    (data[a] - data[c]) * (data[b + 1] - data[a + 1]) -
                    (data[a] - data[b]) * (data[c + 1] - data[a + 1]));
        }
        return polygonArea === 0 && trianglesArea === 0 ? 0 :
                Math.abs((trianglesArea - polygonArea) / polygonArea);
    }

}
}


