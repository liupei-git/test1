#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# encoding: utf-8
# 
# Fomo3D Smart Contract Monitoring
#
# Copyright 2018 FawkesPan
# Contact : i@fawkex.me / Telegram@FawkesPan
#
# Do What the Fuck You Want To Public License
#

import requests
import re
import json
import time
import datetime

LogReset()

if TG == 1:
    TG_ENABLE = True 
else:
    TG_ENABLE = False
if WECHAT == 1:
    WC_ENABLE = True 
else:
    WC_ENABLE = False
    
TG_BOT_KEY = TGKEY

TGURL = 'https://api.telegram.org/bot%s/sendMessage' % TG_BOT_KEY
TGPARAM = {}
TGPARAM['chat_id'] = TGID

def Send(message):
    if TG_ENABLE == False:
        return
    try:
        TGPARAM['text'] = message
        res = requests.post(TGURL, data = TGPARAM)
        return
    except IOError as e:
        print(e)
        return


def Refresh():
    URL = 'https://mainnet.infura.io/%s' % INFURAKEY
    HEADER = {'Content-Type': 'application/json'}
    PARAM = '{"jsonrpc": "2.0", "id": 1, "method": "eth_call", "params": [{"data":"0x747dff42","to":"%s"},"latest"]}' % CONTRACT
    data = requests.post(URL,data=PARAM,headers=HEADER).json()
    HEX = re.sub('(0{2,})','X',data['result']).split('X')[3]
    print(HEX)
    INT = int(HEX, 16)
    NOW = int(time.time())
    LEFT = INT - NOW
    return LEFT

def main():
    Log('Started!')
    Log('ContractAddress: ' + CONTRACT)
    Log('Telegram Enabled: ' + str(TG_ENABLE))
    Log('WeChat Enabled: ' + str(WC_ENABLE))
    while True:
        try:
            DATE = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            TIMELEFT = Refresh()
            message = 'Time before FOMO ENDING : %d' % TIMELEFT
            if TIMELEFT < 0:
                TIMELEFT = THRESHOLD + 10
            if TIMELEFT <= THRESHOLD:
                Send(message)
                if WC_ENABLE == True:
                    message = message + ' !@'
                    
                Log(message)
            else:
                Log(message)

        except IOError as e:
            print(e)
            time.sleep(REFRESH_DELAY)
            pass

        time.sleep(REFRESH_DELAY)
