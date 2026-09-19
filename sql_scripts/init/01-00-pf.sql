create schema if not exists pf authorization webdwh;
grant usage on schema pf to viewer;

set role webdwh;

create table if not exists pf.tickers (
	icode int2 not null,
	tick varchar(20) not null,
	scode varchar(20) not null,
	pf_category_ru varchar not null,
	pf_category_en varchar not null,
	constraint tickers_pk primary key (icode),
	constraint tickers_scode_unique unique (scode),
	constraint tickers_tick_unique unique (tick)
);
grant select on pf.tickers to viewer;

create table if not exists pf.quotes (
	evts timestamptz not null,
	icode int2 not null,
	ask numeric not null,
	bid numeric not null,
	nch numeric not null,
	tick_cnt integer not null,
	extts timestamptz not null,
  insts timestamptz not null default now(),
  sid_run integer not null,
  cid_run integer not null
) with (
  tsdb.hypertable,
  tsdb.partition_column = 'evts',
  tsdb.chunk_interval='1 h',
  tsdb.segmentby = 'icode',
  tsdb.orderby = 'evts DESC',
  tsdb.enable_columnstore
);
grant select on pf.quotes to viewer;

create unlogged table if not exists pf.quotes_last (
	evts timestamptz not null,
	icode int2 not null,
	ask numeric not null,
	bid numeric not null,
	nch numeric not null,
	tick_cnt integer not null,
	extts timestamptz not null,
  insts timestamptz not null default now(),
  sid_run integer not null,
  cid_run integer not null,
  constraint quotes_last_pk primary key (icode)
) with (
  fillfactor = 70,
  autovacuum_vacuum_scale_factor = 0.05,
  autovacuum_vacuum_threshold = 50,
  autovacuum_vacuum_cost_delay = 2,
  autovacuum_vacuum_cost_limit = 1000
);
grant select on pf.quotes_last to viewer;

create table if not exists pf.bonds (
	evts timestamptz not null,
	icode int2 not null,
	ask_y numeric not null,
	bid_y numeric not null,
	nch numeric not null,
	tick_cnt integer not null,
	extts timestamptz not null,
  insts timestamptz not null default now(),
  sid_run integer not null,
  cid_run integer not null
) with (
  tsdb.hypertable,
  tsdb.partition_column = 'evts',
  tsdb.chunk_interval='1 h',
  tsdb.segmentby = 'icode',
  tsdb.orderby = 'evts DESC',
  tsdb.enable_columnstore
);
grant select on pf.bonds to viewer;

create unlogged table if not exists pf.bonds_last (
	evts timestamptz not null,
	icode int2 not null,
	ask_y numeric not null,
	bid_y numeric not null,
	nch numeric not null,
	tick_cnt integer not null,
	extts timestamptz not null,
  insts timestamptz not null default now(),
  sid_run integer not null,
  cid_run integer not null,
  constraint bonds_last_pk primary key (icode)
) with (
  fillfactor = 70,
  autovacuum_vacuum_scale_factor = 0.05,
  autovacuum_vacuum_threshold = 50,
  autovacuum_vacuum_cost_delay = 2,
  autovacuum_vacuum_cost_limit = 1000
);
grant select on pf.bonds_last to viewer;

create table if not exists pf.indices (
	evts timestamptz not null,
	icode int2 not null,
	lstpr numeric not null,
	nch numeric not null,
	tick_cnt integer not null,
	extts timestamptz not null,
  insts timestamptz not null default now(),
  sid_run integer not null,
  cid_run integer not null
) with (
  tsdb.hypertable,
  tsdb.partition_column = 'evts',
  tsdb.chunk_interval='1 h',
  tsdb.segmentby = 'icode',
  tsdb.orderby = 'evts DESC',
  tsdb.enable_columnstore
);
grant select on pf.indices to viewer;

create unlogged table if not exists pf.indices_last (
	evts timestamptz not null,
	icode int2 not null,
	lstpr numeric not null,
	nch numeric not null,
	tick_cnt integer not null,
	extts timestamptz not null,
  insts timestamptz not null default now(),
  sid_run integer not null,
  cid_run integer not null,
  constraint indices_last_pk primary key (icode)
) with (
  fillfactor = 70,
  autovacuum_vacuum_scale_factor = 0.05,
  autovacuum_vacuum_threshold = 50,
  autovacuum_vacuum_cost_delay = 2,
  autovacuum_vacuum_cost_limit = 1000
);
grant select on pf.indices_last to viewer;

