/
CREATE OR REPLACE TYPE MY_INT_ARR AS VARRAY(15) OF integer;
/
/
CREATE OR REPLACE TYPE MY_NUM_ARR IS VARRAY(15) OF number;
/
/
CREATE OR REPLACE TYPE MY_VARCHAR_ARR IS VARRAY(15) OF varchar(16);
/
/
CREATE OR REPLACE TYPE MY_TS_ARR IS VARRAY(15) OF TIMESTAMP;
/

/
create or replace package bmsql_type AS
TYPE MY_INT_TABLE IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
TYPE MY_ROWID_TABLE IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
END bmsql_type;
/

/
create or replace
PROCEDURE bmsql_func_neworder
(
    in_w_id IN integer,
    in_d_id IN integer,
    in_c_id IN integer,
    in_ol_cnt IN integer,
    in_o_all_local IN integer,
    in_ol_iid MY_INT_ARR,
    in_ol_supply_wid MY_INT_ARR,
    in_ol_quantity MY_INT_ARR
) as 
v_district_oid integer;
v_customer_discount decimal(4,4);
v_customer_last varchar(16);
v_customer_credit char(2);
v_warehouse_tax decimal(4,4);
v_item_name varchar(24);
v_item_price decimal(5,2);
v_item_data varchar(50);
v_stock_quantity integer;
v_stock_data varchar(50);
v_dist_1 char(24);
v_dist_2 char(24);
v_dist_3 char(24);
v_dist_4 char(24);
v_dist_5 char(24);
v_dist_6 char(24);
v_dist_7 char(24);
v_dist_8 char(24);
v_dist_9 char(24);
v_dist_10 char(24);
v_ol_amount decimal(6,2);
v_update_stock_3 integer;
BEGIN
SELECT d_next_o_id INTO v_district_oid
    FROM bmsql_district
    WHERE d_w_id = in_w_id AND d_id = in_d_id FOR UPDATE;
SELECT c_discount, c_last, c_credit, w_tax
    INTO v_customer_discount, v_customer_last, v_customer_credit, v_warehouse_tax
    FROM bmsql_customer JOIN bmsql_warehouse ON (w_id = c_w_id)
    WHERE c_w_id = in_w_id AND c_d_id = in_d_id AND c_id = in_c_id;
UPDATE bmsql_district
    SET d_next_o_id = d_next_o_id + 1
    WHERE d_w_id = in_w_id AND d_id = in_d_id;
INSERT INTO bmsql_oorder
    (o_id, o_d_id, o_w_id, o_c_id, o_entry_d, o_ol_cnt, o_all_local)
    VALUES
    (v_district_oid, in_d_id, in_w_id, in_c_id, CURRENT_TIMESTAMP, in_ol_cnt, in_o_all_local);
INSERT INTO bmsql_new_order
    (no_o_id, no_d_id, no_w_id)
    VALUES
    (v_district_oid, in_d_id, in_w_id);
