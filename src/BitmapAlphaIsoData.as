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

package
{
	import org.oguzsan.image.*;
	import flash.display.BitmapData;

	final public class BitmapAlphaIsoData implements IIsoData
	{
		//  MEMBERS
		private var _bitmapData:BitmapData;
		private var _threshold:int;

		//  ACCESSORS
		public function get width():int	                {	return _bitmapData.width;	}
		public function get height():int	            {	return _bitmapData.height;  }
		public function get threshold():int	            {	return _threshold;  		}
		public function set threshold( value:int ):void	{	_threshold = value;	        }

		//  CONSTRUCTOR
		public function BitmapAlphaIsoData( inBitmapData:BitmapData, inThreshold:int=0 )
		{
			_bitmapData = inBitmapData;
		}

		//  METHODS
		public function getValueAt( inX:int, inY:int ):int
		{
			return ((_bitmapData.getPixel32(inX,inY)>>24)&0xff)>_threshold?1:0;
		}

	}
}
