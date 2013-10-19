package
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.system.fscommand;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;


	import org.oguzsan.image.MarchingSquare;

	[SWF(width="1024",height="768",frameRate="30")]
	public class Main extends Sprite
	{
		//  CONSTANTS
		private const IMAGE_WIDTH:int   = 256;
		private const IMAGE_HEIGHT:int  = 256;
		private const IMAGE_DRAW_COLOR:int  = 0xff4400;

		private const THUMBNAIL_WIDTH:Number    = 100;
		private const THUMBNAIL_HEIGHT:Number   = 100;
		private const THUMBNAIL_PADDING:Number  = 10;
		private const THUMBNAIL_CONTAINER_HEIGHT:Number = THUMBNAIL_HEIGHT + THUMBNAIL_PADDING*2;

		private const CLOSED_ISO_LINE_COLOR:int = 0x00FF00;
		private const OPEN_ISO_LINE_COLOR:int = 0xFF00FF;
		private const POLYGON_LINE_THICKNESS:int = 3;

		//  MEMBERS
		private var _bgPatternImage:BitmapData;

		private var _imageContainer:Sprite;
		private var _imageBgDisplay:Sprite;
		private var _imageDisplay:Bitmap;
		private var _polygonDisplay:Sprite;

		private var _thumbnailContainer:Sprite;
		private var _thumbnailDictionary:Dictionary;
		private var _thumbnailCount:int;
		private var _logText:TextField;
		private var _closeLines:Boolean;

		//  CONSTRUCTOR
		public function Main()
		{
			if (stage)
			{
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				stage.addEventListener( KeyboardEvent.KEY_DOWN, stage_onKeyDown );

				addEventListener(Event.ENTER_FRAME, this_onFirstFrame );
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, this_onAddedToStage );
			}

		}

		//	METHODS
		private function this_onFirstFrame( inEvent:Event ):void
		{
			removeEventListener(Event.ENTER_FRAME, this_onFirstFrame );

			init();
		}

		private function this_onAddedToStage(inEvent:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, this_onAddedToStage );

			init();
		}

		private function stage_onKeyDown(inEvent:KeyboardEvent):void
		{
			if ( inEvent.keyCode == Keyboard.ESCAPE )
			{
				fscommand("quit");
			}
		}

		private function stage_onResize( inEvent:Event ):void
		{
			imageContainer_resize();
			thumbnail_resize();
		}

		private function init():void
		{
			_bgPatternImage = new BitmapData( 16, 16, false, 0xeeeeee );
			var boxes:Sprite = new Sprite();
			boxes.graphics.beginFill( 0xdddddd );
			boxes.graphics.drawRect(0,0,8,8);
			boxes.graphics.drawRect(8,8,8,8);
			boxes.graphics.endFill();
			_bgPatternImage.draw( boxes);

			imageContainer_init();

			thumbnailContainer_init();

			_logText = new TextField();
			_logText.autoSize = TextFieldAutoSize.LEFT;
			addChild(_logText);

			stage_onResize( null );
			stage.addEventListener(Event.RESIZE, stage_onResize );
		}

		private function imageContainer_init():void
		{
			_imageContainer = new Sprite();
			addChild( _imageContainer );

			_imageBgDisplay = new Sprite();
			_imageContainer.addChild( _imageBgDisplay );

			_imageDisplay = new	Bitmap();
			_imageContainer.addChild(_imageDisplay);

			_polygonDisplay = new Sprite();
			_imageContainer.addChild(_polygonDisplay);
		}

		private function imageContainer_resize():void
		{
			_imageContainer.x = (stage.stageWidth-_imageContainer.width)*0.5;
			_imageContainer.y = ((stage.stageHeight-THUMBNAIL_CONTAINER_HEIGHT)-_imageContainer.width)*0.5;
		}

		private function thumbnailContainer_init():void
		{
			_thumbnailContainer = new Sprite();
			_thumbnailContainer.graphics.beginFill( 0xFFA67E );
			_thumbnailContainer.graphics.drawRect(0, 0, 2000, THUMBNAIL_CONTAINER_HEIGHT );
			addChild( _thumbnailContainer );

			_thumbnailDictionary = new Dictionary();

			addThumbnail( testImage1() );
			addThumbnail( testImage2() );
			addThumbnail( testImage3() );
			addThumbnail( testImage4() );
			addThumbnail( testImage5() );
			addThumbnail( testImage6() );
			addThumbnail( testImage7() );
		}

		private function addThumbnail( inThumbnailImage:BitmapData ):void
		{
			var thumbDisplay:Sprite = new Sprite( );
			thumbDisplay.x = THUMBNAIL_PADDING + _thumbnailCount*(THUMBNAIL_WIDTH+THUMBNAIL_PADDING);
			thumbDisplay.y = THUMBNAIL_PADDING;
			thumbDisplay.buttonMode = true;
			thumbDisplay.useHandCursor = true;
			thumbDisplay.mouseChildren = false;
			thumbDisplay.addEventListener(MouseEvent.CLICK, thumbnail_onClick );

			var bg:Sprite = new Sprite()
			bg.graphics.beginBitmapFill( _bgPatternImage );
			bg.graphics.drawRect( 0, 0, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT );
			bg.graphics.endFill();
			thumbDisplay.addChild( bg );

			var thumbBitmap:Bitmap = new Bitmap( inThumbnailImage );
			thumbBitmap.scaleX = THUMBNAIL_WIDTH/inThumbnailImage.width;
			thumbBitmap.scaleY = THUMBNAIL_HEIGHT/inThumbnailImage.height;
			thumbDisplay.addChild( thumbBitmap );

			_thumbnailContainer.addChild( thumbDisplay );
			_thumbnailDictionary[thumbDisplay] = inThumbnailImage;
			_thumbnailCount++;
		}

		private function thumbnail_onClick( inEvent:MouseEvent ):void
		{
			var thumbnailDisplay:Sprite = inEvent.currentTarget as Sprite;
			var image:BitmapData = _thumbnailDictionary[thumbnailDisplay] as BitmapData;
			_imageDisplay.bitmapData = image;
			_imageContainer.scaleX = 512 / image.width;
			_imageContainer.scaleY = 512 / image.height;

			_imageBgDisplay.graphics.clear();
			_imageBgDisplay.graphics.beginBitmapFill(_bgPatternImage);
			_imageBgDisplay.graphics.drawRect( 0, 0, image.width, image.height );
			_imageBgDisplay.graphics.endFill();



			var beforeTime:Number = (new Date()).getTime();
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////    MAGIC HAPPENS HERE  ////////////////////////////////////////////////////////////////////////////////////

			_closeLines = false;

			var isoData:BitmapAlphaIsoData = new BitmapAlphaIsoData( image );
			var marchingSquare:MarchingSquare = new MarchingSquare( isoData, _closeLines );


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			var afterTime:Number = (new Date()).getTime();



			_logText.text =
				"close line count:" + marchingSquare.closedIsoLineCount +
				"\nopen line count:" + marchingSquare.openIsoLineCount +
				"\ncalculation time:"+(afterTime-beforeTime);


			_polygonDisplay.graphics.clear();
			for( var p:int=0 ; p<marchingSquare.closedIsoLineCount; p++ )
			{
				var pointList:Vector.<Point> = marchingSquare.createClosedIsoLinePoints( p );

				drawPolygon( _polygonDisplay.graphics, pointList, POLYGON_LINE_THICKNESS, CLOSED_ISO_LINE_COLOR, true );
			}
			for( p=0 ; p<marchingSquare.openIsoLineCount; p++ )
			{
				pointList = marchingSquare.createOpenIsoLinePoints( p );

				drawPolygon( _polygonDisplay.graphics, pointList, POLYGON_LINE_THICKNESS, OPEN_ISO_LINE_COLOR, false );
			}

			imageContainer_resize();
		}

		private function thumbnail_resize():void
		{
			_thumbnailContainer.x = 0;
			_thumbnailContainer.y = stage.stageHeight - THUMBNAIL_CONTAINER_HEIGHT;
		}

		private function drawPolygon( inGraphics:Graphics, inPointList:Vector.<Point>, inThickness:Number, inColor:uint, inClose:Boolean ):void
		{
			inGraphics.lineStyle( inThickness, inColor, 1, false, LineScaleMode.NONE );
			inGraphics.moveTo( inPointList[0].x, inPointList[0].y );
			for( var i:int = 1 ; i<inPointList.length ; i++ )
			{
				inGraphics.lineTo( inPointList[i].x, inPointList[i].y );
			}
			if( inClose )
			{
				inGraphics.lineTo( inPointList[0].x, inPointList[0].y );
			}
		}

		private function testImage1( ):BitmapData
		{
			var sprite:Sprite = new Sprite();

			sprite.graphics.beginFill( IMAGE_DRAW_COLOR );
			sprite.graphics.drawCircle( 50, 50, 40 );
			sprite.graphics.endFill();

			var matrix:Matrix = new Matrix();
			matrix.scale(IMAGE_WIDTH/100,IMAGE_HEIGHT/100);

			var bitmapData:BitmapData = new BitmapData( IMAGE_WIDTH, IMAGE_HEIGHT, true, 0 );
			bitmapData.draw( sprite, matrix );

			return bitmapData;
		}

		private function testImage2( ):BitmapData
		{
			var sprite:Sprite = new Sprite();

			for( var i:int=0; i<12; i++ )
			{
				sprite.graphics.beginFill( IMAGE_DRAW_COLOR );
				sprite.graphics.drawEllipse( 10+Math.random()*80, 10+Math.random()*80, 10+Math.random()*30, 10+Math.random()*30 );
				sprite.graphics.endFill();
			}

			var matrix:Matrix = new Matrix();
			matrix.scale(IMAGE_WIDTH/100,IMAGE_HEIGHT/100);

			var bitmapData:BitmapData = new BitmapData( IMAGE_WIDTH, IMAGE_WIDTH, true, 0 );
			bitmapData.draw( sprite, matrix );

			return bitmapData;
		}

		private function testImage3( ):BitmapData
		{
			var sprite:Sprite = new Sprite();

			sprite.graphics.beginFill( IMAGE_DRAW_COLOR );
			sprite.graphics.drawCircle( 50, 50, 40 );
			sprite.graphics.drawCircle( 50, 50, 20 );
			sprite.graphics.endFill();

			var matrix:Matrix = new Matrix();
			matrix.scale(IMAGE_WIDTH/100,IMAGE_HEIGHT/100);

			var bitmapData:BitmapData = new BitmapData( IMAGE_WIDTH, IMAGE_HEIGHT, true, 0 );
			bitmapData.draw( sprite, matrix );

			return bitmapData;
		}

		private function testImage4( ):BitmapData
		{
			var sprite:Sprite = new Sprite();

			sprite.graphics.beginFill( IMAGE_DRAW_COLOR );
			sprite.graphics.drawEllipse( -20, 25, 80, 45 );
			sprite.graphics.endFill();

			var matrix:Matrix = new Matrix();
			matrix.scale(IMAGE_WIDTH/100,IMAGE_HEIGHT/100);

			var bitmapData:BitmapData = new BitmapData( IMAGE_WIDTH, IMAGE_HEIGHT, true, 0 );
			bitmapData.draw( sprite, matrix );

			return bitmapData;
		}

		private function testImage5( ):BitmapData
		{
			var sprite:Sprite = new Sprite();

			sprite.graphics.beginFill( IMAGE_DRAW_COLOR );
			sprite.graphics.drawCircle( 10, 10, 45 );
			sprite.graphics.endFill();

			sprite.graphics.beginFill( IMAGE_DRAW_COLOR );
			sprite.graphics.drawCircle( 60, 60, 30 );
			sprite.graphics.endFill();

			var matrix:Matrix = new Matrix();
			matrix.scale(IMAGE_WIDTH/100,IMAGE_HEIGHT/100);

			var bitmapData:BitmapData = new BitmapData( IMAGE_WIDTH, IMAGE_HEIGHT, true, 0 );
			bitmapData.draw( sprite, matrix );

			return bitmapData;
		}

		private function testImage6( ):BitmapData
		{
			var sprite:Sprite = new Sprite();

			sprite.graphics.beginFill( IMAGE_DRAW_COLOR );
			sprite.graphics.drawRect( 0, 0, 100, 100 );
			sprite.graphics.drawEllipse( -20, 25, 80, 45 );
			sprite.graphics.endFill();

			var matrix:Matrix = new Matrix();
			matrix.scale(IMAGE_WIDTH/100,IMAGE_HEIGHT/100);

			var bitmapData:BitmapData = new BitmapData( IMAGE_WIDTH, IMAGE_HEIGHT, true, 0 );
			bitmapData.draw( sprite, matrix );

			return bitmapData;
		}

		private function testImage7( ):BitmapData
		{
			var sprite:Sprite = new Sprite();

			sprite.graphics.beginFill( IMAGE_DRAW_COLOR );
			sprite.graphics.drawEllipse( -20, 20, 80, 60 );
			sprite.graphics.drawEllipse( -15, 35, 60, 30 );
			sprite.graphics.endFill();

			var matrix:Matrix = new Matrix();
			matrix.scale(IMAGE_WIDTH/100,IMAGE_HEIGHT/100);

			var bitmapData:BitmapData = new BitmapData( IMAGE_WIDTH, IMAGE_HEIGHT, true, 0 );
			bitmapData.draw( sprite, matrix );

			return bitmapData;
		}

	}
}
