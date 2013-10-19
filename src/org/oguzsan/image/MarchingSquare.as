/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Oğuz Sandıkçı http://oguzsan.org/
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * 	subject to the following conditions:
 *
 * 	The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package org.oguzsan.image
{
	import flash.geom.Point;

	public class MarchingSquare
	{
		//  MEMBERS
		private var _width:int;
		private var _height:int;
		private var _neightbourXOffsetList:Vector.<int>;
		private var _neightbourYOffsetList:Vector.<int>;
		private var _cellListByRow:Vector.<MarchingSquareList>;
		private var _closedIsoLineList:Vector.<MarchingSquareList>;
		private var _openIsoLineList:Vector.<MarchingSquareList>;

		//  ACCESSORS
		public function get width():int		        {	return _width;	        }
		public function get height():int	        {	return _height;	        }
		public function get closedIsoLineCount():int{   return _closedIsoLineList.length;   }
		public function get openIsoLineCount():int  {   return _openIsoLineList.length;     }

		//  CONSTRUCTOR
		public function MarchingSquare( inIsoData:IIsoData, inCloseLines:Boolean )
		{
			createMarchingSquareCells( inIsoData );
			createIsoLines( inCloseLines );
		}

		//  METHODS
		public function createClosedIsoLinePoints( inIsoLineIndex:int ):Vector.<Point>
		{
			return _closedIsoLineList[inIsoLineIndex].createPointList();
		}

		public function createOpenIsoLinePoints( inIsoLineIndex:int ):Vector.<Point>
		{
			return _openIsoLineList[inIsoLineIndex].createPointList();
		}

		private function createMarchingSquareCells( inIsoData:IIsoData ):void
		{
			_width = inIsoData.width;
			_height = inIsoData.height;
			_cellListByRow = new Vector.<MarchingSquareList>(_height,true);

			_cellListByRow[0] = new MarchingSquareList();
			for( var y:int=1 ; y<_height ; y++ )
			{
				var lineList:MarchingSquareList = new MarchingSquareList();

				for( var x:int= 1; x<_width; x++ )
				{
					var value:int = 0;
					if(inIsoData.getValueAt(x-1, y-1)>0)    value += 1;
					if(inIsoData.getValueAt(x,   y-1)>0)    value += 2;
					if(inIsoData.getValueAt(x,   y  )>0)    value += 4;
					if(inIsoData.getValueAt(x-1, y  )>0)    value += 8;

					switch(value)
					{
						case 0:     break;
						case 1:     lineList.addToEnd( new CellData( x, y, CellData.PREV_X, CellData.PREV_Y ) ); break;
						case 2:     lineList.addToEnd( new CellData( x, y, CellData.PREV_Y, CellData.NEXT_X ) ); break;
						case 3:     lineList.addToEnd( new CellData( x, y, CellData.PREV_X, CellData.NEXT_X ) ); break;
						case 4:     lineList.addToEnd( new CellData( x, y, CellData.NEXT_X, CellData.NEXT_Y ) ); break;
						case 5:     lineList.addToEnd( new CellData( x, y, CellData.PREV_X, CellData.NEXT_Y ) );
									lineList.addToEnd( new CellData( x, y, CellData.NEXT_X, CellData.PREV_Y ) ); break;
						case 6:     lineList.addToEnd( new CellData( x, y, CellData.PREV_Y, CellData.NEXT_Y ) ); break;
						case 7:     lineList.addToEnd( new CellData( x, y, CellData.PREV_X, CellData.NEXT_Y ) ); break;
						case 8:     lineList.addToEnd( new CellData( x, y, CellData.NEXT_Y, CellData.PREV_X ) ); break;
						case 9:     lineList.addToEnd( new CellData( x, y, CellData.NEXT_Y, CellData.PREV_Y ) ); break;
						case 10:    lineList.addToEnd( new CellData( x, y, CellData.NEXT_Y, CellData.NEXT_X ) );
									lineList.addToEnd( new CellData( x, y, CellData.PREV_Y, CellData.PREV_X ) ); break;
						case 11:    lineList.addToEnd( new CellData( x, y, CellData.NEXT_Y, CellData.NEXT_X ) ); break;
						case 12:    lineList.addToEnd( new CellData( x, y, CellData.NEXT_X, CellData.PREV_X ) ); break;
						case 13:    lineList.addToEnd( new CellData( x, y, CellData.NEXT_X, CellData.PREV_Y ) ); break;
						case 14:    lineList.addToEnd( new CellData( x, y, CellData.PREV_Y, CellData.PREV_X ) ); break;
						case 15:    break;
					}
				}
				_cellListByRow[y] = lineList;
			}

		}

		private function createIsoLines( inCloseLines:Boolean ):void
		{
			_neightbourXOffsetList = new <int>[1,0,-1,0];
			_neightbourYOffsetList = new <int>[0,1,0,-1];

			_closedIsoLineList = new Vector.<MarchingSquareList>();
			_openIsoLineList = new Vector.<MarchingSquareList>();

			var freeCell:CellData = getFreeCell();
			while( freeCell )
			{
				var isoLine:MarchingSquareList = new MarchingSquareList();
				isoLine.addToStart( freeCell );

				forwardIterationOnLine( isoLine );
				if( !isLineClosed(isoLine) )
				{
					backwardIterationOnLine( isoLine );
				}

				if( isLineClosed(isoLine) )
				{
					_closedIsoLineList.push( isoLine );
				}
				else
				{
					isoLine.addToStart( createPaddingCell( isoLine.first  ) );
					isoLine.addToEnd(   createPaddingCell( isoLine.last   ) );
					_openIsoLineList.push( isoLine );
				}

				freeCell = getFreeCell();
			}

			_cellListByRow = null;

			if( inCloseLines )
			{
				closeLines();
			}
		}

		private function getFreeCell():CellData
		{
			var freeCell:CellData;
			for( var y:int=0 ; y<_height; y++ )
			{
				if( _cellListByRow[y].count>0 )
				{
					freeCell = _cellListByRow[y].first;
					_cellListByRow[y].removeCell(_cellListByRow[y].first);
					break;
				}
			}
			return freeCell;
		}

		private function forwardIterationOnLine( inPolygon:MarchingSquareList ):void
		{
			var currentCell:CellData = inPolygon.first;

			do
			{
				var nextX:int = currentCell.x + _neightbourXOffsetList[currentCell.outputDirection];//currentCell.nextX;
				var nextY:int = currentCell.y + _neightbourYOffsetList[currentCell.outputDirection];//currentCell.nextY;
				if( nextX==-1 || nextY==-1 || nextX==_width || nextY==_height )
				{
					break;
				}

				var nextCell:CellData = null;

				for( var cell:CellData = _cellListByRow[nextY].first; cell; cell=cell.nextData )
				{
					if( cell.x==nextX )
					{
						if( (currentCell.outputDirection+2)%4 == cell.inputDirection )
						{
							nextCell = cell;
							_cellListByRow[nextY].removeCell( cell );
							break;
						}
					}
				}

				if( nextCell!=null )
				{
					currentCell = nextCell;
					inPolygon.addToEnd( currentCell );
				}
				else
				{
					currentCell = null;
				}
			}
			while(currentCell);
		}

		private function backwardIterationOnLine( inPolygon:MarchingSquareList ):void
		{
			var currentCell:CellData = inPolygon.first;

			do
			{
				var prevX:int = currentCell.x + _neightbourXOffsetList[currentCell.inputDirection];//currentCell.prevX;
				var prevY:int = currentCell.y + _neightbourYOffsetList[currentCell.inputDirection];//currentCell.prevY;
				if( prevX==-1 || prevY==-1 || prevX==_width || prevY==_height )
				{
					break;
				}

				var prevCell:CellData = null;

				for( var cell:CellData = _cellListByRow[prevY].first; cell; cell=cell.nextData )
				{
					if( cell.x==prevX )
					{
						if( (currentCell.inputDirection+2)%4 == cell.outputDirection )
						{
							prevCell = cell;
							_cellListByRow[prevY].removeCell( cell );
							break;
						}
					}
				}

				if( prevCell!=null )
				{
					currentCell = prevCell;
					inPolygon.addToStart( currentCell );
				}
				else
				{
					currentCell = null;
				}
			}
			while(currentCell);
		}



		public function isLineClosed( inLine:MarchingSquareList ):Boolean
		{
			var first:CellData = inLine.first;
			var last:CellData = inLine.last;
			return(
				first.x+_neightbourXOffsetList[first.inputDirection]==last.x &&
				first.y+_neightbourYOffsetList[first.inputDirection]==last.y &&
				first.inputDirection==(last.outputDirection+2)%4 )
		}

		private function closeLines():void
		{
			var edgeList:Vector.<EdgeData> = new Vector.<EdgeData>(4,true);
			edgeList[0] = new EdgeData( 0,        0,        _height,    0       );
			edgeList[1] = new EdgeData( 0,        _width,   0,          0       );
			edgeList[2] = new EdgeData( _width,   _width,   0,          _height );
			edgeList[3] = new EdgeData( _width,   0,        _height,    _height );

			//  Iterate all open lines
			while( _openIsoLineList.length )
			{
				//  take first one without removing from list
				var currentLine:MarchingSquareList = _openIsoLineList[0];

				//  find edge of first cell
				var currentEdge:EdgeData;
				for( var currentEdgeId:int = 0; currentEdgeId<edgeList.length ; currentEdgeId++ )
				{
					currentEdge = edgeList[currentEdgeId];
					if( currentEdge.isPointOnEdge( currentLine.first.x, currentLine.first.y ) )
					{
						break;
					}
				}

				//  Iterate end points of all lines
				while( currentLine )
				{
					var newLineNo:int = -1;
					var newLineDistance:int = _height*_width;  //    just some big number
					for( var i:int=0 ; i<_openIsoLineList.length ; i++ )
					{
						var newLine:MarchingSquareList = _openIsoLineList[i];
						if( currentEdge.isPointOnEdge( newLine.last.x, newLine.last.y ) )
						{
							var distance:int =  (newLine.last.x-currentLine.first.x)*currentEdge.xDirection+
												(newLine.last.y-currentLine.first.y)*currentEdge.yDirection;

							if( distance>0 && distance<newLineDistance )
							{
								newLineNo = i;
								newLineDistance = distance;
							}
						}
					}

					//  found closing line
					if( newLineNo!=-1 )
					{
						//  self closing
						if(newLineNo==0)
						{
							_closedIsoLineList.push( _openIsoLineList.shift() );
							currentLine = null;
						}
						else
						{
							//  closing to another line
							currentLine.appendListToStart( newLine );
							_openIsoLineList.splice( newLineNo, 1 );
						}
					}
					else
					{
						//  No closing poly, move to next edge
						_openIsoLineList[0].addToStart( new CellData( currentEdge.xEnd,currentEdge.yEnd,0,0 ) );

						currentEdgeId = (currentEdgeId+1)%4;
						currentEdge = edgeList[currentEdgeId];
					}
				}
			}
		}

		private function createPaddingCell( inCell:CellData):CellData
		{
			var cell:CellData;
			if( inCell.x==1)
			{
				cell = new CellData( 0, inCell.y, 0, 0 );
			}
			else if( inCell.y==1 )
			{
				cell = new CellData( inCell.x, 0, 0, 0 );
			}
			if( inCell.x==_width-1)
			{
				cell = new CellData( _width, inCell.y, 0, 0 );
			}
			else if( inCell.y==_height-1 )
			{
				cell = new CellData( inCell.x, _height, 0, 0 );
			}

			return cell;
		}

	}
}

