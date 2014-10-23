
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
	
	public class ColorBall extends Ball
	{
		
		private var BALL_VALUE:Number;//this constant value means how many scores player can earn by kicking it to hole
		private var BALL_COLOR:String;//this constant value is represent the ball's color
		
		public function ColorBall(pWorld:b2World , pColor:String , pRule:RuleTest):void{
			BALL_COLOR = pColor;
			detectValue(BALL_COLOR);
			
			initBall(pWorld , BALL_COLOR , pRule);
		}	
		
		
		
		override public function destroyBall():void{
			_body = null;
		}
	
		
		
		/** setting values for different color balls **/
		
		private function detectValue(pColor:String):void{
			switch(pColor)
			{
			case("Black"):
				BALL_VALUE = 7;
				break;
			case("Blue"):
				BALL_VALUE = 5;
				break;
			case("Brown"):
				BALL_VALUE = 4;
				break;
			case("Green"):
				BALL_VALUE = 3;
				break;
			case("Pink"):
				BALL_VALUE = 6;
				break;
			case("Yellow"):
				BALL_VALUE = 2;
				break;
			}
		}
		
		override protected function setUserData(pBodyDef:b2BodyDef):void{
			switch(BALL_COLOR)
			{
				case("Black"):
					pBodyDef.userData = new BlackBallIcon();
					break;
				case("Blue"):
					pBodyDef.userData = new BlueBallIcon();
					break;
				case("Brown"):
					pBodyDef.userData = new BrownBallIcon();
					break;
				case("Green"):
					pBodyDef.userData = new GreenBallIcon();
					break;
				case("Pink"):
					pBodyDef.userData = new PinkBallIcon();
					break;
				case("Yellow"):
					pBodyDef.userData = new YellowBallIcon();
					break;
			}
		}
		
		
		
		/** when user initializes the balls' position, the user needs balls' color 
		 * so that to judge which position the ball should be **/
		
		override public function get getColor():String{
			return BALL_COLOR;
		}
		
		override public function get getValue():Number{
			return BALL_VALUE;
		}
	}
}