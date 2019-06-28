/
create or replace
TYPE MY_INT_ARR AS VARRAY(15) OF integer;
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
var_district_oid integer;
var_customer_discount decimal(4,4);
var_customer_last varchar(16);
var_customer_credit char(2);
var_warehouse_tax decimal(4,4);
var_item_name varchar(24);
var_item_price decimal(5,2);
var_item_data varchar(50);
var_stock_quantity integer;
var_stock_data varchar(50);
var_dist_1 char(24);
var_dist_2 char(24);
var_dist_3 char(24);
var_dist_4 char(24);
var_dist_5 char(24);
var_dist_6 char(24);
var_dist_7 char(24);
var_dist_8 char(24);
var_dist_9 char(24);
var_dist_10 char(24);
var_ol_amount decimal(6,2);
var_update_stock_3 integer;
BEGIN
SELECT d_next_o_id INTO var_district_oid FROM bmsql_district WHERE d_w_id = in_w_id AND d_id = in_d_id FOR UPDATE;
SELECT c_discount, c_last, c_credit, w_tax INTO var_customer_discount, var_customer_last, var_customer_credit, var_warehouse_tax FROM bmsql_customer JOIN bmsql_warehouse ON (w_id = c_w_id) WHERE c_w_id = in_w_id AND c_d_id = in_d_id AND c_id = in_c_id;
UPDATE bmsql_district SET d_next_o_id = d_next_o_id + 1 WHERE d_w_id = in_w_id AND d_id = in_d_id;
INSERT INTO bmsql_oorder (o_id, o_d_id, o_w_id, o_c_id, o_entry_d, o_ol_cnt, o_all_local) VALUES (var_district_oid, in_d_id, in_w_id, in_c_id, CURRENT_TIMESTAMP, in_ol_cnt, in_o_all_local);
INSERT INTO bmsql_new_order (no_o_id, no_d_id, no_w_id) VALUES (var_district_oid, in_d_id, in_w_id);
FOR i IN 1..in_ol_cnt LOOP
    -- This could be empty (1%)
    SELECT i_price, i_name, i_data into var_item_price, var_item_name, var_item_data FROM bmsql_item WHERE i_id = in_ol_iid(i);
    SELECT s_quantity, s_dist_01, s_dist_02, s_dist_03, s_dist_04, s_dist_05, s_dist_06, s_dist_07, s_dist_08, s_dist_09, s_dist_10 into var_stock_quantity, var_dist_1, var_dist_2, var_dist_3, var_dist_4, var_dist_5, var_dist_6, var_dist_7, var_dist_8, var_dist_9, var_dist_10 FROM bmsql_stock WHERE s_w_id = in_ol_supply_wid(i) AND s_i_id = in_ol_iid(i) FOR UPDATE;
    CASE in_d_id
        WHEN 2 THEN var_dist_1 := var_dist_2;
        WHEN 3 THEN var_dist_1 := var_dist_3;
        WHEN 4 THEN var_dist_1 := var_dist_4;
        WHEN 5 THEN var_dist_1 := var_dist_5;
        WHEN 6 THEN var_dist_1 := var_dist_6;
        WHEN 7 THEN var_dist_1 := var_dist_7;
        WHEN 8 THEN var_dist_1 := var_dist_8;
        WHEN 9 THEN var_dist_1 := var_dist_9;
        WHEN 10 THEN var_dist_1 := var_dist_10;
        ELSE EXIT;
    END CASE;
    var_ol_amount := var_item_price * in_ol_quantity(i);
    IF var_stock_quantity >= in_ol_quantity(i) + 10 THEN
        var_stock_quantity := var_stock_quantity - in_ol_quantity(i);
    ELSE
        var_stock_quantity := var_stock_quantity + 91;
    END IF;
    IF in_ol_supply_wid(i) = in_w_id THEN
        var_update_stock_3 := 0;
    ELSE
        var_update_stock_3 := 1;
    END IF;
    UPDATE bmsql_stock SET s_quantity = var_stock_quantity, s_ytd = s_ytd + in_ol_quantity(i), s_order_cnt = s_order_cnt + 1, s_remote_cnt = s_remote_cnt + var_update_stock_3 WHERE s_w_id = in_ol_supply_wid(i) AND s_i_id = in_ol_iid(i);
    INSERT INTO bmsql_order_line (ol_o_id, ol_d_id, ol_w_id, ol_number, ol_i_id, ol_supply_w_id, ol_quantity, ol_amount, ol_dist_info) VALUES (var_district_oid, in_d_id, in_w_id, i, in_ol_iid(i), in_ol_supply_wid(i), in_ol_quantity(i), var_ol_amount, var_dist_1);
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
    in_c_id IN integer
) as
var_d_name varchar(10);
var_w_name varchar(10);
var_c_data varchar(500);
var_c_credit char(2);
BEGIN
UPDATE bmsql_district SET d_ytd = d_ytd + in_h_amount WHERE d_w_id = in_w_id AND d_id = in_d_id;
SELECT d_name INTO var_d_name FROM bmsql_district WHERE d_w_id = in_w_id AND d_id = in_d_id;
UPDATE bmsql_warehouse SET w_ytd = w_ytd + in_h_amount WHERE w_id = in_w_id;
SELECT w_name INTO var_w_name FROM bmsql_warehouse WHERE w_id = in_w_id;
-- exec in userspace
-- if in_c_last > 0 THEN
-- SELECT c_id FROM bmsql_customer WHERE c_w_id = in_w_id AND c_d_id = in_d_id AND c_last = in_c_last ORDER BY c_first;
SELECT c_credit INTO var_c_credit FROM bmsql_customer WHERE c_w_id = in_c_w_id AND c_d_id = in_c_d_id AND c_id = in_c_id;
-- var_c_balance = var_c_balance - in_h_amount;
IF var_c_credit = 'GC' THEN
UPDATE bmsql_customer SET c_balance = c_balance - in_h_amount, c_ytd_payment = c_ytd_payment + in_h_amount, c_payment_cnt = c_payment_cnt + 1 WHERE c_w_id = in_c_w_id AND c_d_id = in_c_d_id AND c_id = in_c_id;
ELSE
SELECT c_data INTO var_c_data FROM bmsql_customer WHERE c_w_id = in_c_w_id AND c_d_id = in_c_d_id AND c_id = in_c_id;
-- omit c_data extension
UPDATE bmsql_customer SET c_balance = c_balance - in_h_amount, c_ytd_payment = c_ytd_payment + in_h_amount, c_payment_cnt = c_payment_cnt + 1, c_data = var_c_data WHERE c_w_id = in_c_w_id AND c_d_id = in_c_d_id AND c_id = in_c_id;
INSERT INTO bmsql_history (h_c_id, h_c_d_id, h_c_w_id, h_d_id, h_w_id, h_date, h_amount, h_data) VALUES (in_c_id, in_c_d_id, in_c_w_id, in_d_id, in_w_id, CURRENT_TIMESTAMP, in_h_amount, CONCAT(var_w_name, var_d_name));
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
var_o_id integer;
var_c_id integer;
var_sum_ol_amount decimal;
BEGIN
FOR i_d_id IN 1..10 LOOP
    var_o_id := -1;
    WHILE var_o_id < 0 LOOP
        -- FETCH SelectOldestNewOrder INTO var_o_id;
        -- EXIT WHEN SelectOldestNewOrder%NOTFOUND;
        -- SELECT no_o_id INTO var_o_id FROM bmsql_new_order WHERE no_w_id = in_w_id AND no_d_id = i_d_id ORDER BY no_o_id ASC;
        -- EXIT WHEN sql%NOTFOUND;
        SELECT NVL(no_o_id, var_o_id) INTO var_o_id FROM (SELECT no_o_id FROM bmsql_new_order WHERE no_w_id = in_w_id AND no_d_id = i_d_id ORDER BY no_o_id ASC);
        DELETE FROM bmsql_new_order WHERE no_w_id = in_w_id AND no_d_id = i_d_id AND no_o_id = var_o_id;
        IF sql%rowcount = 0 THEN
            var_o_id := -1;
        END IF;
    END LOOP;
    if var_o_id < 0 THEN
    CONTINUE;
    END IF;
    UPDATE bmsql_oorder SET o_carrier_id = in_o_carrier_id WHERE o_w_id = in_w_id AND o_d_id = i_d_id AND o_id = var_o_id;
    SELECT o_c_id INTO var_c_id FROM bmsql_oorder WHERE o_w_id = in_w_id AND o_d_id = i_d_id AND o_id = var_o_id;
    UPDATE bmsql_order_line SET ol_delivery_d = CURRENT_TIMESTAMP WHERE ol_w_id = in_w_id AND ol_d_id = i_d_id AND ol_o_id = var_o_id;
    SELECT sum(ol_amount) INTO var_sum_ol_amount FROM bmsql_order_line WHERE ol_w_id = in_w_id AND ol_d_id = i_d_id AND ol_o_id = var_o_id;
    UPDATE bmsql_customer SET c_balance = c_balance + var_sum_ol_amount, c_delivery_cnt = c_delivery_cnt + 1 WHERE c_w_id = in_w_id AND c_d_id = i_d_id AND c_id = var_c_id;
END LOOP;
COMMIT;
END bmsql_func_deliverybg;
/

-- orderStatus
-- stockLevel
-- delivery