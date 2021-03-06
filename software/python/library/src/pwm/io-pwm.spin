{{
┌──────────────────────────────────────────┐
│ led_pwm_demo v1.0                        │
│ Author: Colin Fox <greenenergy@gmail.com>│
│ Copyright (c) 2011 Colin Fox             │
│ See end of file for terms of use.        │
└──────────────────────────────────────────┘
}}
CON
  _CLKMODE = xtal1 + pll16x
  _XINFREQ = 6_000_000
  
  FW_VERSION    = %111_00001
  NUM_LEDS      = 30
  
  CMD_FW        = 0
  CMD_DUTY      = 1
  CMD_SERVO     = 2
  CMD_PULSE     = 3
  CMD_RESET     = 255

OBJ

  serial : "FullDuplexSerial"
  pwm    : "PWM_32_v4.spin"

PUB Main | pin, rx, x, pwm_duty, pwm_hz, servo_pulse, pwm_ontime, pwm_offtime
  serial.start( 31, 30, 0, 115200 )
  pwm.Start
  
  waitcnt(cnt + clkfreq)
  
  'Transmit firmware version
  serial.Tx(FW_VERSION)
  
  {
  ' Debug test
  repeat x from 0 to NUM_LEDS-1
    pwm.Duty(x,75,16666)
    waitcnt(cnt + (clkfreq/10))
    pwm.Duty(x,0,16666)
    waitcnt(cnt + (clkfreq/10))
  }
  repeat
    ' LEDs only number up to 30, so we'll only
    ' get two consecutive 255s as a start sequence
    if serial.Rx == 255 and serial.Rx == 255
        rx := serial.Rx
        
        if rx == CMD_FW
          serial.Tx(FW_VERSION)
          
        elseif rx == CMD_DUTY
          pin := serial.Rx
          if pin > NUM_LEDS-1
            pin := NUM_LEDS-1
            
          pwm_duty := serial.Rx
          pwm_hz   := (serial.Rx<<8) + serial.Rx
          
          if pwm_hz > 100
            pwm_hz := 100
          
          pwm.Duty(pin,pwm_duty,pwm_hz)
        
        elseif rx == CMD_SERVO
          pin := serial.Rx
          if pin > NUM_LEDS-1
            pin := NUM_LEDS-1
            
          servo_pulse := (serial.Rx<<8) + serial.Rx
          
          pwm.Servo(pin,servo_pulse)
          
        elseif rx == CMD_PULSE 'PWM Pulse
          pin := serial.Rx
          if pin > NUM_LEDS-1
            pin := NUM_LEDS-1
            
          pwm_ontime  := (serial.Rx<<8) + serial.Rx
          pwm_offtime := (serial.Rx<<8) + serial.Rx
          
          pwm.PWM(pin, pwm_ontime, pwm_offtime)
          
        elseif rx == CMD_RESET 'Reset PWM engine
          pwm.Stop
          pwm.Start
          
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}
