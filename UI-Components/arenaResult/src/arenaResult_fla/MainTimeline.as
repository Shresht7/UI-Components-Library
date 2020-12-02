package arenaResult_fla
{
   import LS_Classes.scrollList;
   import LS_Classes.textHelpers;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.utils.Timer;
   
   public dynamic class MainTimeline extends MovieClip
   {
       
      
      public var resultPanel_mc:MovieClip;
      
      public var events:Array;
      
      public var layout:String;
      
      public var score_text:String;
      
      public var less_text:String;
      
      public var more_text:String;
      
      public var kills_text:String;
      
      public var damage_text:String;
      
      public var heal_text:String;
      
      public var btn_array:Array;
      
      public var console_hints_txt_array:Array;
      
      public var console_hints_icon_array:Array;
      
      public var rematchShowTimer:Timer;
      
      public var text_array:Array;
      
      public var string_array:Array;
      
      public var team_array:Array;
      
      public var player_array:Array;
      
      public var hero_array:Array;
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function onEventInit() : *
      {
         var _loc2_:uint = 0;
         this.rematchShowTimer = new Timer(1000,1);
         this.rematchShowTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onRematchShowTimerDone);
         this.resultPanel_mc.init();
         this.btn_array = new Array(this.resultPanel_mc.toMainMenu_mc,this.resultPanel_mc.toLobby_mc,this.resultPanel_mc.rematch_mc);
         this.console_hints_txt_array = new Array(this.resultPanel_mc.toMainMenu_txt_c_mc,this.resultPanel_mc.toLobby_txt_c_mc,this.resultPanel_mc.rematch_txt_c_mc);
         this.console_hints_icon_array = new Array(this.resultPanel_mc.toMainMenu_c_mc,this.resultPanel_mc.toLobby_c_mc,this.resultPanel_mc.rematch_c_mc);
         var _loc1_:Array = new Array("mainMenuBtnPressed","lobbyBtnPressed","yesBtnPressed","noBtnPressed");
         while(_loc2_ < this.btn_array.length)
         {
            this.btn_array[_loc2_].funcStr = _loc1_[_loc2_];
            this.btn_array[_loc2_].pressedFunc = this.onButtonPressed;
            _loc2_++;
         }
      }
      
      public function onButtonPressed(param1:MouseEvent) : *
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_)
         {
            ExternalInterface.call("PlaySound","UI_Generic_Click");
            ExternalInterface.call(_loc2_.funcStr);
         }
      }
      
      public function setButtonText(param1:Number, param2:String) : *
      {
         if(param1 >= 0 && param1 < this.btn_array.length && this.btn_array[param1].text_mc.text_txt)
         {
            this.btn_array[param1].text_mc.text_txt.htmlText = param2;
            this.console_hints_txt_array[param1].htmlText = param2;
         }
         else
         {
            ExternalInterface.call("UIAssert","setButtonText incorrect id :" + param1 + " for label:" + param2);
         }
      }
      
      public function setButtonDisabled(param1:Number, param2:Boolean) : *
      {
         if(param1 >= 0 && param1 < this.btn_array.length)
         {
            if(this.btn_array[param1].setDisabled != null)
            {
               this.btn_array[param1].setDisabled(param2);
            }
            else if(this.btn_array[param1].disabled_mc)
            {
               this.btn_array[param1].disabled_mc.visible = param2;
            }
            else
            {
               ExternalInterface.call("UIAssert","setButtonDisabled BORKED id :" + param1);
            }
         }
         else
         {
            ExternalInterface.call("UIAssert","setButtonDisabled incorrect id :" + param1);
         }
      }
      
      public function setButtonVisible(param1:Number, param2:Boolean) : *
      {
         if(param1 >= 0 && param1 < this.btn_array.length)
         {
            this.btn_array[param1].visible = param2;
         }
         else
         {
            ExternalInterface.call("UIAssert","setButtonVisible incorrect id :" + param1);
         }
      }
      
      public function showRematch() : *
      {
         this.resultPanel_mc.showRematch();
      }
      
      public function setControllerMode(param1:Boolean) : *
      {
         var _loc2_:uint = 0;
         this.resultPanel_mc.isController = param1;
         this.resultPanel_mc.refreshPlayerButtons();
         if(param1)
         {
            _loc2_ = 0;
            while(_loc2_ < this.btn_array.length - 1)
            {
               this.btn_array[_loc2_].visible = false;
               _loc2_++;
            }
            _loc2_ = 0;
            while(_loc2_ < this.console_hints_icon_array.length - 1)
            {
               this.console_hints_icon_array[_loc2_].visible = true;
               _loc2_++;
            }
            _loc2_ = 0;
            while(_loc2_ < this.console_hints_txt_array.length - 1)
            {
               this.console_hints_txt_array[_loc2_].visible = true;
               _loc2_++;
            }
         }
         else
         {
            _loc2_ = 0;
            while(_loc2_ < this.btn_array.length - 1)
            {
               this.btn_array[_loc2_].visible = true;
               _loc2_++;
            }
            _loc2_ = 0;
            while(_loc2_ < this.console_hints_icon_array.length - 1)
            {
               this.console_hints_icon_array[_loc2_].visible = false;
               _loc2_++;
            }
            _loc2_ = 0;
            while(_loc2_ < this.console_hints_txt_array.length - 1)
            {
               this.console_hints_txt_array[_loc2_].visible = false;
               _loc2_++;
            }
         }
      }
      
      public function hideRematch() : *
      {
         this.resultPanel_mc.hideRematch();
      }
      
      public function onRematchShowTimerDone(param1:TimerEvent) : *
      {
         this.showRematch();
      }
      
      public function startShowRematch() : *
      {
         this.hideRematch();
         this.rematchShowTimer.reset();
      }
      
      public function onEventResize() : *
      {
         ExternalInterface.call("setPosition","center","splitscreen","center");
      }
      
      public function setAnchor(param1:Number, param2:* = true) : *
      {
         ExternalInterface.call("registerAnchorId","arenaResult" + param1);
      }
      
      public function onEventDown(param1:Number, param2:Number, param3:Number) : *
      {
         var _loc4_:Boolean = false;
         var _loc5_:String = this.events[param1];
         switch(this.events[param1])
         {
            case "IE UICancel":
               _loc4_ = true;
               break;
            case "IE UIAccept":
               _loc4_ = true;
               break;
            case "IE UIUp":
               _loc4_ = true;
               break;
            case "IE UIDown":
               _loc4_ = true;
               break;
            case "IE UIShowInfo":
               _loc4_ = true;
               break;
            case "IE UITooltipUp":
               this.startScroll(true,param3);
               _loc4_ = true;
               break;
            case "IE UITooltipDown":
               this.startScroll(false,param3);
               _loc4_ = true;
         }
         return _loc4_;
      }
      
      public function onEventUp(param1:Number) : *
      {
         var _loc2_:Boolean = false;
         var _loc3_:String = this.events[param1];
         switch(this.events[param1])
         {
            case "IE UICancel":
               _loc2_ = true;
               ExternalInterface.call("mainMenuBtnPressed");
               break;
            case "IE UIAccept":
               _loc2_ = true;
               ExternalInterface.call("lobbyBtnPressed");
               break;
            case "IE UIUp":
               _loc2_ = true;
               this.resultPanel_mc.selectPrevPlayer();
               break;
            case "IE UIDown":
               _loc2_ = true;
               this.resultPanel_mc.selectNextPlayer();
               break;
            case "IE UIShowInfo":
               _loc2_ = true;
               this.resultPanel_mc.toggleInfo();
               break;
            case "IE UITooltipUp":
            case "IE UITooltipDown":
               this.stopScroll();
               _loc2_ = true;
         }
         return _loc2_;
      }
      
      public function startScroll(param1:Boolean, param2:Number) : *
      {
         var _loc3_:scrollList = this.resultPanel_mc.list;
         if(_loc3_ != null)
         {
            _loc3_.m_scrollbar_mc.m_autoScrollDefaultMultiplier = Math.abs(param2) * 4;
            _loc3_.m_scrollbar_mc.startAutoScroll(!param1);
         }
      }
      
      public function stopScroll() : *
      {
         var _loc1_:scrollList = this.resultPanel_mc.list;
         if(_loc1_ != null)
         {
            _loc1_.m_scrollbar_mc.stopAutoScroll();
         }
      }
      
      public function setText(param1:Number, param2:String) : *
      {
         if(param1 >= 0 && param1 < this.text_array.length)
         {
            this.text_array[param1].htmlText = param2;
         }
         if(param1 == 0)
         {
            textHelpers.smallCaps(this.resultPanel_mc.title_txt,13,true);
         }
      }
      
      public function setString(param1:Number, param2:String) : *
      {
         if(param1 >= 0 && param1 < this.string_array.length)
         {
            this.string_array[param1] = param2;
         }
      }
      
      public function clearList() : *
      {
         this.resultPanel_mc.clearList();
         this.resultPanel_mc.players = [];
      }
      
      public function setCurrentPlayer(param1:Number, param2:Boolean) : *
      {
         this.resultPanel_mc.header_mc.gotoAndStop(!!param2?1:2);
         this.resultPanel_mc.setPlayerID(param1);
      }
      
      public function addPlayer(param1:Number, param2:Number, param3:Number, param4:String, param5:Boolean) : *
      {
         this.resultPanel_mc.addPlayer(param1,param2,param3,param4,param5);
      }
      
      public function addTeam(param1:Number, param2:Number) : *
      {
         this.resultPanel_mc.addTeam(param1,param2);
      }
      
      public function addHero(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number) : *
      {
         this.resultPanel_mc.addHero(param1,param2,param3,param4,param5,param6,param7);
      }
      
      public function update() : *
      {
         var _loc1_:uint = 0;
         this.clearList();
         while(_loc1_ < this.team_array.length)
         {
            this.addTeam(this.team_array[_loc1_],this.team_array[_loc1_ + 1]);
            _loc1_ = _loc1_ + 2;
         }
         _loc1_ = 0;
         while(_loc1_ < this.player_array.length)
         {
            this.addPlayer(this.player_array[_loc1_],this.player_array[_loc1_ + 1],this.player_array[_loc1_ + 2],this.player_array[_loc1_ + 3],this.player_array[_loc1_ + 4]);
            _loc1_ = _loc1_ + 5;
         }
         _loc1_ = 0;
         while(_loc1_ < this.hero_array.length)
         {
            this.addHero(this.hero_array[_loc1_],this.hero_array[_loc1_ + 1],this.hero_array[_loc1_ + 2],this.hero_array[_loc1_ + 3],this.hero_array[_loc1_ + 4],this.hero_array[_loc1_ + 5],this.hero_array[_loc1_ + 6]);
            _loc1_ = _loc1_ + 7;
         }
         this.resultPanel_mc.updateDone();
         this.team_array = new Array();
         this.hero_array = new Array();
         this.player_array = new Array();
      }
      
      function frame1() : *
      {
         this.events = new Array("IE UIAccept","IE UICancel","IE UIUp","IE UIDown","IE UIShowInfo","IE UITooltipUp","IE UITooltipDown");
         this.layout = "fixed";
         this.text_array = new Array(this.resultPanel_mc.title_txt,this.resultPanel_mc.subTitle_txt);
         this.string_array = new Array(this.score_text,this.more_text,this.less_text,this.kills_text,this.damage_text,this.heal_text);
         this.team_array = new Array();
         this.player_array = new Array();
         this.hero_array = new Array();
      }
   }
}