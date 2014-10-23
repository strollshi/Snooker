/*
 *

  this class is take charge of the rule testing in every single time of hitting ball. in addition, this class will charge in the import of XML file from outside space.
  if gamer breaks the rule, the class will make response to that. for example, if I hit the white ball to a hole, this ball will back to the previous position before 
  falling the hole. This means this class will create some same color balls from the previous falling balls.

 *
 */



package RuleTest
{
	import Ball.Ball;
	import Ball.ColorBall;
	import Ball.WhiteBall;
	
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Dynamics.Joints.*;
	
	import ControlBoard.ControlBoard;
	
	import Cue.Cue;
	
	import MakeSound.MakeSound;
	
	import PowerBarController.PowerBarController;
	
	import SnookerPlayer.SnookerPlayer;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class RuleTest extends Sprite
	{
		static private var loader:URLLoader;
		static private var xmlData:XML;
		static private var myXMLList:XMLList	 = new XMLList();
		static private var aXMLList:XMLList		 = new XMLList();
		static private var _isComplete:Boolean	 = new Boolean(false);//to detect whether the _point has received xmlData
		
		private var _world:b2World;
		private var _ballContainer:Sprite;
		private var _powerBar:PowerBarController;
		
		private var _ball:Ball;
		private var _cue:Cue;
		
		private var _point:Point		 = new Point();
		private var _color:String		 = new String();
		private var _ballCounter:int	 = 0;
		
		private var _ballArray:Array	 = new Array();//getting _ballArray
		private var _fallBallArray:Array = new Array();
		private var _colorBallArray:Array = new Array("Yellow" , "Green" , "Brown" , "Blue" , "Pink" , "Black");
		private var _score:int 				= 0;
		
		private var _isInHole:Boolean	 = new Boolean(false);//to judge whether the ball get in hole
		private var _isCollide:Boolean	 = new Boolean(false);//to make decision whether white collides with other balls, if it dose, just make the first collision as the right one and stop count next collisions
		private var _isBreakRule:Boolean = new Boolean(false);//to judge whether player breaks the rule or not
		private var _rightColor:String	 = new String("Red");//to mark the right color which player should choose as this value
		private var _currentColor:String = new String();
		private var _redBallExistance:Boolean = new Boolean(true);// to make sure any red ball exist in _ballArray or not
		private var _isBallsStatic:Boolean = new Boolean(true);// to judge whether all of balls are static or not
		private var _isScoreCounted:Boolean = new Boolean(false);
		private var _isPosited:Boolean   = new Boolean(false);
		
		private const RATIO:Number		 = new Number(40);
		
		private var myMakeSound:MakeSound;
		
		
		static private var _player:SnookerPlayer = new SnookerPlayer("player");
		static private var _computer:SnookerPlayer = new SnookerPlayer("computer");
		static private var _currentPlayer:SnookerPlayer = _player;
		
		
		
		
		public function RuleTest(pWorld:b2World , pContainer:Sprite , sd:MakeSound):void{
			_world = pWorld;
			_ballContainer = pContainer;
			myMakeSound = sd;
			
			loadXML();
		}
		
		/** loading xml data which is in charge the deployment of balls' initial positions **/
		
		private function loadXML():void{
			var req:URLRequest = new URLRequest("BallPosition.txt");
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE , onCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR , onErrorHandler);
			loader.load(req);
		}
		
		private function onCompleteHandler(evt:Event):void{
			xmlData = new XML(evt.target.data);
			myXMLList = xmlData.elements();
			trace("import succeed");
			//trace(myXMLList);
			//trace(xmlData.toString());
			
			_isComplete = true;
			
			
			addEventListener(Event.ENTER_FRAME , onEnterFrameHandler);
		}
		
		private function onErrorHandler(evt:IOErrorEvent):void{
			trace("IO Error");
		}
		
		

		
		/***-----------------------------------------------------------------------------
		 ----------------------------------------------------------------------------***/

		
		
		
		/** setting initial position for balls **/
		
		public function deployInitialPosition(pColor:String):void{
			//trace("color");
			_color = pColor;
			
			var _p:Point = deploy(_color);
			
			_point.x = _p.x;
			_point.y = _p.y;
		}
		
		/** deploy positons for balls **/
		
		private function deploy(pColor:String):Point{
			//trace(myXMLList);
			var _p:Point = new Point();
			
			for each(var element:XML in myXMLList)
			{
				//trace(element);
				if(pColor == element.@color)
				{
					//trace("nnnnnnnnnnnnnnnnnnnnnnn" , element.@color);
					
					if(element.@color != "Red")
					{
						_p.x = Number(element.positionX);
						_p.y = Number(element.positionY);
						//trace(_p);
						break;
					}
					else
					{
						if(_isPosited == false)
						{
							_isPosited = true;
							aXMLList = element.elements();
							//trace(aXMLList);
						}
						
						_p.x = Number(aXMLList[_ballCounter]);
						_p.y = Number(aXMLList[_ballCounter+1]);
						if(_ballCounter <= 28)
						{
							_ballCounter += 2;
						}
						else
						{
							_ballCounter = 0;
							_isPosited = false;
						}

						//trace(_p);
						
						break;
					}
				}
			}
			
			return _p;
		}
		
		
		
		/** color ball array must be renew after each round **/
		
		public function renewColorBallArray():void{
			_colorBallArray = new Array("Yellow" , "Green" , "Brown" , "Blue" , "Pink" , "Black");
		}

		
		
		/** making score count after all balls' static **/
		
		private function onEnterFrameHandler(evt:Event):void{
			if(_ball)
			{
				if(_ball.getBody.GetLinearVelocity().x == 0 && _ball.getBody.GetLinearVelocity().y == 0)
				{
					//trace(testStatic(),_isScoreCounted);
					if(testStatic() && _isScoreCounted)
					{
						hittingTypeDetector();
						scoreCounter();
						
						//trace("fuck");
						_isScoreCounted = false;
						_isCollide = false;
						_isInHole = false;
						
						trace(_fallBallArray);
						if(_fallBallArray[0] != null && _cue != null)
						{
							for each(var i:Ball in _fallBallArray)
							{
								pickOutColorBall(i.getColor , _cue);
								_fallBallArray[0] = null;
								_fallBallArray.shift();
							}
						}
					}
				}
			}
		}
		
		
		
		/** to make sure that if the white ball kicks any ball in hole or just collides with balls or even not collide with them**/
		
		private function hittingTypeDetector():void{
			if(testRedBallExistance() && _isCollide)
			{
				testFoul_1();//runing only when red balls exist
			}
			if(!testRedBallExistance() && _isCollide)
			{
				testFoul_2();//runing only when color balls exist
			}
			if(!_isCollide)
			{
				
			}
		}
		
		
		
		
		/***-----------------------------------------------------------------------------
		 ----------------------------------------------------------------------------***/

  
 
		/** this function take charge of score counting **/
		
		private function scoreCounter():void{
			trace(_score , _isBreakRule);
		}
		
		
		
		/** updating right color on time after counting scores **/
		
		private function modulateRightColor():void{
			if(testRedBallExistance())
			{
				if(_rightColor == "Red")
				{
					_rightColor = "Color";
				}
				if(_rightColor == "Color")
				{
					_rightColor = "Red";
				}
			}
			else
			{
				_colorBallArray[0] = null;
				_colorBallArray.shift();
				_rightColor = _colorBallArray[0];
			}
		}
		
		
		
		/** change player if one of them hit th ball wrong or don't hit the right ball in hole **/
		
		private function changePlayer():void{
			if(_currentPlayer == _player)
			{
				_currentPlayer = _computer;
			}
			if(_currentPlayer == _computer)
			{
				_currentPlayer = _player;
			}
		}
		
		
		
		/** to make sure if really exist red balls in _ballArray **/
		
		private function testRedBallExistance():Boolean{
			if(_ballArray)
			{
				for each(var counter:Ball in _ballArray)
				{
					if(counter.getColor == "Red")
					{
						_redBallExistance = true;
						break;
					}
					else
					{
						_redBallExistance = false;
					}
				}
			}
			
			return _redBallExistance;
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
		
		
		/** trying to get value by test current color **/
		
		private function detectValueByColor(pColor:String):int{
			switch(pColor)
			{
				case("White"):
					return 4;
					break;
				case("Red"):
					return 1;
					break;
				case("Yellow"):
					return 2;
					break;
				case("Green"):
					return 3;
					break;
				case("Brown"):
					return 4;
					break;
				case("Blue"):
					return 5;
					break;
				case("Pink"):
					return 6;
					break;
				case("Black"):
					return 7;
					break;
				default:
					return 0;
			}
		}
		
		
		
		/**if there still gotta some red balls on table, pick up the color ball which just fell in hole on table again**/ 
		
		private function pickOutColorBall(pColor:String , pCue:Cue):void{
			if(testRedBallExistance())
			{
				switch(pColor)
				{
					case("Yellow"):
						var myYellowBall:ColorBall = new ColorBall(_world,"Yellow",this);
						_ballContainer.addChild(myYellowBall.getBodyDef.userData);
						_ballArray.push(myYellowBall);
						break;
					case("Green"):
						var myGreenBall:ColorBall = new ColorBall(_world,"Green",this);
						_ballContainer.addChild(myGreenBall.getBodyDef.userData);
						_ballArray.push(myGreenBall);
						break;
					case("Brown"):
						var myBrownBall:ColorBall = new ColorBall(_world,"Brown",this);
						_ballContainer.addChild(myBrownBall.getBodyDef.userData);
						_ballArray.push(myBrownBall);
						break;
					case("Blue"):
						var myBlueBall:ColorBall = new ColorBall(_world,"Blue",this);
						_ballContainer.addChild(myBlueBall.getBodyDef.userData);
						_ballArray.push(myBlueBall);
						break;
					case("Pink"):
						var myPinkBall:ColorBall = new ColorBall(_world,"Pink",this);
						_ballContainer.addChild(myPinkBall.getBodyDef.userData);
						_ballArray.push(myPinkBall);
						break;
					case("Black"):
						var myBlackBall:ColorBall = new ColorBall(_world,"Black",this);
						_ballContainer.addChild(myBlackBall.getBodyDef.userData);
						_ballArray.push(myBlackBall);
						break;
					case("White"):
						var myWhiteBall:WhiteBall = new WhiteBall(_world , this);
						this.setWhiteBall = myWhiteBall;
						_ballContainer.addChild(myWhiteBall.getBody.m_userData);
						_ballArray.unshift(myWhiteBall);
						
						_ballContainer.removeChild(pCue);
						pCue.destroyCue();
						pCue = null;
						
						var myCue:Cue = new Cue(_ball.getBody.GetPosition().x*RATIO , _ball.getBody.GetPosition().y*RATIO , _ball.getBody , _ballArray);
						_ballContainer.addChild(myCue);
						myCue.setSound = myMakeSound;
						myCue.setMyRule = this;
						_powerBar.setCue = myCue;
						this.setCue = myCue;
						
						//trace("put the ball on the line");
						break;
				}
			}
		}
		
		
		
		
		/***-----------------------------------------------------------------------------
		 ----------------------------------------------------------------------------***/
		
		
		
		
		/* getting fell ball only one by one */
		
		public function testFallBall(pBall:Ball , pCue:Cue):void{	
			if(!_isInHole)
			{
				_isInHole = true;
				_isScoreCounted = true;
				trace(pBall.getColor);
			}
			
			_fallBallArray.push(pBall);//save fall balls in array
			
			_ballContainer.swapChildren(_powerBar.getCue , _ballContainer.getChildAt(_ballContainer.numChildren-1));//keep cue on the above of _ballContainer

			//trace("holy smoke");
		}
		
		
		
		/* to test whether the collided ball is on the right color */
		
		public function testCollideBall(pBall:Ball):void{
			if(!_isCollide)
			{
				_isCollide = true;
				_isScoreCounted = true;
				_currentColor = pBall.getColor;
				trace(pBall.getColor);
			}
		}
		
		
		
		/* to test if the player make fouls only when ball array saves red balls */
		
		private function testFoul_1():void{
			trace("this is testFoul_1");
			
			//hit the right ball
			if(_currentColor == "Red" && _currentColor == _rightColor)
			{
				//ball in hole
				if(_isInHole && _isCollide)
				{
					//not only getting in hole with one ball
					if(_fallBallArray.length > 1)
					{
						//detect color of in hole balls
						for each(var i:Ball in _fallBallArray)
						{
							if(i.getColor != "Red")
							{
								_isBreakRule = true;
								break;
							}
							else
							{
								_isBreakRule = false;
							}
						}
						
						//not only the target red ball in hole, but alsosome color balls in hole
						if(_isBreakRule)
						{
							for each(var j:Ball in _fallBallArray)
							{
								if(j.getColor != "Red")
								{
									if(detectValueByColor(j.getColor) > 4)
									{
										_score += detectValueByColor(j.getColor);
									}
									else
									{
										_score += 4;
									}
								}
							}
						}
						//only the target red ball and some other red balls in hole
						else
						{
							for each(var k:Ball in _fallBallArray)
							{
								if(k.getColor == "Red")
								{
									_score += detectValueByColor(k.getColor);
								}
							}
						}
					}
					//only getting in hole with one ball
					if(_fallBallArray.length == 1)
					{
						if(_fallBallArray[0])
						{
							if(Ball(_fallBallArray[0]).getColor != "Red")
							{
								_isBreakRule = true;
							}
							else
							{
								_isBreakRule = false;
							}
							
							_score = detectValueByColor(Ball(_fallBallArray[0]).getColor);
						}
					}
				}
			}
			//hit the wrong ball
			if(_currentColor == "Red" && _currentColor != _rightColor)
			{
				_isBreakRule = true;
				
				if(_fallBallArray[0])
				{
					_score = detectValueByColor(Ball(_fallBallArray[0]).getColor);
				}
			}
			
			
			//hit the right ball
			if(_currentColor != "Red" && _currentColor == _rightColor)
			{
				//ball in hole
				if(_isInHole && _isCollide)
				{
					if(_fallBallArray.length > 1)
					{
						_isBreakRule = true;
						
						//not only the target red ball in hole, but alsosome color balls in hole
						if(_isBreakRule)
						{
							for each(var z:Ball in _fallBallArray)
							{
								if(detectValueByColor(z.getColor) > 4)
								{
									_score += detectValueByColor(z.getColor);
								}
								else
								{
									_score += 4;
								}
							}
						}
					}
					if(_fallBallArray.length == 1)
					{
						if(_fallBallArray[0])
						{
							if(Ball(_fallBallArray[0]).getColor == "White")
							{
								_isBreakRule = true;
							}
							else
							{
								_isBreakRule = false;
							}
							
							_score = detectValueByColor(Ball(_fallBallArray[0]).getColor);
						}
					}
				}
			}
			//hit the wrong ball
			if(_currentColor == "Color" && _currentColor != _rightColor)
			{
				_isBreakRule = true;
				
				if(_fallBallArray[0])
				{
					_score = detectValueByColor(Ball(_fallBallArray[0]).getColor);
				}
			}
		}
		
		
		
		/* to test if the player make fouls when ball array only saves color balls */
		
		private function testFoul_2():void{
			if(_isInHole && _isCollide)
			{
				if(_fallBallArray.length > 1)
				{
					_isBreakRule = true;
					
					for each(var counter:Ball in _fallBallArray)
					{
						_score += detectValueByColor(counter.getColor);
					}
				}
				if(_fallBallArray.length == 1)
				{
					if(_fallBallArray[0])
					{
						if(_currentColor == Ball(_fallBallArray[0]).getColor == String(_colorBallArray[0]))
						{
							_isBreakRule = false;
							_score = detectValueByColor(_currentColor);
						}
						else
						{
							_isBreakRule = true;
							_score = detectValueByColor(_currentColor);
						}
					}
				}
			}
			if(!_isInHole && _isCollide)
			{
				if(_currentColor == Ball(_fallBallArray[0]).getColor == String(_colorBallArray[0]))
				{
					
				}
				else
				{
					_isBreakRule = true;
					_score = detectValueByColor(_currentColor);
				}
			}
		}
		
		
		
		
		/***-----------------------------------------------------------------------------
		 ----------------------------------------------------------------------------***/
		
		
		
		
		/** get _isComplete, thus to make sure that _bodyDef can get _point **/
		
		public function get getIsComplete():Boolean{
			return _isComplete;
		}
		
		public function set setIsComplete(bool:Boolean):void{
			_isComplete = bool;
		}
		
		/** get ball's initial position **/
		
		public function get getInitialPosition():Point{
			return _point;
		}
		
		/** get _ballArray so that this class will be able to push element(ball) to it **/

		public function set setBallArray(pArray:Array):void{
			_ballArray = pArray;
		}

		public function set setPowerBar(pPowerBar:PowerBarController):void{
			_powerBar = pPowerBar;
		}
		
		/** get white ball for detecting the ball's velocity so that we can deploy color balls **/
		
		public function set setWhiteBall(pBall:Ball):void{
			_ball = pBall;
		}

		public function get getWhiteBall():Ball{
			return _ball;
		}
		
		public function set setCue(pCue:Cue):void{
			_cue = pCue;
		}
		
		public function get getCue():Cue{
			return _cue;
		}
		
		
		/** getting the score the player get in this time **/
		
		public function get getScore():int{
			return _score;
		}
		
		/** initializing the score as zero **/
		
		public function setScoreAsZero():void{
			_score = 0;
		}
		
		/** setting _isBreakRule **/
		
		public function set setIsBreakRule(bool:Boolean):void{
			_isBreakRule = bool;
		}
		
		/** getting _isBreakRule **/
		
		public function get getIsBreakRule():Boolean{
			return _isBreakRule;
		}
		
		/* getting players */
		
		public function get getPlayer():SnookerPlayer{
			return _player;
		}
		
		public function get getComputer():SnookerPlayer{
			return _computer;
		}
		
		public function set setIsCollide(bool:Boolean):void{
			bool = _isCollide;
		}
		
		public function get getIsCollide():Boolean{
			return _isCollide;
		}
	}
}