import flash.geom.Point;


class CellData
{
	//  CONSTANTS
	static public const NEXT_X:int = 0;
	static public const NEXT_Y:int = 1;
	static public const PREV_X:int = 2;
	static public const PREV_Y:int = 3;

	//  MEMBERS
	public var x:int;
	public var y:int;
	public var inputDirection:int;
	public var outputDirection:int;
	public var prevData:CellData;
	public var nextData:CellData;

//	internal var ownerList:MarchingSquareList;

	//  CONSTRUCTOR
	public function CellData( inX:int, inY:int, inInput:int, inOutput:int )
	{
		x = inX;
		y = inY;
		inputDirection = inInput;
		outputDirection = inOutput;
	}

}

class MarchingSquareList
{
	//  MEMBERS
	public var first:CellData;
	public var last:CellData;
	public var count:int;

	//  CONSTRUCTOR
	public function MarchingSquareList()
	{
		first = last = null;
		count = 0;
	}

	//  METHODS
	public function addToEnd( inCell:CellData ):void
	{
//		if( inCell.ownerList!=null)
//		{
//			log("ERROR:adding another list's cell");
//		}
//		inCell.ownerList = this;

		if( count>0 )
		{
			last.nextData = inCell;
			inCell.prevData = last;
			last = inCell;
		}
		else
		{
			last = first = inCell;
		}
		count++;
	}

