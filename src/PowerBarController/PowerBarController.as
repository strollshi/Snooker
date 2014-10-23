/*
 *

  this class is a display object on the stage, which take charge of the control of power. So, you can press the power bar 
  so that the bar will return a value of power to Cue class. Then, the cue will make a hit. Moreover, this class will also 
  

 *
 */


package PowerBarController
{
	import Cue.Cue;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;

	public class PowerBarController extends Sprite
	{
		static private var powerBar:PowerBarIcon	 = new PowerBarIcon();
		static private var myTurnLeft:TurnLeftIcon	 = new TurnLeftIcon();
		static private var myTurnRight:TurnRightIcon = new TurnRightIcon();
		static private var myPower:PowerIcon 		 = new PowerIcon();
		
		static private const TOTAL_POWER:Number		 = new Number(400);
		static private var _power:Number			 = new Number(0);
		
		private var _ballContainer:Sprite			 = new Sprite();
		private var _powerMask:Shape 				 = new Shape();
		private var _isClick:Boolean				 = new Boolean(false);
		private var myCue:Cue;
		
		
		public function PowerBarController(pCue:Cue , pContainer:Sprite)
		{
			_ballContainer = pContainer;
			
			addChild(powerBar);
			this.setCue = pCue;

			addChild(myPower);
			addChild(_powerMask);
			myPower.mask = _powerMask;

			addChild(myTurnLeft);
			addChild(myTurnRight);
			
			myTurnLeft.x = 20;
			myTurnLeft.y = -20;
			myTurnRight.x = 20;
			myTurnRight.y = 330;
			
			powerBar.addEventListener(MouseEvent.MOUSE_DOWN , onPowerChoose);
			myPower.addEventListener(MouseEvent.MOUSE_UP , onPowerOver);
			
			myTurnRight.addEventListener(MouseEvent.MOUSE_DOWN , onMouseDownHandler);
			myTurnRight.addEventListener(MouseEvent.MOUSE_DOWN , onMouseUpHandler);
			
			myTurnLeft.addEventListener(MouseEvent.MOUSE_DOWN , onMouseDownHandler);
			myTurnLeft.addEventListener(MouseEvent.MOUSE_DOWN , onMouseUpHandler);
		}
		
		
		
		private function onPowerChoose(evt:MouseEvent):void{
			addEventListener(Event.ENTER_FRAME , onPowerChange);
		}
		
		private function onPowerOver(evt:MouseEvent):void{
			clearMask();
			removeEventListener(Event.ENTER_FRAME , onPowerChange);
			if(myCue.getCueVisible == true)
			{
				capturePower(stage.mouseY);
				_isClick = true;
				myCue.hitBall(_power);
			}
		}
		
		
		
		private function onPowerChange(evt:Event):void{
			drawMask(stage.mouseY);
		}
		
		
		
		private function onMouseDownHandler(evt:MouseEvent):void{
			
			evt.target.addEventListener(Event.ENTER_FRAME , onTurn);
		}
		
		private function onMouseUpHandler(evt:MouseEvent):void{
			
			evt.target.removeEventListener(Event.ENTER_FRAME , onTurn);
		}
		
		private function onTurn(evt:Event):void{
			trace("//////////////////");
			myCue.rotation += 1;
		}
		
		
		
		/** destructing PowerBar instance **/
		
		private function destroyPowerBar():void{
			
		}
		
		
		
		/** calculating how much power the cue will get **/
		
		private function capturePower(pY:Number):void{
			_power = TOTAL_POWER*(pY - 240)/powerBar.height;
			//trace(_power , pY);
		}
		
		
		
		/** drawing mask for power bar **/
		
		private function drawMask(pY:Number):void{
			clearMask();
			_powerMask.graphics.beginFill(0x000000,1);
			_powerMask.graphics.drawRect(0,0,40,pY-this.y);
			_powerMask.graphics.endFill();
		}
		
		private function clearMask():void{
			_powerMask.graphics.clear();
		}
		
		
		
		
		/** getting power value then take it to Cue class' instance as 
		 * parameter of how much force the Box2D engine should provides **/
		
		public function get getPower():Number{
			if(_isClick)
			{
				_isClick = false;
				return _power;
			}
			else
			{
				return 0;
			}
		}

		
		
		/** setting cue which will apply force on ball **/
		
		public function set setCue(pCue:Cue):void{
			myCue = pCue;
		}
		
		public function get getCue():Cue{
			return myCue;
		}
	}
}