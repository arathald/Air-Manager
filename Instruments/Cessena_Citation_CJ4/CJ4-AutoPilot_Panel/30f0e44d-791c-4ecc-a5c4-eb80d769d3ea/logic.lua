--[[
******************************************************************************************
******************Cessna Citation CJ4 AutoPilot Panel**********************************
******************************************************************************************
    
    Made by SIMSTRUMENTATION "EXTERMINATE THE MICE FROM YOUR COCKPIT!"
    GitHub: https://github.com/simstrumentation
   
- **v1.0**  03-07-2021 Rob "FlightLevelRob" Verdon
    - Original Panel Created
- **v1.1**  09-22-2021 Todd "Toddimus831" Lorey
   - Removed all Mobiflight functions
   - Reworked logic and event calls in many places
   - Added 1/2 Bank functionality
   - Repaired CRS1, CRS2, ALT, YD functions
- **v2.0**  09-26-2021 Joe "Crunchmeister" Gilker and Rob "FlightLevelRob" Verdon
   - Added night mode
   - Added backlighting
   - Changed dial behaviours to include rotation for backlit dials
   - Added CRS1 and CRS2 Push
   - Added IAS/MACH Toggle
   - Fixed APXFR 
   - Migrated AP Disconnect to move image instead of 2 images.
   - Cleaned code 
--*********END OF INTERNAL ALPHA TESTING****************
- **v2.0** 10-5-21 Rob "FlightLevelRob" Verdon and Joe "Crunchmeister" Gilker and Todd "Toddimus831" Lorey
    !!- Initial Public Release -!!
    - Variable renaming for clarity
    - Added backlight logic to account for battery, external power and bus volts status
   
##Left To Do:
    - 	
	
##Notes:
    - The Alt Knob has an outer and inner dials. Outer changes 1000' increments, Inner 100' increments.   
    
******************************************************************************************    
--]]

--Backgroud Image before anything else
img_add_fullscreen("background.png")

--SOUNDS
snd_click = sound_add("click.wav")
snd_fail = sound_add("beepfail.wav")
snd_dial = sound_add("dial.wav")

--Locals
local AP_DIS_STATUS_LOCAL = false
local current_heading = 0
local yd_state = nil
local ap_max_bank = nil
local ap_xfr_state = nil
local orignav1_obs = nil
local orignav2_obs = nil
local ias_mach_state = nil

--=======Night Lighting=============================================
img_bg_night = img_add_fullscreen("background_night.png")
-- Ambient Light Control
function ss_ambient_darkness(value)
    if value < 0.7 then
       dimval = 1-value
    else
        dimval = 0.2
    end
    opacity(img_bg_night, value, "LOG", 0.04)
    opacity(dial_crs1, dimval, "LOG", 0.04)
    opacity(dial_crs2, dimval, "LOG", 0.04)
    opacity(dial_IAS, dimval, "LOG", 0.04)
    opacity(dial_hdg, dimval, "LOG", 0.04)
    opacity(dial_alt_outer, dimval, "LOG", 0.04)
    opacity(img_alt_dial , dimval, "LOG", 0.04)
    opacity(img_AP_Dis, dimval, "LOG", 0.04)
end
si_variable_subscribe("sivar_ambient_darkness", "FLOAT", ss_ambient_darkness)

--=======Back  Lighting=============================================
img_labels_backlight = img_add_fullscreen("backlight.png")

function ss_backlighting(value, power, extpower, busvolts)
    value = var_round(value,2)
    
    if value == 1.0 or (power == false and extpower == false and busvolts < 5) then 
     
        opacity(img_labels_backlight, 0, "LOG", 0.04)       
        opacity(img_labels_backlight, 0, "LOG", 0.04)
        opacity(img_ALT_dial_backlight, 0, "LOG", 0.04)
        opacity(img_CRS1_dial_backlight, 0, "LOG", 0.04)
        opacity(img_CRS2_dial_backlight, 0, "LOG", 0.04)
        opacity(img_HDG_dial_backlight, 0, "LOG", 0.04)
        opacity(img_IAS_backlight, 0, "LOG", 0.04)
    else
        opacity(img_labels_backlight, ((value/2)+0.5), "LOG", 0.04)
        opacity(img_ALT_dial_backlight, ((value/2)+0.5), "LOG", 0.04)
        opacity(img_CRS1_dial_backlight, ((value/2)+0.5), "LOG", 0.04)
        opacity(img_CRS2_dial_backlight, ((value/2)+0.5), "LOG", 0.04)
        opacity(img_HDG_dial_backlight, ((value/2)+0.5), "LOG", 0.04)
        opacity(img_IAS_backlight, ((value/2)+0.5), "LOG", 0.04)
    end
