/**
 * Created with IntelliJ IDEA.
 * User: Oguzsan
 * Date: 19.10.2013
 * Time: 06:12
 * To change this template use File | Settings | File Templates.
 */
package org.oguzsan.image
{
	public interface IIsoData
	{
		function get width():int;
		function get height():int;
		function getValueAt( inX:int, inY:int ):int;
	}
}
