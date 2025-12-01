## Metadata для Analytics (не Trading)

**Metadata для TAP = намного проще чем для trading platform. Основная задача: display formatting + symbol mapping + data availability tracking.**

## ЧТО НУЖНО vs ЧТО НЕ НУЖНО

### ❌ НЕ НУЖНО (trading-specific):

- **Order validation specs:**
    - Min/max order quantity
    - Min notional value
    - Lot size restrictions
    - Max leverage per tier
    - Maintenance margin rates

- **Trading rules:**
    - Rate limits per account
    - Order type restrictions
    - Trading hours (если есть)

- **Risk parameters:**
    - Position limits
    - Liquidation prices
    - Funding rate для perpetuals (если не показываем в UI)

---

### ✅ НУЖНО (analytics/visualization):

**Базовая идентификация:**
- Symbol (canonical: BTC/USDT)
- Venue symbols (Binance: BTCUSDT, Kraken: XBT/USD)
- Base asset / Quote asset
- Instrument type (SPOT, PERPETUAL, FUTURES)

**Display metadata:**
- Human-readable name ("Bitcoin / Tether")
- Venue (Binance, Bybit, Coinbase)
- Category/tags (crypto, major, liquid)
- Icon/logo URL

**Data interpretation:**
- Price precision (для округления в UI)
- Volume precision
- Tick size (для корректного отображения графиков)

**Data availability:**
- Available timeframes (1m, 5m, 1h, 1d)
- Historical data range (from_date, to_date)
- Status (active, delisted, suspended)

---

## УПРОЩЕННАЯ METADATA SCHEMA

```
Instrument {
  // Identity
  id: UUID
  canonical_symbol: "BTC/USDT"
  base_asset: "BTC"
  quote_asset: "USDT"
  instrument_type: "SPOT" | "PERPETUAL" | "FUTURES"
  venue: "binance"
  venue_symbol: "BTCUSDT"
  
  // Display
  display_name: "Bitcoin / Tether"
  category: "crypto"
  tags: ["major", "liquid", "high-volume"]
  icon_url: "https://..."
  
  // Data format
  price_precision: 2      // для UI formatting
  volume_precision: 3
  tick_size: 0.01        // для графиков
  
  // Data availability
  available_timeframes: ["1m", "5m", "1h", "1d"]
  data_from: "2020-01-01T00:00:00Z"
  data_to: null          // null = до сих пор активен
  status: "ACTIVE"
  
  // Metadata
  created_at: timestamp
  updated_at: timestamp
}
```

**НЕТ:**
- ❌ min_order_qty, max_order_qty
- ❌ min_notional
- ❌ max_leverage
- ❌ maintenance_margin_rate

---

## METADATA SYSTEM SCOPE (для TAP)

**Упрощенная версия:**

```
Metadata System {
  
  // 1. Instrument Registry (упрощенный)
  - Instrument specs (display + data format)
  - Symbol mappings (canonical ↔ venue)
  - Status tracking (active, delisted)
  
  // 2. Venue Registry
  - Supported venues (Binance, Bybit, ...)
  - Venue metadata (name, logo, website)
  
  // 3. Data Catalog
  - Available instruments per venue
  - Available timeframes per instrument
  - Data availability windows
  
  // НЕТ:
  ❌ Trading rules
  ❌ Risk parameters
  ❌ Order validation
}
```

---

## USE CASES для TAP Metadata

### Use Case 1: User browses instruments
```
User → UI: "Покажи доступные инструменты"
UI → Metadata System: GET /instruments?venue=binance&status=ACTIVE
Metadata → UI: [BTC/USDT, ETH/USDT, ...]
UI → displays list with names, icons, categories
```

### Use Case 2: User opens chart
```
User → UI: "Открой BTC/USDT 1h chart"
UI → Metadata System: GET /instruments/BTC-USDT
Metadata → UI: {price_precision: 2, tick_size: 0.1, ...}
UI → correctly formats Y-axis (price) with precision=2
UI → Stream Provider: subscribe to BTC/USDT candles-1h
```

### Use Case 3: Feed Adaptor normalizes symbol
```
Feed Adaptor receives: {"s": "BTCUSDT", ...}
Adaptor → Metadata System (cached): lookup "BTCUSDT"
Metadata → "BTCUSDT" (Binance) = "BTC/USDT" (canonical)
Adaptor → publishes with canonical symbol
```

### Use Case 4: Historical query validation
```
User → "Дай BTC/USDT candles от 2019-01-01"
Stream Provider → Metadata System: GET /instruments/BTC-USDT
Metadata → {data_from: "2020-01-01", ...}
Stream Provider → User: "Данные доступны только с 2020-01-01"
```

---

## METADATA SYSTEM ОСТАЕТСЯ PLATFORM SERVICE?

**Вопрос:** Если только analytics, может оставить в Market Data System?

**Мой ответ: ВСЁ РАВНО ВЫНЕСТИ**

**Почему:**

1. **Даже для analytics может быть несколько систем:**
    - Market Data System (real-time charts)
    - Backtesting System (strategy simulation)
    - Reporting System (daily/monthly reports)
    - Alert System (price alerts, anomaly detection)

2. **Metadata = configuration, не data:**
    - Market Data System = runtime data (prices, volumes)
    - Metadata System = configuration (что показывать, как форматировать)
    - Разная природа → разные системы

3. **Разные lifecycle:**
    - Market Data перезапускается → данные теряются (в памяти)
    - Metadata перезапускается → нельзя потерять (нужна персистентность)
    - Market Data может упасть → UI все равно должна показать список инструментов

4. **Будущее расширение:**
    - Сегодня: только crypto
    - Завтра: добавляем stocks, forex
    - Metadata управляет asset taxonomy → проще добавлять новые классы

---

## КРИТИЧЕСКИЙ ВОПРОС: источник metadata?

**Откуда берутся данные для Metadata System?**

### Вариант A: Manual entry
- Admin UI для добавления инструментов
- Ручное заполнение specs

**Проблема:** не масштабируется (100+ instruments)

### Вариант B: Sync from exchanges
- Metadata System периодически queries exchange APIs
- Автоматически обновляет instrument specs
- Обнаруживает new/delisted instruments

**Правильный подход для TAP**

### Вариант C: Metadata Loader (отдельный сервис)
```
Metadata Loader (cron job):
  - Queries exchange APIs (REST)
  - Extracts instrument specs
  - Normalizes to canonical format
  - Writes to Metadata System DB
  - Runs 1x per hour (или on-demand)
```

**Архитектура:**
```
[Exchange APIs] 
      ↓ REST (periodic)
[Metadata Loader] (cron)
      ↓ writes
[Metadata System DB]
      ↓ reads (cached)
[Market Data System components]
```

---

## ГРАНИЦЫ УВЕРЕННОСТИ

**Что точно:**
- ✅ Metadata для analytics проще чем для trading
- ✅ Не нужны order validation specs, risk parameters
- ✅ Нужны display specs, data availability, symbol mappings
