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
CREATE OR REPLACE TYPE MY_CHAR_ARR IS VARRAY(15) OF CHAR(24);
/
/
create or replace package bmsql_type AS
TYPE MY_INT_TABLE IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
TYPE MY_ROWID_TABLE IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE MY_NUM_TABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE MY_CHAR_TABLE IS TABLE OF CHAR(24) INDEX BY BINARY_INTEGER;
idx_heler MY_INT_ARR := MY_INT_ARR(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);
END bmsql_type;
/

/
CREATE OR REPLACE VIEW bmsql_stock_item
(i_id, s_w_id, i_price, i_name, i_data, s_data, s_quantity,
 s_order_cnt, s_ytd, s_remote_cnt,
 s_dist_01, s_dist_02, s_dist_03, s_dist_04, s_dist_05,
 s_dist_06, s_dist_07, s_dist_08, s_dist_09, s_dist_10)
AS
SELECT i.i_id, s_w_id, i.i_price, i.i_name, i.i_data,
s_data, s_quantity, s_order_cnt, s_ytd, s_remote_cnt,
s_dist_01, s_dist_02, s_dist_03, s_dist_04, s_dist_05,
s_dist_06, s_dist_07, s_dist_08, s_dist_09, s_dist_10
FROM bmsql_stock s, bmsql_item i WHERE i.i_id = s.s_i_id;
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
v_dist bmsql_type.MY_CHAR_TABLE; -- must be table
v_ol_amount bmsql_type.MY_NUM_TABLE;
idx PLS_INTEGER;
dummy_local PLS_INTEGER := in_d_id;
cache_ol_cnt PLS_INTEGER := in_ol_cnt;

PROCEDURE u1 IS
BEGIN
    FORALL idx IN 1..cache_ol_cnt
        UPDATE bmsql_stock_item
        SET s_order_cnt = s_order_cnt + 1,
        s_ytd = s_ytd + in_ol_quantity(idx),
        s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                       THEN 0 ELSE 1 END),
        s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                      THEN s_quantity + 91
                      ELSE s_quantity
                      END) - in_ol_quantity(idx)
        WHERE i_id = in_ol_iid(idx)
        AND s_w_id = in_ol_supply_wid(idx)
        RETURNING s_dist_01, i_price * in_ol_quantity(idx)
    BULK COLLECT INTO v_dist, v_ol_amount;
END u1;

PROCEDURE u2 IS
BEGIN
    FORALL idx IN 1..cache_ol_cnt
        UPDATE bmsql_stock_item
        SET s_order_cnt = s_order_cnt + 1,
        s_ytd = s_ytd + in_ol_quantity(idx),
        s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                       THEN 0 ELSE 1 END),
        s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                      THEN s_quantity + 91
                      ELSE s_quantity
                      END) - in_ol_quantity(idx)
        WHERE i_id = in_ol_iid(idx)
        AND s_w_id = in_ol_supply_wid(idx)
        RETURNING s_dist_02, i_price * in_ol_quantity(idx)
    BULK COLLECT INTO v_dist, v_ol_amount;
END u2;

PROCEDURE u3 IS
BEGIN
    FORALL idx IN 1..cache_ol_cnt
        UPDATE bmsql_stock_item
        SET s_order_cnt = s_order_cnt + 1,
        s_ytd = s_ytd + in_ol_quantity(idx),
        s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                       THEN 0 ELSE 1 END),
        s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                      THEN s_quantity + 91
                      ELSE s_quantity
                      END) - in_ol_quantity(idx)
        WHERE i_id = in_ol_iid(idx)
        AND s_w_id = in_ol_supply_wid(idx)
        RETURNING s_dist_03, i_price * in_ol_quantity(idx)
    BULK COLLECT INTO v_dist, v_ol_amount;
END u3;

PROCEDURE u4 IS
BEGIN
    FORALL idx IN 1..cache_ol_cnt
        UPDATE bmsql_stock_item
        SET s_order_cnt = s_order_cnt + 1,
        s_ytd = s_ytd + in_ol_quantity(idx),
        s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                       THEN 0 ELSE 1 END),
        s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                      THEN s_quantity + 91
                      ELSE s_quantity
                      END) - in_ol_quantity(idx)
        WHERE i_id = in_ol_iid(idx)
        AND s_w_id = in_ol_supply_wid(idx)
        RETURNING s_dist_04, i_price * in_ol_quantity(idx)
    BULK COLLECT INTO v_dist, v_ol_amount;