FOR i IN 1..in_ol_cnt LOOP
    -- This could be empty (1%)
    SELECT i_price, i_name, i_data
        INTO v_item_price, v_item_name, v_item_data
        FROM bmsql_item WHERE i_id = in_ol_iid(i);
    SELECT s_quantity, s_dist_01, s_dist_02, s_dist_03, s_dist_04, s_dist_05, s_dist_06, s_dist_07, s_dist_08, s_dist_09, s_dist_10
        INTO v_stock_quantity, v_dist_1, v_dist_2, v_dist_3, v_dist_4, v_dist_5, v_dist_6, v_dist_7, v_dist_8, v_dist_9, v_dist_10
        FROM bmsql_stock
        WHERE s_w_id = in_ol_supply_wid(i) AND s_i_id = in_ol_iid(i)
        FOR UPDATE;
    CASE in_d_id
        WHEN 2 THEN v_dist_1 := v_dist_2;
        WHEN 3 THEN v_dist_1 := v_dist_3;
        WHEN 4 THEN v_dist_1 := v_dist_4;
        WHEN 5 THEN v_dist_1 := v_dist_5;
        WHEN 6 THEN v_dist_1 := v_dist_6;
        WHEN 7 THEN v_dist_1 := v_dist_7;
        WHEN 8 THEN v_dist_1 := v_dist_8;
        WHEN 9 THEN v_dist_1 := v_dist_9;
        WHEN 10 THEN v_dist_1 := v_dist_10;
        ELSE EXIT;
    END CASE;
    v_ol_amount := v_item_price * in_ol_quantity(i);
    IF v_stock_quantity >= in_ol_quantity(i) + 10 THEN
        v_stock_quantity := v_stock_quantity - in_ol_quantity(i);
    ELSE
        v_stock_quantity := v_stock_quantity + 91 - in_ol_quantity(i);
    END IF;
    IF in_ol_supply_wid(i) = in_w_id THEN
        v_update_stock_3 := 0;
    ELSE
        v_update_stock_3 := 1;
    END IF;
    UPDATE bmsql_stock
        SET s_quantity = v_stock_quantity,
        s_ytd = s_ytd + in_ol_quantity(i),
        s_order_cnt = s_order_cnt + 1,
        s_remote_cnt = s_remote_cnt + v_update_stock_3
        WHERE s_w_id = in_ol_supply_wid(i) AND s_i_id = in_ol_iid(i);
    INSERT INTO bmsql_order_line
        (ol_o_id, ol_d_id, ol_w_id, ol_number, ol_i_id, ol_supply_w_id, ol_quantity, ol_amount, ol_dist_info)
        VALUES
        (v_district_oid, in_d_id, in_w_id, i, in_ol_iid(i), in_ol_supply_wid(i), in_ol_quantity(i), v_ol_amount, v_dist_1);
END LOOP;
COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    ROLLBACK;
END bmsql_func_neworder;
/

/
create or replace
PROCEDURE bmsql_func_payment
(
    in_w_id IN integer,
    in_d_id IN integer,
    in_c_w_id IN integer,
    in_c_d_id IN integer,
    in_h_amount IN decimal,
    in_c_id IN integer,
    in_c_last IN varchar
) as
v_c_id integer := in_c_id;
v_d_name varchar(10);
v_w_name varchar(10);
v_c_data varchar(500);
v_c_credit char(2);
v_rowid ROWID;
BEGIN
UPDATE bmsql_district SET d_ytd = d_ytd + in_h_amount
    WHERE d_w_id = in_w_id AND d_id = in_d_id;
SELECT d_name INTO v_d_name
    FROM bmsql_district
    WHERE d_w_id = in_w_id AND d_id = in_d_id;
UPDATE bmsql_warehouse SET w_ytd = w_ytd + in_h_amount
    WHERE w_id = in_w_id;
SELECT w_name INTO v_w_name
    FROM bmsql_warehouse
    WHERE w_id = in_w_id;

if in_c_last IS NOT NULL THEN
    bmsql_func_rowid_from_clast(in_w_id, in_d_id, in_c_last, v_rowid);
    SELECT c_credit, c_id INTO v_c_credit, v_c_id
        FROM bmsql_customer WHERE rowid = v_rowid;
ELSE
    SELECT c_credit INTO v_c_credit
        FROM bmsql_customer
        WHERE c_w_id = in_c_w_id AND c_d_id = in_c_d_id AND c_id = v_c_id;
END IF;

-- v_c_balance = v_c_balance - in_h_amount;
IF v_c_credit = 'GC' THEN
    UPDATE bmsql_customer
        SET c_balance = c_balance - in_h_amount,
        c_ytd_payment = c_ytd_payment + in_h_amount,
        c_payment_cnt = c_payment_cnt + 1
        WHERE c_w_id = in_c_w_id AND c_d_id = in_c_d_id AND c_id = v_c_id;
ELSE
    SELECT c_data INTO v_c_data
        FROM bmsql_customer
        WHERE c_w_id = in_c_w_id AND c_d_id = in_c_d_id AND c_id = v_c_id;
-- omit c_data extension
    UPDATE bmsql_customer
        SET c_balance = c_balance - in_h_amount,
        c_ytd_payment = c_ytd_payment + in_h_amount,
        c_payment_cnt = c_payment_cnt + 1,
        c_data = v_c_data
        WHERE c_w_id = in_c_w_id AND c_d_id = in_c_d_id AND c_id = v_c_id;
    INSERT INTO bmsql_history
        (h_c_id, h_c_d_id, h_c_w_id, h_d_id, h_w_id, h_date, h_amount, h_data)
        VALUES
        (v_c_id, in_c_d_id, in_c_w_id, in_d_id, in_w_id, CURRENT_TIMESTAMP, in_h_amount, CONCAT(v_w_name, v_d_name));
