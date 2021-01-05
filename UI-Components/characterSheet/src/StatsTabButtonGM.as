package
{
   import LS_Classes.tooltipHelper;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   
   public dynamic class StatsTabButtonGM extends MovieClip
   {
       
      
      public var bg_mc:MovieClip;
      
      public var icon_mc:MovieClip;
      
      public var selected_mc:MovieClip;
      
      public var base:MovieClip;
      
      public var pressedFunc:Function;
      
      public var texty:Number;
      
      public function StatsTabButtonGM()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function onMouseOver(param1:MouseEvent) : *
      {
         this.bg_mc.gotoAndStop(2);
         this.selected_mc.gotoAndStop(2);
         ExternalInterface.call("PlaySound","UI_Game_Journal_Over");
         if(this.tooltip != "")
         {
            this.tooltipYOffset = 2;
            tooltipHelper.ShowTooltipForMC(this,root,"top");
         }
      }
      
      public function onMouseOut(param1:MouseEvent) : *
      {
         this.bg_mc.gotoAndStop(1);
         this.selected_mc.gotoAndStop(1);
         removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
         ExternalInterface.call("hideTooltip");
         this.icon_mc.y = this.texty;
      }
      
      public function onDown(param1:MouseEvent) : *
      {
         this.selected_mc.gotoAndStop(3);
         this.bg_mc.gotoAndStop(3);
         addEventListener(MouseEvent.MOUSE_UP,this.onUp);
         this.icon_mc.y = this.texty + 2;
      }
      
      public function onUp(param1:MouseEvent) : *
      {
         this.selected_mc.gotoAndStop(2);
         this.bg_mc.gotoAndStop(2);
         removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
         this.icon_mc.y = this.texty;
         if(this.pressedFunc != null)
         {
            ExternalInterface.call("PlaySound","UI_Game_CharacterSheet_Attribute_Select_Click");
            this.pressedFunc(this.id);
         }
      }
      
      public function setActive(param1:Boolean) : *
      {
         this.bg_mc.visible = !param1;
         this.selected_mc.visible = param1;
      }
      
      function frame1() : *
      {
         this.base = root as MovieClip;
         addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
         addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
      }
   }
}
