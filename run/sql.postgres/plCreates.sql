CREATE OR REPLACE VIEW bmsql_stock_item
(i_id, s_w_id, i_price, i_name, i_data, s_data, s_quantity,
 s_order_cnt, s_ytd, s_remote_cnt,
 s_dist_01, s_dist_02, s_dist_03, s_dist_04, s_dist_05,
 s_dist_06, s_dist_07, s_dist_08, s_dist_09, s_dist_10)
AS
SELECT /*+ leading(s) use_nl(i) */ i.i_id, s_w_id, i.i_price, i.i_name, i.i_data,
s_data, s_quantity, s_order_cnt, s_ytd, s_remote_cnt,
s_dist_01, s_dist_02, s_dist_03, s_dist_04, s_dist_05,
s_dist_06, s_dist_07, s_dist_08, s_dist_09, s_dist_10
FROM bmsql_stock s, bmsql_item i WHERE i.i_id = s.s_i_id;

/
create or replace
function bmsql_func_neworder
(
    in_w_id integer,
    in_d_id integer,
    in_c_id integer,
    in_ol_cnt integer,
    in_o_all_local integer,
    in_ol_iid integer[],
    in_ol_supply_wid integer[],
    in_ol_quantity integer[]
) as $$
declare
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
v_dist char(24)[]; -- must be table
v_ol_amount number[];
idx integer := 0;
dummy_local integer := in_d_id;
cache_ol_cnt integer := in_ol_cnt;
-- fix-item
ows_lost integer := 0;
max_index integer := 0;
temp_index integer := 0;

BEGIN
SELECT d.d_next_o_id INTO v_district_oid
    FROM bmsql_district d
    WHERE d.d_w_id = in_w_id AND d.d_id = in_d_id FOR UPDATE OF d.d_next_o_id;
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
    (v_district_oid, in_d_id, in_w_id, in_c_id,
    clock_timestamp(), cache_ol_cnt, in_o_all_local);
INSERT INTO bmsql_new_order
    (no_o_id, no_d_id, no_w_id)
    VALUES
    (v_district_oid, in_d_id, in_w_id);

IF (dummy_local < 6) THEN
    IF (dummy_local < 3) THEN
        IF (dummy_local = 1) THEN
            WITH t AS
                UPDATE bmsql_stock_item
                    SET s_order_cnt = s_order_cnt + 1,
                    s_ytd = s_ytd + in_ol_quantity(idx),
                    s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                                THEN 0 ELSE 1 END),
                    s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                                THEN s_quantity + 91
                                ELSE s_quantity
                                END) - in_ol_quantity(idx)
                    FROM generate_series(1, cache_ol_cnt) tt(idx)
                    WHERE i_id = in_ol_iid(idx)
                    AND s_w_id = in_ol_supply_wid(idx)
                    RETURNING s_dist_01, i_price * in_ol_quantity(idx) price
            SELECT array_agg(s_dist_01, price) INTO v_dist, v_ol_amount;
        ELSE
            WITH t AS
                UPDATE bmsql_stock_item
                    SET s_order_cnt = s_order_cnt + 1,
                    s_ytd = s_ytd + in_ol_quantity(idx),
                    s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                                THEN 0 ELSE 1 END),
                    s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                                THEN s_quantity + 91
                                ELSE s_quantity
                                END) - in_ol_quantity(idx)
                    FROM generate_series(1, cache_ol_cnt) tt(idx)
                    WHERE i_id = in_ol_iid(idx)
                    AND s_w_id = in_ol_supply_wid(idx)
                    RETURNING s_dist_02, i_price * in_ol_quantity(idx) price
            SELECT array_agg(s_dist_02, price) INTO v_dist, v_ol_amount;            
        END IF;
    ELSE
        IF (dummy_local = 3) THEN
            WITH t AS
                UPDATE bmsql_stock_item
                    SET s_order_cnt = s_order_cnt + 1,
                    s_ytd = s_ytd + in_ol_quantity(idx),
                    s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                                THEN 0 ELSE 1 END),
                    s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                                THEN s_quantity + 91
                                ELSE s_quantity
                                END) - in_ol_quantity(idx)
                    FROM generate_series(1, cache_ol_cnt) tt(idx)
                    WHERE i_id = in_ol_iid(idx)
                    AND s_w_id = in_ol_supply_wid(idx)
                    RETURNING s_dist_03, i_price * in_ol_quantity(idx) price
            SELECT array_agg(s_dist_03, price) INTO v_dist, v_ol_amount;
        ELSIF (dummy_local = 4) THEN
            WITH t AS
                UPDATE bmsql_stock_item
                    SET s_order_cnt = s_order_cnt + 1,
                    s_ytd = s_ytd + in_ol_quantity(idx),
                    s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                                THEN 0 ELSE 1 END),
                    s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                                THEN s_quantity + 91
                                ELSE s_quantity
                                END) - in_ol_quantity(idx)
                    FROM generate_series(1, cache_ol_cnt) tt(idx)
                    WHERE i_id = in_ol_iid(idx)
                    AND s_w_id = in_ol_supply_wid(idx)
                    RETURNING s_dist_04, i_price * in_ol_quantity(idx) price
            SELECT array_agg(s_dist_04, price) INTO v_dist, v_ol_amount;
        ELSE
            WITH t AS
                UPDATE bmsql_stock_item
                    SET s_order_cnt = s_order_cnt + 1,
                    s_ytd = s_ytd + in_ol_quantity(idx),
                    s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                                THEN 0 ELSE 1 END),
                    s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                                THEN s_quantity + 91
                                ELSE s_quantity
                                END) - in_ol_quantity(idx)
                    FROM generate_series(1, cache_ol_cnt) tt(idx)
                    WHERE i_id = in_ol_iid(idx)
                    AND s_w_id = in_ol_supply_wid(idx)
                    RETURNING s_dist_05, i_price * in_ol_quantity(idx) price
            SELECT array_agg(s_dist_05, price) INTO v_dist, v_ol_amount;
        END IF;
    END IF;