	public function addToStart( inCell:CellData ):void
	{
//		if( inCell.ownerList!=null)
//		{
//			log("adding another list's cell");
//		}
//		inCell.ownerList = this;

		if( count>0 )
		{
			first.prevData = inCell;
			inCell.nextData = first;
			first = inCell;
		}
		else
		{
			last = first = inCell;
		}
		count++;
	}

	public function removeCell( inCell:CellData  ):void
	{
//		if( inCell.ownerList!=this )
//		{
//			log("removeing another list's cell");
//		}
//		inCell.ownerList = null;

		if( count>1 )
		{
			if( inCell.prevData	)
			{
				inCell.prevData.nextData = inCell.nextData;
			}
			else
			{
				first = first.nextData;
				first.prevData = null;
			}

			if( inCell.nextData )
			{
				inCell.nextData.prevData = inCell.prevData;
			}
			else
			{
				last = last.prevData;
				last.nextData = null;
			}
		}
		else if( count==1)
		{
			first = last = null;
		}
		count--;

		inCell.nextData = null;
		inCell.prevData = null;
	}

	public function createPointList( ):Vector.<Point>
	{
		var list:Vector.<Point> = new Vector.<Point>(count, true);

		var i:int = 0;
		for( var cell:CellData=first; cell; cell = cell.nextData )
		{
			list[i++] = new Point(cell.x,cell.y);
		}

		return list;
	}

