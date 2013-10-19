/**
 * Created with IntelliJ IDEA.
 * User: Oguzsan
 * Date: 19.10.2013
 * Time: 06:14
 * To change this template use File | Settings | File Templates.
 */
package
{
	import org.oguzsan.image.*;
	import flash.display.BitmapData;

	public class BitmapAlphaIsoData implements IIsoData
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
