#!/bin/sh
cd /home/yryr/agqr
python3 agqr_to_json.py
curl localhost:1234/api/reload

