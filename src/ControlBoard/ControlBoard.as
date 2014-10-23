package ControlBoard
{
	import RuleTest.RuleTest;
	
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class ControlBoard extends Sprite
	{
		static private var _menu:OpeningMenu	   = new OpeningMenu();
		static private var _quitBtn:QuitIcon	   = new QuitIcon();
		static private var _returnBtn:ReturnIcon   = new ReturnIcon();
		static private var _isSinglePlayer:Boolean = false;
		static private var _isMultiPlayer:Boolean  = false;
		static private var _isReturnToMenu:Boolean = false;
		static private var _isEsc:Boolean = false;
		
		static private var _singlePlayerMode:TextField	   = new TextField();
		static private var _manMachineBattleMode:TextField = new TextField();
		static private var _helper:TextField			   = new TextField();
		
		static private var _helperText:HelperTextIcon = new HelperTextIcon();
		static private var _singlePlayerText:SinglePlayerTextIcon = new SinglePlayerTextIcon();
		static private var _manMachineText:ManMachineTextIcon = new ManMachineTextIcon();
		
		private var fm:TextFormat = new TextFormat("Helonia" , 15 , 0xffffff , true);
		
		static private var _myRule:RuleTest;
		
		
		
		
		public function ControlBoard()
		{	
			addingMenu();
			addingListener();
			
			addEventListener(Event.ENTER_FRAME , onEnterFrameHandler);
		}
		
		private function onEnterFrameHandler(evt:Event):void{
			if(_isEsc == true)
			{
				
			}
			
			if(_isSinglePlayer == true && _isMultiPlayer == false)
			{
				
			}
			if(_isSinglePlayer == false && _isMultiPlayer == true)
			{
				
			}
		}
		
		
		
		public function clean():void{
			_isSinglePlayer = false;
			_isMultiPlayer  = false;
			_isReturnToMenu = false;
			_isEsc = false;
		}
		
		
		
		private function addingCounter():void{
			
		}
		
		
		
		private function addingTags():void{
			
		}
		
		
		
		private function addingMenu():void{
			addChild(_menu);
			addChild(_quitBtn);
			addChild(_singlePlayerMode);
			addChild(_manMachineBattleMode);
			addChild(_helper);
			
			addChild(_helperText);
			addChild(_singlePlayerText);
			addChild(_manMachineText);
			
			_helperText.x = 650;
			_helperText.y = 400;
			_singlePlayerText.x = 650;
			_singlePlayerText.y = 200;
			_manMachineText.x = 650;
			_manMachineText.y = 300;
			
			_quitBtn.x = 50;
			_quitBtn.y = 450;
			
			_singlePlayerMode.x = 100;
			_singlePlayerMode.y = 100;
			_manMachineBattleMode.x = 100;
			_manMachineBattleMode.y = 200;
			_helper.x = 100;
			_helper.y = 300;
		}
		
		
		
		private function addingListener():void{
			_helperText.addEventListener(MouseEvent.CLICK , onClickEventHandler);
			_singlePlayerText.addEventListener(MouseEvent.CLICK , onClickEventHandler);
			_manMachineText.addEventListener(MouseEvent.CLICK , onClickEventHandler);
			_quitBtn.addEventListener(MouseEvent.CLICK , onClickEventHandler);
		}
		
		private function onClickEventHandler(evt:MouseEvent):void{
			switch(evt.target)
			{
			case(_helperText):
				break;
			case(_singlePlayerText):
				_isSinglePlayer = true;
				_isMultiPlayer = false;
				_myRule.setIsComplete = true;
				break;
			case(_manMachineText):
				_isMultiPlayer = true;
				_isSinglePlayer = false;
				_myRule.setIsComplete = true;
				break;
			case(_quitBtn):
				_isEsc = true;
				_isSinglePlayer = false;
				_isMultiPlayer = false;
				//trace("''''''''''''''''");
				NativeApplication.nativeApplication.exit();
				break;
			}
			
			//trace("^^^^^^^^^^^^^^^^^^^^^^^^^^^ " , _isSinglePlayer , _isMultiPlayer , _isEsc);
		}
		
		
		
		/** getting play model **/
		
		public function get getIsSinglePlayer():Boolean{
			return _isSinglePlayer;
		}
		
		public function get getIsMultiPlayer():Boolean{
			return _isMultiPlayer;
		}
		
		public function set setRule(pRule:RuleTest):void{
			_myRule = pRule;
		}
	}
}