ELSE
    IF (dummy_local < 8) THEN
        IF (dummy_local = 6) THEN
            WITH t AS
                UPDATE bmsql_stock_item
                    SET s_order_cnt = s_order_cnt + 1,
                    s_ytd = s_ytd + in_ol_quantity(idx),
                    s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                                THEN 0 ELSE 1 END),
                    s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                                THEN s_quantity + 91
                                ELSE s_quantity
                                END) - in_ol_quantity(idx)
                    FROM generate_series(1, cache_ol_cnt) tt(idx)
                    WHERE i_id = in_ol_iid(idx)
                    AND s_w_id = in_ol_supply_wid(idx)
                    RETURNING s_dist_06, i_price * in_ol_quantity(idx) price
            SELECT array_agg(s_dist_06, price) INTO v_dist, v_ol_amount;
        ELSE
            WITH t AS
                UPDATE bmsql_stock_item
                    SET s_order_cnt = s_order_cnt + 1,
                    s_ytd = s_ytd + in_ol_quantity(idx),
                    s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                                THEN 0 ELSE 1 END),
                    s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                                THEN s_quantity + 91
                                ELSE s_quantity
                                END) - in_ol_quantity(idx)
                    FROM generate_series(1, cache_ol_cnt) tt(idx)
                    WHERE i_id = in_ol_iid(idx)
                    AND s_w_id = in_ol_supply_wid(idx)
                    RETURNING s_dist_07, i_price * in_ol_quantity(idx) price
            SELECT array_agg(s_dist_07, price) INTO v_dist, v_ol_amount;
        END IF;
    ELSE
        IF (dummy_local = 8) THEN
            WITH t AS
                UPDATE bmsql_stock_item
                    SET s_order_cnt = s_order_cnt + 1,
                    s_ytd = s_ytd + in_ol_quantity(idx),
                    s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                                THEN 0 ELSE 1 END),
                    s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                                THEN s_quantity + 91
                                ELSE s_quantity
                                END) - in_ol_quantity(idx)
                    FROM generate_series(1, cache_ol_cnt) tt(idx)
                    WHERE i_id = in_ol_iid(idx)
                    AND s_w_id = in_ol_supply_wid(idx)
                    RETURNING s_dist_08, i_price * in_ol_quantity(idx) price
            SELECT array_agg(s_dist_08, price) INTO v_dist, v_ol_amount;
        ELSIF (dummy_local = 9) THEN
            WITH t AS
                UPDATE bmsql_stock_item
                    SET s_order_cnt = s_order_cnt + 1,
                    s_ytd = s_ytd + in_ol_quantity(idx),
                    s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                                THEN 0 ELSE 1 END),
                    s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                                THEN s_quantity + 91
                                ELSE s_quantity
                                END) - in_ol_quantity(idx)
                    FROM generate_series(1, cache_ol_cnt) tt(idx)
                    WHERE i_id = in_ol_iid(idx)
                    AND s_w_id = in_ol_supply_wid(idx)
                    RETURNING s_dist_09, i_price * in_ol_quantity(idx) price
            SELECT array_agg(s_dist_09, price) INTO v_dist, v_ol_amount;
        ELSE
            WITH t AS
                UPDATE bmsql_stock_item
                    SET s_order_cnt = s_order_cnt + 1,
                    s_ytd = s_ytd + in_ol_quantity(idx),
                    s_remote_cnt = s_remote_cnt + (CASE WHEN in_w_id = in_ol_supply_wid(idx)
                                                THEN 0 ELSE 1 END),
                    s_quantity = (CASE WHEN s_quantity < in_ol_quantity(idx) + 10
                                THEN s_quantity + 91
                                ELSE s_quantity
                                END) - in_ol_quantity(idx)
                    FROM generate_series(1, cache_ol_cnt) tt(idx)
                    WHERE i_id = in_ol_iid(idx)
                    AND s_w_id = in_ol_supply_wid(idx)
                    RETURNING s_dist_10, i_price * in_ol_quantity(idx) price
            SELECT array_agg(s_dist_10, price) INTO v_dist, v_ol_amount;
        END IF;
    END IF;
