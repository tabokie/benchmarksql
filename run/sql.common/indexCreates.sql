
create unique index bmsql_warehouse_pkey
  on bmsql_warehouse (w_id);

create unique index bmsql_district_pkey
  on bmsql_district (d_w_id, d_id);

create unique index bmsql_customer_pkey
  on bmsql_customer (c_w_id, c_d_id, c_id);

create index bmsql_customer_idx
  on bmsql_customer (c_w_id, c_last, c_d_id, c_first, c_id);

create unique index bmsql_oorder_pkey
  on bmsql_oorder (o_w_id, o_d_id, o_c_id, o_id);

create unique index bmsql_new_order_pkey
  on bmsql_new_order (no_w_id, no_d_id, no_o_id);

create unique index bmsql_order_line_pkey
  on bmsql_order_line (ol_w_id, ol_d_id, ol_o_id, ol_number);

create unique index bmsql_stock_pkey
  on bmsql_stock(s_i_id, s_w_id);

create unique index bmsql_item_pkey
  on bmsql_item (i_id);
