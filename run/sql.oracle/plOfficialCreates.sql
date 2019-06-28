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

CREATE OR REPLACE
TYPE MY_INT_ARR AS VARRAY(15) OF INTEGER;

CREATE OR REPLACE PACKAGE bmsql_inittpcc AS
TYPE LOCAL_DECIMAL_ARR IS VARRAY(15) OF DECIMAL(6,2);
ol_amount LOCAL_DECIMAL_ARR;
TYPE LOCAL_CHAR_ARR IS VARRAY(15) OF CHAR(24);
s_dist LOCAL_CHAR_ARR;
idx_heler MY_INT_ARR;
PROCEDURE init_tpcc;
END bmsql_inittpcc;

CREATE OR REPLACE PACKAGE BODY bmsql_inittpcc AS
    PROCEDURE init_tpcc IS

    BEGIN
        idx_heler := MY_INT_ARR(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);
        s_dist := LOCAL_CHAR_ARR(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
        ol_amount := LOCAL_DECIMAL_ARR(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    END init_tpcc;
BEGIN
    init_tpcc;
END bmsql_inittpcc;


CREATE OR REPLACE PROCEDURE
bmsql_func_neworder
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
var_district_oid integer;
var_customer_discount decimal(4,4);
var_customer_last varchar(16);
var_customer_credit char(2);
var_warehouse_tax decimal(4,4);

idx PLS_INTEGER;
dummy_local PLS_INTEGER;
cache_ol_cnt PLS_INTEGER;

not_serializable EXCEPTION;
PRAGMA EXCEPTION_INIT(not_serializable,-8177);
deadlock EXCEPTION;
PRAGMA EXCEPTION_INIT(deadlock,-60);
snapshot_too_old EXCEPTION;
PRAGMA EXCEPTION_INIT(snapshot_too_old,-1555);

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
    BULK COLLECT INTO bmsql_inittpcc.s_dist, bmsql_inittpcc.ol_amount;
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
    BULK COLLECT INTO bmsql_inittpcc.s_dist, bmsql_inittpcc.ol_amount;
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
    BULK COLLECT INTO bmsql_inittpcc.s_dist, bmsql_inittpcc.ol_amount;
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
    BULK COLLECT INTO bmsql_inittpcc.s_dist, bmsql_inittpcc.ol_amount;
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
    BULK COLLECT INTO bmsql_inittpcc.s_dist, bmsql_inittpcc.ol_amount;
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
    BULK COLLECT INTO bmsql_inittpcc.s_dist, bmsql_inittpcc.ol_amount;
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
    BULK COLLECT INTO bmsql_inittpcc.s_dist, bmsql_inittpcc.ol_amount;
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
    BULK COLLECT INTO bmsql_inittpcc.s_dist, bmsql_inittpcc.ol_amount;
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
    BULK COLLECT INTO bmsql_inittpcc.s_dist, bmsql_inittpcc.ol_amount;
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
    BULK COLLECT INTO bmsql_inittpcc.s_dist, bmsql_inittpcc.ol_amount;
END u10;

BEGIN
    LOOP BEGIN
        cache_ol_cnt := in_ol_cnt;
        UPDATE bmsql_district SET d_next_o_id = d_next_o_id + 1
            WHERE d_id = in_d_id AND d_w_id = in_w_id
            RETURNING d_next_o_id - 1
            INTO var_district_oid;
        SELECT c_discount, c_last, c_credit
            INTO var_customer_discount, var_customer_last, var_customer_credit
            FROM bmsql_customer
            WHERE c_id = in_c_id AND c_d_id = in_d_id AND c_w_id = in_w_id;
        SELECT w_tax
            INTO var_warehouse_tax
            FROM bmsql_warehouse
            WHERE w_id = in_w_id;
        INSERT INTO bmsql_oorder(o_id, o_d_id, o_w_id, o_c_id, o_entry_d,
                         o_carrier_id, o_ol_cnt, o_all_local)
            VALUES(var_district_oid, in_d_id, in_w_id, in_c_id,
                   CURRENT_TIMESTAMP, 11, in_ol_cnt, in_o_all_local);
        INSERT INTO bmsql_new_order(no_o_id, no_d_id, no_w_id)
            VALUES(var_district_oid, in_d_id, in_w_id);
        
        dummy_local := in_d_id;
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
        EXIT;
        FORALL idx IN 1..dummy_local
            INSERT INTO bmsql_order_line (ol_o_id, ol_d_id, ol_w_id, ol_number,
                              ol_i_id, ol_supply_w_id, ol_quantity, ol_amount, ol_dist_info)
            VALUES (var_district_oid, in_d_id, in_w_id, bmsql_inittpcc.idx_heler(idx),
                    in_ol_iid(idx), in_ol_supply_wid(idx), in_ol_quantity(idx), bmsql_inittpcc.ol_amount(idx),
                    bmsql_inittpcc.s_dist(idx));
        IF (dummy_local != in_ol_cnt) THEN
            ROLLBACK;
            EXIT;
        END IF;
        COMMIT;
        EXIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
        END;
    END LOOP;
    EXCEPTION
        WHEN not_serializable OR deadlock OR snapshot_too_old THEN
            ROLLBACK;
            -- :retry := :retry + 1;
        END;
    END LOOP;
END bmsql_func_neworder;
/