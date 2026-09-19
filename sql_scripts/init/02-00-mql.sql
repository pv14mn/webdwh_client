create schema if not exists mql authorization webdwh;
grant usage on schema mql to viewer;

set role webdwh;

create table if not exists mql.tickers(
	icode integer not null,
	scode varchar(6) not null,
  c1 varchar(2) not null,
  c2 varchar(2) not null,
	description varchar(64) not null,
	constraint tickers_pk primary key (icode),
	constraint tickers_scode_unique unique (scode)
);
grant select on mql.tickers to viewer;

create table if not exists mql.quotes(
	evts timestamptz not null,
	icode integer not null,
	ask numeric not null,
	bid numeric not null,
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
grant select on mql.quotes to viewer;

create unlogged table if not exists mql.quotes_last(
	evts timestamptz not null,
	icode integer not null,
	ask numeric not null,
	bid numeric not null,
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
grant select on mql.quotes_last to viewer;

\i /sql_scripts/init/02-01-mql-load_dict.txt
\i /sql_scripts/init/02-02-mql-load_fact.txt

CREATE TEMP TABLE tmp_tickers(LIKE mql.tickers);
COPY tmp_tickers (icode, scode, c1, c2, description) FROM STDIN;
2	GBPUSD	gb	us	Фунт стерлингов / Доллар США
3	USDCHF	us	ch	Доллар США / Швейцарский франк
4	USDJPY	us	jp	Доллар США / Японская иена
5	USDCAD	us	ca	Доллар США / Канадский доллар
6	AUDUSD	au	us	Австралийский доллар / Доллар США
7	AUDNZD	au	nz	Австралийский доллар / Новозеландский доллар
8	AUDCAD	au	ca	Австралийский доллар / Канадский доллар
9	AUDCHF	au	ch	Австралийский доллар / Швейцарский франк
10	AUDJPY	au	jp	Австралийский доллар / Японская иена
11	CHFJPY	ch	jp	Швейцарский франк / Японская иена
12	EURGBP	eu	gb	Евро / Фунт стерлингов
13	EURAUD	eu	au	Евро / Австралийский доллар
14	EURCHF	eu	ch	Евро / Швейцарский франк
15	EURJPY	eu	jp	Евро / Японская иена
16	EURNZD	eu	nz	Евро / Новозеландский доллар
17	EURCAD	eu	ca	Евро / Канадский доллар
18	GBPCHF	gb	ch	Фунт стерлингов / Швейцарский франк
19	GBPJPY	gb	jp	Фунт стерлингов / Японская иена
20	CADCHF	ca	ch	Канадский доллар / Швейцарский франк
313	NZDUSD	nz	us	Новозеландский доллар / Доллар США
318	USDSEK	us	se	Доллар США / Шведская крона
377	USDHKD	us	hk	Доллар США / Гонконгский доллар
378	EURHKD	eu	hk	Евро / Гонконгский доллар
379	USDMXN	us	mx	Доллар США / Мексиканское песо
380	USDZAR	us	za	Доллар США / Южноафриканский рэнд
508	EURTRY	eu	tr	Евро / Турецкая лира
509	USDTRY	us	tr	Доллар США / Турецкая лира
552	NZDCAD	nz	ca	Новозеландский доллар / Канадский доллар
553	NZDCHF	nz	ch	Новозеландский доллар / Швейцарский франк
554	NZDJPY	nz	jp	Новозеландский доллар / Японская иена
555	NZDSGD	nz	sg	Новозеландский доллар / Сингапурский доллар
556	SGDJPY	sg	jp	Сингапурский доллар / Японская иена
1495	CADJPY	ca	jp	Канадский доллар / Японская иена
1496	USDDKK	us	dk	Доллар США / Датская крона
1497	USDNOK	us	no	Доллар США / Норвежская крона
1498	GBPNZD	gb	nz	Фунт стерлингов / Новозеландский доллар
1499	USDSGD	us	sg	Доллар США / Сингапурский доллар
1500	GBPAUD	gb	au	Фунт стерлингов / Австралийский доллар
1501	GBPCAD	gb	ca	Фунт стерлингов / Канадский доллар
1502	EURSEK	eu	se	Евро / Шведская крона
1503	GBPSEK	gb	se	Фунт стерлингов / Шведская крона
1504	GBPSGD	gb	sg	Фунт стерлингов / Сингапурский доллар
1505	USDHUF	us	hu	Доллар США / Венгерский форинт
1506	EURHUF	eu	hu	Евро / Венгерский форинт
1507	USDPLN	us	pl	Доллар США / Польский злотый
1508	USDCZK	us	cz	Доллар США / Чешская крона
1509	EURPLN	eu	pl	Евро / Польский злотый
1510	GBPPLN	gb	pl	Фунт стерлингов / Польский злотый
1511	EURNOK	eu	no	Евро / Норвежская крона
1512	EURMXN	eu	mx	Евро / Мексиканское песо
1513	EURCZK	eu	cz	Евро / Чешская крона
1752	EURDKK	eu	dk	Евро / Датская крона
1753	EURZAR	eu	za	Евро / Южноафриканский рэнд
1754	GBPNOK	gb	no	Фунт стерлингов / Норвежская крона
1755	GBPZAR	gb	za	Фунт стерлингов / Южноафриканский рэнд
1756	USDCNH	us	cn	Доллар США / китайский офшорный юань
1893	EURRUB	eu	ru	Евро / Российский рубль
1894	USDRUB	us	ru	Доллар США / Российский рубль
4252	EURUSD	eu	us	Евро / Доллар США
21411	GBPMXN	gb	mx	Фунт стерлингов / Мексиканское песо
21412	CADMXN	ca	mx	Canadian Dollar vs Mexican Peso
21414	MXNJPY	mx	jp	Мексиканское песо / Японская иена
21416	USDCOP	us	co	US Dollar vs Colombian Peso
21418	USDCLP	us	cl	US Dollar vs Chilean Peso
67216	AUDSEK	au	se	Австралийский доллар / Шведская крона
67217	EURSGD	eu	sg	Евро / Сингапурский доллар
67218	GBPCZK	gb	cz	Фунт стерлингов / Чешская крона
67219	GBPDKK	gb	dk	Фунт стерлингов / Датская крона
67220	GBPHUF	gb	hu	Фунт стерлингов / Венгерский форинт
67221	GBPTRY	gb	tr	Фунт стерлингов / Турецкая лира
67222	NOKSEK	no	se	Норвежская крона / Шведская крона
67223	USDILS	us	il	Доллар США / Новый израильский шекель
67224	ZARJPY	za	jp	Южноафриканский рэнд / Японская иена
67225	AUDDKK	au	dk	Australian Dollar vs Danish Krona
67226	AUDNOK	au	no	Australian Dollar vs Norwegian Krona
67227	AUDPLN	au	pl	Australian Dollar vs Zloty
67228	AUDSGD	au	sg	Австралийский доллар / Сингапурский доллар
67230	CADNOK	ca	no	Canadian Dollar vs Norwegian Krona
67232	CHFDKK	ch	dk	Швейцарский франк / Датская крона
67233	CHFNOK	ch	no	Швейцарский франк / Норвежская крона
67234	CHFPLN	ch	pl	Швейцарский франк / Польский злотый
67235	CHFSEK	ch	se	Швейцарский франк / Шведская крона
67236	CHFSGD	ch	sg	Швейцарский франк / Сингапурский доллар
67238	CHFZAR	ch	za	Swiss Franc vs South African Rand
67240	HKDJPY	hk	jp	Гонконгский доллар / Японская иена
67242	NOKJPY	no	jp	Норвежская крона / Японская иена
67243	NZDDKK	nz	dk	Новозеландский доллар / Датская крона
67245	NZDSEK	nz	se	Новозеландский доллар / Шведская крона
67246	PLNJPY	pl	jp	Zloty vs Japanese Yen
67247	SEKJPY	se	jp	Шведская крона / Японская иена
67248	SGDHKD	sg	hk	Сингапурский доллар / Гонконгский доллар
67249	TRYJPY	tr	jp	Турецкая лира / Японская иена
67250	USDTHB	us	th	Доллар США / Тайский бат
67251	USDRMB	us	cn	Доллар США / Китайский юань
67252	AUDHUF	au	hu	Australian Dollar vs Hungarian Florint
67253	CHFHUF	ch	hu	Швейцарский франк / Венгерский форинт
67254	EURILS	eu	il	Euro vs Israeli Shekel
67255	NZDHUF	nz	hu	New Zealand Dollar vs Hungarian Florint
67256	AUDHKD	au	hk	Australian Dollar vs Hong Kong Dollar
67258	CADSGD	ca	sg	Канадский доллар / Сингапурский доллар
67259	DKKSEK	dk	se	Датская крона / Шведская крона
67263	CNHJPY	cn	jp	Chinese Yuan Renminbi vs Japanese Yen
67265	EURCNH	eu	cn	Евро / китайский офшорный юань
67266	GBPHKD	gb	hk	Фунт стерлингов / Гонконгский доллар
68097	USDBRL	us	br	US Dollar vs Brazilian Real
89843	USDKRW	us	kr	US Dollar vs South korean won
89844	USDINR	us	in	US Dollar vs Indian Rupee
89847	USDNGN	us	ng	US Dollar vs Nigerian Naira
89848	USDIDR	us	id	US Dollar vs Indonesian Rupiah
\.

insert into mql.tickers
select * from tmp_tickers
on conflict do nothing;