END IF;
dummy_local := array_length(v_dist);
IF (dummy_local != cache_ol_cnt) THEN
    idx := 1;
    rows_lost := 0;
    max_index := dummy_local;
    WHILE (max_index != cache_ol_cnt) LOOP
        WHILE (idx <= sql%rowcount AND sql%bulk_rowcount(idx+rows_lost) = 1) LOOP
            idx := idx + 1;
        END LOOP;
        FOR temp_index IN idx+rows_lost+1 .. max_index LOOP
            v_ol_amount(temp_index) := v_ol_amount(temp_index - 1);
            v_dist(temp_index) := v_dist(temp_index - 1);
        END LOOP;
        IF (idx + rows_lost <= cache_ol_cnt) THEN
            v_ol_amount(idx + rows_lost) := 0;
            v_dist(idx + rows_lost) := NULL;
            rows_lost := rows_lost + 1;
            max_index := max_index + 1;
        END IF;
    END LOOP;
END IF;
INSERT INTO bmsql_order_line (ol_o_id, ol_d_id, ol_w_id, ol_number,
        ol_i_id, ol_supply_w_id, ol_quantity, ol_amount, ol_dist_info)
    select v_district_oid, in_d_id, in_w_id, idx,
        in_ol_iid(idx), in_ol_supply_wid(idx), in_ol_quantity(idx),
        v_ol_amount(idx), v_dist(idx) from
    generate_series(1, dummy_local) t(idx);

COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    ROLLBACK;
END;
$$ LANGUAGE plpgsql;
/

/
create or replace
function bmsql_func_payment
(
    in_w_id integer,
    in_d_id integer,
    in_c_w_id integer,
    in_c_d_id integer,
    in_h_amount decimal,
    in_c_id integer,
    in_c_last varchar
) as $$
declare
v_c_id integer := in_c_id;
v_d_name varchar(10);
v_w_name varchar(10);
v_c_data varchar(500);
v_c_credit char(2);
v_rowid tid;
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
    v_rowid := bmsql_func_rowid_from_clast(in_w_id, in_d_id, in_c_last);
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
    UPDATE bmsql_customer
        SET c_balance = c_balance - in_h_amount,
        c_ytd_payment = c_ytd_payment + in_h_amount,
        c_payment_cnt = c_payment_cnt + 1,
        c_data = v_c_data
        WHERE c_w_id = in_c_w_id AND c_d_id = in_c_d_id AND c_id = v_c_id
        RETURNING c_data INTO v_c_data;
    INSERT INTO bmsql_history
        (h_c_id, h_c_d_id, h_c_w_id, h_d_id, h_w_id, h_date, h_amount, h_data)
        VALUES
        (v_c_id, in_c_d_id, in_c_w_id, in_d_id, in_w_id,
        clock_timestamp(), in_h_amount, v_w_name || v_d_name));
END IF;
COMMIT;
END;
$$ LANGUAGE plpgsql;
/

/
create or replace
function bmsql_func_deliverybg
(
    in_w_id integer,
    in_o_carrier_id integer
) returns void as $$
declare
v_order_id integer[];
v_d_id integer[];
v_ordcnt integer := 0;
v_o_c_id integer[];
v_sums number[];
v_current_ts TIMESTAMP := clock_timestamp();
BEGIN

-- aggregate function not allowed in returning
-- tunnable, multiple plans during execution
WITH t AS
    DELETE FROM bmsql_new_order N
        WHERE no_d_id IN generate_series(1,10)
        AND no_w_id = in_w_id AND no_o_id = (
            SELECT min(no_o_id) FROM bmsql_new_order
                WHERE no_d_id = N.no_d_id
                AND no_w_id = N.no_w_id)
            RETURNING no_d_id, no_o_id
SELECT array_agg(no_d_id), array_agg(no_o_id) INTO v_d_id, v_order_id;
v_ordcnt := array_length(v_d_id);
-- here is a doubtful inconsistency w.r.t. fdr
-- use order_line.ol_o_id or ol_i_id
WITH t AS
    UPDATE bmsql_oorder SET o_carrier_id = in_o_carrier_id
        FROM generate_series(1, v_ordcnt) tt(idx)
        WHERE o_id = v_order_id(idx) AND o_d_id = v_d_id(idx)
        AND o_w_id = in_w_id
        RETURNING o_c_id