END IF;
COMMIT;
END bmsql_func_payment;
/

/
create or replace
PROCEDURE bmsql_func_deliverybg
(
    in_w_id IN integer,
    in_o_carrier_id IN integer
) as
-- CURSOR SelectOldestNewOrder is SELECT no_o_id FROM bmsql_new_order WHERE no_w_id = in_w_id AND no_d_id = i_d_id ORDER BY no_o_id ASC;
v_o_id integer;
v_c_id integer;
v_sum_ol_amount decimal;
BEGIN
FOR i_d_id IN 1..10 LOOP
    v_o_id := -1;
    WHILE v_o_id < 0 LOOP
        -- FETCH SelectOldestNewOrder INTO v_o_id;
        -- EXIT WHEN SelectOldestNewOrder%NOTFOUND;
        -- SELECT no_o_id INTO v_o_id FROM bmsql_new_order WHERE no_w_id = in_w_id AND no_d_id = i_d_id ORDER BY no_o_id ASC;
        -- EXIT WHEN sql%NOTFOUND;
        SELECT NVL(no_o_id, v_o_id) INTO v_o_id
            FROM
            (SELECT no_o_id FROM bmsql_new_order
                WHERE no_w_id = in_w_id AND no_d_id = i_d_id
                ORDER BY no_o_id ASC);
        DELETE FROM bmsql_new_order
            WHERE no_w_id = in_w_id AND no_d_id = i_d_id AND no_o_id = v_o_id;
        IF sql%rowcount = 0 THEN
            v_o_id := -1;
        END IF;
    END LOOP;
    if v_o_id < 0 THEN
        CONTINUE;
    END IF;
    UPDATE bmsql_oorder SET o_carrier_id = in_o_carrier_id
        WHERE o_w_id = in_w_id AND o_d_id = i_d_id AND o_id = v_o_id;
    SELECT o_c_id INTO v_c_id FROM bmsql_oorder
        WHERE o_w_id = in_w_id AND o_d_id = i_d_id AND o_id = v_o_id;
    UPDATE bmsql_order_line SET ol_delivery_d = CURRENT_TIMESTAMP
        WHERE ol_w_id = in_w_id AND ol_d_id = i_d_id AND ol_o_id = v_o_id;
    SELECT sum(ol_amount) INTO v_sum_ol_amount
        FROM bmsql_order_line
        WHERE ol_w_id = in_w_id AND ol_d_id = i_d_id AND ol_o_id = v_o_id;
    UPDATE bmsql_customer
        SET c_balance = c_balance + v_sum_ol_amount,
        c_delivery_cnt = c_delivery_cnt + 1
        WHERE c_w_id = in_w_id AND c_d_id = i_d_id AND c_id = v_c_id;
END LOOP;
COMMIT;
END bmsql_func_deliverybg;
/

/
create or replace
PROCEDURE bmsql_func_stocklevel
(
    in_w_id IN integer,
    in_d_id IN integer,
    in_threshold IN integer
) AS
result integer;
BEGIN
SELECT count(1) INTO result FROM (
    SELECT s_w_id, s_i_id, s_quantity
        FROM bmsql_stock
        WHERE s_w_id = in_w_id AND s_quantity < in_threshold AND s_i_id IN (
            SELECT ol_i_id
                FROM bmsql_district
                JOIN bmsql_order_line ON ol_w_id = d_w_id
                AND ol_d_id = d_id
                AND ol_o_id >= d_next_o_id - 20
                AND ol_o_id < d_next_o_id
                WHERE d_w_id = in_w_id AND d_id = in_d_id
        )
);
COMMIT;
END bmsql_func_stocklevel;
/

/
create or replace
PROCEDURE bmsql_func_rowid_from_clast
(
    in_w_id IN integer,
    in_d_id IN integer,
    in_c_last IN varchar,
    out_rowid OUT rowid
) AS
v_rowid_list bmsql_type.MY_ROWID_TABLE;
BEGIN
SELECT rowid BULK COLLECT INTO v_rowid_list FROM bmsql_customer
    WHERE c_w_id = in_w_id AND c_d_id = in_d_id AND c_last = in_c_last
    ORDER BY c_first;
