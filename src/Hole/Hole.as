/*
 *

  this class will detect whether the ball fall into the hole. If it dose, will arouse RuleTest class to test if it is brken the rule
  More, this class will make some animation as well, to substract ball's alpha if it gets in hole

 *
 */

package Hole
{
	import Ball.Ball;
	
	import Box2D.Common.Math.b2Vec2;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	public class Hole extends Sprite
	{
		private var myHole:HoleIcon = new HoleIcon();
		private var ballArray:Array;
		private const RATIO:Number = new Number(40);
		
		private var p1:Point = new Point();
		private var p2:Point = new Point();
		
		private var fallBall:Ball;
		
		private var _isGetBall:Boolean = new Boolean(false);
		
		
		
		public function Hole(pX:Number , pY:Number , pArray:Array):void{
			addChild(myHole);
			myHole.x = pX;
			myHole.y = pY;
			
			ballArray = pArray;
			//trace("ballArray" + ballArray);
			
			this.addEventListener(Event.ENTER_FRAME , onEnterFrameHandler);
		}
		
		private function onEnterFrameHandler(evt:Event):void{
			for(var counter:int=0 ; counter<ballArray.length ; counter++)
			{
				// calculating if the ball get in the hole
				if(testBallInHole(Ball(ballArray[counter]).getPosition.x*RATIO , Ball(ballArray[counter]).getPosition.y*RATIO , myHole.x , myHole.y) == true && Ball(ballArray[counter]).getIsInHole == false)
				{
					Ball(ballArray[counter]).setIsInHole = true;
					fallingAnimation(Ball(ballArray[counter]));
					//trace(Ball(ballArray[counter]).getIsInHole);
				}
			}
		}
		
		
		
		/** locking the falling ball and play the animation **/
		
		private function fallingAnimation(pBall:Ball):void{
			fallBall = pBall;
			//trace("on animation");
			this.addEventListener(Event.ENTER_FRAME , onFalling);
		}
		
		private function onFalling(evt:Event):void{
			fallBall.getBody.m_linearVelocity = new b2Vec2(0 , 0);
			
			//trace(myHole.x , myHole.y , fallBall.getBody.m_userData.x , fallBall.getBody.m_userData.y);
			//trace(fallBall.getBody.m_userData.alpha);
			
			fallBall.getBody.m_userData.alpha -= 0.1;
			
			if(fallBall.getBody.m_userData.alpha < 0.1)
			{
				//trace("off animation");
				fallBall.getBody.m_userData.alpha = 0;
				this.removeEventListener(Event.ENTER_FRAME , onFalling);
			}
		}
		
		
		
		/** to detect whether ball is in hole or not **/
		
		private function testBallInHole(pX:Number , pY:Number , bX:Number , bY:Number):Boolean{
			p1.x = pX;
			p1.y = pY;
			
			p2.x = bX;
			p2.y = bY;
			
			//trace(pX , pY + " " + bX , bY);
			if(Point.distance(p1,p2)  < myHole.width/2 )
			{
				//trace(" the ball get in the hole!");
				return true;
			}
			else
			{
				return false;
			}
		}
		
		
		
		/** getting the falling ball **/
		
		public function get getFallBall():Ball{
			return fallBall;
		}
		
		/** getting hole's position **/
		
		public function get getHole():HoleIcon{
			return myHole;
		}
	}
}