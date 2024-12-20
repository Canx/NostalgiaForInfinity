#!/bin/bash
# simple backtests to check that current code protects against the 9 of december drop
export EXCHANGE="binance"
export TRADING_MODE="spot"
export STRATEGY_NAME="NostalgiaForInfinityX5"
export TIMERANGE="20241209-20241210"
freqtrade download-data --exchange binance -t 1m 5m 15m 1h 4h 1d --pairs DOGS/USDT

# Backtest NFIX5 20241208 version (shows the bad entry)
git checkout f6c3c0ebe09a23fe6b9f68c38451dd6942e0c2b7
freqtrade backtesting -c configs/backtest.json --pairs DOGS/USDT --timerange $TIMERANGE --export trades --timeframe-detail 1m

# After protections added by iterative (no bad entry detected)
git checkout main
freqtrade backtesting -c configs/backtest.json --pairs DOGS/USDT --timerange $TIMERANGE --export trades --timeframe-detail 1m