create table if not exists pf.futures (
	evts timestamptz not null,
	icode int2 not null,
	lstpr numeric not null,
	nch numeric not null,
	tick_cnt integer not null,
	extts timestamptz not null,
  insts timestamptz not null default now(),
  sid_run integer not null,
  cid_run integer not null
) with (
  tsdb.hypertable,
  tsdb.partition_column = 'evts',
  tsdb.chunk_interval='1 h',
  tsdb.segmentby = 'icode',
  tsdb.orderby = 'evts DESC',
  tsdb.enable_columnstore
);
grant select on pf.futures to viewer;

create table if not exists pf.futures_last (
	evts timestamptz not null,
	icode int2 not null,
	lstpr numeric not null,
	nch numeric not null,
	tick_cnt integer not null,
	extts timestamptz not null,
  insts timestamptz not null default now(),
  sid_run integer not null,
  cid_run integer not null,
  constraint futures_last_pk primary key (icode)
) with (
  fillfactor = 70,
  autovacuum_vacuum_scale_factor = 0.05,
  autovacuum_vacuum_threshold = 50,
  autovacuum_vacuum_cost_delay = 2,
  autovacuum_vacuum_cost_limit = 1000
);
grant select on pf.futures_last to viewer;

\i /sql_scripts/init/01-01-pf-load_batch.txt


----------
-- data --
CREATE TEMP TABLE tmp_tickers(LIKE pf.tickers);