END u4;

PROCEDURE u5 IS
BEGIN
    FORALL idx IN 1..cache_ol_cnt
        UPDATE bmsql_stock_item
        SET s_order_cnt = s_order_cnt + 1,
        s_ytd = s_ytd + in_ol_quantity(idx),
        s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                       THEN 0 ELSE 1 END),
        s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                      THEN s_quantity + 91
                      ELSE s_quantity
                      END) - in_ol_quantity(idx)
        WHERE i_id = in_ol_iid(idx)
        AND s_w_id = in_ol_supply_wid(idx)
        RETURNING s_dist_05, i_price * in_ol_quantity(idx)
    BULK COLLECT INTO v_dist, v_ol_amount;
END u5;

PROCEDURE u6 IS
BEGIN
    FORALL idx IN 1..cache_ol_cnt
        UPDATE bmsql_stock_item
        SET s_order_cnt = s_order_cnt + 1,
        s_ytd = s_ytd + in_ol_quantity(idx),
        s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                       THEN 0 ELSE 1 END),
        s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                      THEN s_quantity + 91
                      ELSE s_quantity
                      END) - in_ol_quantity(idx)
        WHERE i_id = in_ol_iid(idx)
        AND s_w_id = in_ol_supply_wid(idx)
        RETURNING s_dist_06, i_price * in_ol_quantity(idx)
    BULK COLLECT INTO v_dist, v_ol_amount;
END u6;

PROCEDURE u7 IS
BEGIN
    FORALL idx IN 1..cache_ol_cnt
        UPDATE bmsql_stock_item
        SET s_order_cnt = s_order_cnt + 1,
        s_ytd = s_ytd + in_ol_quantity(idx),
        s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                       THEN 0 ELSE 1 END),
        s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                      THEN s_quantity + 91
                      ELSE s_quantity
                      END) - in_ol_quantity(idx)
        WHERE i_id = in_ol_iid(idx)
        AND s_w_id = in_ol_supply_wid(idx)
        RETURNING s_dist_07, i_price * in_ol_quantity(idx)
    BULK COLLECT INTO v_dist, v_ol_amount;
END u7;

PROCEDURE u8 IS
BEGIN
    FORALL idx IN 1..cache_ol_cnt
        UPDATE bmsql_stock_item
        SET s_order_cnt = s_order_cnt + 1,
        s_ytd = s_ytd + in_ol_quantity(idx),
        s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                       THEN 0 ELSE 1 END),
        s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                      THEN s_quantity + 91
                      ELSE s_quantity
                      END) - in_ol_quantity(idx)
        WHERE i_id = in_ol_iid(idx)
        AND s_w_id = in_ol_supply_wid(idx)
        RETURNING s_dist_08, i_price * in_ol_quantity(idx)
    BULK COLLECT INTO v_dist, v_ol_amount;
END u8;

PROCEDURE u9 IS
BEGIN
    FORALL idx IN 1..cache_ol_cnt
        UPDATE bmsql_stock_item
        SET s_order_cnt = s_order_cnt + 1,
        s_ytd = s_ytd + in_ol_quantity(idx),
        s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                       THEN 0 ELSE 1 END),
        s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                      THEN s_quantity + 91
                      ELSE s_quantity
                      END) - in_ol_quantity(idx)
        WHERE i_id = in_ol_iid(idx)
        AND s_w_id = in_ol_supply_wid(idx)
        RETURNING s_dist_09, i_price * in_ol_quantity(idx)
    BULK COLLECT INTO v_dist, v_ol_amount;
END u9;

PROCEDURE u10 IS
BEGIN
    FORALL idx IN 1..cache_ol_cnt
        UPDATE bmsql_stock_item
        SET s_order_cnt = s_order_cnt + 1,
        s_ytd = s_ytd + in_ol_quantity(idx),
        s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                       THEN 0 ELSE 1 END),
        s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                      THEN s_quantity + 91
                      ELSE s_quantity
                      END) - in_ol_quantity(idx)
        WHERE i_id = in_ol_iid(idx)
        AND s_w_id = in_ol_supply_wid(idx)
        RETURNING s_dist_10, i_price * in_ol_quantity(idx)
    BULK COLLECT INTO v_dist, v_ol_amount;
END u10;

