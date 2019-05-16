// =================================================================================================
//
//	Created by Rodrigo Lopez [roipeker™] on 05/01/2019.
//
// =================================================================================================

package com.roipeker.starling.draw.utils.svg {
public class DPathParser {

    private var regExpMap:Object = {
        command: /\s*([achlmqstvzo])/gi,
        number: /\s*([+-]?\d*\.?\d+(?:e[+-]?\d+)?)/gi,
        comma: /\s*(?:(,)|\s)/g,
        flag: /\s*([01])/g
    };

    private var matchers:Object = {};
    private var commands:Array;
    private var index:int;
    private var data:String;
    private var relative:Boolean;
    private var curr_cmd:String;

    private static const FLAG:String = 'flag';
    private static const COMMA:String = 'comma';
    private static const COMMAND:String = 'command';

    private static const NUMBER:String = 'number';
    private static const COORD_PAIR:String = 'coord_pair';
    private static const ARC_DEF:String = 'arc_definition';


    public function DPathParser() {
        init();
    }

    private function init():void {
        /* var res:* = arrayReduce([0, 1, 2, 3, 4], function (valorAnterior:Number, valorActual:Number, indice:int, vector:Array):Number {
             return valorAnterior + valorActual;
         }, 10);
         trace("REsult:", res);

         return;*/

        matchers[NUMBER] = function (must:Boolean):Number {
            var a:* = get(NUMBER, must);
            return Number(a);
        };

        matchers[COORD_PAIR] = function (must:Boolean):Object {
            var xs:String = get(NUMBER, must);
            if (!xs && !must) return null;
            get(COMMA, false);
            var ys:String = get(NUMBER, true);
            return {x: Number(xs), y: Number(ys)};
        };

        matchers[ARC_DEF] = function (must:Boolean):Object {
            var radii:Object = matchers[COORD_PAIR](must);
            if (!radii && !must) return null;
            get(COMMA);
            var rot:Number = Number(get(NUMBER, true));
            get(COMMA, true);
            var large:Boolean = Boolean(Number(get(FLAG, true)));
            get(COMMA);
            var clockwise:Boolean = Boolean(Number(get(FLAG, true)));
            get(COMMA);
            var end:Object = matchers[COORD_PAIR](true);
            return {
                radii: radii,
                rotation: rot, large: large, clockwise: clockwise, end: end
            };
        }
    }

    public function reset():void {
        curr_cmd = null;
        data = null;
        commands = null;
        relative = false;
        index = 0;
    }

    private function get(key:String, must:Boolean = false):String {
        var re:RegExp = regExpMap[key];
        re.lastIndex = index;
        var res:Object = re.exec(data);
        if (!res || res.index != index) {
            if (!must) return null;
            throw new Error("Expected " + key + " at position " + index);
        }
        index = re.lastIndex;
        return res[1];
    }


    public function parse(d:String):Array {
        reset();
        data = d;
        commands = [];
        relative = false;

        var len:int = d.length;
        while (index < len) {
            curr_cmd = get(COMMAND, false);
            if (!curr_cmd) {
                ++index;
                continue;
            }
            var upcmd:String = curr_cmd.toUpperCase();
            relative = curr_cmd != upcmd;
            var seq:Array;
            if (upcmd == "M") {
                seq = getSeq(COORD_PAIR).map(function (coords:Object, i:int, arr:Array) {
                    if (i == 1) curr_cmd = relative ? 'l' : 'L';
                    return makeCommand({end: coords});
                });
            } else if (upcmd == "L" || upcmd == "T") {
                seq = getSeq(COORD_PAIR).map(function (coords:Object, i:int, arr:Array) {
                    return makeCommand({end: coords});
                });
            } else if (upcmd == "C") {
                seq = getSeq(COORD_PAIR);
                if (seq.length % 3) {
                    throw new Error("Expected coordinate pair triplet at position " + index);
                }
                seq = arrayReduce(seq, function (prev:Object, coords:Object, i:int, arr:Array):* {
                    var rest:int = i % 3;
                    if (!rest) {
                        prev.push(makeCommand({cp1: coords}));
                    } else {
                        var last:Object = prev[prev.length - 1];
                        if (rest === 1) {
                            last.cp2 = coords;
                        } else {
                            last.end = coords;
                        }
                    }
                    return prev;
                }, []) as Array;

            } else if (upcmd == "Q" || upcmd == "S") {

                seq = getSeq(COORD_PAIR);
                if (seq.length & 1) {
                    throw new Error("Expected coordinate pair couple at position " + index);
                }
                seq = arrayReduce(seq, function (prev:Object, coords:Object, i:int, arr:Array):Object {
                    var odd:int = i & 1;
                    if (!odd) {
                        prev.push(makeCommand({cp: coords}));
                    } else {
                        var last:Object = prev[prev.length - 1];
                        last.end = coords;
                    }
                    return prev;
                }, []) as Array;

            } else if (upcmd == "H" || upcmd == "V") {
//                trace("adding h/v!")
                seq = getSeq(NUMBER).map(function (value:Object, i:int, arr:Array) {
//                    trace("WTF ? ! >> ", value)
                    return makeCommand({value: value});
                });
            } else if (upcmd == "A") {
                seq = getSeq(ARC_DEF).map(function (value:Object, i:int, arr:Array) {
                    return makeCommand(value);
                });
            } else if (upcmd == "Z") {
                seq = [{code: "Z"}]
            } else if (upcmd == "O") {
                seq = [{code: "O"}]
            }
//            trace("Rel", rel, curr_cmd);
//            ++index;
            commands.push.apply(commands, seq);
        }
        return commands;
    }

    private function makeCommand(obj:Object):Object {
        obj.code = curr_cmd;
        obj.relative = relative;
        return obj;
    }

    private function getSeq(id:String):Array {
        var s:Array = [];
        var matched:Object;
        var must:Boolean = true;
        var valid:Boolean = true;
        while (valid) {
            matched = matchers[id](must);
            if (matched) {
                s.push(matched);
                must = Boolean(get("comma", false));
                valid = true;
            } else {
                valid = false;
            }
        }
        return s;
    }

    private static function arrayReduce(arr:Array, callback:Function, initValue:* = null):* {
        var len:int = arr.length;
        var prevValue:*;
        if (initValue) {
            var i:int = 0;
            prevValue = initValue;
        } else {
            i = 1;
            prevValue = arr[0];
        }
        for (i; i < len; i++) {
            var nextValue:* = arr[i];
            if (nextValue == null) continue;
            prevValue = callback(prevValue, nextValue, i, arr);
        }
        return prevValue;
    }
}
}
