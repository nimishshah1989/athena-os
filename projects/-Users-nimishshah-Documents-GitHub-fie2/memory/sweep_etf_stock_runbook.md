---
name: sweep_etf_stock_runbook
description: Step-by-step commands to run ETF and stock momentum sweeps overnight on production
type: reference
---

## Overnight Momentum Sweep — ETF & Stock Universes

### Prerequisites
- SSH into production: `ssh -i ~/.ssh/jsl-wealth-key.pem ubuntu@13.206.34.214`
- Container: `marketpulse` (fie2 image, port 8004)

### Step 1: Enter the container
```bash
sudo docker exec -it marketpulse bash
```

### Step 2: Run ETF sweep (~30 min)
```bash
python scripts/momentum_sweep.py --data etf --save data/momentum_sweep_etf_$(date +%Y%m%d_%H%M).json
```

### Step 3: Run Stock sweep (~45-60 min, larger universe)
```bash
python scripts/momentum_sweep.py --data stock --save data/momentum_sweep_stock_$(date +%Y%m%d_%H%M).json
```

### Step 4: Verify results
```bash
ls -la data/momentum_sweep_*.json
python -c "import json; d=json.load(open('data/momentum_sweep_etf_*.json')); print(f'ETF: {len(d.get(\"full\", d.get(\"train\", [])))} results')"
```

### Step 5: Exit container
```bash
exit
```

### Optional: Run with train/test validation
```bash
python scripts/momentum_sweep.py --data etf --train-test --save data/momentum_sweep_etf_$(date +%Y%m%d_%H%M).json
python scripts/momentum_sweep.py --data stock --train-test --save data/momentum_sweep_stock_$(date +%Y%m%d_%H%M).json
```

### After sweeps complete
- Results auto-appear in Lab UI under ETF / Stock tabs (the API reads latest file by glob)
- No container restart needed — endpoint reads JSON files on each request

### Notes
- ETF universe: ~50 equity ETFs, many are young (limited history)
- Stock universe: NIFTY 200+ with 1yr+ history, larger and slower to sweep
- Full grid = ~6,300 combos. Focused grid = ~1,800 (default, faster)
- Add `--full` flag for exhaustive sweep (3x longer)