end
fs2020_variable_subscribe("A:LIGHT POTENTIOMETER:3", "Number",
                          "ELECTRICAL MASTER BATTERY","Bool",
                          "EXTERNAL POWER ON:1", "Bool",
                          "ELECTRICAL MAIN BUS VOLTAGE", "Volts", ss_backlighting)
						  
--IMG
img_AP_Dis = img_add("AP_Dis.png", 1515,117,170,75)

---------------------------------------------------------------

--Flight Director ON   
function callback_FD()
   fs2020_event("TOGGLE_FLIGHT_DIRECTOR")
   sound_play(snd_click)
end
button_add(nil,"FD_pressed.png",  103,37,63,48, callback_FD)
button_add(nil,"FD_pressed.png",  1751,37,63,48, callback_FD)
--Virticle Speed    
function callback_VS()
   fs2020_event("H:WT_CJ4_AP_VS_PRESSED")
   sound_play(snd_click)
end
button_add(nil,"VS_pressed.png", 270,37,63,48, callback_VS)
--FLC    
function callback_FLC()
   fs2020_event("H:WT_CJ4_AP_FLC_PRESSED")
   sound_play(snd_click)
end
button_add(nil,"FLC_pressed.png", 607,37,63,48, callback_FLC) 
--NAV    
function callback_NAV()
   fs2020_event("H:WT_CJ4_AP_NAV_PRESSED")
   sound_play(snd_click)
end
button_add(nil,"NAV_pressed.png", 775,37,63,48, callback_NAV) 
--HDG    
function callback_HDG()
   fs2020_event("H:WT_CJ4_AP_HDG_PRESSED")
   sound_play(snd_click)
end
button_add(nil,"HDG_pressed.png", 935,37,63,48, callback_HDG) 
--APPR    
function callback_APPR()
   fs2020_event("H:WT_CJ4_AP_APPR_PRESSED")
   sound_play(snd_click)
end
button_add(nil,"APPR_pressed.png", 1085,37,63,48, callback_APPR) 
--ALT    
function callback_ALT()
   fs2020_event("H:WT_CJ4_AP_ALT_PRESSED")
   sound_play(snd_click)
end
button_add(nil,"ALT_pressed.png", 1236,37,63,48, callback_ALT) 
--YD    
function ss_yd_state(val)
    yd_state = val
end
fs2020_variable_subscribe("AUTOPILOT YAW DAMPER","Bool", ss_yd_state)
function callback_YD()
   if yd_state == false then
       fs2020_event("YAW_DAMPER_ON")
   else
       fs2020_event("YAW_DAMPER_OFF")
   end
   sound_play(snd_click)
end
button_add(nil,"YD_pressed.png", 1389,37,63,48, callback_YD) 
--AP    
function callback_AP()
   fs2020_event("AP_MASTER")
   sound_play(snd_click)
end
button_add(nil,"AP_pressed.png", 1569,37,63,48, callback_AP) 
--VNAV    
function callback_VNAV()
   fs2020_event("H:WT_CJ4_AP_VNAV_PRESSED")
   sound_play(snd_click)
end
button_add(nil,"VNAV_pressed.png", 270,135,63,48, callback_VNAV) 
--BANK  
function ss_ap_bank(val)
    ap_max_bank = val
end
fs2020_variable_subscribe("AUTOPILOT MAX BANK", "degrees", ss_ap_bank)
function callback_BANK()
   if ap_max_bank < 16 then
       fs2020_event("AP_MAX_BANK_INC")
   else
       fs2020_event("AP_MAX_BANK_DEC")
   end
   sound_play(snd_click)
end
button_add(nil,"BANK_pressed.png", 775,135,63,48, callback_BANK) 
--BackCourse    
function callback_BC()
   fs2020_event("H:WT_CJ4_AP_BC_PRESSED")
   sound_play(snd_click)
end
button_add(nil,"BC_pressed.png", 1085,135,63,48, callback_BC) 
--APXFR 
function ss_ap_xfr(val)
    ap_xfr_state = val
end
fs2020_variable_subscribe("L:XMLVAR_PushXFR","Int", ss_ap_xfr)
function callback_APXFR()
   fs2020_variable_write("L:XMLVAR_PushXFR","Int", fif(ap_xfr_state==1, 0, 1))
   sound_play(snd_click)
end
button_add(nil,"AP-XFR_pressed.png", 1389,135,63,48, callback_APXFR) 

