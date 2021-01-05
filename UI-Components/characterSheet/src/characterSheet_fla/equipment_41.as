package characterSheet_fla
{
   import LS_Classes.larTween;
   import fl.motion.easing.Quartic;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   
   public dynamic class equipment_41 extends MovieClip
   {
       
      
      public var animContainer_mc:empty;
      
      public var container_mc:MovieClip;
      
      public var dollHit_mc:MovieClip;
      
      public var helmet_mc:MovieClip;
      
      public var iggy_Icons:MovieClip;
      
      public var infoStatHolder_mc:MovieClip;
      
      public const startDragDiff = 10;
      
      public var cellSize:Number;
      
      public var disableActions:Boolean;
      
      public var item_array:Array;
      
      public var slot_array:Array;
      
      public var slotAmount:Number;
      
      public var overContainer:Boolean;
      
      public var currentHLSlot:Number;
      
      public var dragHandle:Number;
      
      public var base:MovieClip;
      
      public var mousePosX:Number;
      
      public var mousePosY:Number;
      
      public function equipment_41()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function onBGOut(param1:MouseEvent) : *
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_)
         {
            _loc2_.removeEventListener(MouseEvent.ROLL_OUT,this.onBGOut);
         }
      }
      
      public function closeUIOnClick(param1:MouseEvent) : *
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_)
         {
            _loc2_.removeEventListener(MouseEvent.ROLL_OUT,this.onBGOut);
            ExternalInterface.call("PlaySound","UI_Game_Inventory_Click");
            ExternalInterface.call("closeCharacterUIs");
         }
      }
      
      public function addItem(param1:Number, param2:Number, param3:Number = 0) : *
      {
         var _loc4_:MovieClip = this.getSlot(param1);
         if(_loc4_ != null)
         {
            _loc4_.itemHandle = param2;
            if(param3 == 0)
            {
               _loc4_.condition_mc.visible = false;
            }
            else
            {
               _loc4_.condition_mc.visible = true;
               _loc4_.condition_mc.gotoAndStop(param3);
            }
         }
      }
      
      public function removeItem(param1:Number) : *
      {
         var _loc2_:MovieClip = this.getSlot(param1);
         if(_loc2_ != null)
         {
            if(this.base.curTooltip == param1)
            {
               ExternalInterface.call("hideTooltip");
            }
            _loc2_.itemHandle = null;
            _loc2_.disable_mc.visible = false;
            _loc2_.hl_mc.visible = false;
            _loc2_.condition_mc.visible = false;
         }
      }
      
      public function clearSlots() : *
      {
         var _loc2_:MovieClip = null;
         var _loc1_:uint = 0;
         while(_loc1_ < this.slot_array.length)
         {
            _loc2_ = this.slot_array[_loc1_];
            _loc2_.disable_mc.visible = false;
            _loc2_.hl_mc.visible = false;
            _loc2_.condition_mc.visible = false;
            _loc1_++;
         }
      }
      
      public function updateItems() : *
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc1_:Array = (root as MovieClip).itemsUpdateList;
         var _loc2_:uint = 0;
         while(_loc2_ < _loc1_.length)
         {
            if(_loc1_[_loc2_] != undefined)
            {
               _loc3_ = Number(_loc1_[_loc2_]);
               _loc4_ = Number(_loc1_[_loc2_ + 1]);
               _loc5_ = Number(_loc1_[_loc2_ + 2]);
               if(_loc4_ != -1)
               {
                  this.addItem(_loc3_,_loc4_,_loc5_);
               }
               else
               {
                  this.removeItem(_loc3_);
               }
            }
            _loc2_ = _loc2_ + 3;
         }
         (root as MovieClip).itemsUpdateList = new Array();
      }
      
      public function onDoubleClick(param1:MouseEvent) : *
      {
         var _loc2_:MovieClip = this.getSlot(this.currentHLSlot);
         if(!this.disableActions && _loc2_)
         {
            if(!this.base.isDragging && _loc2_ && _loc2_.itemHandle != null)
            {
               ExternalInterface.call("doubleClickItem",_loc2_.itemHandle);
               ExternalInterface.call("PlaySound","UI_Game_Inventory_Click");
            }
         }
      }
      
      public function onContainerOver(param1:MouseEvent) : *
      {
         this.overContainer = true;
         this.container_mc.addEventListener(MouseEvent.ROLL_OUT,this.onContainerOut);
         this.container_mc.addEventListener(MouseEvent.MOUSE_MOVE,this.onCheckSlotsOver);
         this.container_mc.addEventListener(MouseEvent.MOUSE_UP,this.onContainerUp);
         this.container_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onContainerDown);
         this.container_mc.addEventListener("IE ContextMenu",this.onContainerContext);
         this.container_mc.addEventListener(MouseEvent.DOUBLE_CLICK,this.onDoubleClick,false,0,true);
      }
      
      public function onContainerOut(param1:MouseEvent) : *
      {
         this.overContainer = false;
         this.clearCurrentHL();
         this.currentHLSlot = -1;
         this.container_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onContainerOut);
         this.container_mc.removeEventListener(MouseEvent.MOUSE_MOVE,this.onCheckSlotsOver);
         this.container_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onContainerUp);
         this.container_mc.removeEventListener(MouseEvent.MOUSE_DOWN,this.onContainerDown);
         ExternalInterface.call("slotUp");
         this.container_mc.removeEventListener("IE ContextMenu",this.onContainerContext);
         this.container_mc.removeEventListener(MouseEvent.DOUBLE_CLICK,this.onDoubleClick);
      }
      
      public function onContainerContext(param1:MouseEvent) : *
      {
         var _loc2_:MovieClip = this.getSlot(this.currentHLSlot);
         if(!this.disableActions && this.overContainer)
         {
            if(!this.base.isDragging)
            {
               if(_loc2_ && _loc2_.itemHandle != null)
               {
                  this.onContextMenuInputUp();
                  ExternalInterface.call("PlaySound","UI_Game_Inventory_Click");
               }
            }
         }
      }
      
      public function onContainerContextEvent() : Boolean
      {
         var _loc1_:MovieClip = this.getSlot(this.currentHLSlot);
         if(!this.disableActions && this.overContainer)
         {
            if(!this.base.isDragging)
            {
               if(_loc1_ && _loc1_.itemHandle != null)
               {
                  this.onContextMenuInputUp();
                  ExternalInterface.call("PlaySound","UI_Game_Inventory_Click");
                  return true;
               }
            }
         }
         return false;
      }
      
      public function onCheckSlotsOver(param1:MouseEvent) : *
      {
         this.checkForSlotUnderMouse();
         var _loc2_:MovieClip = this.getSlot(this.currentHLSlot);
         if(!_loc2_)
         {
            ExternalInterface.call("slotUp");
         }
      }
      
      public function checkForSlotUnderMouse() : *
      {
         var _loc2_:MovieClip = null;
         var _loc1_:Number = this.getSlotOnXY(this.container_mc.mouseX,this.container_mc.mouseY);
         if(this.currentHLSlot != _loc1_)
         {
            this.clearCurrentHL();
            this.currentHLSlot = _loc1_;
            _loc2_ = this.getSlot(this.currentHLSlot);
            if(_loc2_)
            {
               _loc2_.onOver(null);
            }
         }
      }
      
      public function clearCurrentHL() : *
      {
         var _loc1_:MovieClip = null;
         if(this.currentHLSlot != -1)
         {
            _loc1_ = this.getSlot(this.currentHLSlot);
            if(_loc1_)
            {
               _loc1_.onOut(null);
            }
         }
      }
      
      public function getSlotOnXY(param1:Number, param2:Number) : Number
      {
         var _loc5_:MovieClip = null;
         var _loc3_:Number = -1;
         var _loc4_:uint = 0;
         while(_loc4_ < this.slot_array.length)
         {
            _loc5_ = this.slot_array[_loc4_];
            if(_loc5_.x < param1 && _loc5_.y < param2 && _loc5_.x + this.cellSize > param1 && _loc5_.y + this.cellSize > param2)
            {
               _loc3_ = _loc4_;
               break;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function onContainerUp(param1:MouseEvent) : *
      {
         if(this.base.isDragging)
         {
            if(this.currentHLSlot >= 0)
            {
               ExternalInterface.call("stopDraggingEquipment",this.currentHLSlot);
            }
            else
            {
               ExternalInterface.call("cancelDragging");
            }
         }
         removeEventListener(MouseEvent.MOUSE_MOVE,this.dragging);
         ExternalInterface.call("slotUp");
         this.dragHandle = 0;
      }
      
      public function onContainerDown(param1:MouseEvent) : *
      {
         this.checkForSlotUnderMouse();
         var _loc2_:MovieClip = this.getSlot(this.currentHLSlot);
         if(!this.disableActions && !this.base.isDragging && _loc2_ && _loc2_.itemHandle != null)
         {
            ExternalInterface.call("slotDown",_loc2_.pos);
            ExternalInterface.call("PlaySound","UI_Game_Inventory_Click");
            if(!this.base.isDragging)
            {
               addEventListener(MouseEvent.MOUSE_MOVE,this.dragging);
               this.mousePosX = stage.mouseX;
               this.mousePosY = stage.mouseY;
               this.dragHandle = _loc2_.itemHandle;
            }
         }
      }
      
      public function dragging(param1:MouseEvent) : *
      {
         if(this.mousePosX + this.startDragDiff < stage.mouseX || this.mousePosX - this.startDragDiff > stage.mouseX || this.mousePosY + this.startDragDiff < stage.mouseY || this.mousePosY - this.startDragDiff > stage.mouseY)
         {
            ExternalInterface.call("startDragging",this.dragHandle);
            removeEventListener(MouseEvent.MOUSE_MOVE,this.dragging);
         }
      }
      
      public function onContextMenuInputDown() : *
      {
         return false;
      }
      
      public function onContextMenuInputUp() : *
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Point = null;
         if(!this.disableActions && this.overContainer && !this.base.isDragging)
         {
            _loc1_ = this.getSlot(this.currentHLSlot);
            if(_loc1_ && _loc1_.itemHandle != null)
            {
               _loc2_ = new Point(0,0);
               _loc2_ = _loc1_.localToGlobal(_loc2_);
               ExternalInterface.call("openContextMenu",_loc1_.itemHandle,-root.x + _loc2_.x + _loc1_.width * 0.5,-root.y + _loc2_.y + _loc1_.height * 0.5);
               return true;
            }
         }
         return false;
      }
      
      public function addIcon(param1:MovieClip, param2:String, param3:Number) : *
      {
         var _loc5_:Bitmap = null;
         if(param2 != param1.texture)
         {
            _loc5_ = param1.getChildByName("img") as Bitmap;
            if(_loc5_ != null)
            {
               param1.removeChild(_loc5_);
            }
            if(param2 != "")
            {
               _loc5_ = new Bitmap(new bitmapPlaceholder(1,1));
               _loc5_.name = "img";
               param1.addChild(_loc5_);
               IggyFunctions.setTextureForBitmap(_loc5_,param2);
               if(_loc5_.width > _loc5_.height)
               {
                  _loc5_.width = param3;
                  _loc5_.scaleY = _loc5_.scaleX;
               }
               else
               {
                  _loc5_.height = param3;
                  _loc5_.scaleX = _loc5_.scaleY;
               }
            }
         }
         param1.texture = param2;
         param1.alpha = 0;
         param1.visible = true;
         var _loc4_:larTween = new larTween(param1,"alpha",Quartic.easeOut,param1.alpha,1,0.4);
      }
      
      public function init() : *
      {
         this.setupSlots();
         ExternalInterface.call("getItemList","equiped");
      }
      
      public function setupSlots() : *
      {
         var _loc1_:uint = 0;
         while(_loc1_ < this.slot_array.length)
         {
            this.slot_array[_loc1_].pos = _loc1_;
            this.slot_array[_loc1_].disable_mc.visible = false;
            this.slot_array[_loc1_].hl_mc.visible = false;
            this.slot_array[_loc1_].itemHandle = null;
            this.slot_array[_loc1_].condition_mc.mouseEnabled = false;
            this.slot_array[_loc1_].condition_mc.visible = false;
            _loc1_++;
         }
      }
      
      public function getSlot(param1:Number) : MovieClip
      {
         var _loc2_:uint = 0;
         while(_loc2_ < this.slot_array.length)
         {
            if(this.slot_array[_loc2_].pos == param1)
            {
               return this.slot_array[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      public function ShowItemUnEquipAnim(param1:Number, param2:Number) : *
      {
         var _loc4_:MovieClip = null;
         var _loc3_:MovieClip = this.slot_array[param1];
         if(_loc3_ != null)
         {
            _loc4_ = new transferItem();
            _loc4_.mouseEnabled = false;
            _loc4_.mouseChildren = false;
            this.animContainer_mc.addChild(_loc4_);
            _loc4_.x = _loc3_.x;
            _loc4_.y = _loc3_.y;
            _loc4_.width = _loc3_.width;
            _loc4_.height = _loc3_.height;
            _loc4_.startAnim("itemUnequipIcon_" + param2,0,0);
         }
      }
      
      public function ShowItemEquipAnim(param1:Number, param2:Number, param3:Boolean = true) : *
      {
         var _loc5_:MovieClip = null;
         var _loc6_:MovieClip = null;
         var _loc7_:BitmapData = null;
         var _loc4_:MovieClip = this.slot_array[param1];
         if(_loc4_ != null)
         {
            if(param3)
            {
               _loc6_ = new MovieClip();
               switch(param1)
               {
                  case 0:
                     _loc7_ = new paperdoll_helmet();
                     break;
                  case 1:
                     _loc7_ = new paperdoll_chestpiece();
                     break;
                  case 2:
                     _loc7_ = new paperdoll_shirt();
                     break;
                  case 3:
                     _loc7_ = new paperdoll_handL();
                     break;
                  case 4:
                     _loc7_ = new paperdoll_handR();
                     break;
                  case 5:
                     _loc7_ = new paperdoll_ringL();
                     break;
                  case 6:
                     _loc7_ = new paperdoll_belt();
                     break;
                  case 7:
                     _loc7_ = new paperdoll_Boots();
                     break;
                  case 8:
                     _loc7_ = new paperdoll_gloves();
                     break;
                  case 9:
                     _loc7_ = new paperdoll_necklace();
                     break;
                  case 11:
                     _loc7_ = new paperdoll_ringR();
               }
               _loc6_.addChild(new Bitmap(_loc7_));
               this.animContainer_mc.addChildAt(_loc6_,0);
               _loc6_.x = _loc4_.x - 6;
               _loc6_.y = _loc4_.y - 6;
               _loc6_.width = _loc7_.width;
               _loc6_.height = _loc7_.height;
            }
            _loc5_ = new transferItem();
            this.animContainer_mc.addChild(_loc5_);
            _loc5_.x = _loc4_.x;
            _loc5_.y = _loc4_.y;
            _loc5_.width = _loc4_.width;
            _loc5_.height = _loc4_.height;
            _loc5_.startAnim("itemEquipIcon_" + param2,0,1,_loc6_);
         }
      }
      
      public function onOut(param1:MouseEvent) : *
      {
         ExternalInterface.call("dollOut");
      }
      
      public function onDown(param1:MouseEvent) : *
      {
         ExternalInterface.call("dollDown");
         this.dollHit_mc.addEventListener(MouseEvent.MOUSE_UP,this.onUp);
      }
      
      public function onUp(param1:MouseEvent) : *
      {
         this.dollHit_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
         ExternalInterface.call("dollUp");
      }
      
      function frame1() : *
      {
         this.cellSize = 64;
         this.disableActions = false;
         this.item_array = new Array();
         this.slot_array = new Array(this.container_mc.s0_mc,this.container_mc.s1_mc,this.container_mc.s2_mc,this.container_mc.s3_mc,this.container_mc.s4_mc,this.container_mc.s5_mc,this.container_mc.s6_mc,this.container_mc.s7_mc,this.container_mc.s8_mc,this.container_mc.s9_mc,this.container_mc.s10_mc);
         this.slotAmount = 12;
         this.overContainer = false;
         this.currentHLSlot = -1;
         this.dragHandle = 0;
         this.base = root as MovieClip;
         this.iggy_Icons.mouseChildren = false;
         this.iggy_Icons.mouseEnabled = false;
         this.container_mc.mouseChildren = false;
         this.container_mc.doubleClickEnabled = true;
         this.mousePosX = 0;
         this.mousePosY = 0;
         this.container_mc.addEventListener(MouseEvent.ROLL_OVER,this.onContainerOver);
         this.dollHit_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         this.dollHit_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
      }
   }
}
