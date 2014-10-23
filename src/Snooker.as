/*
 *

this game is a Snooker simulating 2D game, which includes single players and 2 players, absolutely follwing the rules of snooker.
the game bases on Box2D physics engine, consolate platform coding by actionscript3.0 and xml. I also used GreenSock's TweenMax to 
help me make some animations thus to increase efficiency of developing the game. In addition, I drawed those items by using PS.
Basically, you will enjoy it for sure.

 *
 */


package
{	
	import Ball.Ball;
	import Ball.ColorBall;
	import Ball.RedBall;
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
	
	import General.Input;
	
	import Hole.Hole;
	
	import MakeSound.MakeSound;
	
	import PowerBarController.PowerBarController;
	
	import RuleTest.RuleTest;
	
	import SnookerPlayer.SnookerPlayer;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	[SWF(frameRate = "50" , backgroundColor = "0x000066")]
	
	public class Snooker extends Sprite
	{
		public var _ballContainer:Sprite 	 = new Sprite();
		
		private const RATIO:Number			 = new Number(40);
		private const TIME_STEP:Number		 = new Number(1/40);
		private const INTERATIONS:Number	 = new Number(30);
		private const NUM:Number			 = new Number(22);
		
		private var _ballArray:Array		 = new Array();//push all balls into this array
		private var _player_1_ballArray:Array = new Array();
		private var _player_2_ballArray:Array = new Array();
		private var _holeArray:Array		  = new Array();
		private var _blockArray:Array		  = new Array();
		
		//these two variables is for avoid one more balls getting in holes situation
		private var _fallBallArray:Array	  = new Array();
		private var _ballHoleArray:Array	  = new Array();
		
		private var _isFirstShot:Boolean	  = new Boolean(true);
		private var _IsStatic:Boolean 		  = new Boolean(false);
		private var _isFall:Boolean			  = new Boolean(false);
		private var _turnsWinner:Boolean	  = new Boolean(true);
		
		private var _world:b2World;
		private var _aWhiteBall:Ball;
		private var _aCue:Cue;
		private var _aPowerBar:PowerBarController;
		private var _aHole:Hole;
		private var _table:TableIcon 		  = new TableIcon();
		private var _p1:Point				  = new Point();
		private var _p2:Point				  = new Point();
		private var _speed:Number			  = new Number(0);
		
		public var myRule:RuleTest;
	
		private var myScoreBoard:ScoreBoardIcon = new ScoreBoardIcon();
		
		private var myMakeSound:MakeSound = new MakeSound();
		
		private var myShadowFilter:DropShadowFilter = new DropShadowFilter(10,60,0x000000,1,10,10,1.5,8);
		
		
		
		public function Snooker():void{
			super();
			
			// 支持 autoOrient
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			// 1. Setting up a world
			createWorld();
			
			addChild(_ballContainer);  
			_ballContainer.x = 35;
			_ballContainer.y = 10;
			
			myRule = new RuleTest(_world , _ballContainer , myMakeSound);//adding RuleTest;//singlet model
			//myControlBoard.setRule = myRule;

			//trace("mmmmmmmmmmmm");
			this.addEventListener(Event.ENTER_FRAME , detector);
		}
		
		private function detector(evt:Event):void{
			if(myRule.getIsComplete == true)
			{
				//trace("...............");

				myMakeSound.backgroundMusic();
				
				initGame();
				
				myRule.setBallArray = _ballArray;//this array will help myRule to judge if the player breaks the rule or not
				myMakeSound.setBallArray = _ballArray;//this array will help MakeSound obj to detect the distance between color balls and white ball, once which collides with each other, making a sound
				
				this.removeEventListener(Event.ENTER_FRAME , detector);
			}
		}
		
		
		
		/** visiting ballArray thus to get some info from it **/
		
		public function get getBallArray():Array{
			return _ballArray;
		}
		
		
		
		/** initializing game by initializing virtual world of Box2D **/
		
		private final function initGame():void{
			// 2. Setting up a floor
			createFloor();
			// 3. Adding balls and board to _world as well as the cue and some boards
			addItems();
			// 4. setting time step and interations
			addEventListener(Event.ENTER_FRAME , onEnterFrameHandler);

			//trace("world's bodies: "+_world.GetBodyCount());//test how many bodies in the world
		}
		
		

		/** setting time steps and interations **/
		
		private function onEnterFrameHandler(evt:Event):void{
			_world.Step(TIME_STEP , INTERATIONS);
			
			updateUserData();
			
			onTestIsInHole();
		}
		
		
		
		/** restart game **/
		
		private function reGame():void{
			
		}
		
		
		/** destroy everything on gaming scene **/
		
		private function destroy():void{

		}
		
		
		
		/** adding balls **/
		
		private function addItems():void{
			// 1. adding table
			_ballContainer.addChild(_table); 
			_table.x = 25;
			_table.y = 23;
			_table.filters = [myShadowFilter];
			
			// 8. adding snooker player
			var myScoreBoard:ScoreBoardIcon = new ScoreBoardIcon();
			myScoreBoard.x = 10;
			myScoreBoard.y = 385;
			myScoreBoard.rotation = 90;
			_ballContainer.addChild(myScoreBoard);
			
			// 2. adding holes
			var upLeftHole:Hole = new Hole(40,32,_ballArray);
			var upRightHole:Hole = new Hole(391,33,_ballArray);
			var midLeftHole:Hole = new Hole(30,387,_ballArray);
			var midRightHole:Hole = new Hole(400,387,_ballArray);
			var bottomLeftHole:Hole = new Hole(40,740,_ballArray);
			var bottomRightHole:Hole = new Hole(390,740,_ballArray);
			_holeArray.push(upLeftHole);
			_holeArray.push(upRightHole);
			_holeArray.push(midLeftHole);
			_holeArray.push(midRightHole);
			_holeArray.push(bottomLeftHole);
			_holeArray.push(bottomRightHole);
			_ballContainer.addChild(upLeftHole);
			_ballContainer.addChild(upRightHole);
			_ballContainer.addChild(midLeftHole);
			_ballContainer.addChild(midRightHole);
			_ballContainer.addChild(bottomLeftHole);
			_ballContainer.addChild(bottomRightHole);
			
			for each(var hole:Hole in _holeArray)
			{
				hole.alpha = 0;
			}
			
			addBalls();
			
			// 6. adding cue for white ball
			//trace("pX : " + myWhiteBall.getBody.GetPosition().x*RATIO , "pY : " + myWhiteBall.getBody.GetPosition().y*RATIO);
			var myCue:Cue = new Cue(_aWhiteBall.getBody.GetPosition().x*RATIO , _aWhiteBall.getBody.GetPosition().y*RATIO , _aWhiteBall.getBody , _ballArray);
			_aCue = myCue;
			myRule.setCue = myCue;
			myCue.setSound = myMakeSound;
			myCue.setMyRule = myRule;
			_ballContainer.addChild(myCue);
			
			// 7. adding power bar
			var myPoerBar:PowerBarController = new PowerBarController(myCue , _ballContainer);
			_aPowerBar = myPoerBar;
			myRule.setPowerBar = myPoerBar;
			_ballContainer.addChild(myPoerBar);
			myPoerBar.x = 420;
			myPoerBar.y = 230;
			
			_ballContainer.swapChildren(myCue , myPoerBar);
			
			// 8. adding return button
			var myReturnBtn:ReturnIcon = new ReturnIcon();
			_ballContainer.addChild(myReturnBtn);
			myReturnBtn.x = 440;
			myReturnBtn.y = 740;
			myReturnBtn.scaleX = 0.7;
			myReturnBtn.scaleY = 0.7;
			myReturnBtn.rotation = 90;
			
			// 9. adding help button
			var myHelpeBtn:HelpNoteIcon = new HelpNoteIcon();
			_ballContainer.addChild(myHelpeBtn);
			myHelpeBtn.x = 440;
			myHelpeBtn.y = 40;
			myHelpeBtn.scaleX = 0.7;
			myHelpeBtn.scaleY = 0.7;
			myHelpeBtn.rotation = 90;
			
			//setDebugDraw();
			
			//trace("ballArray : " + _ballArray);
			
			/*
			for(var i:int=0 ; i<_ballContainer.numChildren ; i++)
			{
				trace(_ballContainer.getChildAt(i));
				//_ballContainer.removeChild(_ballContainer.getChildAt(counter));
			}
			*/
		}
		
		
		
		/* only create balls in ballContainer */
		
		private function addBalls():void{
			// 1. adding white ball
			var myWhiteBall:Ball = new WhiteBall(_world , myRule);
			myRule.setWhiteBall = myWhiteBall;
			_ballContainer.addChild(myWhiteBall.getBodyDef.userData);
			_ballArray.push(myWhiteBall);
			
			_aWhiteBall = myRule.getWhiteBall;
			
			
			// 2. adding 15 red balls
			for(var counter:int=0 ; counter<15 ; counter++)
			{
				var myRedBall:Ball = new RedBall(_world , myRule);
				_ballContainer.addChild(myRedBall.getBodyDef.userData);
				_ballArray.push(myRedBall);
			}
			
			// 3. adding 6 color balls
			var myBlackBall:Ball = new ColorBall(_world , "Black" , myRule);
			var myBlueBall:Ball = new ColorBall(_world , "Blue" , myRule);
			var myBrownBall:Ball = new ColorBall(_world , "Brown" , myRule);
			var myGreenBall:Ball = new ColorBall(_world , "Green" , myRule);
			var myPinkBall:Ball = new ColorBall(_world , "Pink" , myRule);
			var myYellowBall:Ball = new ColorBall(_world , "Yellow" , myRule);
			
			_ballContainer.addChild(myBlackBall.getBodyDef.userData);
			_ballContainer.addChild(myBlueBall.getBodyDef.userData);
			_ballContainer.addChild(myBrownBall.getBodyDef.userData);
			_ballContainer.addChild(myGreenBall.getBodyDef.userData);
			_ballContainer.addChild(myPinkBall.getBodyDef.userData);
			_ballContainer.addChild(myYellowBall.getBodyDef.userData);
			
			_ballArray.push(myBlackBall);
			_ballArray.push(myBlueBall);
			_ballArray.push(myBrownBall);
			_ballArray.push(myGreenBall);
			_ballArray.push(myPinkBall);
			_ballArray.push(myYellowBall);
		}

		
		
		/** debug draw shapes **/
		
		private function setDebugDraw():void{
			var spriteToDrawOn:Sprite = new Sprite();
			_ballContainer.addChild(spriteToDrawOn);
			
			var myDebugDraw:b2DebugDraw = new b2DebugDraw();
			with(myDebugDraw)
			{
				m_sprite = spriteToDrawOn;
				m_drawScale = RATIO;
				SetFlags(b2DebugDraw.e_shapeBit);
				m_alpha = 0.5;
				m_lineThickness = 1;
				m_fillAlpha = 0.2;
			}
			
			_world.SetDebugDraw(myDebugDraw);
		}
		
		
		
		/** create blocks , related data will import to this function by using XML**/
		
		private function createFloor():void{
			createBlock(215,30,[155,5],0);
			createBlock(215,746,[155,5],0);
			createBlock(35,212,[5,160],0);
			createBlock(395,212,[5,160],0);
			createBlock(35,562,[5,160],0);
			createBlock(395,562,[5,160],0);
			createBlock(50,23,[15,5],Math.PI/5.5);
			createBlock(28,42,[5,15],-Math.PI/5.5);
			createBlock(380,23,[15,5],-Math.PI/5.5);
			createBlock(403,42,[5,15],Math.PI/5.5);
			createBlock(25,373,[15,5],-Math.PI/8);
			createBlock(24,402,[5,15],-Math.PI/2.5);
			createBlock(406,373,[15,5],Math.PI/8);
			createBlock(406,402,[5,15],Math.PI/2.5);
			createBlock(50,753,[15,5],-Math.PI/6);
			createBlock(28,731,[5,15],Math.PI/6);
			createBlock(403,734,[15,5],Math.PI/3);
			createBlock(380,753,[5,15],-Math.PI/3);
			//trace(_world.GetBodyCount());
		}
		
		private function createBlock(pX:Number , pY:Number , pShape:Array , pAngle:Number):void{
			var floorShapeDef:b2PolygonDef	 = new b2PolygonDef();
			var floorBodyDef:b2BodyDef		 = new b2BodyDef();
			
			with(floorShapeDef)
			{
				SetAsBox(pShape[0]/RATIO , pShape[1]/RATIO);
				density = 0;
				friction = 0.1;
				restitution = 0.5;
			}
			with(floorBodyDef)
			{
				angle = pAngle;
				position.Set(pX/RATIO , pY/RATIO);
			}
			
			var floorBody:b2Body = _world.CreateBody(floorBodyDef);
			floorBody.CreateShape(floorShapeDef);
			floorBody.SetMassFromShapes();
		}
		
		
		
		/** create a world **/
		
		private function createWorld():void{
			// 1. Setting bounce
			var universe:b2AABB = new b2AABB();
			universe.lowerBound.Set(-4000/RATIO , -4000/RATIO);
			universe.upperBound.Set(4000/RATIO , 4000/RATIO);
			// 2. Setting gravity
			var gravity:b2Vec2 = new b2Vec2(0 , 0);
			// 3. Setting if it is sleep
			var isSleep:Boolean = new Boolean(true);
			
			_world = new b2World(universe , gravity , isSleep);

			//trace(_world.GetBodyCount());
		}
		
	
		
		/** update ball skins' position immediately **/
		
		private function updateUserData():void{
			for (var bb:b2Body = _world.m_bodyList; bb; bb = bb.m_next){
				//trace(bb.m_userData);
				if (bb.m_userData is Sprite){
					bb.m_userData.x = bb.GetPosition().x * RATIO;
					bb.m_userData.y = bb.GetPosition().y * RATIO;
				}
			}
		}

		
		
		/** to test balls' circumstances **/
		
		private function onTestIsInHole():void{	
			for(var counter:int=0 ; counter<_ballArray.length ; counter++)
			{
				//to test if any ball is in hole, then make the mark that the ball is already in hole 
				if(Ball(_ballArray[counter]).getIsInHole == true && Ball(_ballArray[counter]).getIsVisit == false)
				{
					var _fallBall:Ball = Ball(_ballArray[counter]);
					
					_fallBall.setIsVisit = true;
					_fallBall.setIsInHole = true;
					_fallBallArray.push(_fallBall);
					//trace(_fallBall.getIsInHole);
					
					// finding the hole which let the ball falls in
					for each(var i:Hole in _holeArray)
					{
						if(Point.distance(new Point(_fallBall.getBody.m_userData.x , _fallBall.getBody.m_userData.y) , new Point(i.getHole.x , i.getHole.y)) < i.getHole.width/2)
						{
							_ballHoleArray.push(i);	
						}
					}
					//trace(_ballHoleArray.length);
					
					_fallBall.addEventListener(Event.ENTER_FRAME , onMoveToHole , false , 0 , true);// to show the animation of the ball getting the hole
					
					//trace(_ballHoleArray.length);
				}
				
				//to test whether the ball is colliding with white ball, then make a mark that the ball already collided
				if(_aWhiteBall && counter>0)
				{	
					_aWhiteBall = myRule.getWhiteBall;
					_p1.x = _aWhiteBall.getBody.m_userData.x;
					_p1.y = _aWhiteBall.getBody.m_userData.y;
					_p2.x = Ball(_ballArray[counter]).getBody.m_userData.x;
					_p2.y = Ball(_ballArray[counter]).getBody.m_userData.y;
					_speed = Math.sqrt(Math.pow(_aWhiteBall.getBody.GetLinearVelocity().x,2)+Math.pow(_aWhiteBall.getBody.GetLinearVelocity().y,2));
					//trace(_speed,_aWhiteBall);
					
					if(Sprite(_aWhiteBall.getBody.m_userData).hitTestObject(Sprite(Ball(_ballArray[counter]).getBody.m_userData)))
					{
						Ball(_ballArray[counter]).setIsCollide = true;
						myRule.testCollideBall(Ball(_ballArray[counter]));//to test color is on right or not
						//trace(Ball(_ballArray[counter]).getIsCollide);
					}
					
					/**
					if(Point.distance(_p1,_p2) <= _aWhiteBall.getBody.m_userData.width + 20*_speed/35.5)
					{
						//Ball(_ballArray[counter]).setIsCollide = true;
						myRule.testCollideBall(Ball(_ballArray[counter]));//to test color is on right or not
						//trace(Ball(_ballArray[counter]).getIsCollide);
					}
					**/
				}
			}
		}
		
		/** push the ball in the hole and destroy it sooner **/
		
		private function onMoveToHole(evt:Event):void{
			for each(var i:Ball in _fallBallArray)
			{
				if(i)
				{
					//trace("........");
	
					_aHole = Hole(_ballHoleArray[0]);
					
					if(_aHole)
					{
						i.getBody.m_userData.x += 0.4*(_aHole.getHole.x - i.getBody.m_userData.x);
						i.getBody.m_userData.y += 0.4*(_aHole.getHole.y - i.getBody.m_userData.y);
						i.getBody.m_userData.scaleX += 0.4*(0.8 - i.getBody.m_userData.scaleX);
						i.getBody.m_userData.scaleY += 0.4*(0.8 - i.getBody.m_userData.scaleY);
					}
					
					if(i.getBody.m_userData.alpha < 0.05 && _isFall == false)
					{	
						i.getBody.m_userData.removeEventListener(Event.ENTER_FRAME , onMoveToHole , false);// remove this fall ball's listener
						
						//remove this ball from ball array
						for(var j:int=0 ; j<_ballArray.length ; j++)
						{
							if(i == _ballArray[j])
							{
								_ballArray[j] = null;
								_ballArray.splice(j,1);
								break;
							}
						}
						
						myMakeSound.fallBallVoice();
						
						_isFall = true;
						
						this.addEventListener(Event.ENTER_FRAME , onDetectVelocity , false , 0 , true);
						
						//trace("remove " , _fallBallArray[0] , _ballArray.length);
					}
				}
			}
		}
		
		private function onDetectVelocity(evt:Event):void{
			if(myRule.getWhiteBall.getBody.GetLinearVelocity().x == 0 && myRule.getWhiteBall.getBody.GetLinearVelocity().y == 0)
			{
				//trace(_fallBallArray);
				
				for(var counter:int=0 ; counter<_fallBallArray.length ; counter++)
				{	
					_ballContainer.removeChild(Ball(_fallBallArray[counter]).getBody.m_userData);// remove skins of balls from sprite
					_world.DestroyBody(Ball(_fallBallArray[counter]).getBody);// destroy concret body from the world
					
					myRule.testFallBall(Ball(_fallBallArray[counter]) , _aCue);
					_aCue = _aPowerBar.getCue;
					_aPowerBar.setCue = _aCue;
					
					_fallBallArray[counter] = null;
					_fallBallArray.shift();
					_ballHoleArray[counter] = null;
					_ballHoleArray.shift();
				}
				
				_isFall = false;
				
				//trace(".,...................");
				this.removeEventListener(Event.ENTER_FRAME , onDetectVelocity , false);
			}
		}
	}
}