PROCEDURE fix_item IS
rows_lost PLS_INTEGER;
max_index PLS_INTEGER;
temp_index PLS_INTEGER;
BEGIN
idx := 1;
rows_lost := 0;
max_index := dummy_local;
WHILE (max_index != cache_ol_cnt) LOOP
    WHILE (idx <= sql%rowcount AND sql%bulk_rowcount(idx+rows_lost) = 1) LOOP
        idx := idx + 1;
    END LOOP;
    temp_index := max_index;
    WHILE (temp_index >= idx + rows_lost) LOOP
        v_ol_amount(temp_index + 1) := v_ol_amount(temp_index);
        v_dist(temp_index + 1) := v_dist(temp_index);
        temp_index := temp_index - 1;
    END LOOP;
    IF (idx + rows_lost <= cache_ol_cnt) THEN
        v_ol_amount(idx + rows_lost) := 0;
        v_dist(idx + rows_lost) := NULL;
        rows_lost := rows_lost + 1;
        max_index := max_index + 1;
    END IF;
END LOOP;
END fix_item;

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
    (v_district_oid, in_d_id, in_w_id, in_c_id, CURRENT_TIMESTAMP, cache_ol_cnt, in_o_all_local);
INSERT INTO bmsql_new_order
    (no_o_id, no_d_id, no_w_id)
    VALUES
    (v_district_oid, in_d_id, in_w_id);

IF (dummy_local < 6) THEN
    IF (dummy_local < 3) THEN
        IF (dummy_local = 1) THEN u1;
        ELSE u2; END IF;
    ELSE
        IF (dummy_local = 3) THEN u3;
        ELSIF (dummy_local = 4) THEN u4;
        ELSE u5; END IF;
    END IF;
ELSE
    IF (dummy_local < 8) THEN
        IF (dummy_local = 6) THEN u6;
        ELSE u7; END IF;
    ELSE
        IF (dummy_local = 8) THEN u8;
        ELSIF (dummy_local = 9) THEN u9;
        ELSE u10; END IF;
    END IF;
END IF;
dummy_local := sql%rowcount;
IF (dummy_local != cache_ol_cnt) THEN
    fix_item;
END IF;
FORALL idx IN 1..dummy_local
    INSERT INTO bmsql_order_line (ol_o_id, ol_d_id, ol_w_id, ol_number,
                        ol_i_id, ol_supply_w_id, ol_quantity, ol_amount, ol_dist_info)
    VALUES (v_district_oid, in_d_id, in_w_id, bmsql_type.idx_heler(idx),
            in_ol_iid(idx), in_ol_supply_wid(idx), in_ol_quantity(idx), v_ol_amount(idx),
            v_dist(idx));

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
v_order_id bmsql_type.MY_INT_TABLE;
v_d_id bmsql_type.MY_INT_TABLE;
v_ordcnt PLS_INTEGER;
v_o_c_id bmsql_type.MY_INT_TABLE;
v_sums bmsql_type.MY_NUM_TABLE;
BEGIN

FORALL d IN 1..10
    DELETE FROM bmsql_new_order N
        WHERE no_d_id = bmsql_type.idx_heler(d)
        AND no_w_id = in_w_id AND no_o_id = (
            SELECT min(no_o_id) FROM bmsql_new_order
                WHERE no_d_id = N.no_d_id
                AND no_w_id = N.no_w_id)
        RETURNING no_d_id, no_o_id BULK COLLECT INTO v_d_id, v_order_id;
v_ordcnt := sql%rowcount;
FORALL o in 1..v_ordcnt
    UPDATE bmsql_oorder SET o_carrier_id = in_o_carrier_id
        WHERE o_id = v_order_id(o) AND o_d_id = v_d_id(o)
        AND o_w_id = in_w_id
        RETURNING o_c_id BULK COLLECT INTO v_o_c_id;
FORALL o in 1..v_ordcnt
    UPDATE bmsql_order_line SET ol_delivery_d = CURRENT_TIMESTAMP
        WHERE ol_w_id = in_w_id AND ol_d_id = v_d_id(o)
        AND ol_i_id = v_order_id(o)
        RETURNING sum(ol_amount) BULK COLLECT INTO v_sums;
FORALL c IN 1..v_ordcnt
    UPDATE bmsql_customer
        SET c_balance = c_balance + v_sums(c),
        c_delivery_cnt = c_delivery_cnt + 1
        WHERE c_w_id = in_w_id AND c_d_id = v_d_id(c)
        AND c_id = v_o_c_id(c);

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