SELECT array_agg(o_c_id) INTO v_o_c_id;
WITH t AS
    UPDATE bmsql_order_line SET ol_delivery_d = v_current_ts
        FROM generate_series(1, v_ordcnt) tt(idx)
        WHERE ol_w_id = in_w_id AND ol_d_id = v_d_id(idx)
        AND ol_o_id = v_order_id(idx)
        RETURNING sum(ol_amount) s
SELECT array_agg(s) INTO v_sums;
UPDATE bmsql_customer
    SET c_balance = c_balance + v_sums(idx),
    c_delivery_cnt = c_delivery_cnt + 1
    FROM generate_series(1, v_ordcnt) tt(idx)
    WHERE c_w_id = in_w_id AND c_d_id = v_d_id(idx)
    AND c_id = v_o_c_id(idx);

COMMIT;
END;
$$ LANGUAGE plpgsql;
/

/
create or replace
function bmsql_func_stocklevel
(
    in_w_id integer,
    in_d_id integer,
    in_threshold integer
) returns void AS $$
declare
result integer;
BEGIN
-- needs @investigate
-- faster than fdr version:
-- SELECT count(DISTINCT s_i_id) INTO result
--     FROM bmsql_order_line, bmsql_stock, bmsql_district
--     WHERE d_id = in_d_id AND d_w_id = in_w_id AND d_id = ol_d_id
--     AND d_w_id = ol_w_id AND ol_i_id = s_i_id AND ol_w_id = s_w_id
--     AND s_quantity < in_threshold AND
--     ol_o_id BETWEEN (d_next_o_id - 20) AND (d_next_o_id - 1)
--     ORDER BY ol_o_id DESC;
-- also, parallel hint
SELECT count(1) INTO result FROM (
    SELECT s_w_id, s_i_id, s_quantity
        FROM bmsql_stock
        WHERE s_w_id = in_w_id AND s_quantity < in_threshold AND s_i_id IN (
            SELECT /*+ CURSOR_SHARING_EXACT */ ol_i_id
                FROM bmsql_district
                JOIN bmsql_order_line ON ol_w_id = d_w_id
                AND ol_d_id = d_id
                AND ol_o_id BETWEEN (d_next_o_id - 20) AND (d_next_o_id - 1)
                WHERE d_w_id = in_w_id AND d_id = in_d_id
        )
);
COMMIT;
END;
$$ LANGUAGE plpgsql;
/

/
create or replace
function bmsql_func_rowid_from_clast
(
    in_w_id integer,
    in_d_id integer,
    in_c_last varchar
) RETURNS tid AS $$
declare
v_rowid_list tid[];
BEGIN
SELECT array_agg(rowid) INTO v_rowid_list FROM bmsql_customer
    WHERE c_w_id = in_w_id AND c_d_id = in_d_id AND c_last = in_c_last
    ORDER BY c_first;
return v_rowid_list[(array_length(v_rowid_list) + 1 )/ 2];
END;
$$ LANGUAGE plpgsql;
/

/
create or replace
function bmsql_func_orderstatus
(
in_w_id integer,
in_d_id integer,
in_c_last varchar,
in_c_id integer
) RETURNS void AS $$
declare
c_id_cache integer := in_c_id;
v_rowid tid;
v_c_first varchar(16);
v_c_middle char(2);
v_c_last varchar(16);
v_c_balance number;
v_o_id integer;
v_o_entry_d TIMESTAMP;
v_o_carrier_id integer;
curs CURSOR FOR
	SELECT array_agg(ol_i_id), array_agg(ol_supply_w_id),
        array_agg(ol_quantity), array_agg(ol_amount),
        array_agg(ol_delivery_d)
	FROM bmsql_order_line
    WHERE ol_w_id = in_w_id AND ol_d_id = in_d_id
	AND ol_o_id = v_o_id
    ORDER BY ol_w_id, ol_d_id, ol_o_id, ol_number
    LIMIT 15;
-- not composite type, or user defined, here use seperate array
v_order_line_i_id integer[];
v_order_line_w_id integer[];
v_order_line_quantity number[];
v_order_line_amount number[];
v_order_line_delivery_d TIMESTAMP[];
BEGIN
if in_c_last IS NOT NULL THEN
    v_rowid := bmsql_func_rowid_from_clast(in_w_id, in_d_id, in_c_last);
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

FETCH curs INTO v_order_line_i_id, v_order_line_w_id, v_order_line_quantity,
    v_order_line_amount, v_order_line_delivery_d;

COMMIT;
END;
$$ LANGUAGE plpgsql;
/
