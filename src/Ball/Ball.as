/*
 *

This class is a abstract class, which will extended by RedBall, ColorBall and WhiteBall.
All of three kinds balls are get these methods and properties but some of them will be override.
Ball Class contents some significant properties and methods such as ballValue, isCollide, PhysicFunc and so on.

 *
 */


package Ball
{
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Dynamics.Joints.*;
	
	import General.Input;
	
	import RuleTest.RuleTest;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	public class Ball extends Sprite
	{
		static private var _rule:RuleTest;
		
		protected const RATIO:Number				 = new Number(40);
		
		protected var _world:b2World; //a cited name of b2World
		protected var _body:b2Body;//a cited name of b2Body
		protected var _bodyDef:b2BodyDef;
		
		private var _color:String				 = new String();
		
		private var _isInHole:Boolean			 = new Boolean(false);//this variable help us to judge if the ball is in hole
		private var _isCurrentTartget:Boolean	 = new Boolean(false);//this variable help us to judge if the ball is on target by white ball
		private var _isVisit:Boolean			 = new Boolean(false);
		private var _isCollide:Boolean			 = new Boolean(false);
		
		
		
		/** constructing function of Ball class **/
		
		public function Ball(){
			
		}
		
		
		
		/** this function take responsible for create balls and add to _world **/
		
		protected final function initBall(pWorld:b2World , pColor:String , pRule:RuleTest):void{
			_world = pWorld;
			_rule = pRule;
			createObjects(pColor);
			
			//trace(_world.GetBodyCount());
		}
		
		
		
		/** destroy ball **/
		
		public function destroyBall():void{
			_body = null;
			_bodyDef = null;
		}
		
		
		
		public function driveSleep():void{
			_bodyDef.allowSleep = true;
			_bodyDef.isSleeping = true;
		}
		
		
		
		/** adding skins for balls **/
		
		protected function setUserData(pBodyDef:b2BodyDef):void{
			// this function will be override in sub class
		}
		
		
		
		/** create balls **/
		
		private function createObjects(pColor:String):void{
			_color = pColor;
			_bodyDef = createBalls(_color);
			
		}

		
		
		/** create concret ball **/
		
		private function createBalls(pColor:String):b2BodyDef{
			_rule.deployInitialPosition(pColor);
			
			var objShapeDef:b2CircleDef		 = new b2CircleDef();
			var objBodyDef:b2BodyDef		 = new b2BodyDef();
			
			with(objShapeDef)
			{
				radius = 0.21;
				density = 2;
				friction = 0;
				restitution = 0.7;
			}
			with(objBodyDef)
			{
				isBullet = true;//eliminating throughing phenomenon
				linearDamping = 0.65;
				angle = Math.random()*180;
				if(pColor == "Red")
				{
					position.Set(_rule.getInitialPosition.x/RATIO , _rule.getInitialPosition.y/RATIO);
				}
				else
				{
					position.Set(_rule.getInitialPosition.x/RATIO , _rule.getInitialPosition.y/RATIO);
				}
			}
			
			setUserData(objBodyDef);//adding skins for balls
			
			var objBody:b2Body = _world.CreateBody(objBodyDef);
			objBody.CreateShape(objShapeDef);
			objBody.SetMassFromShapes();
			_body = objBody;
			
			//trace(_body.GetPosition().x*RATIO , _body.GetPosition().y*RATIO);
			
			return objBodyDef;
		}
		
		
		
		/** to make a sound **/
		
		private function makeSounds():void{
			if(this._isCollide == true)
			{
				
			}
		}
		
		
		
		/** setting or getting attributes **/

		public function set setIsInHole(bool:Boolean):void{
			_isInHole = bool;
		}

		public function get getIsInHole():Boolean{
			return _isInHole;
		}
		
		public function set setIsCurrentTartget(bool:Boolean):void{
			_isCurrentTartget = bool;
		}
		
		public function get getIsCurrentTartget():Boolean{
			return _isCurrentTartget;
		}
		
		public function set setIsVisit(bool:Boolean):void{
			_isVisit = bool;
		}
		
		public function get getIsVisit():Boolean{
			return _isVisit;
		}
		
		public function get getPosition():b2Vec2{
			return _body.GetPosition();
		}
		
		
		
		/** get Box2D infos **/
		
		public function get getWorld():b2World{
			return _world
		}
		
		public function get getBody():b2Body{
			return _body;
		}
		
		public function get getBodyDef():b2BodyDef{
			return _bodyDef;
		}
		
		public function get getUserData():Sprite{
			return _body.m_userData;
		}
		
		
		
		/** getting color and value of balls **/
		
		public function get getColor():String{
			return "Ball";
		}
		
		public function get getValue():Number{
			return 0;
		}
		
		
		/** to define the _isCollide **/
		
		public function set setIsCollide(bool:Boolean):void{
			_isCollide = bool;
		}

		/** to get _isCollide **/
		
		public function get getIsCollide():Boolean{
			return _isCollide;
		}
		
		/** returning the velocity of the ball **/
		
		public function get getVelocity():Number{
			var _velocity:Number = Math.sqrt(Math.pow(_body.GetLinearVelocity().x,2) + Math.pow(_body.GetLinearVelocity().y,2));
			return _velocity;
		}
	}
}