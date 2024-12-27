#!/bin/bash
# 启动 Flask 应用
python app.py &
# 等待 Flask 应用启动
sleep 2
# 启动 Ngrok
ngrok http --domain=fast-raven-national.ngrok-free.app 5001 