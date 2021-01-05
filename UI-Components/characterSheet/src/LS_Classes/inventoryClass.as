package LS_Classes
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   
   public class inventoryClass extends grid
   {
       
      
      public var SND_Click:String = "UI_Game_Inventory_Click";
      
      public var m_ItemUseCallback:String = "doubleClickItem";
      
      public var m_id:Number = 0;
      
      private var cellClass:Class = null;
      
      private var item_array:Array;
      
      public var maxRows:uint = 900;
      
      public var minRows:uint = 2;
      
      public var cellWidth:Number;
      
      public var cellHeight:Number;
      
      public var cellSpacing:Number = 2;
      
      public var gridRefresh:Boolean = false;
      
      private var m_bgDiscrap:Number = 0;
      
      public var invYoffset:Number = 0;
      
      private var m_IggyImageHolder:MovieClip;
      
      private var m_IggyImage:MovieClip;
      
      private var m_OverContainer:Boolean = false;
      
      public var m_Base:MovieClip;
      
      private var dragStartMP:Point;
      
      private var m_DragHandle:Number = 0;
      
      private var m_CustomIggyName:String = "";
      
      private const startDragDiff:Number = 10;
      
      private var m_allowDoubleClick:Boolean = true;
      
      public var disableActions:Boolean = false;
      
      public var invScrollYoffset:Number = 0;
      
      public var onCellClicked:Function = null;
      
      public var onCellCreate:Function = null;
      
      public var onClearCell:Function = null;
      
      public var onCellDoubleClicked:Function = null;
      
      public var m_downStr:String = "down_id";
      
      public var m_upStr:String = "up_id";
      
      public var m_handleStr:String = "handle_id";
      
      public var m_bgStr:String = "scrollBg_id";
      
      public var m_ffDownStr:String = "";
      
      public var m_ffUpStr:String = "";
      
      public var m_scrollbar_mc:scrollbar;
      
      public var SB_SPACING:Number = 10;
      
      private var m_mouseWheelWhenOverEnabled:Boolean = false;
      
      private var m_mouseWheelEnabled:Boolean = false;
      
      private var m_down1:MovieClip = null;
      
      private var m_down2:MovieClip = null;
      
      private var m_bgHit:Sprite;
      
      public function inventoryClass(param1:Number, param2:String = "Cell", param3:uint = 6, param4:uint = 6, param5:Number = -1, param6:Number = -1, param7:Number = -1, param8:Function = null)
      {
         var _loc10_:MovieClip = null;
         this.item_array = new Array();
         this.dragStartMP = new Point(0,0);
         super();
         this.onCellCreate = param8;
         addEventListener(MouseEvent.MOUSE_UP,this.onContainerUp);
         this.m_IggyImageHolder = new MovieClip();
         this.m_IggyImage = new MovieClip();
         containerBG_mc.addChild(this.m_IggyImageHolder);
         this.m_IggyImageHolder.addChild(this.m_IggyImage);
         var _loc9_:Sprite = new Sprite();
         _loc9_.graphics.lineStyle(1,16777215);
         _loc9_.graphics.beginFill(16777215);
         _loc9_.graphics.drawRect(0,0,100,100);
         _loc9_.graphics.endFill();
         this.m_IggyImage.addChild(_loc9_);
         this.id = param1;
         this.cellClass = getDefinitionByName(param2) as Class;
         col = param3;
         row = param4;
         if(param5 == -1 || param6 == -1)
         {
            _loc10_ = new this.cellClass();
            if(_loc10_)
            {
               this.cellWidth = _loc10_.width;
               this.cellHeight = _loc10_.height;
            }
         }
         if(param7 != -1)
         {
            this.cellSpacing = param7;
         }
         if(param6 != -1)
         {
            this.cellWidth = param6;
         }
         if(param5 != -1)
         {
            this.cellHeight = param5;
         }
         container_mc.doubleClickEnabled = true;
         container_mc.addEventListener(MouseEvent.ROLL_OVER,this.onContainerOver);
         container_mc.mouseChildren = false;
         this.setupGrid();
      }
      
      public function get overContainer() : Boolean
      {
         return this.m_OverContainer;
      }
      
      public function set customIggyName(param1:String) : *
      {
         this.m_CustomIggyName = param1;
         if(this.m_CustomIggyName == "")
         {
            this.m_IggyImageHolder.name = "iggy_" + this.id;
         }
         else
         {
            this.m_IggyImageHolder.name = "iggy_" + this.m_CustomIggyName;
         }
         this.m_IggyImageHolder.y = this.invYoffset;
      }
      
      public function set id(param1:Number) : *
      {
         this.m_id = param1;
         if(this.m_CustomIggyName == "")
         {
            this.m_IggyImageHolder.name = "iggy_" + this.id;
         }
      }
      
      public function get id() : Number
      {
         return this.m_id;
      }
      
      public function set allowDoubleClick(param1:Boolean) : *
      {
         if(this.m_allowDoubleClick != param1)
         {
            if(this.m_allowDoubleClick)
            {
               container_mc.addEventListener(MouseEvent.DOUBLE_CLICK,this.onDoubleClick,false,0,true);
            }
            else
            {
               container_mc.removeEventListener(MouseEvent.DOUBLE_CLICK,this.onDoubleClick);
            }
            this.m_allowDoubleClick = param1;
         }
      }
      
      public function get allowDoubleClick() : Boolean
      {
         return this.m_allowDoubleClick;
      }
      
      private function onContainerOver(param1:MouseEvent) : *
      {
         this.m_OverContainer = true;
         container_mc.addEventListener(MouseEvent.ROLL_OUT,this.onContainerOut);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onCheckSlotsOver);
         container_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onContainerDown);
         if(this.m_allowDoubleClick)
         {
            container_mc.addEventListener(MouseEvent.DOUBLE_CLICK,this.onDoubleClick,false,0,true);
         }
      }
      
      public function set mouseWheelEnabled(param1:Boolean) : *
      {
         this.m_mouseWheelEnabled = param1;
         if(this.m_scrollbar_mc)
         {
            this.m_scrollbar_mc.mouseWheelEnabled = this.m_mouseWheelEnabled;
         }
      }
      
      public function get mouseWheelEnabled() : Boolean
      {
         return this.m_mouseWheelEnabled;
      }
      
      public function set mouseWheelWhenOverEnabled(param1:Boolean) : *
      {
         if(this.m_mouseWheelWhenOverEnabled != param1)
         {
            this.m_mouseWheelWhenOverEnabled = param1;
            if(this.m_mouseWheelWhenOverEnabled)
            {
               this.addEventListener(MouseEvent.ROLL_OUT,this.disableMouseWheelOnOut);
               this.addEventListener(MouseEvent.ROLL_OVER,this.enableMouseWheelOnOver);
            }
            else
            {
               this.removeEventListener(MouseEvent.ROLL_OUT,this.disableMouseWheelOnOut);
               this.removeEventListener(MouseEvent.ROLL_OVER,this.enableMouseWheelOnOver);
            }
         }
      }
      
      private function disableMouseWheelOnOut(param1:MouseEvent) : *
      {
         if(this.m_scrollbar_mc)
         {
            this.m_scrollbar_mc.mouseWheelEnabled = false;
         }
      }
      
      private function enableMouseWheelOnOver(param1:MouseEvent) : *
      {
         if(this.m_scrollbar_mc)
         {
            this.m_scrollbar_mc.mouseWheelEnabled = true;
         }
      }
      
      private function onContainerDown(param1:MouseEvent) : *
      {
         this.checkForSlotUnderMouse();
         if(!this.disableActions && !this.m_Base.isDragging && m_CurrentSelection && m_CurrentSelection.amount > 0)
         {
            if(this.m_down1 == null || this.m_down1 != m_CurrentSelection)
            {
               this.m_down1 = m_CurrentSelection;
               this.m_down2 = null;
            }
            else if(this.m_down2 == null)
            {
               this.m_down2 = m_CurrentSelection;
            }
            ExternalInterface.call("PlaySound",this.SND_Click);
            this.m_DragHandle = m_CurrentSelection.itemHandle;
            ExternalInterface.call("slotDown",currentSelection);
            this.dragStartMP.x = stage.mouseX;
            this.dragStartMP.y = stage.mouseY;
         }
         container_mc.addEventListener(MouseEvent.MOUSE_UP,this.onContainerEatEvent);
      }
      
      private function onContainerEatEvent(param1:MouseEvent) : *
      {
         ExternalInterface.call("slotUp");
         container_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onContainerEatEvent);
      }
      
      private function onContainerUp(param1:MouseEvent) : *
      {
         if(this.m_Base.isDragging)
         {
            if(currentSelection >= 0)
            {
               if(this.m_id == 0)
               {
                  ExternalInterface.call("stopDragging",currentSelection);
               }
               else
               {
                  ExternalInterface.call("stopDragging",this.m_id,currentSelection);
               }
            }
            else
            {
               ExternalInterface.call("cancelDragging");
            }
         }
         else if(this.onCellClicked != null)
         {
            if(m_CurrentSelection && this.m_DragHandle == m_CurrentSelection.itemHandle)
            {
               this.onCellClicked(m_CurrentSelection);
            }
         }
         this.m_DragHandle = 0;
      }
      
      private function onCheckSlotsOver(param1:MouseEvent) : *
      {
         if(this.m_OverContainer)
         {
            this.checkForSlotUnderMouse();
         }
      }
      
      private function onContainerOut(param1:MouseEvent) : *
      {
         this.m_down1 = null;
         this.m_down2 = null;
         this.m_OverContainer = false;
         clearSelection();
         container_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onContainerOut);
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onCheckSlotsOver);
         container_mc.removeEventListener(MouseEvent.MOUSE_DOWN,this.onContainerDown);
         container_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onContainerEatEvent);
         if(this.m_allowDoubleClick)
         {
            container_mc.removeEventListener(MouseEvent.DOUBLE_CLICK,this.onDoubleClick);
         }
         ExternalInterface.call("hideTooltip");
      }
      
      private function onDoubleClick(param1:MouseEvent) : *
      {
         if(this.m_down1 == m_CurrentSelection && this.m_down2 == m_CurrentSelection && this.useSelectedItem())
         {
            if(this.onCellDoubleClicked != null)
            {
               this.onCellDoubleClicked(m_CurrentSelection);
            }
            this.m_down1 = null;
            this.m_down2 = null;
         }
      }
      
      public function useSelectedItem() : Boolean
      {
         if(!this.disableActions && m_CurrentSelection && m_CurrentSelection.amount > 0)
         {
            ExternalInterface.call(this.m_ItemUseCallback,m_CurrentSelection.itemHandle);
            ExternalInterface.call("hideTooltip");
            ExternalInterface.call("PlaySound",this.SND_Click);
            return true;
         }
         return false;
      }
      
      public function onContextMenuInputUp() : *
      {
         var _loc1_:Point = null;
         if(!this.disableActions && this.m_OverContainer && !this.m_Base.isDragging)
         {
            if(m_CurrentSelection && m_CurrentSelection.itemHandle != 0)
            {
               _loc1_ = new Point(0,0);
               _loc1_ = m_CurrentSelection.localToGlobal(_loc1_);
               if(this.m_id == 0)
               {
                  ExternalInterface.call("openContextMenu",m_CurrentSelection.itemHandle,-root.x + _loc1_.x + m_CurrentSelection.width * 0.5,-root.y + _loc1_.y + m_CurrentSelection.height * 0.5 + this.invScrollYoffset);
               }
               else
               {
                  ExternalInterface.call("openContextMenu",this.m_id,m_CurrentSelection.itemHandle,-root.x + _loc1_.x + m_CurrentSelection.width * 0.5,-root.y + _loc1_.y + m_CurrentSelection.height * 0.5 + this.invScrollYoffset);
               }
            }
            return true;
         }
         return false;
      }
      
      public function addItem(param1:uint, param2:Number, param3:Number) : MovieClip
      {
         var _loc4_:Number = Math.ceil((param1 + 1) / col);
         if(_loc4_ >= row && _loc4_ <= this.maxRows)
         {
            this.extendGrid(_loc4_ - row + 1);
         }
         var _loc5_:MovieClip = this.getSlot(param1);
         if(_loc5_ != null)
         {
            if(_loc5_.itemHandle == null || _loc5_.itemHandle == 0)
            {
               this.item_array.push(_loc5_);
            }
            _loc5_.itemHandle = param2;
            _loc5_.amount = param3;
            if(param3 == 1)
            {
               _loc5_.amount_txt.htmlText = "";
               _loc5_.amount_txt.visible = false;
            }
            else
            {
               _loc5_.amount_txt.htmlText = param3;
               _loc5_.amount_txt.visible = true;
            }
            if(this.gridRefresh)
            {
               this.refreshGridSize();
            }
            _loc5_.isUpdated = true;
            if(currentSelection == _loc5_.list_pos && _loc5_.selectElement != null)
            {
               _loc5_.selectElement();
            }
         }
         return _loc5_;
      }
      
      public function removeItem(param1:uint) : *
      {
         var _loc3_:uint = 0;
         var _loc2_:MovieClip = this.getSlot(param1);
         if(_loc2_ != null)
         {
            this.clearSlotMC(_loc2_);
            _loc3_ = 0;
            while(_loc3_ < this.item_array.length)
            {
               if(_loc2_ == this.item_array[_loc3_])
               {
                  this.item_array.splice(_loc3_,1);
                  break;
               }
               _loc3_++;
            }
         }
      }
      
      public function cleanUpItems() : *
      {
         var _loc1_:uint = 0;
         while(_loc1_ < this.item_array.length)
         {
            if(this.item_array[_loc1_].isUpdated)
            {
               this.item_array[_loc1_].isUpdated = false;
               _loc1_++;
            }
            else
            {
               this.clearSlotMC(this.item_array[_loc1_]);
               this.item_array.splice(_loc1_,1);
            }
         }
         if(this.gridRefresh)
         {
            this.refreshGridSize();
         }
      }
      
      public function clearSlotMC(param1:MovieClip) : *
      {
         param1.amount = -1;
         param1.itemHandle = 0;
         param1.amount_txt.htmlText = "";
         param1.amount_txt.visible = false;
         if(this.onClearCell != null)
         {
            this.onClearCell(param1);
         }
      }
      
      public function clearSlots() : *
      {
         var _loc1_:uint = 0;
         while(_loc1_ < content_array.length)
         {
            this.clearSlotMC(content_array[_loc1_]);
            _loc1_++;
         }
         this.item_array = new Array();
      }
      
      public function getSlotOnXY(param1:Number, param2:Number) : uint
      {
         var _loc3_:int = int(param1 / (this.cellWidth + this.cellSpacing));
         var _loc4_:int = param2 / (this.cellHeight + this.cellSpacing);
         return Math.floor(_loc4_ * col + _loc3_);
      }
      
      public function getLastUsedRow() : uint
      {
         var _loc1_:Number = 0;
         var _loc2_:uint = 0;
         while(_loc2_ < this.item_array.length)
         {
            if(this.item_array[_loc2_].list_pos > _loc1_)
            {
               _loc1_ = this.item_array[_loc2_].list_pos;
            }
            _loc2_++;
         }
         return Math.ceil((_loc1_ + 1) / col);
      }
      
      public function resizeGrid(param1:int) : *
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:uint = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(param1 > 0 && param1 != col)
         {
            _loc2_ = Math.ceil(content_array.length / param1);
            _loc3_ = this.getLastUsedRow();
            if(_loc2_ == _loc3_)
            {
               _loc2_ = _loc2_ + 1;
            }
            else
            {
               _loc2_ = _loc3_ + 1;
            }
            _loc4_ = param1 * _loc2_;
            if(content_array.length > _loc4_)
            {
               _loc5_ = _loc4_;
               while(_loc5_ < content_array.length)
               {
                  removeElement(_loc5_,false);
               }
            }
            else if(content_array.length < _loc4_)
            {
               _loc6_ = content_array.length;
               while(_loc6_ < _loc4_)
               {
                  _loc7_ = _loc6_ / col;
                  _loc8_ = _loc6_ % col;
                  this.createCell(_loc7_,_loc8_);
                  _loc6_++;
               }
            }
            row = _loc2_;
            col = param1;
            this.positionElements();
         }
      }
      
      public function refreshGridSize() : void
      {
         var _loc1_:Number = this.getLastUsedRow();
         var _loc2_:Number = _loc1_ + 1;
         if(_loc2_ > row)
         {
            if(_loc2_ <= this.maxRows)
            {
               this.extendGrid(1);
            }
         }
         else if(_loc2_ < row)
         {
            if(_loc2_ > this.minRows)
            {
               this.shortenGrid(_loc2_);
            }
            else if(row > this.minRows)
            {
               this.shortenGrid(this.minRows);
            }
         }
         if(this.m_scrollbar_mc)
         {
            this.m_scrollbar_mc.scrollbarVisible();
         }
      }
      
      private function shortenGrid(param1:uint) : *
      {
         var _loc2_:int = param1 * col;
         while(_loc2_ < content_array.length)
         {
            removeElement(_loc2_,false);
         }
         row = param1;
         this.updateGridCallback();
         if(this.m_scrollbar_mc)
         {
            this.m_scrollbar_mc.scrollToFit();
         }
      }
      
      public function set bgDiscrap(param1:Number) : *
      {
         this.m_bgDiscrap = param1;
         this.positionElements();
      }
      
      private function createCell(param1:Number, param2:Number) : MovieClip
      {
         var _loc3_:MovieClip = new this.cellClass();
         _loc3_.inv = this;
         _loc3_.tooltipOverrideW = _loc3_.overrideWidth = this.cellWidth;
         _loc3_.tooltipOverrideH = _loc3_.overrideHeight = this.cellHeight;
         _loc3_.selector_mc.visible = false;
         _loc3_.x = (this.cellWidth + this.cellSpacing) * param2 - this.m_bgDiscrap;
         _loc3_.y = (this.cellHeight + this.cellSpacing) * param1 - this.m_bgDiscrap + this.invYoffset;
         _loc3_.name = "c" + param1 + "_" + param2;
         _loc3_.amount = -1;
         _loc3_.itemHandle = 0;
         _loc3_.amount_txt.visible = false;
         if(_loc3_.cellInit != null)
         {
            _loc3_.cellInit();
         }
         addElement(_loc3_,false);
         if(this.onCellCreate != null)
         {
            this.onCellCreate(_loc3_);
         }
         return _loc3_;
      }
      
      private function setupGrid() : *
      {
         var _loc2_:uint = 0;
         var _loc1_:uint = 0;
         while(_loc1_ < row)
         {
            _loc2_ = 0;
            while(_loc2_ < col)
            {
               this.createCell(_loc1_,_loc2_);
               _loc2_++;
            }
            _loc1_++;
         }
         this.updateGridCallback();
      }
      
      private function checkForSlotUnderMouse() : *
      {
         if(this.m_DragHandle != 0)
         {
            if(this.dragStartMP.x + this.startDragDiff < stage.mouseX || this.dragStartMP.y + this.startDragDiff < stage.mouseY || this.dragStartMP.x - this.startDragDiff > stage.mouseX || this.dragStartMP.y - this.startDragDiff > stage.mouseY)
            {
               ExternalInterface.call("startDragging",this.m_DragHandle);
               this.m_DragHandle = 0;
               this.m_down1 = null;
               this.m_down2 = null;
            }
         }
         var _loc1_:Number = container_mc.mouseY;
         if(container_mc.scrollRect != null)
         {
            _loc1_ = _loc1_ + container_mc.scrollRect.y;
         }
         var _loc2_:Number = this.getSlotOnXY(container_mc.mouseX,_loc1_);
         if(currentSelection != _loc2_)
         {
            select(_loc2_);
            this.m_down1 = null;
            this.m_down2 = null;
         }
      }
      
      private function updateGridCallback() : void
      {
         this.m_IggyImage.height = (this.cellHeight + this.cellSpacing) * row;
         this.m_IggyImage.width = (this.cellWidth + this.cellSpacing) * col;
         dispatchEvent(new Event("GridChanged"));
      }
      
      private function getSlot(param1:Number) : MovieClip
      {
         var _loc2_:MovieClip = null;
         if(param1 >= 0 && content_array.length > param1)
         {
            _loc2_ = content_array[param1];
         }
         return _loc2_;
      }
      
      private function extendGrid(param1:Number) : *
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:MovieClip = null;
         if(param1 > 0)
         {
            param1 = param1 + row;
            _loc2_ = row;
            while(_loc2_ < param1)
            {
               _loc3_ = 0;
               while(_loc3_ < col)
               {
                  _loc4_ = this.createCell(_loc2_,_loc3_);
                  _loc3_++;
               }
               _loc2_++;
            }
            row = param1;
            this.updateGridCallback();
         }
      }
      
      override public function positionElements() : *
      {
         var _loc4_:MovieClip = null;
         if(content_array.length < 1)
         {
            return;
         }
         var _loc1_:uint = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < content_array.length)
         {
            _loc4_ = getAt(_loc1_);
            if(_loc2_ >= col)
            {
               _loc2_ = 0;
               _loc3_++;
            }
            _loc4_.x = (this.cellWidth + this.cellSpacing) * _loc2_++ - this.m_bgDiscrap;
            _loc4_.y = (this.cellHeight + this.cellSpacing) * _loc3_ - this.m_bgDiscrap + this.invYoffset;
            _loc1_++;
         }
      }
      
      public function setInternalRow(param1:Number) : *
      {
         if(param1 < this.minRows)
         {
            param1 = this.minRows;
         }
         row = param1;
      }
      
      override public function setFrame(param1:Number, param2:Number) : *
      {
         if(this.m_scrollbar_mc == null)
         {
            this.m_scrollbar_mc = new scrollbar(this.m_downStr,this.m_upStr,this.m_handleStr,this.m_bgStr,this.m_ffDownStr,this.m_ffUpStr);
         }
         this.m_scrollbar_mc.visible = false;
         this.addChild(this.m_scrollbar_mc);
         container_mc.scrollRect = new Rectangle(0,0,param1,param2);
         this.m_scrollbar_mc.x = this.SB_SPACING + param1;
         this.m_scrollbar_mc.addContent(container_mc);
         this.checkScrollBar();
         if(!this.m_bgHit)
         {
            this.m_bgHit = new Sprite();
            this.m_bgHit.alpha = 0;
         }
         else
         {
            this.removeChild(this.m_bgHit);
         }
         this.m_bgHit.graphics.beginFill(16711935);
         this.m_bgHit.graphics.drawRect(0,0,this.width,param2);
         this.m_bgHit.graphics.endFill();
         this.addChildAt(this.m_bgHit,0);
      }
      
      public function checkScrollBar() : *
      {
         if(this.m_scrollbar_mc)
         {
            this.m_scrollbar_mc.scrollbarVisible();
         }
      }
      
      override public function cursorAccept() : *
      {
         if(this.onCellClicked != null)
         {
            if(m_CurrentSelection)
            {
               this.onCellClicked(m_CurrentSelection);
            }
         }
      }
   }
}
