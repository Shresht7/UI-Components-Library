package
{
   import LS_Classes.listDisplay;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public dynamic class Visual extends MovieClip
   {
       
      
      public var selection_mc:MovieClip;
      
      public var selectorData_mc:empty;
      
      public var title_txt:TextField;
      
      public var contentID:uint;
      
      public var root_mc:MovieClip;
      
      public var visualContentList:listDisplay;
      
      public function Visual()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function onInit(param1:MovieClip) : *
      {
         this.root_mc = param1;
         this.selection_mc.onInit(param1);
         this.visualContentList = new listDisplay();
         this.visualContentList.EL_SPACING = 5;
         this.selectorData_mc.addChild(this.visualContentList);
      }
      
      public function selectOption(param1:uint) : *
      {
         this.selection_mc.selectOptionByID(param1);
         this.setContent(this.selection_mc.currentElContent);
      }
      
      public function addContent(param1:uint, param2:MovieClip) : *
      {
         this.selection_mc.addContent(param1,param2);
         param2.setContentSize(this.root_mc.fixedContentSize);
         this.setContent(this.selection_mc.currentElContent);
      }
      
      public function clearOptions() : *
      {
         this.selection_mc.clearOptions();
         this.visualContentList.clearElements();
      }
      
      public function setContent(param1:MovieClip) : *
      {
         var _loc2_:uint = 0;
         var _loc3_:MovieClip = null;
         this.visualContentList.clearElements();
         if(param1)
         {
            if(param1.numChildren > 0)
            {
               _loc2_ = 0;
               while(_loc2_ < param1.length)
               {
                  _loc3_ = param1.getAt(_loc2_);
                  this.visualContentList.addElement(_loc3_);
                  _loc3_.x = -_loc3_.width / 2;
                  _loc2_++;
               }
            }
         }
      }
      
      public function setTitle(param1:String) : *
      {
         this.title_txt.htmlText = param1;
      }
      
      public function addOption(param1:uint, param2:String) : *
      {
         this.selection_mc.addOption(param1,param2);
         if(this.selection_mc.currentIdx < 0)
         {
            this.selection_mc.selectEl(0,false);
            this.setContent(this.selection_mc.currentElContent);
         }
      }
      
      public function get numberOfOptions() : int
      {
         return this.selection_mc.optionsList.length;
      }
      
      public function setEnabled(param1:Boolean) : *
      {
         this.selection_mc.setEnabled(param1);
      }
      
      public function findOptionByID(param1:uint) : Object
      {
         return this.selection_mc.findOptionByID(param1);
      }
      
      public function addTooltip(param1:uint, param2:String) : *
      {
         this.selection_mc.addTooltip(param1,param2);
      }
      
      function frame1() : *
      {
      }
   }
}
