--  ===============================
--  REGISTER PATH-OVERRIDE LISTENER
--  ===============================

Ext.RegisterListener(
    "ModuleLoadStarted",

    function()
        Ext.AddPathOverride(
            "Public/Game/GUI/msgBox.swf",
            "Public/S7_UI_Components_Library_b66d56c6-12f9-4abc-844f-0c30b89d32e4/GUI/msgBox.swf"
        )
    end
)