out_rowid := v_rowid_list((SQL%ROWCOUNT + 1 )/ 2);
END bmsql_func_rowid_from_clast;
/

/
create or replace
PROCEDURE bmsql_func_orderstatus
(
in_w_id IN integer,
in_d_id IN integer,
in_c_last IN varchar,
in_c_id IN OUT integer
) AS
v_rowid ROWID;
v_c_first varchar(16);
v_c_middle char(2);
v_c_last varchar(16);
v_c_balance number;
v_o_id integer;
v_o_entry_d TIMESTAMP;
v_o_carrier_id integer;
v_ol_idx integer := 1;
CURSOR cursor IS
	SELECT ol_i_id, ol_supply_w_id, ol_quantity, ol_amount, ol_delivery_d
	FROM bmsql_order_line
    WHERE ol_w_id = in_w_id AND ol_d_id = in_d_id
	AND ol_o_id = v_o_id
    ORDER BY ol_w_id, ol_d_id, ol_o_id, ol_number;
v_order_line cursor%rowtype;
out_ol_supply_w_id MY_INT_ARR := MY_INT_ARR();
out_ol_i_id MY_INT_ARR := MY_INT_ARR();
out_ol_quantity MY_INT_ARR := MY_INT_ARR();
out_ol_amount MY_NUM_ARR := MY_NUM_ARR();
out_ol_delivery_d MY_VARCHAR_ARR := MY_VARCHAR_ARR();
v_ol_delivery_d MY_TS_ARR := MY_TS_ARR();
BEGIN
out_ol_supply_w_id.EXTEND(15);
out_ol_i_id.EXTEND(15);
out_ol_quantity.EXTEND(15);
out_ol_amount.EXTEND(15);
out_ol_delivery_d.EXTEND(15);
v_ol_delivery_d.EXTEND(15);

-- if c_last != null
if in_c_last IS NOT NULL THEN
    bmsql_func_rowid_from_clast(in_w_id, in_d_id, in_c_last, v_rowid);
    SELECT c_first, c_middle, c_balance, c_id
        INTO v_c_first, v_c_middle, v_c_balance, in_c_id
        FROM bmsql_customer
        WHERE rowid = v_rowid;
ELSE
    SELECT c_first, c_middle, c_last, c_balance
        INTO v_c_first, v_c_middle, v_c_last, v_c_balance
        FROM bmsql_customer
        WHERE c_w_id = in_w_id AND c_d_id = in_d_id AND c_id = in_c_id;
END IF;

SELECT o_id, o_entry_d, o_carrier_id
    INTO v_o_id, v_o_entry_d, v_o_carrier_id
    FROM bmsql_oorder
    WHERE o_w_id = in_w_id AND o_d_id = in_d_id AND o_c_id = in_c_id
    AND o_id = (
        SELECT max(o_id) FROM bmsql_oorder
            WHERE o_w_id = in_w_id AND o_d_id = in_d_id AND o_c_id = in_c_id
    );

OPEN cursor;
FETCH cursor INTO v_order_line;

WHILE cursor%found LOOP
    out_ol_i_id(v_ol_idx) := v_order_line.ol_i_id;
    out_ol_supply_w_id(v_ol_idx) := v_order_line.ol_supply_w_id;
    out_ol_quantity(v_ol_idx) := v_order_line.ol_quantity;
    out_ol_amount(v_ol_idx) := v_order_line.ol_amount;
    v_ol_delivery_d(v_ol_idx) := v_order_line.ol_delivery_d;
    v_ol_idx := v_ol_idx + 1;
    FETCH cursor INTO v_order_line;
END LOOP;

CLOSE cursor;

WHILE v_ol_idx < 16 LOOP
    out_ol_i_id (v_ol_idx) := 0;
    out_ol_supply_w_id(v_ol_idx) := 0;
    out_ol_quantity(v_ol_idx) := 0;
    out_ol_amount(v_ol_idx) := 0.0;
    v_ol_delivery_d(v_ol_idx) := NULL;
    v_ol_idx := v_ol_idx + 1;
END LOOP;

FOR v_cnt IN 1..15 LOOP
    out_ol_delivery_d(v_cnt) := TO_CHAR(v_ol_delivery_d(v_cnt), 'YYYY-MM-DD');
END LOOP;

COMMIT;
END bmsql_func_orderstatus;
/