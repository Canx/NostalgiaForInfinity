#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/../../" && pwd)

# Debugging prints
echo "Debug: SCRIPT_DIR is set to: $SCRIPT_DIR"
echo "Debug: ROOT_DIR is set to: $ROOT_DIR"

# Change to the root directory to ensure correct paths
cd "$ROOT_DIR" || exit 1

# Welcome message
echo "===== Welcome to the Interactive Backtesting Assistant ====="

# Prompt for environment variables
read -p "Enter the Exchange name (default: binance): " EXCHANGE
EXCHANGE=${EXCHANGE:-binance}

read -p "Enter the Trading Mode (default: spot): " TRADING_MODE
TRADING_MODE=${TRADING_MODE:-spot}

read -p "Enter the Strategy Name (default: NostalgiaForInfinityX5): " STRATEGY_NAME
STRATEGY_NAME=${STRATEGY_NAME:-NostalgiaForInfinityX5}

read -p "Enter the Strategy Version (default: auto): " STRATEGY_VERSION
if [[ -z "$STRATEGY_VERSION" ]]; then
  STRATEGY_VERSION=$(date '+%Y_%m_%d-%H_%M')
fi

read -p "Enter the Time Range (default: current year): " TIMERANGE
TIMERANGE=${TIMERANGE:-$(date '+%Y0101-')}

# Allow the user to specify a specific pair (optional)
read -p "Do you want to test a specific pair (e.g., DOGE/USDT)? Leave empty for all pairs: " PAIR

# Determine the appropriate pairlist file
PAIRLIST_FILE="configs/pairlist-backtest-static-${EXCHANGE}-${TRADING_MODE}-usdt.json"

if [[ ! -f "$PAIRLIST_FILE" ]]; then
  echo "Error: Pairlist file '$PAIRLIST_FILE' not found."
  echo "Please ensure the pairlist file exists for the selected exchange and trading mode."
  exit 1
fi

# Display the configured parameters
echo "===== Configured Parameters ====="
echo "Exchange: $EXCHANGE"
echo "Trading Mode: $TRADING_MODE"
echo "Strategy Name: $STRATEGY_NAME"
echo "Strategy Version: $STRATEGY_VERSION"
echo "Time Range: $TIMERANGE"
echo "Pairlist File: $PAIRLIST_FILE"
if [[ -n "$PAIR" ]]; then
  echo "Testing Specific Pair: $PAIR"
else
  echo "Testing All Pairs"
fi

# Download the necessary data using freqtrade
if [[ -n "$PAIR" ]]; then
  echo "Downloading data for pair '$PAIR' on exchange '$EXCHANGE' and trading mode '$TRADING_MODE'..."
  freqtrade download-data --exchange $EXCHANGE --pairs "$PAIR" --timerange $TIMERANGE --config "$PAIRLIST_FILE" -t 1m 5m 15m 1h 4h 1d
else
  echo "Downloading data for all pairs on exchange '$EXCHANGE' and trading mode '$TRADING_MODE'..."
  freqtrade download-data --exchange $EXCHANGE --pairs all --timerange $TIMERANGE --config "$PAIRLIST_FILE" -t 1m 5m 15m 1h 4h 1d
fi

if [[ $? -ne 0 ]]; then
  echo "Error downloading data. Please check your configuration and try again."
  exit 1
fi
echo "Data download completed successfully!"

# Prompt the user to select a script to run
echo "Which backtesting script would you like to execute?"
select SCRIPT in $(ls tests/backtests/*.sh); do
  # Verify the user made a valid selection
  if [[ -n "$SCRIPT" ]]; then
    echo "Executing the script: $SCRIPT"
    # Run the selected script
    bash "$SCRIPT"
    break
  else
    echo "Invalid selection. Please try again."
  fi
done