	public function appendListToStart( inList:MarchingSquareList ):void
	{
		first.prevData = inList.last;
		inList.last.nextData = first;
		first = inList.first;
		count += inList.count;

		inList.first = null;
		inList.last = null;
		inList.count = 0;
	}
}

class EdgeData
{
	public var xStart:int;
	public var xEnd:int;
	public var xDirection:int;
	public var yStart:int;
	public var yEnd:int;
	public var yDirection:int;
	private var xMin:int;
	private var xMax:int;
	private var yMin:int;
	private var yMax:int;

	public function EdgeData( inXStart:int, inXEnd:int, inYStart:int, inYEnd:int )
	{
		xStart      = inXStart;
		xEnd        = inXEnd;
		xDirection  = inXEnd-inXStart;
		xDirection  = (xDirection > 0)?(1):( (xDirection < 0)?(-1):(0) );

		yStart      = inYStart;
		yEnd        = inYEnd;
		yDirection  = inYEnd-inYStart;
		yDirection  = (yDirection > 0)?(1):( (yDirection < 0)?(-1):(0) );

		xMin = Math.min( xStart, xEnd );
		xMax = Math.max( xStart, xEnd );
		yMin = Math.min( yStart, yEnd );
		yMax = Math.max( yStart, yEnd );
	}

	public function isPointOnEdge( inX:int, inY:int ):Boolean
	{
		return ( xMin<=inX && inX<=xMax && yMin<=inY && inY<=yMax )?(true):(false);
	}
}


//function log( inMessage:String ):void
//{
//	trace(inMessage);
//}