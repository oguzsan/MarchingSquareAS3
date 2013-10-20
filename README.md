# Marching Squares

A [marching squares][] implementation for Actionscript 3.

### How to use

Create a class that implements IIsoData interface.

    public interface IIsoData
    {
		function get width():int;
		function get height():int;
		function getValueAt( inX:int, inY:int ):int;
    }
    
IIsoData.getValueAt method must return zero for outer locations and a higher value for inner locations.

Example:
    
    public class BitmapAlphaIsoData implements IIsoData


Use IIsoData implementation with MarchingSquare class.

    var closeLines:Boolean = true;
    var isoData:BitmapAlphaIsoData = new BitmapAlphaIsoData( image );
    var marchingSquare:MarchingSquare = new MarchingSquare( );
	marchingSquare.execute( isoData, _closeLines );


Iterate on results.

    for( var i:int=0 ; i<marchingSquare.closedIsoLineCount; i++ )
    {
        var pointList:Vector.<Point> = marchingSquare.createClosedIsoLinePoints( i );
        .
        .
        .
    }
    
    for( var i:int=0 ; i<marchingSquare.openIsoLineCount; i++ )
    {
        var pointList:Vector.<Point> = marchingSquare.createOpenIsoLinePoints( i );
        .
        .
        .
    }
    
## Things to do ##

* Better an more complete readme file
* More comments
* Better usage examples
* Optimisations


[marching squares]: http://en.wikipedia.org/wiki/Marching_squares
