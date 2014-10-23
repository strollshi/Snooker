/*

  this class takes charge of the player simulating, including turns counting, playing and score counting

*/

package SnookerPlayer
{
	import Ball.Ball;
	
	import Cue.Cue;
	
	import RuleTest.RuleTest;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class SnookerPlayer extends Sprite
	{
		private var _score:int 				 = 0;
		private var _accumulationValue:int   = 0;
		
		private var _playerName:String 		 = new String();
		
		private var _scoreTextField:TextField = new TextField();//to show how many score the player gets
		private var _turnsTextField:TextField = new TextField();//to show which kind of ball the player should kick
		private var _fm:TextFormat			  = new TextFormat("Helonia",20,0xffffff,true);				
		
		public function SnookerPlayer(pPlayerName:String)
		{
			this._playerName = pPlayerName;
			
			//scoreDecorator();
		}

		
		
		/** accumulating plus scores **/
		
		private function scoresCounter(pName:String , pScore:int):void{
			_accumulationValue += pScore;
		}
		
		
		
		/** to show how many score the player gets in this time **/
		
		public function scoreDecorator():void{
			trace(this._playerName + " : " + _accumulationValue);//total score for player
		}
		
		
		
		/** to simulate player how to aim target and shot the ball preciously **/
		
		public function playerSimulator():void{
			
		}
		
		
		
		public function clean():void{

		}

	}
}