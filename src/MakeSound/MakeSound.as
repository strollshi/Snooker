package MakeSound
{
	import Ball.Ball;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	
	public class MakeSound extends Sprite
	{
		private var _p1:Point = new Point();
		private var _p2:Point = new Point();
		
		private var _isDeployed:Boolean = new Boolean(false);
		private var _isCollideBlock:Boolean	= new Boolean(false);
		
		private var _ballArray:Array;
		
		private var stm1:SoundTransform;
		private var stm2:SoundTransform = new SoundTransform(1);
		private var stm3:SoundTransform = new SoundTransform(0.2);
		private var stm4:SoundTransform = new SoundTransform(0.2);
		private var stm5:SoundTransform = new SoundTransform(0.5);
		private var stm6:SoundTransform = new SoundTransform(1);
		private var stm7:SoundTransform;
		private var stm8:SoundTransform = new SoundTransform(1);
		
		
//		[Embed(source="SnookerData/hittingVoice2.mp3")]
//		private var myHittingVoice:Class;
//		
//		[Embed(source="SnookerData/depositeBall.mp3")]
//		private var myDepositeBallVoice:Class;
//		
//		[Embed(source="SnookerData/openingMusic.mp3")]
//		private var myOpeningMusic:Class;
//		
//		[Embed(source="SnookerData/passingMusic.mp3")]
//		private var myPassingMusic:Class;
//		
//		[Embed(source="SnookerData/backgroundMusic1.mp3")]
//		private var myBackGroundMusic_1:Class;
//		
//		[Embed(source="SnookerData/backgroundMusic2.mp3")]
//		private var myBackGroundMusic_2:Class;
//		
//		[Embed(source="SnookerData/hittingball.mp3")]
//		private var myHitBall:Class;
//		
//		[Embed(source="SnookerData/applause.mp3")]
//		private var myApplause:Class;
		
		
		
//		private var _snd_myHittingVoice:Sound = new myHittingVoice();
//		private var _snd_myDepositeBallVoice:Sound = new myDepositeBallVoice();
//		private var _snd_myFallBallVoice:Sound = new myHittingVoice();
//		private var _snd_myOpeningMusic:Sound = new myOpeningMusic();
//		private var _snd_myPassingMusic:Sound = new myPassingMusic();
//		private var _snd_myBackGroundMusic_1:Sound = new myBackGroundMusic_1();
//		private var _snd_myBackGroundMusic_2:Sound = new myBackGroundMusic_2();
//		private var _snd_myHitBall:Sound = new myHitBall();
		
		
		public function MakeSound()
		{	
			addEventListener(Event.ENTER_FRAME , onDetect);
			
		}
		
		
		
		private function onDetect(evt:Event):void{
			if(_ballArray != null)
			{
				//trace("..................................................................");
				removeEventListener(Event.ENTER_FRAME , onDetect);
				addEventListener(Event.ENTER_FRAME , onEnterFrameHandler);
			}
		}

		private function onEnterFrameHandler(evt:Event):void{
			if(_isDeployed == false)
			{
				onDepositeBallVoice();
			}
			
			//different force, different hitting voice
			stm1 = new SoundTransform(Ball(_ballArray[0]).getVelocity/35);
			stm7 = new SoundTransform(Ball(_ballArray[0]).getVelocity/35);
			
			detectCollidesWithWhiteBall();
			detectWhiteBallStatic();
		}
		
		
		
		public function clean():void{
			
		}
		
		
		
		/** In every begining of game, to make this sound for simulating ball deployment **/
		
		private function onDepositeBallVoice():void{
//			_snd_myDepositeBallVoice.play(6950,1).soundTransform = stm2;
			_isDeployed = true;
		}
		
		
		
		public function hitBall():void{
//			_snd_myHitBall.play(7900,1).soundTransform = stm8;
		}
		
		
		
		/** if white ball collides with this ball, so make a sound of colliding **/
		
		private function detectCollidesWithWhiteBall():void{
			for each(var counter:Ball in _ballArray)
			{
				//trace(counter.getColor , counter.getIsCollide);
				if(counter.getColor != "White" && counter.getIsCollide == false)
				{
					_p1.x = Ball(_ballArray[0]).getBody.m_userData.x;
					_p1.y = Ball(_ballArray[0]).getBody.m_userData.y;
					_p2.x = counter.getBody.m_userData.x;
					_p2.y = counter.getBody.m_userData.y;
					
					//trace(_p1.x , _p1.y);
					
					if(Point.distance(_p1,_p2) <= counter.getBody.m_userData.width+10*Ball(_ballArray[0]).getVelocity/35)
					{
						//trace(counter.getIsCollide);
						if(counter.getIsCollide == false)
						{
							//trace("&&&&&&&&&&&&&&&&&&&&&&&&");
							counter.setIsCollide = true;
//							_snd_myHittingVoice.play(300,1).soundTransform = stm1;
						}
					}
					else
					{
						counter.setIsCollide = false;
					}
				}
			}
		}
		
		/** if white ball's velocity is zero, then to make every ball's _isCollide value as false **/
		
		private function detectWhiteBallStatic():void{
			if(_ballArray[0] != null)
			{
				if(Ball(_ballArray[0]).getBody.m_linearVelocity.x == 0 && Ball(_ballArray[0]).getBody.m_linearVelocity.y == 0)
				{	
					for each(var counter:Ball in _ballArray)
					{
						_p1.x = Ball(_ballArray[0]).getBody.m_userData.x;
						_p1.y = Ball(_ballArray[0]).getBody.m_userData.y;
						_p2.x = counter.getBody.m_userData.x;
						_p2.y = counter.getBody.m_userData.y;
						
						// to avoid two or more balls stick togheter when white ball is unmove
						if(Point.distance(_p1,_p2) <= counter.getBody.m_userData.width)
						{
							counter.setIsCollide = true;
						}
						else
						{
							counter.setIsCollide = false;
						}
					}
				}
			}
		}
		
		
		
		/** when ball fall into hole, play this sound **/
		
		public function fallBallVoice():void{
//			_snd_myFallBallVoice.play(700,1).soundTransform = stm3;
		}
		
		
		
		/** you need it when the game is beginning **/
		
		public function openingMusic():void{
//			_snd_myOpeningMusic.play(0,0).soundTransform = stm3;
		}
		
		
		
		/** this music will play all the time when you play the game **/
		
		public function backgroundMusic():void{
//			_snd_myBackGroundMusic_2.play(0,100).soundTransform = stm4;
		}
		
		
		
		/** this music only show up when you pass to next level or change stages **/
		
		public function passingMusic():void{
//			_snd_myPassingMusic.play(0,0).soundTransform = stm5;
		}
		
		
		
		public function victoryMusic():void{
			
		}
		
		
		
		/** setting _ballArray **/
		
		public function set setBallArray(pArray:Array):void{
			this._ballArray = pArray;
		}
		
		/** getting _ballArray **/
		
		public function get getBallArray():Array{
			return _ballArray;
		}
		
		public function set setIsDeployed(bool:Boolean):void{
			_isDeployed = bool;
		}
		
		public function get getIsDeployed():Boolean{
			return _isDeployed;
		}
		
		public function set setIsCollideBlock(bool:Boolean):void{
			_isCollideBlock = bool;
		}
		
		public function get getIsCollideBlock():Boolean{
			return _isCollideBlock;
		}
	}
}