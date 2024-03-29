# Проект 1

## 1.1. Требования к витрине

- назначение витрины: RFM-классификации пользователей приложения.
  * Recency - время от последнего заказа (не делал заказов = очень давно)
  * Frequency - кол-во заказов
  * Monetary - суммарные траты
- расположение: в той же базе в схеме analysis
- название: dm_rfm_segments
- структура витрины:
  * user_id
  * recency (число от 1 до 5)
  * frequency (число от 1 до 5)
  * monetary_value (число от 1 до 5)
- глубина: с начала 2021 года
- обновляемая: нет
- успешно выполненный заказ: статус Closed
- учитывать ли тех, кто вообще не делал заказы: да (следует из описания проекта,раздел "Как провести RFM-сегментацию")

## 1.2. Источники данных

Требуется сделать представление analysis.orders от таблиц в схеме production.

Необходимы такие поля в источниках:

* production.users:
  * id (int4)
* production.orders:
  * order_id (int4),
  * user_id (int4),
  * order_ts (timestamp),
  * cost (numeric(19,5)),
  * status (int4)
* production.orderstatuses:
  * id (int4),
  * key (varchar(255))

## 1.3. Качество исходных данных

* все таблицы имеют PK (orderstatuses.id, orders.order_id, users.id), соотв. дублей не будет

* production.orders имеет constraint orders_check CHECK ((cost = (payment + bonus_payment))), соотв. смело используем поле cost в качестве стоимости заказа

* заказы с нолевой стоимостью:

```
select count(*) from production.orders where cost <= 0;

-- 0 штук
```

Но это неважно, так как мы учитываем даже тех, кто не делал заказов вовсе.

* Типы у всех полей подходящие
  * ссылочные поля - int4, соответствуют по типу PK-полям.
  * Цена - numeric(19,5).
  * Дата заказа - timestamp.

## 1.4. Подготовка витрины

* Делаем представление analysis.orders

```
/src/orders.ddl.sql
```

* Создаём таблицу analysis.dm_rfm_segments

```
/src/dm_rfm_segments.ddl.sql
```

* Заполняем analysis.dm_rfm_segments

```
/src/dm_rfm_segments.dml.sql
```

* Проверяем распределения по сегментам запросами

```
SELECT recency, COUNT(*) FROM analysis.dm_rfm_segments GROUP BY recency;
SELECT frequency, COUNT(*) FROM analysis.dm_rfm_segments GROUP BY frequency;
SELECT monetary_value, COUNT(*) FROM analysis.dm_rfm_segments GROUP BY monetary_value;
```

## 2. Если нельзя учитывать поле production.order.status

То представление перестраиваем через production.orderstatuslog запросом из

```
/src/orders2.ddl.sql
```