-----VS Dial-------------
prop_VSDialorButtons = user_prop_add_boolean("VS Dial acts as buttons instead of dial", false, "") -- Show or hide the unit type onscreen
if user_prop_get(prop_VSDialorButtons) then
    --VS DEC    
    function callback_VS_DEC()
       fs2020_event("AP_VS_VAR_DEC")
       sound_play(snd_dial)
    end
    button_add(nil,"VS_DEC_pressed.png", 437,42,40,68, callback_VS_DEC) 
    --VS INC    
    function callback_VS_INC()
       fs2020_event("AP_VS_VAR_INC")
       sound_play(snd_dial)
    end
    button_add(nil,"VS_INC_pressed.png", 437,110,40,68, callback_VS_INC) 
else
    function callback_VS_DIAL( direction)
         if direction ==  -1 then
             fs2020_event("AP_VS_VAR_DEC")
             sound_play(snd_dial)
         elseif direction == 1 then
             fs2020_event("AP_VS_VAR_INC")
             sound_play(snd_dial)
         end
    end
    dial_VS = dial_add(nil, 437,42,40,148, callback_VS_DIAL)
end

--CRS1 DIAL (PILOT)
function ss_update_nav1_obs(deg)
    orignav1_obs = deg
end
fs2020_variable_subscribe("NAV OBS:1", "Degrees", ss_update_nav1_obs)
crs1_angle = 0
function callback_CRS1_DIAL(direction)
    if direction == -1 then
        crs1_angle = crs1_angle -10
        orignav1_obs = orignav1_obs - 1
        if orignav1_obs < 1 then
            orignav1_obs = 360
        end
    else
        crs1_angle = crs1_angle +10
        orignav1_obs = orignav1_obs + 1
        if orignav1_obs > 360 then
            orignav1_obs = 1
        end
    end
    rotate(img_CRS1_dial_backlight , crs1_angle)
    fs2020_event("VOR1_SET", orignav1_obs)
    sound_play(snd_dial)
end
dial_crs1 = dial_add("CRS_DIAL.png", 89,112,96,95, callback_CRS1_DIAL, calllback_CRS1_DIAL_click)
img_CRS1_dial_backlight = img_add("CRS_DIAL_backlight.png", 89,112,96,95)

--CRS1 PRESS
function callback_CRS1_DIAL_click()
    fs2020_event("K:VOR1_SET", current_heading )  
    sound_play(snd_click)
end    
button_add(nil,nil, 110,135,50,50, callback_CRS1_DIAL_click) 


--CRS2 DIAL (PILOT)


function ss_update_nav2_obs(deg)
    orignav2_obs = deg
end
fs2020_variable_subscribe("NAV OBS:2", "Degrees", ss_update_nav2_obs)
crs2_angle = 0
function callback_CRS2_DIAL(direction)
    if direction == -1 then
        crs2_angle = crs2_angle -10
        orignav2_obs = orignav2_obs - 1
        if orignav2_obs < 1 then
            orignav2_obs = 360
        end
    else
        crs2_angle = crs2_angle +10
        orignav2_obs = orignav2_obs + 1
        if orignav2_obs > 360 then
            orignav2_obs = 1
        end
    end
    rotate(img_CRS2_dial_backlight , crs2_angle)
    fs2020_event("VOR2_SET", orignav2_obs)
    sound_play(snd_dial)
end
dial_crs2 = dial_add("CRS_DIAL.png", 1739,112,96,95, callback_CRS2_DIAL, callback_CRS2_DIAL_click)
img_CRS2_dial_backlight = img_add("CRS_DIAL_backlight.png", 1739,112,96,95)

--CRS2 PRESS
function callback_CRS2_DIAL_click()
    fs2020_event("K:VOR2_SET", current_heading )  
    sound_play(snd_click)
end    
button_add(nil,nil, 1763,135,50,50, callback_CRS2_DIAL_click) 

--IAS DIAL
IAS_angle = 0
function callback_IAS_DIAL(direction)
     if direction ==  -1 then
         IAS_angle = IAS_angle - 10
         fs2020_event("AP_SPD_VAR_DEC")
         sound_play(snd_dial)
     elseif direction == 1 then
         IAS_angle = IAS_angle + 10
         fs2020_event("AP_SPD_VAR_INC")
         sound_play(snd_dial)
     end
     rotate(img_IAS_backlight, IAS_angle)
end
dial_IAS = dial_add("IAS_DIAL.png", 592,112,96,95, callback_IAS_DIAL, callback_IAS_DIAL_click)
img_IAS_backlight = img_add("IAS_DIAL_backlight.png", 592,112,96,95)

--IAS PRESS 
function ss_ias_mach_callback(var)
     ias_mach_state = var
end
fs2020_variable_subscribe("XMLVAR_AirSpeedIsInMach","Double", ss_ias_mach_callback)

function callback_IAS_DIAL_click()
     if ias_mach_state == 1 then
         fs2020_variable_write("L:XMLVAR_AirSpeedIsInMach","Double",0.0) 
     else
         fs2020_variable_write("L:XMLVAR_AirSpeedIsInMach","Double",1.0)
     end
    sound_play(snd_click)
 end    
