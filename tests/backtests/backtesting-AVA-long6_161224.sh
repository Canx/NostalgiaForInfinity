#!/bin/bash
# check that current code protects against the bad entry on AVA the 16 of december (signal 6)
export EXCHANGE="binance"
export TRADING_MODE="spot"
export STRATEGY_NAME="NostalgiaForInfinityX5"
export TIMERANGE="20241216-20241217"
export TIMERANGE_DOWNLOAD="20241201-20241217"
freqtrade download-data --exchange binance -t 1m 5m 15m 1h 4h 1d --pairs AVA/USDT --timerange $TIMERANGE_DOWNLOAD
git checkout b1eaa070b9c8690cbd0b0596e18aaf2f05c73827 # Last commit before 16/12/24
freqtrade backtesting -c tests/backtests/backtest_signal6_AVA.json --pairs AVA/USDT --timerange $TIMERANGE --export signals --timeframe-detail 1m 
freqtrade backtesting-analysis -c tests/backtests/backtest_signal6_AVA.json --analysis-groups 0 1 2 3 4 5 
#git checkout main
#freqtrade backtesting -c tests/backtests/backtest_signal6_AVA.json --pairs AVA/USDT --timerange $TIMERANGE --export trades --timeframe-detail 1m
