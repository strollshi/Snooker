
/*
*

this class is extending from Ball class, which is a specific class. if you create a instance of RedBall class, 
this instance will add to _world automatically. RedBall class records _world, _body and _bodyDef cites,
so that we can visit some functions and attributes from these cites.

*
*/

package Ball
{
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;
	
	import RuleTest.RuleTest;
	
	public class RedBall extends Ball
	{
		
		private const BALL_VALUE:Number = 1;//this constant value means how many scores player can earn by kicking it to hole
		private const BALL_COLOR:String = "Red";//this constant value is represent the ball's color
		private var _bool:Boolean		= new Boolean(false);//to detect whether this ball has been initialize position 
		
		public function RedBall(pWorld:b2World , pRule:RuleTest):void{
			initBall(pWorld , BALL_COLOR , pRule);
		}
		
		
		
		override public function destroyBall():void{
			_body = null;
		}
		
		
		
		override protected function setUserData(pBodyDef:b2BodyDef):void{
			pBodyDef.userData = new RedBallIcon();
		}
		
		
		
		/** when user initializes the balls' position, the user needs balls' color 
		 * so that to judge which position the ball should be **/
		
		override public function get getColor():String{
			return BALL_COLOR;
		}
		
		override public function get getValue():Number{
			return BALL_VALUE;
		}
		
		
		
		public function set setBool(bool:Boolean):void{
			_bool = bool;
		}
		
		public function get getBool():Boolean{
			return _bool;
		}
	}
}