button_add(nil,nil, 607,140,40,40, callback_IAS_DIAL_click) 


--HDG Knob
function ss_ap_heading_bug_callback(heading)   
    HDG_Degrees = heading
    return HDG_Degrees
end
fs2020_variable_subscribe("AUTOPILOT HEADING LOCK DIR", "Degrees", ss_ap_heading_bug_callback)
hdg_angle = 0
function hdg_turn_inner( direction)
    if direction ==  -1 then
            hdg_angle = hdg_angle -10
            HDG_Degrees = HDG_Degrees - 1
            if HDG_Degrees <= 0 then
                NewHdg = 360
            else
                NewHdg = HDG_Degrees
            end            
            fs2020_event("HEADING_BUG_SET", NewHdg)
    elseif direction == 1 then
            hdg_angle = hdg_angle +10
            HDG_Degrees = HDG_Degrees + 1
            if HDG_Degrees >= 361 then
                NewHdg = HDG_Degrees - 360
            else
                NewHdg = HDG_Degrees
            end
            fs2020_event("HEADING_BUG_SET", NewHdg)
    end
    rotate(img_HDG_dial_backlight, hdg_angle)
end
dial_hdg = dial_add("HDG_DIAL.png", 917,120,90,90, hdg_turn_inner)
img_HDG_dial_backlight = img_add("HDG_dial_backlight.png", 917,120,90,90)

--HDG PRESS
function callback_HDG_DIAL_click()
    fs2020_event("HEADING_BUG_SET", current_heading )  
    sound_play(snd_click)
end    
button_add(nil,nil, 940,140,40,40, callback_HDG_DIAL_click) 

function ss_current_heading_callback(heading)   
    current_heading = heading
end
fs2020_variable_subscribe("A:HEADING INDICATOR", "Degrees", ss_current_heading_callback)

-- Altitude Target Knob
alt_knob_angle = 0
function alt_large_callback(direction)
    if direction == 1 then
        alt_knob_angle = alt_knob_angle + 10
        fs2020_event("AP_ALT_VAR_INC", 1000)
    else
        alt_knob_angle = alt_knob_angle - 10
        fs2020_event("AP_ALT_VAR_DEC", 1000)
    end
	rotate(img_ALT_dial_backlight, alt_knob_angle)
	rotate(img_alt_dial,  alt_knob_angle)
	sound_play(snd_click)
end

function alt_small_callback(direction)
    if direction == 1 then
		alt_knob_angle = alt_knob_angle + 10
        fs2020_event("AP_ALT_VAR_INC", 100)
    else
        alt_knob_angle = alt_knob_angle - 10
        fs2020_event("AP_ALT_VAR_DEC", 100)
    end
    rotate(img_ALT_dial_backlight, alt_knob_angle)
    rotate(img_alt_dial,  alt_knob_angle)
    sound_play(snd_click)
end
dial_alt_outer = dial_add(nil, 1217,117,95,95, alt_large_callback)
img_alt_dial = img_add("ALT_DIAL.png", 1217,117,95,95)
img_ALT_dial_backlight = img_add("ALT_dial_backlight.png", 1217,117,95,95)
dial_click_rotate(dial_alt_outer, 6)

dial_alt_inner = dial_add(nil, 1232,135,65,65, alt_small_callback)
dial_click_rotate(dial_alt_inner, 6)

--ALT PRESS
--[[
function ALT_DIAL_click()
    fs2020_event("HEADING_BUG_SET")  
    sound_play(snd_click)
end    
button_add(nil,nil, 940,140,40,40, ALT_DIAL_click) 
]]--

--AP_DIS
function  ss_AP_DIS_STATUS(AP_DIS_STATUS1)
    if AP_DIS_STATUS1 == true then
        AP_DIS_STATUS_LOCAL = true
		move(img_AP_Dis, 1515,130,170,75,"LOG", 0.04 )        
    else 
        AP_DIS_STATUS_LOCAL = false
		move(img_AP_Dis, 1515,117,170,75,"LOG", 0.04 )       
    end
end
fs2020_variable_subscribe("AUTOPILOT DISENGAGED","Bool", ss_AP_DIS_STATUS)   

function callback_AP_DIS()
    if AP_DIS_STATUS_LOCAL == true then
        fs2020_event("AUTOPILOT_DISENGAGE_SET",0)
        sound_play(snd_click)
    else
        fs2020_event("AUTOPILOT_DISENGAGE_SET",1)
        sound_play(snd_click)
    end
end
 button_add(nil,nil, 1515,127,170,68, callback_AP_DIS)



