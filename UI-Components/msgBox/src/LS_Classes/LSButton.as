package LS_Classes
{
   import flash.display.MovieClip;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class LSButton extends MovieClip
   {
       
      
      private var pressedFunc:Function = null;
      
      public var onOverFunc:Function = null;
      
      public var onOutFunc:Function = null;
      
      public var onUpFunc:Function = null;
      
      public var onDownFunc:Function = null;
      
      public var onOverParams:Object = null;
      
      public var onOutParams:Object = null;
      
      public var onDownParams:Object = null;
      
      private var pressedParams:Object = null;
      
      private var textY:Number;
      
      private var iconY:Number;
      
      public var tooltip:String;
      
      public var alignTooltip:String;
      
      public var hoverSound:String;
      
      public var clickSound:String;
      
      public var textNormalAlpha:Number = 1;
      
      public var textClickAlpha:Number = 1;
      
      public var textDisabledAlpha:Number = 0.5;
      
      public var hitArea_mc:MovieClip;
      
      public var text_txt:TextField = null;
      
      public var bg_mc_close:MovieClip;
      
      public var icon_mc:MovieClip;
      
      public var disabled_mc:MovieClip;
      
      public var m_Disabled:Boolean = false;
      
      public var SND_Press:String = "";
      
      public var SND_Over:String = "UI_Generic_Over";
      
      public var SND_Click:String = "UI_Gen_XButton_Click";
      
      public function LSButton()
      {
         super();
         if(this.text_txt)
         {
            this.text_txt.mouseEnabled = false;
            this.text_txt.alpha = this.textNormalAlpha;
         }
         if(this.icon_mc)
         {
            this.icon_mc.mouseEnabled = false;
            this.icon_mc.alpha = this.textNormalAlpha;
         }
         if(this.hitArea_mc)
         {
            this.hitArea_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
            this.hitArea_mc.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
            this.hitArea_mc.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         }
         else
         {
            addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
            addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
            addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         }
         addEventListener(FocusEvent.FOCUS_OUT,this.onFocusLost);
      }
      
      public function init(param1:Function, param2:Object = null, param3:Boolean = false) : *
      {
         this.pressedFunc = param1;
         if(param2)
         {
            this.pressedParams = param2;
         }
         this.setEnabled(!param3);
         if(this.text_txt)
         {
            this.textY = this.text_txt.y;
         }
         if(this.icon_mc)
         {
            this.iconY = this.icon_mc.y;
         }
      }
      
      public function initialize(param1:String, param2:Function, param3:Object = null, param4:Number = -1, param5:Boolean = false) : *
      {
         this.pressedFunc = param2;
         if(param3)
         {
            this.pressedParams = param3;
         }
         this.setEnabled(!param5);
         if(this.text_txt)
         {
            this.textY = this.text_txt.y;
         }
         if(this.icon_mc)
         {
            this.iconY = this.icon_mc.y;
         }
         this.setText(param1,param4);
      }
      
      public function setText(param1:String, param2:Number = -1) : *
      {
         var _loc3_:TextFormat = null;
         if(this.text_txt)
         {
            this.text_txt.y = this.textY;
            if(param2 != -1)
            {
               _loc3_ = this.text_txt.defaultTextFormat;
               _loc3_.size = param2;
               this.text_txt.defaultTextFormat = _loc3_;
            }
            this.text_txt.htmlText = param1;
            this.textY = this.text_txt.y;
            this.text_txt.filters = textEffect.createStrokeFilter(0,1.5,0.75,1,3);
         }
      }
      
      public function setEnabled(param1:Boolean) : *
      {
         if(this.disabled_mc)
         {
            this.disabled_mc.visible = !param1;
         }
         if(this.text_txt)
         {
            this.text_txt.alpha = !!param1?Number(this.textNormalAlpha):Number(this.textDisabledAlpha);
         }
         if(this.icon_mc)
         {
            this.icon_mc.alpha = !!param1?Number(this.textNormalAlpha):Number(this.textDisabledAlpha);
         }
         this.m_Disabled = !param1;
      }
      
      private function onFocusLost(param1:FocusEvent) : void
      {
         if(this.text_txt)
         {
            this.text_txt.y = this.textY;
         }
         if(this.icon_mc)
         {
            this.icon_mc.y = this.iconY;
         }
      }
      
      public function onMouseOver(param1:MouseEvent) : *
      {
         tooltipHelper.ShowTooltipForMC(this as MovieClip,this.root,this.alignTooltip != null?this.alignTooltip:"right");
         if(!this.m_Disabled)
         {
            if(this.SND_Over != null)
            {
               ExternalInterface.call("PlaySound",this.SND_Over);
            }
            if(this.text_txt)
            {
               this.text_txt.alpha = this.textClickAlpha;
            }
            if(this.icon_mc)
            {
               this.icon_mc.alpha = this.textClickAlpha;
            }
            this.bg_mc_close.gotoAndStop(2);
            if(this.onOverFunc != null)
            {
               if(this.onOverParams == null)
               {
                  this.onOverFunc();
               }
               else
               {
                  this.onOverFunc(this.onOverParams);
               }
            }
         }
      }
      
      public function onMouseOut(param1:MouseEvent) : *
      {
         if(this.hitArea_mc)
         {
            this.hitArea_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
         }
         else
         {
            removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
         }
         if(this.tooltip != null)
         {
            ExternalInterface.call("hideTooltip");
         }
         this.bg_mc_close.gotoAndStop(1);
         if(this.onOutFunc != null)
         {
            if(this.onOutParams == null)
            {
               this.onOutFunc();
            }
            else
            {
               this.onOutFunc(this.onOutParams);
            }
         }
         if(this.text_txt && !this.m_Disabled)
         {
            this.text_txt.alpha = this.textNormalAlpha;
            this.text_txt.y = this.textY;
         }
         if(this.icon_mc && !this.m_Disabled)
         {
            this.icon_mc.alpha = this.textNormalAlpha;
            this.icon_mc.y = this.iconY;
         }
      }
      
      public function onDown(param1:MouseEvent) : *
      {
         if(this.text_txt)
         {
            this.text_txt.y = this.textY;
         }
         if(!this.m_Disabled)
         {
            if(this.hitArea_mc)
            {
               this.hitArea_mc.addEventListener(MouseEvent.MOUSE_UP,this.onUp);
            }
            else
            {
               addEventListener(MouseEvent.MOUSE_UP,this.onUp);
            }
            this.bg_mc_close.gotoAndStop(3);
            if(this.SND_Press != null)
            {
               ExternalInterface.call("PlaySound",this.SND_Press);
            }
            if(this.onDownFunc != null)
            {
               if(this.onDownParams == null)
               {
                  this.onDownFunc();
               }
               else
               {
                  this.onDownFunc(this.onDownParams);
               }
            }
            if(this.text_txt)
            {
               this.text_txt.y = this.textY + 2;
            }
            if(this.icon_mc)
            {
               this.icon_mc.y = this.iconY + 2;
            }
         }
      }
      
      public function onUp(param1:MouseEvent) : *
      {
         if(this.hitArea_mc)
         {
            this.hitArea_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
         }
         else
         {
            removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
         }
         this.bg_mc_close.gotoAndStop(2);
         if(this.SND_Click != null)
         {
            ExternalInterface.call("PlaySound",this.SND_Click);
         }
         if(this.onUpFunc != null)
         {
            this.onUpFunc();
         }
         if(this.text_txt)
         {
            this.text_txt.y = this.textY;
         }
         if(this.icon_mc)
         {
            this.icon_mc.y = this.iconY;
         }
         if(this.pressedFunc != null && !this.m_Disabled)
         {
            if(this.pressedParams != null)
            {
               this.pressedFunc(this.pressedParams);
            }
            else
            {
               this.pressedFunc();
            }
         }
      }
   }
}
