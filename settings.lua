data:extend {
   {
        type = "bool-setting",
        name = "run",
        setting_type = "runtime-global",
        default_value = false,
    }, {
        type = "int-setting",
        name = "clone_speed",
        setting_type = "runtime-global",
        default_value = 1,
    }, {
        type = "string-setting",
        name = "trail-particles",
        setting_type = "runtime-global",
        default_value = "off",
        allowed_values = {"off", "fire", "poison", "all"}
    }, {
       type = "string-setting",
       name = "trail-for-unit",
       setting_type = "runtime-global",
       default_value = "off",
       allowed_values = {"off", "clones", "player", "all"}
   }

}