COPY tmp_tickers (icode, tick, scode, pf_category_ru, pf_category_en) FROM STDIN;
1	DJIA	DJIA	Фондовые индексы	Stock Indices
2	SPX	SP500	Фондовые индексы	Stock Indices
4	!NDX	NASD100	Фондовые индексы	Stock Indices
5	UKXe	FTSE100	Фондовые индексы	Stock Indices
6	DAXif	DAX	Фондовые индексы	Stock Indices
8	PZ1p	CAC40	Фондовые индексы	Stock Indices
10	RTSTr	RTST	Фондовые индексы	Stock Indices
11	USD_INDEX	USD_INDEX	Фондовые индексы	Stock Indices
20	gold	Gold	Товарные рынки	Commodities
21	silver	Silver	Товарные рынки	Commodities
22	platinum	Platinum	Товарные рынки	Commodities
23	palladium	Palladium	Товарные рынки	Commodities
24	aluminum	Aluminum	Товарные рынки	Commodities
25	copper	Copper	Товарные рынки	Commodities
26	nickel	Nickel	Товарные рынки	Commodities
27	brent	Brent oil	Товарные рынки	Commodities
28	wti	WTI oil	Товарные рынки	Commodities
29	USDRUB	USD/RUB	Курс рубля	Ruble Exchange Rate
30	EURRUB	EUR/RUB	Курс рубля	Ruble Exchange Rate
33	AUDJPY	AUD/JPY	Мировые валюты	World Currencies
34	AUDUSD	AUD/USD	Мировые валюты	World Currencies
35	CADJPY	CAD/JPY	Мировые валюты	World Currencies
36	CHFJPY	CHF/JPY	Мировые валюты	World Currencies
37	EURAUD	EUR/AUD	Мировые валюты	World Currencies
38	EURCAD	EUR/CAD	Мировые валюты	World Currencies
39	EURCHF	EUR/CHF	Мировые валюты	World Currencies
40	EURGBP	EUR/GBP	Мировые валюты	World Currencies
41	EURJPY	EUR/JPY	Мировые валюты	World Currencies
42	EURUSD	EUR/USD	Мировые валюты	World Currencies
43	GBPCHF	GBP/CHF	Мировые валюты	World Currencies
44	GBPJPY	GBP/JPY	Мировые валюты	World Currencies
45	GBPUSD	GBP/USD	Мировые валюты	World Currencies
46	USDCAD	USD/CAD	Мировые валюты	World Currencies
47	USDCHF	USD/CHF	Мировые валюты	World Currencies
48	USDJPY	USD/JPY	Мировые валюты	World Currencies
55	DJIA_FUT	DJIA_FUT	Фьючерсы на индексы	Index Futures
56	SP500_FUT	SP500_FUT	Фьючерсы на индексы	Index Futures
57	NASD100_FUT	NASD100_FUT	Фьючерсы на индексы	Index Futures
58	NIK225_FUT	NIK_FUT	Фьючерсы на индексы	Index Futures
379	USDUAH	USD/UAH	Валюты СНГ	CIS Currencies
380	USDKGS	USD/KGS	Валюты СНГ	CIS Currencies
381	USDTJS	USD/TJS	Валюты СНГ	CIS Currencies
382	USDUZS	USD/UZS	Валюты СНГ	CIS Currencies
391	USDKZT	USD/KZT	Валюты СНГ	CIS Currencies
392	XBTUSD	XBT/USD	Криптовалюты	Cryptocurrencies
393	USDCNY	USD/CNY	Мировые валюты	World Currencies
394	USDBRL	USD/BRL	Мировые валюты	World Currencies
395	USDMXN	USD/MXN	Мировые валюты	World Currencies
396	USDEGP	USD/EGP	Мировые валюты	World Currencies
397	USDTRY	USD/TRY	Мировые валюты	World Currencies
398	USDMDL	USD/MDL	Валюты СНГ	CIS Currencies
399	USDCZK	USD/CZK	Мировые валюты	World Currencies
400	USDZAR	USD/ZAR	Мировые валюты	World Currencies
401	USDPLN	USD/PLN	Мировые валюты	World Currencies
402	USDSEK	USD/SEK	Мировые валюты	World Currencies
403	USDDKK	USD/DKK	Мировые валюты	World Currencies
404	USDHKD	USD/HKD	Мировые валюты	World Currencies
405	USDSGD	USD/SGD	Мировые валюты	World Currencies
413	MMVBi	MMVB	Фондовые индексы	Stock Indices
415	DAX_FUT	DAX_FUT	Фьючерсы на индексы	Index Futures
416	GasUS	Gas US	Товарные рынки	Commodities
417	GasUK	Gas UK	Товарные рынки	Commodities
423	ETHUSD_BTFNX	ETH/USD	Криптовалюты	Cryptocurrencies
425	LTCUSD_BTFNX	LTC/USD	Криптовалюты	Cryptocurrencies
429	XRPUSD_BTFNX	XRP/USD	Криптовалюты	Cryptocurrencies
432	NZDUSD	NZD/USD	Мировые валюты	World Currencies
442	USDCNH	USD/CNH	Мировые валюты	World Currencies
448	USDINR	USD/INR	Мировые валюты	World Currencies
449	USDTHB	USD/THB	Мировые валюты	World Currencies
450	USDKRW	USD/KRW	Мировые валюты	World Currencies
453	USDBYN	USD/BYN	Валюты СНГ	CIS Currencies
454	USDTWD	USD/TWD	Мировые валюты	World Currencies
455	USDNOK	USD/NOK	Мировые валюты	World Currencies
460	Nikkei_225	Nikkei 225	Фондовые индексы	Stock Indices
461	ASX_200	ASX 200	Фондовые индексы	Stock Indices
462	CSI_300	CSI 300	Фондовые индексы	Stock Indices
464	gasoline	Gasoline	Товарные рынки	Commodities
466	USDGEL	USD/GEL	Валюты СНГ	CIS Currencies
468	USDIDR	USD/IDR	Мировые валюты	World Currencies
469	USDMYR	USD/MYR	Мировые валюты	World Currencies
476	USDAMD	USD/AMD	Валюты СНГ	CIS Currencies
506	EOSUSD_BTFNX	EOS/USD	Криптовалюты	Cryptocurrencies
508	GasEU	Gas EU	Товарные рынки	Commodities
509	TTFUSD1000	TTF USD1000	Товарные рынки	Commodities
526	GasoilEU	Gasoil EU	Товарные рынки	Commodities
528	US	US 10y	Облигации	Bonds
529	UK	UK 10y	Облигации	Bonds
530	Canada	Canada 10y	Облигации	Bonds
532	Germany	Germany 10y	Облигации	Bonds
533	India	India 10y	Облигации	Bonds
534	China	China 10y	Облигации	Bonds
535	Japan	Japan 10y	Облигации	Bonds
536	Australia	Australia 10y	Облигации	Bonds
538	CNYRUB	CNY/RUB	Курс рубля	Ruble Exchange Rate
\.

insert into pf.tickers
select * from tmp_tickers
on conflict do nothing;
