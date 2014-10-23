/*
 *

this class' name is Cue, which is a single pattern modle. Only get one instance that is myCue.
Cue class will detec white ball's position and update cue's position as soon as pissible
Cue class also can help white ball chip away some slight velocity which can't be see by human's eyes 
 
 *
 */


package Cue
{
	import Ball.Ball;
	import Ball.WhiteBall;
	
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	
	import MakeSound.MakeSound;
	
	import PowerBarController.PowerBarController;
	
	import RuleTest.RuleTest;
	
	import SnookerPlayer.SnookerPlayer;
	
	import flash.display.*;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;

	
	public class Cue extends Sprite
	{	
		private var myCue:CueClass		 = new CueClass();//this is the only instance of Cue class, which represents cue
		private var myHelper:HelperIcon	 = new HelperIcon();//this instance will help gamer aim target better
		private var myAimLine:Sprite 	 = new Sprite();//this instance will help gamer aim target better
		
		private var _targetBody:b2Body;
		
		private var _sound:MakeSound;
		
		private const RATIO:Number		  	= new Number(40);//ratio of meter to pixel
		
		private var targetPosition:Point  	= new Point();//white ball's position
		private var aimPosition:Point	  	= new Point();//aim line's position
		private var ballPoint:Point	 	 	= new Point();//aimed ball's position
		private var helperPoint:Point	  	= new Point();//aimer's position
		private var intersectionPoint:Point = new Point();//the point of intersection of aim line and ball line
		private var previousPosition:Point  = new Point();//to record previous position the cue used be
		
		private var _aim_k:Number		  = new Number(0);
		private var _aim_b:Number  		  = new Number(0);
		private var _ball_k:Number		  = new Number(0);
		private var _ball_b:Number		  = new Number(0);
		private var _dist:Number		  = new Number(0);
		private var _interval:Number	  = new Number(16);
		private var _counter:int 		  = 1;
		
		private var _isWhiteBallStatic:Boolean = new Boolean(false);
		private var _isHitted:Boolean		   = new Boolean(false);
		private var _isBallsStatic:Boolean	   = new Boolean(true);
		
		private var _ballArray:Array;
		
		private var myRule:RuleTest;
		
		
		private var _aSnookerPlayer:SnookerPlayer;
		
		
		
		/** this constructing function in order to get (x,y) of White ball 
		 * so that the cue would be in the right position **/
		
		public function Cue(pX:Number , pY:Number , pTrgetBody:b2Body , pArray:Array):void{
			//trace("&&&&&&&&&&&&&&&&&&&&&");
			
			addChild(myCue);
			addChild(myHelper);
			addChild(myAimLine);
			
			renewParameter(pX , pY , pTrgetBody , pArray);
			
			myCue.addEventListener(MouseEvent.MOUSE_DOWN , onMouseDownHandler);
			this.addEventListener(Event.ENTER_FRAME , onUpdatePosition);
		}
		
		private function onMouseDownHandler(evt:MouseEvent):void{
			//trace(_ballArray.length);
			
			this.addEventListener(Event.ENTER_FRAME , onEnterFrameHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP , onMouseUpHandler);
			
			myAimLine.graphics.clear();
			myAimLine.visible = true;
			myHelper.visible = true;
			myHelper.x = myCue.x;
			myHelper.y = myCue.y;
			
			evt.updateAfterEvent();
		}
		
		private function onMouseUpHandler(evt:MouseEvent):void{
			this.removeEventListener(Event.ENTER_FRAME , onEnterFrameHandler);
			myCue.removeEventListener(MouseEvent.MOUSE_DOWN , onMouseDownHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP , onMouseUpHandler);
			evt.updateAfterEvent();
		}
		
		private function onEnterFrameHandler(evt:Event):void{
			myAimLine.graphics.clear();
			figureAimLine(rotateCue());//drawing aim line for myAimLine
			drawHelperAndAimLine(rotateCue());
			testAimedBall(rotateCue());
		}
		
		
		private function renewParameter(pX:Number , pY:Number , pTrgetBody:b2Body , pArray:Array):void{
			  _aim_k	  = 0;
			  _aim_b  	  = 0;
			  _ball_k	  = 0;
			  _ball_b	  = 0;
			  _dist		  = 0;
			  _interval	  = 0;
			  
			  myHelper.x = pX;
			  myHelper.y = pY;
			  myAimLine.graphics.clear();
			  myAimLine.x = pX;
			  myAimLine.y = pY;
			  myCue.x = pX;
			  myCue.y = pY;
			  helperPoint.x = pX;
			  helperPoint.y = pY;
			  targetPosition.x = pX;
			  targetPosition.y = pY;
			  
			  _targetBody = pTrgetBody;//white ball
			  _ballArray = pArray;
			  
			  myCue.rotation = Math.random()*(-90);
			  
			  //trace(_ballArray , _targetBody , myCue , myAimLine , myHelper);
		}
		
		
		
		/** destructing cue instance **/
		
		public function destroyCue():void{

		}
		
		
		/** this listener will keep an eye on whiteBall's position
		 * and updating as soon as possible **/
		
		private function onUpdatePosition(e:Event):void{
			detectCueVanish(_targetBody);// invisible aim when the ball is on move
			detectTargetVelocity();//detect ball's velocity
			updatePosition(_targetBody.GetPosition().x*RATIO , _targetBody.GetPosition().y*RATIO);//update whiteBall's position frame by frame
		}
		
		private function updatePosition(pX:Number , pY:Number):void{
			myCue.x			 = pX;
			myCue.y		     = pY;
			targetPosition.x = pX;
			targetPosition.y = pY;
			aimPosition.x    = pX;
			aimPosition.y 	 = pY;
			
			//trace("whiteBall's position : " + "x " + pX + " " + "y " + pY);
		}
		
		/** this function will take responsible for rotation Cue **/
		
		public function rotateCue():Number{
			myCue.rotation = (Math.atan2(stage.mouseY-myCue.y , stage.mouseX-myCue.x)*180/Math.PI) - 90;
			//trace("myCue.rotation : " + myCue.rotation + " " + ((Math.atan2(stage.mouseY-myCue.y , stage.mouseX-myCue.x)*180/Math.PI) - 90));
			
			return myCue.rotation;
		}
		
		
		
		/** this function will calculate some parameters then take it to Box2D engiene, 
		 * it will produce apply force to the ball **/
		
		public function hitBall(pForce:Number):void{
			// 1. getting rotation angle and target position
			var angel:Number = new Number(myCue.rotation-90);
			var force:b2Vec2 = new b2Vec2(pForce*Math.cos(angel*Math.PI/180) , pForce*Math.sin(angel*Math.PI/180));
			var position:b2Vec2 = new b2Vec2(targetPosition.x , targetPosition.y);
			// 2. providing apply force
			_targetBody.ApplyForce(force , position);
			
			// 3. making sound
			_sound.hitBall();
			
			_isHitted = true;
			
			//trace("***************************" , _targetBody.m_linearVelocity.x , _targetBody.m_linearVelocity.y);
		}
		
		
		
		/** detect target ball's speed, if it is slightly move a little bit, 
		 * just stop it by setting velocity as zero **/
		
		private function detectTargetVelocity():void{
			//if the target ball's speed small enough, to set velocity as zero
			if(Math.abs(_targetBody.GetLinearVelocity().x) <= 0.04 && Math.abs(_targetBody.GetLinearVelocity().y) <= 0.04)
			{
				_targetBody.SetLinearVelocity(new b2Vec2(0,0));
				_targetBody.SetAngularVelocity(0);
		
				//trace("%%%%%%%%%%%");
				if(_isHitted == true)
				{
					_isHitted = false;
					_isWhiteBallStatic = true;
				}
			}
			
			//trace("speed : " + _targetBody.GetLinearVelocity().x + " " + _targetBody.GetLinearVelocity().y);
		}
		
		
		
		/** if white ball still moving, the cue should not emerge till white ball dosen't move **/
		
		private function detectCueVanish(pBody:b2Body):void{
			if(pBody.GetLinearVelocity().x != 0 && pBody.GetLinearVelocity().y != 0)
			{
				myCue.visible = false;
				myAimLine.visible = false;
				myHelper.visible = false;
				
			}
			if(pBody.GetLinearVelocity().x == 0 && pBody.GetLinearVelocity().y == 0)
			{
				if(testStatic())
				{
					myCue.visible = true;
					myCue.addEventListener(MouseEvent.MOUSE_DOWN , onMouseDownHandler);
				}
			}
		}
		
		
		
		/** to detect whether all balls are static or not **/
		
		private function testStatic():Boolean{
			for each(var counter:Ball in _ballArray)
			{
				if(counter.getBody.GetLinearVelocity().x != 0 && counter.getBody.GetLinearVelocity().y != 0)
				{
					_isBallsStatic = false;
					break;
				}
				else
				{
					_isBallsStatic = true;
				}
			}
			
			/*
			if(_isBallsStatic)
			{
			trace("static");
			}
			*/
			
			return _isBallsStatic;
		}
		
		
		
		/** to judge whether the ball is aimed by myHelper **/
		
		private function testAimedBall(pRotate:Number):void{
			for(var counter:int=_counter ; counter<_ballArray.length ; counter++)
			{	
				if(myCue.hitTestObject(Ball(_ballArray[counter]).getBody.m_userData) == false)
				{
					//trace("..................");
					
					calculatePoints(pRotate+90 , Ball(_ballArray[counter]));
					
					if(Point.distance(ballPoint , intersectionPoint) <= myHelper.width/2 + _targetBody.m_userData.width/2)
					{	
						_counter = counter;
						//trace(counter);
						figureDistance(Ball(_ballArray[counter]) , pRotate+90);
						figureAimLine(pRotate);//drawing aim line for myAimLine
						drawHelperAndAimLine(pRotate);
						break;
						//trace(pRotate);
					}
					if(Point.distance(ballPoint , intersectionPoint) > myHelper.width/2 + _targetBody.m_userData.width/2)
					{
						figureDistance(Ball(_ballArray[counter]) , pRotate+90);
						figureAimLine(pRotate);
						drawHelperAndAimLine(pRotate);
						_counter = 1;
						//trace(pRotate);
						//break;
					}
				}
			}
		}
		
		
		
		/** calculating points for aim balls exactly **/
		
		private function calculatePoints(pRotate:Number , pBall:Ball):void{
			/**
			 * calculating y = kx + b, then figure out the distance between
			 * the ball and the aim line, compaired with ball's radius afterward.
			 * finally, to judge wheter the ball collides with aim line. 
			 **/
			
			ballPoint.x = pBall.getBody.m_userData.x;
			ballPoint.y = pBall.getBody.m_userData.y;
			//trace(ballPoint);
			
			_aim_k = Math.tan(Math.PI*(pRotate)/180);
			//trace(myAimLine.rotation);
			_ball_k = -1/_aim_k;
			_aim_b = targetPosition.y - _aim_k*targetPosition.x;
			_ball_b = ballPoint.y - _ball_k*ballPoint.x; 
			
			intersectionPoint.x = (_ball_b - _aim_b)/(_aim_k - _ball_k);
			intersectionPoint.y = _ball_k*(_ball_b - _aim_b)/(_aim_k - _ball_k) + _ball_b;
			
			//trace(ballPoint , intersectionPoint , _aim_k);
		}
		
		
		
		/** calculating the distance between helperPoint and aimPosition **/
		
		private function figureDistance(pBall:Ball , pRotate:Number):void{
			_dist = Math.sqrt(Math.pow(myHelper.width/2 + pBall.getBody.m_userData.width/2 , 2) - Math.pow(Point.distance(ballPoint,intersectionPoint) , 2));
			//trace("dist " , _dist);	
			
			if(Point.distance(ballPoint , intersectionPoint) <= myHelper.width/2 + _targetBody.m_userData.width/2)
			{				
				helperPoint.x = _dist*Math.cos(Math.PI*(pRotate)/180) + intersectionPoint.x;
				helperPoint.y = _dist*Math.sin(Math.PI*(pRotate)/180) + intersectionPoint.y;
				//trace(helperPoint);
			}
			else			
			{
				helperPoint.x = -_targetBody.m_userData.width*Math.cos(Math.PI*(pRotate)/180) + targetPosition.x;
				helperPoint.y = -_targetBody.m_userData.height*Math.sin(Math.PI*(pRotate)/180) + targetPosition.y;
				//trace(helperPoint);
			}

			//trace(helperPoint , aimPosition , _interval);
		}
		
		
		
		/** calculating aim line's distance **/
		
		private function figureAimLine(pRotate:Number):void{
			_interval = Point.distance(helperPoint,aimPosition);
			//trace(_interval);
		}
		
		
		
		/** drawing aim line and setting helper's position **/
		
		private function drawHelperAndAimLine(pRotate:Number):void{
			
			if(Point.distance(helperPoint , intersectionPoint) > Point.distance(targetPosition , intersectionPoint))
			{	
					//trace(".....");
					
					helperPoint.x = -_targetBody.m_userData.width*Math.cos(Math.PI*(pRotate+90)/180) + targetPosition.x;
					helperPoint.y = -_targetBody.m_userData.height*Math.sin(Math.PI*(pRotate+90)/180) + targetPosition.y;
					
					myHelper.x = helperPoint.x;
					myHelper.y = helperPoint.y;
						
					myAimLine.x = targetPosition.x;
					myAimLine.y = targetPosition.y;
					myAimLine.graphics.lineStyle(0.5,0xffffff,1);
					myAimLine.graphics.lineTo(0 , 0);
					myAimLine.graphics.moveTo(0 , -_targetBody.m_userData.height);
					myAimLine.rotation = pRotate;

			}
			if(Point.distance(helperPoint , intersectionPoint) < Point.distance(targetPosition , intersectionPoint))
			{
				
					//trace(helperPoint);
		
					myHelper.x = helperPoint.x;
					myHelper.y = helperPoint.y;
					
					//trace(myAimLine.height);
					//myAimLine.graphics.clear();
					myAimLine.x = targetPosition.x;
					myAimLine.y = targetPosition.y;
					myAimLine.graphics.lineStyle(0.5,0xffffff,1);
					myAimLine.graphics.lineTo(0 , 0);
					myAimLine.graphics.moveTo(0 , -_interval);
					myAimLine.rotation = pRotate;
			}
		}
		
		
		
		/** if myCue's visible is true, user can click the power bar **/
		
		public function get getCueVisible():Boolean{
			return myCue.visible;
		}
		
		/** getting aim line **/
		
		public function get getAimLine():Sprite{
			return myAimLine;
		}
		
		public function set setMyRule(pRule:RuleTest):void{
			myRule = pRule;
		}
		
		public function set setSound(sd:MakeSound):void{
			_sound = sd;
		}
		
		public function set setIsWhiteBallStatic(bool:Boolean):void{
			_isWhiteBallStatic = bool;
		}
		
		public function get getIsWhiteBallStatic():Boolean{
			return _isWhiteBallStatic;
		}
		
		public function set setSnookerPlayer(player:SnookerPlayer):void{
			_aSnookerPlayer = player;
		}
		
		public function get getIsHitted():Boolean{
			return _isHitted;
		}
	}
}