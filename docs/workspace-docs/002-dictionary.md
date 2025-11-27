## Единый язык

[TOC]

### **Market Data Source**

Любой источник сырых рыночных данных — включая биржи, брокеров, агрегаторов, провайдеров, внутренние пайплайны и
хранилища.  
Уровень ниже, чем *provider*: source хранит или генерирует данные, но не обязательно предоставляет интерфейс их
систематизированного получения.  
Примеры: Binance Public Market Data endpoint, Kafka-топик trades внутри компании, файловый архив, Polygon.io raw stream.

### **Market Data Provider**

Сервис, предоставляющий стандартизированный доступ к данным из одного или нескольких sources (REST/WS API, нормализация,
ретрансляция).  
Пример: Polygon.io, TwelveData, Kaiko, внутренний Market Data System.

### **Trading Venue**

Любая площадка, на которой совершается торговля.  
Характеристики: собственные правила торгов, спецификации инструментов, исполнение сделок, ликвидность, комиссии, типы
ордеров.  
Примеры: Binance Spot, Binance Futures, Bybit Derivatives, CME, ICE, NYSE, LSE.

### **Exchange**

Тип *venue*, где существует централизованный matching engine и формальная регуляция.  
Классические примеры: CME, NYSE, NASDAQ.  
Криптобиржи — гибридный случай, часто не подпадают под классическое определение.

### **Feed**

Конкретный поток данных определённого типа:

- trades-feed
- orderbook/quotes-feed
- candles-feed
- funding-feed
- liquidation-feed

Feed может идти от одного или нескольких sources/providers.

### **Instrument**

Торгуемый объект с полным набором атрибутов: тикер, тип (spot, future, option), размер лота, шаг цены, дата экспирации,
валюта котировки, множитель.  
Примеры: BTCUSDT, ESZ5 (S&P 500 future), ETH-PERP.

### **Symbol**

Наименование инструмента в рамках конкретного *venue* или *provider*.  
Symbol — это представление, а не сам объект.  
Один и тот же инструмент может иметь разные symbols у разных venues/providers.  
Примеры:

- Binance Spot: BTCUSDT
- Binance Futures: BTCUSDT_PERP
- CME: ESZ5
- Internal: btc_usdt_spot

### **Market Data Stream / Channel**

Логическое объединение нескольких feed’ов по типу или инструменту (например, “all trades for futures”, “orderbook for
all spot symbols”). Часто соответствует WebSocket-каналу или Kafka-топику.

### **Orderbook / Quote**

Отдельный тип данных, часто выделяемый терминологически:

- *orderbook* — агрегированное состояние стакана
- *quotes* — best bid/ask (NBBO в регуляторных рынках)
